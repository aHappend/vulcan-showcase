module mf_response_owner #(
    parameter integer CLIENT_W = 2,
    parameter integer SLOT_W = 1
) (
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 commit,
    input  wire [CLIENT_W-1:0]  commit_client,
    input  wire [SLOT_W-1:0]    commit_slot,
    input  wire                 commit_write,
    output wire                 awaiting,
    input  wire                 rsp_valid,
    output wire                 rsp_ready,
    input  wire [31:0]          rsp_rdata,
    input  wire                 rsp_error,
    output wire                 store,
    output wire [CLIENT_W-1:0]  store_client,
    output wire [SLOT_W-1:0]    store_slot,
    output wire [31:0]          store_data,
    output wire                 store_error
);
    reg occupied;
    reg [CLIENT_W-1:0] client_id;
    reg [SLOT_W-1:0] slot_id;
    reg write_flag;

    assign awaiting = occupied;
    assign rsp_ready = occupied && !rst;
    assign store = rsp_valid && rsp_ready;
    assign store_client = client_id;
    assign store_slot = slot_id;
    assign store_error = store && rsp_error;
    assign store_data = (store && !write_flag && !rsp_error) ? rsp_rdata : 32'b0;

    always @(posedge clk) begin
        if (rst) begin
            occupied <= 0;
            client_id <= 0;
            slot_id <= 0;
            write_flag <= 0;
        end else begin
            if (store)
                occupied <= 0;
            if (commit) begin
                occupied <= 1;
                client_id <= commit_client;
                slot_id <= commit_slot;
                write_flag <= commit_write;
            end
        end
    end
endmodule
