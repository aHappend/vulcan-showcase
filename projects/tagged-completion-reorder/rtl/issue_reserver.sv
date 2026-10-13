module issue_reserver #(
    parameter integer CLIENTS = 3
) (
    input wire clk, rst,
    input wire selection_enable,
    input wire [CLIENTS-1:0] candidate_valid,
    input wire [CLIENTS*3-1:0] candidate_slot,
    input wire [CLIENTS*7-1:0] candidate_tag,
    input wire [CLIENTS*16-1:0] candidate_id,
    input wire [CLIENTS*32-1:0] candidate_data,
    output wire issue_valid,
    input wire issue_ready,
    output reg [1:0] issue_client,
    output reg [2:0] issue_slot,
    output reg [6:0] issue_tag,
    output reg [15:0] issue_id,
    output reg [31:0] issue_data,
    output wire issue_fire
);
    reg reserved;
    reg [1:0] cursor;
    reg select_valid;
    reg [1:0] select_client;
    integer scan, index;

    assign issue_valid = !rst && reserved;
    assign issue_fire = issue_valid && issue_ready;
    always @* begin
        select_valid = 1'b0;
        select_client = 2'b0;
        index = 0;
        for (scan = 0; scan < CLIENTS; scan = scan + 1) begin
            index = cursor + scan;
            if (index >= CLIENTS) index = index - CLIENTS;
            if (!select_valid && candidate_valid[index]) begin
                select_valid = 1'b1;
                select_client = index;
            end
        end
    end
    always @(posedge clk) begin
        if (rst) begin
            reserved <= 1'b0;
            cursor <= 2'b0;
            issue_client <= 2'b0;
            issue_slot <= 3'b0;
            issue_tag <= 7'b0;
            issue_id <= 16'b0;
            issue_data <= 32'b0;
        end else begin
            if (!reserved && selection_enable && select_valid) begin
                reserved <= 1'b1;
                issue_client <= select_client;
                issue_slot <= candidate_slot[select_client*3 +: 3];
                issue_tag <= candidate_tag[select_client*7 +: 7];
                issue_id <= candidate_id[select_client*16 +: 16];
                issue_data <= candidate_data[select_client*32 +: 32];
            end
            if (issue_fire) begin
                reserved <= 1'b0;
                cursor <= (issue_client == CLIENTS-1) ?
                    2'd0 : issue_client + 2'd1;
            end
        end
    end
endmodule
