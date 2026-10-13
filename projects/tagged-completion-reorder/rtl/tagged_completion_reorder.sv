module tagged_completion_reorder #(
    parameter integer CLIENTS = 3,
    parameter integer ROB_DEPTH = 3,
    parameter integer TAGS = 7
) (
    input wire clk, rst,
    input wire [((CLIENTS > 0) ? CLIENTS : 1)-1:0] req_valid,
    output reg [((CLIENTS > 0) ? CLIENTS : 1)-1:0] req_ready,
    input wire [((CLIENTS > 0) ? CLIENTS : 1)*16-1:0] req_id,
    input wire [((CLIENTS > 0) ? CLIENTS : 1)*32-1:0] req_data,
    output wire [((CLIENTS > 0) ? CLIENTS : 1)-1:0] rsp_valid,
    input wire [((CLIENTS > 0) ? CLIENTS : 1)-1:0] rsp_ready,
    output wire [((CLIENTS > 0) ? CLIENTS : 1)*16-1:0] rsp_id,
    output wire [((CLIENTS > 0) ? CLIENTS : 1)*32-1:0] rsp_data,
    output wire issue_valid,
    input wire issue_ready,
    output wire [1:0] issue_client,
    output wire [6:0] issue_tag,
    output wire [15:0] issue_id,
    output wire [31:0] issue_data,
    input wire cpl_valid,
    output wire cpl_ready,
    input wire [6:0] cpl_tag,
    input wire [31:0] cpl_data,
    input wire csr_valid,
    output wire csr_ready,
    input wire csr_write,
    input wire [7:0] csr_addr,
    input wire [31:0] csr_wdata,
    input wire [3:0] csr_wstrb,
    output wire csr_rsp_valid,
    input wire csr_rsp_ready,
    output wire [31:0] csr_rdata,
    output wire [1:0] csr_error,
    output wire irq
);
    generate
        if (CLIENTS < 1 || CLIENTS > 4 || ROB_DEPTH < 1 ||
            ROB_DEPTH > 5 || TAGS < 1 || TAGS > 16) begin : illegal_parameters
            initial $fatal(1, "PARAMETER ERROR: CLIENTS=1..4 ROB_DEPTH=1..5 TAGS=1..16 required");
        end else begin : implementation

    wire admission_enable, selection_enable;
    wire [CLIENTS-1:0] client_enable, space;
    wire [CLIENTS-1:0] accept_events = req_valid & req_ready;
    wire [CLIENTS-1:0] issue_events, retire_events;
    wire [CLIENTS*3-1:0] tail_slots, occupancies, candidate_slots;
    wire [CLIENTS-1:0] candidate_valid;
    wire [CLIENTS*7-1:0] candidate_tags;
    wire [CLIENTS*16-1:0] candidate_ids;
    wire [CLIENTS*32-1:0] candidate_data;
    wire free_valid, issue_fire, completion_valid;
    wire [6:0] free_tag;
    wire [4:0] owned_count;
    wire [3:0] completion_errors;
    wire [1:0] completion_client;
    wire [2:0] completion_slot, issue_slot;
    reg [1:0] admission_cursor, admission_client;
    reg admission_found;
    wire allocate = |accept_events;
    integer scan, index;

    assign cpl_ready = !rst;
    always @* begin
        req_ready = {CLIENTS{1'b0}};
        admission_found = 1'b0;
        admission_client = 2'b0;
        index = 0;
        for (scan = 0; scan < CLIENTS; scan = scan + 1) begin
            index = admission_cursor + scan;
            if (index >= CLIENTS) index = index - CLIENTS;
            if (!rst && admission_enable && free_valid && !admission_found &&
                client_enable[index] && space[index] && req_valid[index]) begin
                admission_found = 1'b1;
                admission_client = index;
                req_ready[index] = 1'b1;
            end
        end
    end
    always @(posedge clk) begin
        if (rst) admission_cursor <= 2'b0;
        else if (allocate)
            admission_cursor <= (admission_client == CLIENTS-1) ?
                2'd0 : admission_client + 2'd1;
    end

    tag_owner_pool #(.TAGS(TAGS)) owner_pool (
        .clk(clk), .rst(rst), .free_valid(free_valid), .free_tag(free_tag),
        .allocate(allocate), .allocate_client(admission_client),
        .allocate_slot(tail_slots[admission_client*3 +: 3]),
        .issue_fire(issue_fire), .issued_tag(issue_tag),
        .cpl_fire(cpl_valid && cpl_ready), .cpl_tag(cpl_tag),
        .completion_valid(completion_valid), .completion_client(completion_client),
        .completion_slot(completion_slot), .completion_errors(completion_errors),
        .owned_count(owned_count)
    );
    genvar client;
        for (client = 0; client < CLIENTS; client = client + 1) begin : clients
            assign issue_events[client] = issue_fire && issue_client == client;
            client_reorder #(.ROB_DEPTH(ROB_DEPTH)) reorder (
                .clk(clk), .rst(rst), .accept(accept_events[client]),
                .accept_id(req_id[client*16 +: 16]),
                .accept_data(req_data[client*32 +: 32]), .accept_tag(free_tag),
                .tail_slot(tail_slots[client*3 +: 3]), .space(space[client]),
                .occupancy(occupancies[client*3 +: 3]),
                .candidate_valid(candidate_valid[client]),
                .candidate_slot(candidate_slots[client*3 +: 3]),
                .candidate_tag(candidate_tags[client*7 +: 7]),
                .candidate_id(candidate_ids[client*16 +: 16]),
                .candidate_data(candidate_data[client*32 +: 32]),
                .issue_fire(issue_events[client]), .issue_slot(issue_slot),
                .complete(completion_valid && completion_client == client),
                .complete_slot(completion_slot), .complete_data(cpl_data),
                .rsp_valid(rsp_valid[client]), .rsp_ready(rsp_ready[client]),
                .rsp_id(rsp_id[client*16 +: 16]), .rsp_data(rsp_data[client*32 +: 32]),
                .retire_fire(retire_events[client])
            );
        end
    issue_reserver #(.CLIENTS(CLIENTS)) reservation (
        .clk(clk), .rst(rst), .selection_enable(selection_enable),
        .candidate_valid(candidate_valid), .candidate_slot(candidate_slots),
        .candidate_tag(candidate_tags), .candidate_id(candidate_ids),
        .candidate_data(candidate_data), .issue_valid(issue_valid),
        .issue_ready(issue_ready), .issue_client(issue_client), .issue_slot(issue_slot),
        .issue_tag(issue_tag), .issue_id(issue_id), .issue_data(issue_data),
        .issue_fire(issue_fire)
    );
    control_status #(.CLIENTS(CLIENTS)) status_control (
        .clk(clk), .rst(rst), .csr_valid(csr_valid), .csr_ready(csr_ready),
        .csr_write(csr_write), .csr_addr(csr_addr), .csr_wdata(csr_wdata),
        .csr_wstrb(csr_wstrb), .csr_rsp_valid(csr_rsp_valid),
        .csr_rsp_ready(csr_rsp_ready), .csr_rdata(csr_rdata), .csr_error(csr_error),
        .admission_enable(admission_enable), .selection_enable(selection_enable),
        .client_enable(client_enable), .accept_events(accept_events),
        .issue_events(issue_events), .retire_events(retire_events),
        .completion_event(completion_valid), .completion_errors(completion_errors),
        .owned_count(owned_count), .occupancies(occupancies),
        .reservation_valid(issue_valid), .irq(irq)
    );
        end
    endgenerate
endmodule
