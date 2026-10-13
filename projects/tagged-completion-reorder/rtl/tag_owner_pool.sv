module tag_owner_pool #(
    parameter integer TAGS = 7
) (
    input wire clk, rst,
    output reg free_valid,
    output reg [6:0] free_tag,
    input wire allocate,
    input wire [1:0] allocate_client,
    input wire [2:0] allocate_slot,
    input wire issue_fire,
    input wire [6:0] issued_tag,
    input wire cpl_fire,
    input wire [6:0] cpl_tag,
    output reg completion_valid,
    output reg [1:0] completion_client,
    output reg [2:0] completion_slot,
    output reg [3:0] completion_errors,
    output reg [4:0] owned_count
);
    reg [TAGS-1:0] owned, seen, issued;
    reg [2:0] generation [0:TAGS-1];
    reg [1:0] owner_client [0:TAGS-1];
    reg [2:0] owner_slot [0:TAGS-1];
    reg [3:0] cursor;
    integer scan, index, reset_index;

    always @* begin
        free_valid = 1'b0;
        free_tag = 7'b0;
        owned_count = 5'b0;
        index = 0;
        for (scan = 0; scan < TAGS; scan = scan + 1) begin
            owned_count = owned_count + owned[scan];
            index = cursor + scan;
            if (index >= TAGS) index = index - TAGS;
            if (!free_valid && !owned[index]) begin
                free_valid = 1'b1;
                free_tag[3:0] = index;
                free_tag[6:4] = seen[index] ?
                    generation[index] + 3'd1 : 3'd0;
            end
        end
    end

    always @* begin
        completion_valid = 1'b0;
        completion_client = 2'b0;
        completion_slot = 3'b0;
        completion_errors = 4'b0;
        if (cpl_fire) begin
            if (cpl_tag[3:0] >= TAGS) begin
                completion_errors[0] = 1'b1;
            end else if (!seen[cpl_tag[3:0]]) begin
                completion_errors[0] = 1'b1;
            end else if (generation[cpl_tag[3:0]] != cpl_tag[6:4]) begin
                completion_errors[2] = 1'b1;
            end else if (!owned[cpl_tag[3:0]]) begin
                completion_errors[1] = 1'b1;
            end else if (!issued[cpl_tag[3:0]] &&
                         !(issue_fire && issued_tag == cpl_tag)) begin
                completion_errors[3] = 1'b1;
            end else begin
                completion_valid = 1'b1;
                completion_client = owner_client[cpl_tag[3:0]];
                completion_slot = owner_slot[cpl_tag[3:0]];
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            owned <= {TAGS{1'b0}};
            seen <= {TAGS{1'b0}};
            issued <= {TAGS{1'b0}};
            cursor <= 4'b0;
            for (reset_index = 0; reset_index < TAGS; reset_index = reset_index + 1) begin
                generation[reset_index] <= 3'b0;
                owner_client[reset_index] <= 2'b0;
                owner_slot[reset_index] <= 3'b0;
            end
        end else begin
            if (allocate) begin
                owned[free_tag[3:0]] <= 1'b1;
                seen[free_tag[3:0]] <= 1'b1;
                issued[free_tag[3:0]] <= 1'b0;
                generation[free_tag[3:0]] <= free_tag[6:4];
                owner_client[free_tag[3:0]] <= allocate_client;
                owner_slot[free_tag[3:0]] <= allocate_slot;
                cursor <= (free_tag[3:0] == TAGS-1) ?
                    4'd0 : free_tag[3:0] + 4'd1;
            end
            if (issue_fire) issued[issued_tag[3:0]] <= 1'b1;
            if (completion_valid) owned[cpl_tag[3:0]] <= 1'b0;
        end
    end
endmodule
