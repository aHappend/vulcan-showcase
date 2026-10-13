module mf_client_queue #(
    parameter integer SLOTS = 2,
    parameter integer SLOT_W = (SLOTS > 1) ? $clog2(SLOTS) : 1
) (
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  push,
    input  wire [SLOT_W-1:0]     push_slot,
    input  wire                  push_write,
    input  wire [15:0]           push_addr,
    input  wire [31:0]           push_wdata,
    input  wire [3:0]            push_wstrb,
    input  wire                  pop,
    output wire                  head_valid,
    output wire [SLOT_W-1:0]     head_slot,
    output wire                  head_write,
    output wire [15:0]           head_addr,
    output wire [31:0]           head_wdata,
    output wire [3:0]            head_wstrb
);
    reg [SLOT_W-1:0] rd_ptr, wr_ptr;
    reg [SLOT_W:0] count;
    reg [SLOT_W-1:0] slots [0:SLOTS-1];
    reg writes [0:SLOTS-1];
    reg [15:0] addresses [0:SLOTS-1];
    reg [31:0] data [0:SLOTS-1];
    reg [3:0] strobes [0:SLOTS-1];
    integer i;

    assign head_valid = !rst && (count != 0);
    assign head_slot = head_valid ? slots[rd_ptr] : {SLOT_W{1'b0}};
    assign head_write = head_valid ? writes[rd_ptr] : 1'b0;
    assign head_addr = head_valid ? addresses[rd_ptr] : 16'b0;
    assign head_wdata = head_valid ? data[rd_ptr] : 32'b0;
    assign head_wstrb = head_valid ? strobes[rd_ptr] : 4'b0;

    always @(posedge clk) begin
        if (rst) begin
            rd_ptr <= 0;
            wr_ptr <= 0;
            count <= 0;
            for (i = 0; i < SLOTS; i = i + 1) begin
                slots[i] <= 0;
                writes[i] <= 0;
                addresses[i] <= 0;
                data[i] <= 0;
                strobes[i] <= 0;
            end
        end else begin
            case ({push, pop})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
            if (push) begin
                slots[wr_ptr] <= push_slot;
                writes[wr_ptr] <= push_write;
                addresses[wr_ptr] <= push_addr;
                data[wr_ptr] <= push_wdata;
                strobes[wr_ptr] <= push_wstrb;
                wr_ptr <= (wr_ptr == SLOTS-1) ? 0 : wr_ptr + 1'b1;
            end
            if (pop)
                rd_ptr <= (rd_ptr == SLOTS-1) ? 0 : rd_ptr + 1'b1;
        end
    end
endmodule
