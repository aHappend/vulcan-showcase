module client_reorder #(
    parameter integer ROB_DEPTH = 3
) (
    input wire clk, rst,
    input wire accept,
    input wire [15:0] accept_id,
    input wire [31:0] accept_data,
    input wire [6:0] accept_tag,
    output wire [2:0] tail_slot,
    output wire space,
    output reg [2:0] occupancy,
    output reg candidate_valid,
    output reg [2:0] candidate_slot,
    output reg [6:0] candidate_tag,
    output reg [15:0] candidate_id,
    output reg [31:0] candidate_data,
    input wire issue_fire,
    input wire [2:0] issue_slot,
    input wire complete,
    input wire [2:0] complete_slot,
    input wire [31:0] complete_data,
    output wire rsp_valid,
    input wire rsp_ready,
    output wire [15:0] rsp_id,
    output wire [31:0] rsp_data,
    output wire retire_fire
);
    reg [2:0] head, tail;
    reg [ROB_DEPTH-1:0] valid, issued, completed;
    reg [15:0] ids [0:ROB_DEPTH-1];
    reg [31:0] requests [0:ROB_DEPTH-1];
    reg [31:0] results [0:ROB_DEPTH-1];
    reg [6:0] tags [0:ROB_DEPTH-1];
    integer scan, index, reset_index;

    assign tail_slot = tail;
    assign space = occupancy < ROB_DEPTH;
    assign rsp_valid = !rst && valid[head] && completed[head];
    assign rsp_id = ids[head];
    assign rsp_data = results[head];
    assign retire_fire = rsp_valid && rsp_ready;

    always @* begin
        candidate_valid = 1'b0;
        candidate_slot = 3'b0;
        candidate_tag = 7'b0;
        candidate_id = 16'b0;
        candidate_data = 32'b0;
        index = 0;
        for (scan = 0; scan < ROB_DEPTH; scan = scan + 1) begin
            index = head + scan;
            if (index >= ROB_DEPTH) index = index - ROB_DEPTH;
            if (!candidate_valid && valid[index] && !issued[index]) begin
                candidate_valid = 1'b1;
                candidate_slot = index;
                candidate_tag = tags[index];
                candidate_id = ids[index];
                candidate_data = requests[index];
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            head <= 3'b0;
            tail <= 3'b0;
            occupancy <= 3'b0;
            valid <= {ROB_DEPTH{1'b0}};
            issued <= {ROB_DEPTH{1'b0}};
            completed <= {ROB_DEPTH{1'b0}};
            for (reset_index = 0; reset_index < ROB_DEPTH; reset_index = reset_index + 1) begin
                ids[reset_index] <= 16'b0;
                requests[reset_index] <= 32'b0;
                results[reset_index] <= 32'b0;
                tags[reset_index] <= 7'b0;
            end
        end else begin
            case ({accept, retire_fire})
                2'b10: occupancy <= occupancy + 3'd1;
                2'b01: occupancy <= occupancy - 3'd1;
                default: occupancy <= occupancy;
            endcase
            if (accept) begin
                valid[tail] <= 1'b1;
                issued[tail] <= 1'b0;
                completed[tail] <= 1'b0;
                ids[tail] <= accept_id;
                requests[tail] <= accept_data;
                tags[tail] <= accept_tag;
                tail <= (tail == ROB_DEPTH-1) ? 3'd0 : tail + 3'd1;
            end
            if (issue_fire) issued[issue_slot] <= 1'b1;
            if (complete) begin
                completed[complete_slot] <= 1'b1;
                results[complete_slot] <= complete_data;
            end
            if (retire_fire) begin
                valid[head] <= 1'b0;
                head <= (head == ROB_DEPTH-1) ? 3'd0 : head + 3'd1;
            end
        end
    end
endmodule
