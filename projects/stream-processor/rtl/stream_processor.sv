module stream_processor #(
    parameter integer CHANNELS = 2,
    parameter integer INPUT_DEPTH = 2,
    parameter integer OUTPUT_DEPTH = 2,
    localparam integer CH_W = (CHANNELS <= 1) ? 1 : $clog2(CHANNELS)
) (
    input wire clk, rst,
    input wire in_valid,
    output wire in_ready,
    input wire signed [15:0] in_sample,
    input wire [CH_W-1:0] in_channel,
    input wire [7:0] in_tag,
    input wire in_sof, in_eof,
    output wire out_valid,
    input wire out_ready,
    output wire signed [15:0] out_data,
    output wire [CH_W-1:0] out_channel,
    output wire [7:0] out_tag,
    output wire out_sof, out_eof, out_protocol_error, out_clipped,
    input wire csr_req_valid,
    output wire csr_req_ready,
    input wire csr_req_write,
    input wire [15:0] csr_req_addr,
    input wire [31:0] csr_req_wdata,
    input wire [3:0] csr_req_wstrb,
    output wire csr_rsp_valid,
    input wire csr_rsp_ready,
    output wire [31:0] csr_rsp_rdata,
    output wire csr_rsp_error,
    output wire irq
);
    generate
        if (CHANNELS < 1 || CHANNELS > 4 ||
            INPUT_DEPTH < 1 || INPUT_DEPTH > 8 ||
            OUTPUT_DEPTH < 1 || OUTPUT_DEPTH > 8) begin: illegal_parameters
            initial $fatal(1, "stream_processor parameters out of range");
        end
    endgenerate

    wire [CHANNELS*16-1:0] shadow_c0, shadow_c1, shadow_c2;
    wire [CHANNELS*32-1:0] shadow_bias;
    wire [CHANNELS*9-1:0] shadow_control;
    wire [CHANNELS-1:0] active;
    wire admission_error, invalid_channel;
    wire [CH_W+144:0] admitted_operands, queued_operands;
    wire [CH_W+52:0] arithmetic_result;
    wire [CH_W+29:0] quantized_beat, output_beat;
    wire ingress_valid, ingress_ready, arithmetic_valid, egress_ready;
    wire [3:0] ingress_count, egress_count;
    wire accept = in_valid && in_ready;
    wire retire = out_valid && out_ready;

    sp_frame_tracker #(.CHANNELS(CHANNELS)) frames (
        .clk(clk), .rst(rst), .accept(accept),
        .sample(in_sample), .channel(in_channel), .tag(in_tag),
        .sof(in_sof), .eof(in_eof),
        .shadow_c0(shadow_c0), .shadow_c1(shadow_c1), .shadow_c2(shadow_c2),
        .shadow_bias(shadow_bias), .shadow_control(shadow_control),
        .active(active), .protocol_error(admission_error),
        .invalid_channel(invalid_channel), .operands(admitted_operands)
    );
    sp_queue #(.WIDTH(CH_W+145), .DEPTH(INPUT_DEPTH)) ingress (
        .clk(clk), .rst(rst), .push_valid(in_valid), .push_ready(in_ready),
        .push_data(admitted_operands), .pop_valid(ingress_valid),
        .pop_ready(ingress_ready), .pop_data(queued_operands),
        .occupancy(ingress_count)
    );
    sp_arithmetic #(.CH_W(CH_W)) arithmetic (
        .clk(clk), .rst(rst), .in_valid(ingress_valid), .in_ready(ingress_ready),
        .operands(queued_operands), .out_valid(arithmetic_valid),
        .out_ready(egress_ready), .result(arithmetic_result)
    );
    sp_quantizer #(.CH_W(CH_W)) quantizer (
        .result(arithmetic_result), .beat(quantized_beat)
    );
    sp_queue #(.WIDTH(CH_W+30), .DEPTH(OUTPUT_DEPTH)) egress (
        .clk(clk), .rst(rst), .push_valid(arithmetic_valid),
        .push_ready(egress_ready), .push_data(quantized_beat),
        .pop_valid(out_valid), .pop_ready(out_ready), .pop_data(output_beat),
        .occupancy(egress_count)
    );
    assign {out_clipped, out_protocol_error, out_channel, out_tag,
            out_sof, out_eof, out_data} = output_beat;
    sp_csr #(.CHANNELS(CHANNELS), .INPUT_DEPTH(INPUT_DEPTH),
             .OUTPUT_DEPTH(OUTPUT_DEPTH)) registers (
        .clk(clk), .rst(rst),
        .req_valid(csr_req_valid), .req_ready(csr_req_ready),
        .req_write(csr_req_write), .req_addr(csr_req_addr),
        .req_wdata(csr_req_wdata), .req_wstrb(csr_req_wstrb),
        .rsp_valid(csr_rsp_valid), .rsp_ready(csr_rsp_ready),
        .rsp_rdata(csr_rsp_rdata), .rsp_error(csr_rsp_error), .irq(irq),
        .accept(accept), .admission_error(admission_error),
        .invalid_channel(invalid_channel), .admission_channel(in_channel),
        .retire(retire), .retirement_clipped(out_clipped),
        .retirement_channel(out_channel),
        .ingress_count(ingress_count), .egress_count(egress_count),
        .arithmetic_valid(arithmetic_valid), .active(active),
        .shadow_c0(shadow_c0), .shadow_c1(shadow_c1), .shadow_c2(shadow_c2),
        .shadow_bias(shadow_bias), .shadow_control(shadow_control)
    );
endmodule
