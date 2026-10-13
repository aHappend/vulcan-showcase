module packet_output #(
    parameter integer INPUTS = 3,
    parameter integer MAX_WORDS = 16,
    parameter integer INPUT_W = (INPUTS > 1) ? $clog2(INPUTS) : 1,
    parameter integer WORD_W = (MAX_WORDS > 1) ? $clog2(MAX_WORDS) : 1,
    parameter integer LENGTH_W = $clog2(MAX_WORDS + 1)
) (
    input  wire                         clk,
    input  wire                         rst,
    input  wire                         grant_valid,
    input  wire [INPUT_W-1:0]           grant_input,
    input  wire [INPUTS*LENGTH_W-1:0]   head_lengths,
    input  wire [INPUTS*32-1:0]         head_words,
    output wire                         out_valid,
    input  wire                         out_ready,
    output wire [31:0]                  out_data,
    output wire                         out_last,
    output wire                         busy,
    output wire [INPUT_W-1:0]           owner_input,
    output wire [WORD_W-1:0]            word_index,
    output wire                         transmitted_beat,
    output wire                         packet_done
);
    reg owned;
    reg [INPUT_W-1:0] owner;
    reg [WORD_W-1:0] index;
    reg [LENGTH_W-1:0] length;

    assign out_valid = !rst && owned;
    assign out_data = owned ? head_words[owner*32 +: 32] : 32'b0;
    assign out_last = out_valid && ({1'b0, index} + 1'b1 == length);
    assign busy = owned;
    assign owner_input = owner;
    assign word_index = index;
    assign transmitted_beat = out_valid && out_ready;
    assign packet_done = transmitted_beat && out_last;

    always @(posedge clk) begin
        if (rst) begin
            owned <= 1'b0;
            owner <= 0;
            index <= 0;
            length <= 0;
        end else if (!owned) begin
            if (grant_valid) begin
                owned <= 1'b1;
                owner <= grant_input;
                length <= head_lengths[grant_input*LENGTH_W +: LENGTH_W];
                index <= 0;
            end
        end else if (transmitted_beat) begin
            if (out_last) begin
                owned <= 1'b0;
                index <= 0;
            end else begin
                index <= index + 1'b1;
            end
        end
    end
endmodule
