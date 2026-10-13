module scaler_frame_control #(
    parameter integer MAX_WIDTH = 16,
    parameter integer MAX_HEIGHT = 12
) (
    input  wire clk,
    input  wire rst,
    input  wire csr_valid,
    output wire csr_ready,
    input  wire csr_write,
    input  wire [7:0] csr_addr,
    input  wire [31:0] csr_wdata,
    input  wire [3:0] csr_wstrb,
    output reg  csr_rvalid,
    input  wire csr_rready,
    output reg  [31:0] csr_rdata,
    output reg  csr_error,
    output wire irq,
    input  wire input_fire,
    input  wire input_sof,
    input  wire input_eof,
    input  wire output_fire,
    input  wire output_slot_valid,
    input  wire all_reserved,
    input  wire production_fault,
    output reg  busy,
    output wire receiving,
    output wire draining,
    output reg  start_frame,
    output wire cancel_work,
    output wire [5:0] input_width,
    output wire [5:0] input_height,
    output wire [5:0] output_width,
    output wire [5:0] output_height,
    output reg  [31:0] frame_id
);
    localparam [8:0] CONFIG_DIM = 9'h001,
                     START_DISABLED = 9'h002,
                     BUSY_START = 9'h004,
                     SOF_ERROR = 9'h008,
                     EOF_ERROR = 9'h010,
                     INPUT_COUNT = 9'h020,
                     OUTPUT_COUNT = 9'h040,
                     ABORTED = 9'h080,
                     CSR_ACCESS = 9'h100;
    reg [31:0] staged_dims, active_dims;
    reg staged_enable, active_enable;
    reg [8:0] errors, irq_mask;
    reg [31:0] started, completed, failed_frames;
    reg [31:0] input_pixels, output_pixels;
    reg failed, input_settled;
    reg access_error, command_error;
    reg [31:0] read_data;
    reg [8:0] events, clear_errors, write_mask;
    reg control_write, dims_write, mask_write;
    reg abort_frame, malformed, completion_count_error;
    wire request_fire = csr_valid && csr_ready;
    wire [11:0] input_total =
        {6'b0, input_width} * {6'b0, input_height};
    wire [11:0] output_total =
        {6'b0, output_width} * {6'b0, output_height};
    wire pending = staged_dims != active_dims ||
                   staged_enable != active_enable;
    wire settle = busy && input_settled && all_reserved &&
                  !output_slot_valid;
    wire output_fault = production_fault ||
                        (output_fire && output_pixels >= {20'b0, output_total});
    wire dimensions_legal =
        staged_dims[5:0] >= 1 && staged_dims[5:0] <= MAX_WIDTH &&
        staged_dims[13:8] >= 1 && staged_dims[13:8] <= MAX_HEIGHT &&
        staged_dims[21:16] >= 1 && staged_dims[21:16] <= MAX_WIDTH &&
        staged_dims[29:24] >= 1 && staged_dims[29:24] <= MAX_HEIGHT;

    assign input_width = active_dims[5:0];
    assign input_height = active_dims[13:8];
    assign output_width = active_dims[21:16];
    assign output_height = active_dims[29:24];
    assign csr_ready = !rst && (!csr_rvalid || csr_rready);
    assign irq = |(errors & irq_mask);
    assign receiving = busy && !failed && !input_settled;
    assign draining = busy && failed && !input_settled;
    assign cancel_work = failed || abort_frame || malformed || output_fault;

    function [31:0] increment_saturating;
        input [31:0] value;
        begin
            increment_saturating = value == 32'hffffffff ?
                                   value : value + 32'd1;
        end
    endfunction

    always @* begin
        read_data = 32'd0;
        access_error = 1'b0;
        command_error = 1'b0;
        events = 9'd0;
        clear_errors = 9'd0;
        write_mask = irq_mask;
        control_write = 1'b0;
        dims_write = 1'b0;
        mask_write = 1'b0;
        start_frame = 1'b0;
        abort_frame = 1'b0;
        malformed = 1'b0;
        completion_count_error = 1'b0;

        case (csr_addr)
            8'h00: read_data = {31'd0, staged_enable};
            8'h04: begin
                read_data[0] = busy;
                read_data[1] = receiving;
                read_data[2] = draining;
                read_data[3] = busy && failed && input_settled;
                read_data[4] = output_slot_valid;
                read_data[5] = pending;
                read_data[6] = input_settled && !failed;
                read_data[7] = active_enable &&
                              output_pixels == {20'b0, output_total};
            end
            8'h08: read_data = {23'd0, errors};
            8'h0c: read_data = {23'd0, irq_mask};
            8'h10: read_data = staged_dims;
            8'h14: read_data = active_dims;
            8'h18: read_data = frame_id;
            8'h1c: read_data = started;
            8'h20: read_data = completed;
            8'h24: read_data = failed_frames;
            8'h28: read_data = input_pixels;
            8'h2c: read_data = output_pixels;
            default: access_error = 1'b1;
        endcase

        if (!csr_write) begin
            if (csr_wstrb != 4'd0)
                access_error = 1'b1;
        end else begin
            read_data = 32'd0;
            case (csr_addr)
                8'h00: begin
                    if (|csr_wstrb[3:1] ||
                        (csr_wstrb[0] && (|csr_wdata[7:3] ||
                         (csr_wdata[1] && csr_wdata[2]))))
                        access_error = 1'b1;
                    else
                        control_write = csr_wstrb[0];
                end
                8'h08, 8'h0c: begin
                    if (|csr_wstrb[3:2] ||
                        (csr_wstrb[1] && |csr_wdata[15:9]))
                        access_error = 1'b1;
                    else begin
                        if (csr_addr == 8'h08) begin
                            if (csr_wstrb[0])
                                clear_errors[7:0] = csr_wdata[7:0];
                            if (csr_wstrb[1])
                                clear_errors[8] = csr_wdata[8];
                        end else begin
                            mask_write = 1'b1;
                            if (csr_wstrb[0])
                                write_mask[7:0] = csr_wdata[7:0];
                            if (csr_wstrb[1])
                                write_mask[8] = csr_wdata[8];
                        end
                    end
                end
                8'h10: begin
                    if ((csr_wstrb[0] && |csr_wdata[7:6]) ||
                        (csr_wstrb[1] && |csr_wdata[15:14]) ||
                        (csr_wstrb[2] && |csr_wdata[23:22]) ||
                        (csr_wstrb[3] && |csr_wdata[31:30]))
                        access_error = 1'b1;
                    else
                        dims_write = 1'b1;
                end
                default: access_error = 1'b1;
            endcase
        end

        if (!request_fire || access_error) begin
            control_write = 1'b0;
            dims_write = 1'b0;
            mask_write = 1'b0;
            clear_errors = 9'd0;
        end
        if (request_fire && access_error)
            events = events | CSR_ACCESS;
        if (control_write) begin
            if (csr_wdata[1]) begin
                if (busy) begin
                    events = events | BUSY_START;
                    command_error = 1'b1;
                end else if (!csr_wdata[0]) begin
                    events = events | START_DISABLED;
                    command_error = 1'b1;
                end else if (!dimensions_legal) begin
                    events = events | CONFIG_DIM;
                    command_error = 1'b1;
                end else
                    start_frame = 1'b1;
            end
            if (csr_wdata[2] && busy) begin
                abort_frame = 1'b1;
                events = events | ABORTED;
            end
        end

        if (receiving && input_fire) begin
            if (input_sof != (input_pixels == 32'd0)) begin
                events = events | SOF_ERROR;
                malformed = 1'b1;
            end
            if (input_eof !=
                (input_pixels == {20'b0, input_total} - 32'd1)) begin
                events = events | EOF_ERROR | INPUT_COUNT;
                malformed = 1'b1;
            end
        end
        if (draining && input_fire) begin
            events = events | INPUT_COUNT;
            if (input_sof)
                events = events | SOF_ERROR;
            if (input_eof)
                events = events | EOF_ERROR;
        end
        if (output_fault)
            events = events | OUTPUT_COUNT;
        if (settle && !failed && output_pixels != {20'b0, output_total}) begin
            completion_count_error = 1'b1;
            events = events | OUTPUT_COUNT;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            csr_rvalid <= 1'b0;
            csr_rdata <= 32'd0;
            csr_error <= 1'b0;
            staged_dims <= 32'h01010101;
            active_dims <= 32'd0;
            staged_enable <= 1'b0;
            active_enable <= 1'b0;
            errors <= 9'd0;
            irq_mask <= 9'd0;
            started <= 32'd0;
            completed <= 32'd0;
            failed_frames <= 32'd0;
            input_pixels <= 32'd0;
            output_pixels <= 32'd0;
            frame_id <= 32'd0;
            busy <= 1'b0;
            failed <= 1'b0;
            input_settled <= 1'b0;
        end else begin
            if (csr_rvalid && csr_rready)
                csr_rvalid <= 1'b0;
            if (request_fire) begin
                csr_rvalid <= 1'b1;
                csr_rdata <= access_error || command_error ? 32'd0 : read_data;
                csr_error <= access_error || command_error;
            end
            errors <= (errors & ~clear_errors) | events;
            if (control_write)
                staged_enable <= csr_wdata[0];
            if (dims_write) begin
                if (csr_wstrb[0])
                    staged_dims[7:0] <= csr_wdata[7:0];
                if (csr_wstrb[1])
                    staged_dims[15:8] <= csr_wdata[15:8];
                if (csr_wstrb[2])
                    staged_dims[23:16] <= csr_wdata[23:16];
                if (csr_wstrb[3])
                    staged_dims[31:24] <= csr_wdata[31:24];
            end
            if (mask_write)
                irq_mask <= write_mask;
            if (input_fire)
                input_pixels <= increment_saturating(input_pixels);
            if (output_fire)
                output_pixels <= increment_saturating(output_pixels);

            if (start_frame) begin
                active_dims <= staged_dims;
                active_enable <= 1'b1;
                frame_id <= frame_id + 32'd1;
                started <= increment_saturating(started);
                input_pixels <= 32'd0;
                output_pixels <= 32'd0;
                busy <= 1'b1;
                failed <= 1'b0;
                input_settled <= 1'b0;
            end else begin
                if (input_fire && input_eof)
                    input_settled <= 1'b1;
                if (malformed || output_fault)
                    failed <= 1'b1;
                if (abort_frame) begin
                    failed <= 1'b1;
                    input_settled <= 1'b1;
                end
                if (settle && !abort_frame && !output_fault) begin
                    busy <= 1'b0;
                    if (failed || completion_count_error) begin
                        failed_frames <= increment_saturating(failed_frames);
                        failed <= 1'b1;
                    end else
                        completed <= increment_saturating(completed);
                end
            end
        end
    end
endmodule
