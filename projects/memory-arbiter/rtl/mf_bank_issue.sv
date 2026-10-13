module mf_bank_issue #(
    parameter integer CLIENT_W = 2,
    parameter integer SLOT_W = 1
) (
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 select_valid,
    input  wire [CLIENT_W-1:0]  select_client,
    input  wire [SLOT_W-1:0]    select_slot,
    input  wire                 select_write,
    input  wire [15:0]          select_addr,
    input  wire [31:0]          select_wdata,
    input  wire [3:0]           select_wstrb,
    output wire                 locked,
    output wire                 req_valid,
    input  wire                 req_ready,
    output wire                 req_write,
    output wire [15:0]          req_addr,
    output wire [31:0]          req_wdata,
    output wire [3:0]           req_wstrb,
    output wire                 commit,
    output wire [CLIENT_W-1:0]  commit_client,
    output wire [SLOT_W-1:0]    commit_slot
);
    reg occupied;
    reg [CLIENT_W-1:0] client_id;
    reg [SLOT_W-1:0] slot_id;
    reg write_flag;
    reg [15:0] address;
    reg [31:0] data;
    reg [3:0] strobes;

    assign locked = occupied;
    assign req_valid = occupied && !rst;
    assign req_write = req_valid ? write_flag : 1'b0;
    assign req_addr = req_valid ? address : 16'b0;
    assign req_wdata = req_valid ? data : 32'b0;
    assign req_wstrb = req_valid ? strobes : 4'b0;
    assign commit = req_valid && req_ready;
    assign commit_client = client_id;
    assign commit_slot = slot_id;

    always @(posedge clk) begin
        if (rst) begin
            occupied <= 0;
            client_id <= 0;
            slot_id <= 0;
            write_flag <= 0;
            address <= 0;
            data <= 0;
            strobes <= 0;
        end else begin
            if (commit)
                occupied <= 0;
            if (select_valid) begin
                occupied <= 1;
                client_id <= select_client;
                slot_id <= select_slot;
                write_flag <= select_write;
                address <= select_addr;
                data <= select_wdata;
                strobes <= select_wstrb;
            end
        end
    end
endmodule
