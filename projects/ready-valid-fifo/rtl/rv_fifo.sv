module rv_fifo #(
    parameter integer DATA_WIDTH = 8,
    parameter integer DEPTH = 4
) (
    input  logic clk,
    input  logic rst,
    input  logic in_valid,
    output logic in_ready,
    input  logic [DATA_WIDTH-1:0] in_data,
    output logic out_valid,
    input  logic out_ready,
    output logic [DATA_WIDTH-1:0] out_data,
    output logic [((($clog2(DEPTH+1)) < 1) ? 1 : $clog2(DEPTH+1))-1:0] occupancy
);
    localparam integer INDEX_WIDTH = ($clog2(DEPTH) < 1) ? 1 : $clog2(DEPTH);

    logic [DATA_WIDTH-1:0] storage [0:DEPTH-1];
    logic [INDEX_WIDTH-1:0] read_index;
    logic [INDEX_WIDTH-1:0] write_index;
    logic enqueue;
    logic dequeue;

    assign out_valid = !rst && (occupancy != 0);
    assign out_data = out_valid ? storage[read_index] : {DATA_WIDTH{1'b0}};
    assign in_ready = !rst && ((occupancy < DEPTH) || (out_valid && out_ready));
    assign enqueue = in_valid && in_ready;
    assign dequeue = out_valid && out_ready;

    always_ff @(posedge clk) begin
        if (rst) begin
            read_index <= '0;
            write_index <= '0;
            occupancy <= '0;
        end else begin
            if (enqueue) begin
                storage[write_index] <= in_data;
                if (write_index == DEPTH-1)
                    write_index <= '0;
                else
                    write_index <= write_index + 1'b1;
            end

            if (dequeue) begin
                if (read_index == DEPTH-1)
                    read_index <= '0;
                else
                    read_index <= read_index + 1'b1;
            end

            case ({enqueue, dequeue})
                2'b10: occupancy <= occupancy + 1'b1;
                2'b01: occupancy <= occupancy - 1'b1;
                default: occupancy <= occupancy;
            endcase
        end
    end
endmodule
