module scratchpad_bank #(
    parameter integer ROWS = 5
) (
    input wire clk, rst,
    input wire grant,
    input wire [1:0] service_class,
    input wire [2:0] service_owner,
    input wire [2:0] service_row,
    input wire service_write,
    input wire [31:0] service_wdata,
    input wire [3:0] service_wstrb,
    input wire [38:0] service_mask,
    output reg busy,
    output wire done,
    output wire [1:0] done_class,
    output wire [2:0] done_owner,
    output reg [31:0] done_data,
    output reg [1:0] done_status,
    output reg done_corrected,
    output wire correction_event,
    output wire uncorrectable_event,
    output wire scrub_event,
    output wire scrub_busy
);
    reg [38:0] memory [0:ROWS-1];
    reg phase;
    reg [1:0] active_class;
    reg [2:0] active_owner, active_row;
    reg active_write;
    reg [31:0] active_wdata;
    reg [3:0] active_wstrb;
    reg [38:0] active_mask;
    reg [31:0] staged_data;
    reg [38:0] staged_code;
    reg staged_corrected, staged_uncorrectable;
    wire [31:0] decoded_data;
    wire [38:0] decoded_code;
    wire decoded_corrected, decoded_uncorrectable;
    reg [31:0] encode_data;
    wire [38:0] encoded_code;
    wire partial_write = active_write && (active_wstrb != 0) &&
                         (active_wstrb != 4'hf);
    integer i, lane;

    secded_decode decoder (
        .code(memory[active_row]), .data(decoded_data),
        .repaired_code(decoded_code), .corrected(decoded_corrected),
        .uncorrectable(decoded_uncorrectable)
    );
    secded_encode encoder (.data(encode_data), .code(encoded_code));

    assign done = !rst && busy && phase;
    assign done_class = active_class;
    assign done_owner = active_owner;
    assign scrub_busy = busy && (active_class == 2);
    assign scrub_event = done && (active_class == 2);
    assign correction_event = done && (
        ((active_class == 2) && staged_corrected) ||
        ((active_class == 0) && done_corrected));
    assign uncorrectable_event = done && (
        ((active_class == 2) && staged_uncorrectable) ||
        ((active_class == 0) && (done_status == 1)));

    always @* begin
        lane = 0;
        encode_data = active_wdata;
        if (partial_write) begin
            encode_data = staged_data;
            for (lane = 0; lane < 4; lane = lane + 1)
                if (active_wstrb[lane])
                    encode_data[8*lane +: 8] = active_wdata[8*lane +: 8];
        end
        done_data = 0;
        done_status = 0;
        done_corrected = 0;
        if (active_class == 0) begin
            if (!active_write) begin
                done_data = decoded_data;
                done_status = decoded_uncorrectable ? 2'd1 : 2'd0;
                done_corrected = decoded_corrected;
            end else if (partial_write) begin
                done_status = staged_uncorrectable ? 2'd1 : 2'd0;
                done_corrected = staged_corrected;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            busy <= 0;
            phase <= 0;
            active_class <= 0;
            active_owner <= 0;
            active_row <= 0;
            active_write <= 0;
            active_wdata <= 0;
            active_wstrb <= 0;
            active_mask <= 0;
            staged_data <= 0;
            staged_code <= 0;
            staged_corrected <= 0;
            staged_uncorrectable <= 0;
            for (i = 0; i < ROWS; i = i + 1) memory[i] <= 39'b0;
        end else begin
            if (grant && !busy) begin
                busy <= 1;
                active_class <= service_class;
                active_owner <= service_owner;
                active_row <= service_row;
                active_write <= service_write;
                active_wdata <= service_wdata;
                active_wstrb <= service_wstrb;
                active_mask <= service_mask;
                phase <= !((service_class == 2) ||
                    ((service_class == 0) && service_write &&
                     (service_wstrb != 0) && (service_wstrb != 4'hf)));
            end
            if (busy && !phase) begin
                staged_data <= decoded_data;
                staged_code <= decoded_code;
                staged_corrected <= decoded_corrected;
                staged_uncorrectable <= decoded_uncorrectable;
                phase <= 1;
            end
            if (done) begin
                busy <= 0;
                if (active_class == 1) begin
                    memory[active_row] <= memory[active_row] ^ active_mask;
                end else if (active_class == 2) begin
                    if (staged_corrected && !staged_uncorrectable)
                        memory[active_row] <= staged_code;
                end else if (active_write) begin
                    if (active_wstrb == 4'hf)
                        memory[active_row] <= encoded_code;
                    else if (partial_write && !staged_uncorrectable)
                        memory[active_row] <= encoded_code;
                end
            end
        end
    end
endmodule
