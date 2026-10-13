module sp_queue #(
    parameter integer WIDTH = 32,
    parameter integer DEPTH = 2,
    localparam integer PTR_W = (DEPTH <= 1) ? 1 : $clog2(DEPTH),
    localparam integer COUNT_W = $clog2(DEPTH + 1)
) (
    input wire clk, rst,
    input wire push_valid,
    output wire push_ready,
    input wire [WIDTH-1:0] push_data,
    output wire pop_valid,
    input wire pop_ready,
    output wire [WIDTH-1:0] pop_data,
    output wire [3:0] occupancy
);
    reg [WIDTH-1:0] storage [0:DEPTH-1];
    reg [PTR_W-1:0] read_ptr, write_ptr;
    reg [COUNT_W-1:0] count;
    wire push = push_valid && push_ready;
    wire pop = pop_valid && pop_ready;
    assign push_ready = !rst && (count < DEPTH);
    assign pop_valid = !rst && (count != 0);
    assign pop_data = storage[read_ptr];
    assign occupancy = count;

    always @(posedge clk) begin
        if (rst) begin
            read_ptr <= 0;
            write_ptr <= 0;
            count <= 0;
        end else begin
            if (push) begin
                storage[write_ptr] <= push_data;
                if (write_ptr == DEPTH-1) write_ptr <= 0;
                else write_ptr <= write_ptr + 1'b1;
            end
            if (pop) begin
                if (read_ptr == DEPTH-1) read_ptr <= 0;
                else read_ptr <= read_ptr + 1'b1;
            end
            case ({push, pop})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end
endmodule
