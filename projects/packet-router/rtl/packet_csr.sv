module packet_csr #(
    parameter integer INPUTS = 3,
    parameter integer OUTPUTS = 3,
    parameter integer PACKET_SLOTS = 2,
    parameter integer MAX_WORDS = 16
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     csr_req_valid,
    output wire                     csr_req_ready,
    input  wire                     csr_req_write,
    input  wire [15:0]              csr_req_addr,
    input  wire [31:0]              csr_req_wdata,
    input  wire [3:0]               csr_req_wstrb,
    output wire                     csr_rsp_valid,
    input  wire                     csr_rsp_ready,
    output wire [31:0]              csr_rsp_rdata,
    output wire                     csr_rsp_error,
    output wire                     irq,
    input  wire [143:0]             route_entries,
    output reg                      route_write,
    output reg  [3:0]               route_write_tag,
    output reg  [8:0]               route_write_entry,
    input  wire [INPUTS-1:0]        accepted_packets,
    input  wire [INPUTS-1:0]        dropped_packets,
    input  wire [INPUTS-1:0]        oversize_packets,
    input  wire [INPUTS-1:0]        accepted_beats,
    input  wire [INPUTS*32-1:0]     occupancies,
    input  wire [INPUTS*32-1:0]     completed_counts,
    input  wire [INPUTS*3-1:0]      input_states,
    input  wire [OUTPUTS-1:0]       transmitted_packets,
    input  wire [OUTPUTS-1:0]       transmitted_beats,
    input  wire [OUTPUTS-1:0]       output_busy,
    input  wire [2:0]               ingress_errors
);
    localparam integer KIND_RO = 0;
    localparam integer KIND_STATUS = 1;
    localparam integer KIND_MASK = 2;
    localparam integer KIND_ROUTE = 3;

    reg response_valid;
    reg [31:0] response_data;
    reg response_error;
    reg [31:0] error_status;
    reg [31:0] interrupt_mask;
    reg [31:0] in_packets [0:INPUTS-1];
    reg [31:0] in_drops [0:INPUTS-1];
    reg [31:0] in_oversize [0:INPUTS-1];
    reg [31:0] in_beats [0:INPUTS-1];
    reg [31:0] out_packets [0:OUTPUTS-1];
    reg [31:0] out_beats [0:OUTPUTS-1];

    reg found;
    integer kind;
    reg [3:0] selected_tag;
    reg [31:0] read_value;
    reg [31:0] merged_value;
    reg [31:0] strobed_data;
    reg decode_error;
    reg [31:0] acknowledge;
    reg mask_write;
    integer t;
    integer i;
    integer o;
    integer counter_input;
    integer counter_output;

    wire request_fire = csr_req_valid && csr_req_ready;
    wire [31:0] new_events = {28'b0, request_fire && decode_error, ingress_errors};

    function [31:0] merge_bytes;
        input [31:0] previous;
        input [31:0] data;
        input [3:0] strobes;
        integer lane;
        begin
            merge_bytes = previous;
            for (lane = 0; lane < 4; lane = lane + 1)
                if (strobes[lane])
                    merge_bytes[lane*8 +: 8] = data[lane*8 +: 8];
        end
    endfunction

    assign csr_req_ready = !rst && !response_valid;
    assign csr_rsp_valid = !rst && response_valid;
    assign csr_rsp_rdata = response_data;
    assign csr_rsp_error = response_error;
    assign irq = !rst && (|(error_status & interrupt_mask));

    always @* begin
        found = 1'b1;
        kind = KIND_RO;
        selected_tag = 0;
        read_value = 0;
        case (csr_req_addr)
            16'h0000: read_value = 32'h50535731;
            16'h0004: read_value = 32'h00010000;
            16'h0008: read_value = INPUTS;
            16'h000c: read_value = OUTPUTS;
            16'h0010: read_value = PACKET_SLOTS;
            16'h0014: read_value = MAX_WORDS;
            16'h0018: read_value = 32'h0000000f;
            16'h0020: begin
                read_value = error_status;
                kind = KIND_STATUS;
            end
            16'h0024: begin
                read_value = interrupt_mask;
                kind = KIND_MASK;
            end
            16'h0028: read_value = error_status & interrupt_mask;
            default: found = 1'b0;
        endcase
        for (t = 0; t < 16; t = t + 1) begin
            if (csr_req_addr == 16'h0100 + 4*t) begin
                found = 1'b1;
                kind = KIND_ROUTE;
                selected_tag = t;
                read_value = {23'b0, route_entries[t*9 +: 9]};
            end
        end
        for (i = 0; i < INPUTS; i = i + 1) begin
            if (csr_req_addr == 16'h0200 + 32*i) begin
                found = 1'b1;
                read_value = in_packets[i];
            end
            if (csr_req_addr == 16'h0204 + 32*i) begin
                found = 1'b1;
                read_value = in_drops[i];
            end
            if (csr_req_addr == 16'h0208 + 32*i) begin
                found = 1'b1;
                read_value = in_oversize[i];
            end
            if (csr_req_addr == 16'h020c + 32*i) begin
                found = 1'b1;
                read_value = in_beats[i];
            end
            if (csr_req_addr == 16'h0210 + 32*i) begin
                found = 1'b1;
                read_value = occupancies[i*32 +: 32];
            end
            if (csr_req_addr == 16'h0214 + 32*i) begin
                found = 1'b1;
                read_value = completed_counts[i*32 +: 32];
            end
            if (csr_req_addr == 16'h0218 + 32*i) begin
                found = 1'b1;
                read_value = {29'b0, input_states[i*3 +: 3]};
            end
        end
        for (o = 0; o < OUTPUTS; o = o + 1) begin
            if (csr_req_addr == 16'h0500 + 16*o) begin
                found = 1'b1;
                read_value = out_packets[o];
            end
            if (csr_req_addr == 16'h0504 + 16*o) begin
                found = 1'b1;
                read_value = out_beats[o];
            end
            if (csr_req_addr == 16'h0508 + 16*o) begin
                found = 1'b1;
                read_value = {31'b0, output_busy[o]};
            end
        end

        merged_value = merge_bytes(read_value, csr_req_wdata, csr_req_wstrb);
        strobed_data = merge_bytes(32'b0, csr_req_wdata, csr_req_wstrb);
        decode_error = !found || (csr_req_addr[1:0] != 0);
        if (csr_req_write && found) begin
            case (kind)
                KIND_STATUS: begin
                    if (strobed_data[31:4] != 0)
                        decode_error = 1'b1;
                end
                KIND_MASK: begin
                    if (merged_value[31:4] != 0)
                        decode_error = 1'b1;
                end
                KIND_ROUTE: begin
                    if (merged_value[31:9] != 0)
                        decode_error = 1'b1;
                end
                default: decode_error = 1'b1;
            endcase
        end

        route_write = 1'b0;
        route_write_tag = selected_tag;
        route_write_entry = merged_value[8:0];
        acknowledge = 0;
        mask_write = 1'b0;
        if (request_fire && csr_req_write && !decode_error) begin
            case (kind)
                KIND_STATUS: acknowledge = strobed_data;
                KIND_MASK: mask_write = 1'b1;
                KIND_ROUTE: route_write = 1'b1;
                default: begin end
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            response_valid <= 1'b0;
            response_data <= 0;
            response_error <= 1'b0;
            error_status <= 0;
            interrupt_mask <= 0;
            for (counter_input = 0; counter_input < INPUTS; counter_input = counter_input + 1) begin
                in_packets[counter_input] <= 0;
                in_drops[counter_input] <= 0;
                in_oversize[counter_input] <= 0;
                in_beats[counter_input] <= 0;
            end
            for (counter_output = 0; counter_output < OUTPUTS; counter_output = counter_output + 1) begin
                out_packets[counter_output] <= 0;
                out_beats[counter_output] <= 0;
            end
        end else begin
            if (request_fire) begin
                response_valid <= 1'b1;
                response_data <= (csr_req_write || decode_error) ? 32'b0 : read_value;
                response_error <= decode_error;
            end else if (response_valid && csr_rsp_ready) begin
                response_valid <= 1'b0;
            end
            error_status <= (error_status & ~acknowledge) | new_events;
            if (mask_write)
                interrupt_mask <= merged_value;
            for (counter_input = 0; counter_input < INPUTS; counter_input = counter_input + 1) begin
                if (accepted_packets[counter_input])
                    in_packets[counter_input] <= in_packets[counter_input] + 32'd1;
                if (dropped_packets[counter_input])
                    in_drops[counter_input] <= in_drops[counter_input] + 32'd1;
                if (oversize_packets[counter_input])
                    in_oversize[counter_input] <= in_oversize[counter_input] + 32'd1;
                if (accepted_beats[counter_input])
                    in_beats[counter_input] <= in_beats[counter_input] + 32'd1;
            end
            for (counter_output = 0; counter_output < OUTPUTS; counter_output = counter_output + 1) begin
                if (transmitted_packets[counter_output])
                    out_packets[counter_output] <= out_packets[counter_output] + 32'd1;
                if (transmitted_beats[counter_output])
                    out_beats[counter_output] <= out_beats[counter_output] + 32'd1;
            end
        end
    end
endmodule
