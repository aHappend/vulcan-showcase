module sp_quantizer #(
    parameter integer CH_W = 1
) (
    input wire [CH_W+52:0] result,
    output wire [CH_W+29:0] beat
);
    wire force_zero, protocol_error, sof, eof, saturation;
    wire [CH_W-1:0] channel;
    wire [7:0] tag;
    wire [3:0] shift;
    wire signed [35:0] sum;
    wire signed [35:0] shifted = sum >>> shift;
    wire high_clip = shifted > 36'sd32767;
    wire low_clip = shifted < -36'sd32768;
    wire clipped = !force_zero && (high_clip || low_clip);
    wire [15:0] data = force_zero ? 16'b0 :
        (saturation && high_clip) ? 16'h7fff :
        (saturation && low_clip) ? 16'h8000 : shifted[15:0];
    assign {force_zero, protocol_error, channel, tag, sof, eof, shift,
            saturation, sum} = result;
    assign beat = {clipped, protocol_error, channel, tag, sof, eof, data};
endmodule
