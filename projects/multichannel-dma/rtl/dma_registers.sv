module dma_registers #(
    parameter integer CHANNELS = 4,
    parameter integer DESC_DEPTH = 2,
    parameter integer DATA_DEPTH = 4,
    parameter integer CHANNEL_WIDTH = (CHANNELS > 1) ? $clog2(CHANNELS) : 1
) (
    input  wire                       clk,
    input  wire                       rst,
    input  wire                       cfg_req_valid,
    input  wire                       cfg_req_write,
    output wire                       cfg_req_ready,
    input  wire [31:0]                cfg_req_addr,
    input  wire [31:0]                cfg_req_wdata,
    input  wire [3:0]                 cfg_req_wstrb,
    output wire                       cfg_rsp_valid,
    input  wire                       cfg_rsp_ready,
    output wire [31:0]                cfg_rsp_rdata,
    output wire                       cfg_rsp_error,
    input  wire [CHANNELS-1:0]        queue_full,
    input  wire [CHANNELS-1:0]        queue_empty,
    input  wire [CHANNELS*5-1:0]      queue_count,
    output reg [CHANNELS-1:0]         enqueue,
    output wire [CHANNELS*76-1:0]     enqueue_data,
    input  wire                       active,
    input  wire [CHANNEL_WIDTH-1:0]   active_channel,
    input  wire                       completed,
    input  wire                       failed,
    input  wire [1:0]                 failure_cause,
    input  wire                       event_interrupt,
    input  wire                       successful_word,
    output wire                       irq
);
    localparam [31:0] IMPLEMENTED_MASK = (32'h1 << CHANNELS) - 1'b1;
    localparam [31:0] CAPABILITIES = CHANNELS |
                                   (DESC_DEPTH << 8) |
                                   (DATA_DEPTH << 16);
    reg [31:0] source_stage [0:CHANNELS-1];
    reg [31:0] destination_stage [0:CHANNELS-1];
    reg [31:0] words_stage [0:CHANNELS-1];
    reg [2:0] control_stage [0:CHANNELS-1];
    reg [31:0] completed_count [0:CHANNELS-1];
    reg [31:0] successful_word_count [0:CHANNELS-1];
    reg [31:0] failed_count [0:CHANNELS-1];
    reg [CHANNELS-1:0] completion_sticky;
    reg [CHANNELS-1:0] error_sticky;
    reg [CHANNELS-1:0] completion_pending;
    reg [CHANNELS-1:0] error_pending;
    reg [1:0] error_cause [0:CHANNELS-1];
    reg [31:0] interrupt_mask;
    wire [31:0] interrupt_pending;
    reg response_valid;
    reg [31:0] response_data;
    reg response_error;
    wire accept_request;
    reg decode_error;
    reg [31:0] decode_data;
    reg [CHANNELS-1:0] write_source;
    reg [CHANNELS-1:0] write_destination;
    reg [CHANNELS-1:0] write_words;
    reg [CHANNELS-1:0] write_control;
    reg [CHANNELS*4-1:0] acknowledge;
    reg write_mask;
    reg channel_found;
    integer decoded_channel;
    reg [5:0] channel_offset;
    reg [32:0] source_end;
    reg [32:0] destination_end;
    reg [32:0] length_displacement;
    reg admission_valid;
    integer decode_index;
    integer state_index;
    genvar descriptor_index;

    function [31:0] merge_bytes;
        input [31:0] previous;
        input [31:0] update;
        input [3:0] strobes;
        integer lane;
        begin
            merge_bytes = previous;
            for (lane = 0; lane < 4; lane = lane + 1)
                if (strobes[lane])
                    merge_bytes[lane*8 +: 8] = update[lane*8 +: 8];
        end
    endfunction

    assign cfg_req_ready = !response_valid && !rst;
    assign cfg_rsp_valid = response_valid && !rst;
    assign cfg_rsp_rdata = response_data;
    assign cfg_rsp_error = response_error;
    assign accept_request = cfg_req_valid && cfg_req_ready;
    assign interrupt_pending = {{(32-CHANNELS){1'b0}},
                                (completion_pending | error_pending)};
    assign irq = !rst && (|(interrupt_pending & interrupt_mask));

    generate
        for (descriptor_index = 0; descriptor_index < CHANNELS;
             descriptor_index = descriptor_index + 1) begin : pack_descriptors
            assign enqueue_data[descriptor_index*76 +: 76] = {
                control_stage[descriptor_index],
                words_stage[descriptor_index][8:0],
                destination_stage[descriptor_index],
                source_stage[descriptor_index]
            };
        end
    endgenerate

    always @* begin
        decode_error = 1'b1;
        decode_data = 0;
        write_source = 0;
        write_destination = 0;
        write_words = 0;
        write_control = 0;
        acknowledge = 0;
        enqueue = 0;
        write_mask = 1'b0;
        channel_found = 1'b0;
        decoded_channel = 0;
        channel_offset = 0;
        source_end = 0;
        destination_end = 0;
        length_displacement = 0;
        admission_valid = 1'b0;

        for (decode_index = 0; decode_index < CHANNELS;
             decode_index = decode_index + 1) begin
            if ((cfg_req_addr >= (32'h100 + decode_index*32'h40)) &&
                (cfg_req_addr < (32'h140 + decode_index*32'h40))) begin
                channel_found = 1'b1;
                decoded_channel = decode_index;
                channel_offset = cfg_req_addr[5:0];
            end
        end

        if (cfg_req_addr[1:0] == 0) begin
            case (cfg_req_addr)
                32'h0000: begin
                    if (!cfg_req_write) begin
                        decode_error = 1'b0;
                        decode_data = 32'h4d434401;
                    end
                end
                32'h0004: begin
                    if (!cfg_req_write) begin
                        decode_error = 1'b0;
                        decode_data = CAPABILITIES;
                    end
                end
                32'h0008: begin
                    decode_error = 1'b0;
                    if (cfg_req_write)
                        write_mask = accept_request;
                    else
                        decode_data = interrupt_mask;
                end
                32'h000c: begin
                    if (!cfg_req_write) begin
                        decode_error = 1'b0;
                        decode_data = interrupt_pending;
                    end
                end
                32'h0010: begin
                    if (!cfg_req_write) begin
                        decode_error = 1'b0;
                        decode_data = 32'd256;
                    end
                end
                default: begin
                    if (channel_found) begin
                        case (channel_offset)
                            6'h00: begin
                                decode_error = 1'b0;
                                if (cfg_req_write)
                                    write_source[decoded_channel] = accept_request;
                                else
                                    decode_data = source_stage[decoded_channel];
                            end
                            6'h04: begin
                                decode_error = 1'b0;
                                if (cfg_req_write)
                                    write_destination[decoded_channel] = accept_request;
                                else
                                    decode_data = destination_stage[decoded_channel];
                            end
                            6'h08: begin
                                decode_error = 1'b0;
                                if (cfg_req_write)
                                    write_words[decoded_channel] = accept_request;
                                else
                                    decode_data = words_stage[decoded_channel];
                            end
                            6'h0c: begin
                                decode_error = 1'b0;
                                if (cfg_req_write)
                                    write_control[decoded_channel] = accept_request;
                                else
                                    decode_data = {29'b0, control_stage[decoded_channel]};
                            end
                            6'h10: begin
                                if (cfg_req_write) begin
                                    decode_error = 1'b0;
                                    if (cfg_req_wstrb[0] && cfg_req_wdata[0]) begin
                                        length_displacement =
                                            ({1'b0, words_stage[decoded_channel]} - 33'd1) << 2;
                                        source_end = {1'b0, source_stage[decoded_channel]} +
                                                     length_displacement;
                                        destination_end =
                                            {1'b0, destination_stage[decoded_channel]} +
                                            length_displacement;
                                        admission_valid =
                                            (words_stage[decoded_channel] >= 1) &&
                                            (words_stage[decoded_channel] <= 256) &&
                                            (source_stage[decoded_channel][1:0] == 0) &&
                                            (destination_stage[decoded_channel][1:0] == 0) &&
                                            (!control_stage[decoded_channel][0] ||
                                             !source_end[32]) &&
                                            (!control_stage[decoded_channel][1] ||
                                             !destination_end[32]) &&
                                            !queue_full[decoded_channel];
                                        decode_error = !admission_valid;
                                        enqueue[decoded_channel] =
                                            accept_request && admission_valid;
                                    end
                                end
                            end
                            6'h14: begin
                                if (!cfg_req_write) begin
                                    decode_error = 1'b0;
                                    decode_data[0] = active &&
                                                     (active_channel == decoded_channel);
                                    decode_data[1] = !queue_empty[decoded_channel];
                                    decode_data[2] = queue_full[decoded_channel];
                                    decode_data[3] = completion_sticky[decoded_channel];
                                    decode_data[4] = error_sticky[decoded_channel];
                                    decode_data[15:8] =
                                        {3'b0, queue_count[decoded_channel*5 +: 5]};
                                end
                            end
                            6'h18: begin
                                if (!cfg_req_write) begin
                                    decode_error = 1'b0;
                                    decode_data = completed_count[decoded_channel];
                                end
                            end
                            6'h1c: begin
                                if (!cfg_req_write) begin
                                    decode_error = 1'b0;
                                    decode_data = successful_word_count[decoded_channel];
                                end
                            end
                            6'h20: begin
                                if (!cfg_req_write) begin
                                    decode_error = 1'b0;
                                    decode_data = failed_count[decoded_channel];
                                end
                            end
                            6'h24: begin
                                if (!cfg_req_write) begin
                                    decode_error = 1'b0;
                                    decode_data[0] = completion_pending[decoded_channel];
                                    decode_data[1] = error_pending[decoded_channel];
                                end
                            end
                            6'h28: begin
                                if (cfg_req_write) begin
                                    decode_error = 1'b0;
                                    if (cfg_req_wstrb[0] && accept_request)
                                        acknowledge[decoded_channel*4 +: 4] =
                                            cfg_req_wdata[3:0];
                                end
                            end
                            6'h2c: begin
                                if (!cfg_req_write) begin
                                    decode_error = 1'b0;
                                    decode_data[1:0] = error_cause[decoded_channel];
                                end
                            end
                            default: begin
                                decode_error = 1'b1;
                            end
                        endcase
                    end
                end
            endcase
        end
        if (decode_error)
            decode_data = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            response_valid <= 1'b0;
            response_data <= 0;
            response_error <= 1'b0;
        end else begin
            if (response_valid && cfg_rsp_ready)
                response_valid <= 1'b0;
            if (accept_request) begin
                response_valid <= 1'b1;
                response_data <= decode_data;
                response_error <= decode_error;
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            interrupt_mask <= 0;
            completion_sticky <= 0;
            error_sticky <= 0;
            completion_pending <= 0;
            error_pending <= 0;
            for (state_index = 0; state_index < CHANNELS;
                 state_index = state_index + 1) begin
                source_stage[state_index] <= 0;
                destination_stage[state_index] <= 0;
                words_stage[state_index] <= 0;
                control_stage[state_index] <= 0;
                completed_count[state_index] <= 0;
                successful_word_count[state_index] <= 0;
                failed_count[state_index] <= 0;
                error_cause[state_index] <= 0;
            end
        end else begin
            if (write_mask)
                interrupt_mask <= merge_bytes(interrupt_mask, cfg_req_wdata,
                                              cfg_req_wstrb) & IMPLEMENTED_MASK;
            for (state_index = 0; state_index < CHANNELS;
                 state_index = state_index + 1) begin
                if (write_source[state_index])
                    source_stage[state_index] <=
                        merge_bytes(source_stage[state_index], cfg_req_wdata, cfg_req_wstrb);
                if (write_destination[state_index])
                    destination_stage[state_index] <=
                        merge_bytes(destination_stage[state_index], cfg_req_wdata, cfg_req_wstrb);
                if (write_words[state_index])
                    words_stage[state_index] <=
                        merge_bytes(words_stage[state_index], cfg_req_wdata, cfg_req_wstrb);
                if (write_control[state_index])
                    control_stage[state_index] <=
                        merge_bytes({29'b0, control_stage[state_index]},
                                    cfg_req_wdata, cfg_req_wstrb) & 32'h7;
                if (acknowledge[state_index*4]) begin
                    completion_sticky[state_index] <= 1'b0;
                end
                if (acknowledge[state_index*4+1]) begin
                    error_sticky[state_index] <= 1'b0;
                    error_cause[state_index] <= 0;
                end
                if (acknowledge[state_index*4+2])
                    completion_pending[state_index] <= 1'b0;
                if (acknowledge[state_index*4+3])
                    error_pending[state_index] <= 1'b0;
                if (active && (active_channel == state_index)) begin
                    if (successful_word)
                        successful_word_count[state_index] <=
                            successful_word_count[state_index] + 32'd1;
                    if (completed) begin
                        completed_count[state_index] <= completed_count[state_index] + 32'd1;
                        completion_sticky[state_index] <= 1'b1;
                        if (event_interrupt)
                            completion_pending[state_index] <= 1'b1;
                    end
                    if (failed) begin
                        failed_count[state_index] <= failed_count[state_index] + 32'd1;
                        error_sticky[state_index] <= 1'b1;
                        error_cause[state_index] <=
                            (acknowledge[state_index*4+1] ? 2'b0 : error_cause[state_index]) |
                            failure_cause;
                        if (event_interrupt)
                            error_pending[state_index] <= 1'b1;
                    end
                end
            end
        end
    end
endmodule
