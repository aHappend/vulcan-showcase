module dma_data_fifo #(
    parameter integer DEPTH = 4,
    parameter integer PTR_WIDTH = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter integer COUNT_WIDTH = $clog2(DEPTH + 1)
) (
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   flush,
    input  wire                   push_valid,
    output wire                   push_ready,
    input  wire [31:0]            push_data,
    output wire                   head_valid,
    input  wire                   head_ready,
    output wire [31:0]            head_data,
    output wire [COUNT_WIDTH-1:0] occupancy,
    output wire                   empty
);
    reg [31:0] words [0:DEPTH-1];
    reg [PTR_WIDTH-1:0] read_pointer;
    reg [PTR_WIDTH-1:0] write_pointer;
    reg [COUNT_WIDTH-1:0] count;
    wire push_fire;
    wire pop_fire;
    integer slot;

    assign empty = (count == 0);
    assign occupancy = count;
    assign head_valid = !rst && !flush && !empty;
    assign head_data = empty ? 32'b0 : words[read_pointer];
    assign pop_fire = head_valid && head_ready;
    assign push_ready = !rst && !flush && ((count < DEPTH) || pop_fire);
    assign push_fire = push_valid && push_ready;

    function [PTR_WIDTH-1:0] next_pointer;
        input [PTR_WIDTH-1:0] pointer;
        begin
            if (pointer == DEPTH - 1)
                next_pointer = 0;
            else
                next_pointer = pointer + 1'b1;
        end
    endfunction

    always @(posedge clk) begin
        if (rst) begin
            read_pointer <= 0;
            write_pointer <= 0;
            count <= 0;
            for (slot = 0; slot < DEPTH; slot = slot + 1)
                words[slot] <= 0;
        end else if (flush) begin
            read_pointer <= 0;
            write_pointer <= 0;
            count <= 0;
        end else begin
            if (push_fire) begin
                words[write_pointer] <= push_data;
                write_pointer <= next_pointer(write_pointer);
            end
            if (pop_fire)
                read_pointer <= next_pointer(read_pointer);
            case ({push_fire, pop_fire})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end
endmodule
