module packet_arbiter #(
    parameter integer INPUTS = 3,
    parameter integer INPUT_W = (INPUTS > 1) ? $clog2(INPUTS) : 1
) (
    input  wire                 clk,
    input  wire                 rst,
    input  wire [INPUTS-1:0]    eligible,
    output reg                  grant_valid,
    output reg  [INPUT_W-1:0]   grant_input,
    input  wire                 packet_done,
    input  wire [INPUT_W-1:0]   completed_input
);
    reg [INPUT_W-1:0] next_input;
    integer offset;
    integer candidate;

    always @* begin
        grant_valid = 1'b0;
        grant_input = 0;
        candidate = 0;
        for (offset = 0; offset < INPUTS; offset = offset + 1) begin
            candidate = next_input + offset;
            if (candidate >= INPUTS)
                candidate = candidate - INPUTS;
            if (!rst && !grant_valid && eligible[candidate]) begin
                grant_valid = 1'b1;
                grant_input = candidate;
            end
        end
    end

    always @(posedge clk) begin
        if (rst)
            next_input <= 0;
        else if (packet_done) begin
            if (completed_input == INPUTS-1)
                next_input <= 0;
            else
                next_input <= completed_input + 1'b1;
        end
    end
endmodule
