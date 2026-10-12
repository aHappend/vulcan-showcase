module dma_descriptor_queue #(
    parameter integer DEPTH = 2,
    parameter integer WIDTH = 76,
    parameter integer PTR_WIDTH = (DEPTH > 1) ? $clog2(DEPTH) : 1,
    parameter integer COUNT_WIDTH = $clog2(DEPTH + 1)
) (
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   push,
    input  wire [WIDTH-1:0]       push_data,
    input  wire                   pop,
    output wire [WIDTH-1:0]       head_data,
    output wire                   empty,
    output wire                   full,
    output wire [COUNT_WIDTH-1:0] occupancy
);
    reg [WIDTH-1:0] storage [0:DEPTH-1];
    reg [PTR_WIDTH-1:0] read_pointer;
    reg [PTR_WIDTH-1:0] write_pointer;
    reg [COUNT_WIDTH-1:0] count;
    wire push_fire;
    wire pop_fire;
    integer slot;

    assign empty = (count == 0);
    assign full = (count == DEPTH);
    assign occupancy = count;
    assign head_data = empty ? {WIDTH{1'b0}} : storage[read_pointer];
    assign push_fire = push && !full && !rst;
    assign pop_fire = pop && !empty && !rst;

    function [PTR_WIDTH-1:0] next_pointer;
        input [PTR_WIDTH-1:0] pointer;
        begin
            if (pointer == DEPTH - 1)
                next_pointer = {PTR_WIDTH{1'b0}};
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
                storage[slot] <= 0;
        end else begin
            if (push_fire) begin
                storage[write_pointer] <= push_data;
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
