module sp_arithmetic #(
    parameter integer CH_W = 1
) (
    input wire clk, rst,
    input wire in_valid,
    output wire in_ready,
    input wire [CH_W+144:0] operands,
    output wire out_valid,
    input wire out_ready,
    output wire [CH_W+52:0] result
);
    wire force_zero, protocol_error, sof, eof, saturation;
    wire [CH_W-1:0] channel;
    wire [7:0] tag;
    wire [3:0] shift;
    wire signed [31:0] bias;
    wire signed [15:0] c0, c1, c2, h1, h2, sample;
    wire signed [31:0] p0 = c0 * sample;
    wire signed [31:0] p1 = c1 * h1;
    wire signed [31:0] p2 = c2 * h2;
    wire signed [35:0] sum =
        $signed({{4{p0[31]}}, p0}) + $signed({{4{p1[31]}}, p1}) +
        $signed({{4{p2[31]}}, p2}) + $signed({{4{bias[31]}}, bias});
    reg valid;
    reg [CH_W+52:0] slot;
    assign {force_zero, protocol_error, channel, tag, sof, eof, shift,
            saturation, bias, c2, c1, c0, h2, h1, sample} = operands;
    assign in_ready = !rst && (!valid || out_ready);
    assign out_valid = !rst && valid;
    assign result = slot;
    always @(posedge clk) begin
        if (rst) begin
            valid <= 0;
            slot <= 0;
        end else if (in_ready) begin
            valid <= in_valid;
            if (in_valid)
                slot <= {force_zero, protocol_error, channel, tag, sof, eof,
                         shift, saturation, sum};
        end
    end
endmodule
