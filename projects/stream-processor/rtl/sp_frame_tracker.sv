module sp_frame_tracker #(
    parameter integer CHANNELS = 2,
    localparam integer CH_W = (CHANNELS <= 1) ? 1 : $clog2(CHANNELS)
) (
    input wire clk, rst, accept,
    input wire signed [15:0] sample,
    input wire [CH_W-1:0] channel,
    input wire [7:0] tag,
    input wire sof, eof,
    input wire [CHANNELS*16-1:0] shadow_c0, shadow_c1, shadow_c2,
    input wire [CHANNELS*32-1:0] shadow_bias,
    input wire [CHANNELS*9-1:0] shadow_control,
    output reg [CHANNELS-1:0] active,
    output wire protocol_error, invalid_channel,
    output wire [CH_W+144:0] operands
);
    reg signed [15:0] history1 [0:CHANNELS-1];
    reg signed [15:0] history2 [0:CHANNELS-1];
    reg [15:0] active_c0 [0:CHANNELS-1];
    reg [15:0] active_c1 [0:CHANNELS-1];
    reg [15:0] active_c2 [0:CHANNELS-1];
    reg [31:0] active_bias [0:CHANNELS-1];
    reg [8:0] active_control [0:CHANNELS-1];
    reg [15:0] c0, c1, c2, h1, h2;
    reg [31:0] bias;
    reg [8:0] control;
    wire force_zero;
    integer k;

    assign invalid_channel = (channel >= CHANNELS);
    assign force_zero = invalid_channel || (!sof && !active[channel]);
    assign protocol_error = invalid_channel ||
                            (sof ? active[channel] : !active[channel]);
    assign operands = {force_zero, protocol_error, channel, tag, sof, eof,
                       control[3:0], control[8], bias, c2, c1, c0,
                       h2, h1, sample};

    always @* begin
        c0 = 0;
        c1 = 0;
        c2 = 0;
        bias = 0;
        control = 9'h100;
        h1 = 0;
        h2 = 0;
        if (!invalid_channel) begin
            if (sof) begin
                c0 = shadow_c0[channel*16 +: 16];
                c1 = shadow_c1[channel*16 +: 16];
                c2 = shadow_c2[channel*16 +: 16];
                bias = shadow_bias[channel*32 +: 32];
                control = shadow_control[channel*9 +: 9];
            end else begin
                c0 = active_c0[channel];
                c1 = active_c1[channel];
                c2 = active_c2[channel];
                bias = active_bias[channel];
                control = active_control[channel];
                h1 = history1[channel];
                h2 = history2[channel];
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            active <= 0;
            for (k = 0; k < CHANNELS; k = k + 1) begin
                history1[k] <= 0;
                history2[k] <= 0;
                active_c0[k] <= 1;
                active_c1[k] <= 0;
                active_c2[k] <= 0;
                active_bias[k] <= 0;
                active_control[k] <= 9'h100;
            end
        end else if (accept && !force_zero) begin
            history1[channel] <= sample;
            history2[channel] <= sof ? 16'b0 : history1[channel];
            active[channel] <= !eof;
            if (sof) begin
                active_c0[channel] <= c0;
                active_c1[channel] <= c1;
                active_c2[channel] <= c2;
                active_bias[channel] <= bias;
                active_control[channel] <= control;
            end
        end
    end
endmodule
