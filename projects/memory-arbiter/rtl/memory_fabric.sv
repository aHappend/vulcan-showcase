module memory_fabric #(
    parameter integer CLIENTS = 3,
    parameter integer BANKS = 2,
    parameter integer SLOTS = 2
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire [CLIENTS-1:0]       c_req_valid,
    output wire [CLIENTS-1:0]       c_req_ready,
    input  wire [8*CLIENTS-1:0]     c_req_tag,
    input  wire [CLIENTS-1:0]       c_req_write,
    input  wire [16*CLIENTS-1:0]    c_req_addr,
    input  wire [32*CLIENTS-1:0]    c_req_wdata,
    input  wire [4*CLIENTS-1:0]     c_req_wstrb,
    output wire [CLIENTS-1:0]       c_rsp_valid,
    input  wire [CLIENTS-1:0]       c_rsp_ready,
    output wire [8*CLIENTS-1:0]     c_rsp_tag,
    output wire [32*CLIENTS-1:0]    c_rsp_rdata,
    output wire [CLIENTS-1:0]       c_rsp_error,
    output wire [BANKS-1:0]         b_req_valid,
    input  wire [BANKS-1:0]         b_req_ready,
    output wire [BANKS-1:0]         b_req_write,
    output wire [16*BANKS-1:0]      b_req_addr,
    output wire [32*BANKS-1:0]      b_req_wdata,
    output wire [4*BANKS-1:0]       b_req_wstrb,
    input  wire [BANKS-1:0]         b_rsp_valid,
    output wire [BANKS-1:0]         b_rsp_ready,
    input  wire [32*BANKS-1:0]      b_rsp_rdata,
    input  wire [BANKS-1:0]         b_rsp_error,
    input  wire                     csr_req_valid,
    output wire                     csr_req_ready,
    input  wire                     csr_req_write,
    input  wire [15:0]              csr_req_addr,
    input  wire [31:0]              csr_req_wdata,
    input  wire [3:0]               csr_req_wstrb,
    output wire                     csr_rsp_valid,
    input  wire                     csr_rsp_ready,
    output wire [31:0]              csr_rsp_rdata,
    output wire                     csr_rsp_error,
    output wire                     irq
);
    localparam integer CLIENT_W = (CLIENTS > 1) ? $clog2(CLIENTS) : 1;
    localparam integer SLOT_W = (SLOTS > 1) ? $clog2(SLOTS) : 1;
    localparam integer COMPLETE_PORTS = BANKS + 1;

    wire [CLIENTS-1:0] admit, head_valid, head_write, aligned, target_bank;
    wire [CLIENTS-1:0] local_complete, pop;
    wire [CLIENTS*SLOT_W-1:0] allocation_slot, head_slot;
    wire [CLIENTS*16-1:0] head_addr;
    wire [CLIENTS*32-1:0] head_wdata, occupancy;
    wire [CLIENTS*4-1:0] head_wstrb;
    wire [CLIENTS*2-1:0] complete_inc, error_inc;
    wire [BANKS*CLIENTS-1:0] bank_grant;
    wire [BANKS-1:0] issue_locked, owner_busy, bank_commit, bank_store, bank_error;
    wire [BANKS*CLIENT_W-1:0] commit_client, store_client;
    wire [BANKS*SLOT_W-1:0] commit_slot, store_slot;
    wire [BANKS*32-1:0] store_data;
    wire [BANKS*3-1:0] bank_state;

    assign admit = c_req_valid & c_req_ready;
    assign local_complete = head_valid & ~aligned;

    genvar c, b;
    generate
        for (c = 0; c < CLIENTS; c = c + 1) begin : clients
            wire [COMPLETE_PORTS-1:0] completion_valid, completion_error;
            wire [COMPLETE_PORTS*SLOT_W-1:0] completion_slot;
            wire [COMPLETE_PORTS*32-1:0] completion_data;

            mf_client_queue #(.SLOTS(SLOTS), .SLOT_W(SLOT_W)) queue (
                .clk(clk), .rst(rst), .push(admit[c]),
                .push_slot(allocation_slot[c*SLOT_W +: SLOT_W]),
                .push_write(c_req_write[c]), .push_addr(c_req_addr[c*16 +: 16]),
                .push_wdata(c_req_wdata[c*32 +: 32]), .push_wstrb(c_req_wstrb[c*4 +: 4]),
                .pop(pop[c]), .head_valid(head_valid[c]),
                .head_slot(head_slot[c*SLOT_W +: SLOT_W]), .head_write(head_write[c]),
                .head_addr(head_addr[c*16 +: 16]), .head_wdata(head_wdata[c*32 +: 32]),
                .head_wstrb(head_wstrb[c*4 +: 4])
            );

            mf_bank_decode #(.BANKS(BANKS)) decode (
                .addr(head_addr[c*16 +: 16]), .aligned(aligned[c]), .bank(target_bank[c])
            );

            assign completion_valid[BANKS] = local_complete[c];
            assign completion_error[BANKS] = local_complete[c];
            assign completion_slot[BANKS*SLOT_W +: SLOT_W] = head_slot[c*SLOT_W +: SLOT_W];
            assign completion_data[BANKS*32 +: 32] = 32'b0;
            for (b = 0; b < BANKS; b = b + 1) begin : bank_completions
                assign completion_valid[b] = bank_store[b] &&
                    (store_client[b*CLIENT_W +: CLIENT_W] == c);
                assign completion_error[b] = bank_error[b];
                assign completion_slot[b*SLOT_W +: SLOT_W] = store_slot[b*SLOT_W +: SLOT_W];
                assign completion_data[b*32 +: 32] = store_data[b*32 +: 32];
            end
            if (BANKS == 1) begin : one_bank_events
                assign pop[c] = local_complete[c] | bank_grant[c];
                assign complete_inc[c*2 +: 2] =
                    {1'b0, completion_valid[0]} + {1'b0, completion_valid[1]};
                assign error_inc[c*2 +: 2] =
                    {1'b0, (completion_valid[0] & completion_error[0])} +
                    {1'b0, (completion_valid[1] & completion_error[1])};
            end else begin : two_bank_events
                assign pop[c] = local_complete[c] | bank_grant[c] | bank_grant[CLIENTS+c];
                assign complete_inc[c*2 +: 2] =
                    {1'b0, completion_valid[0]} + {1'b0, completion_valid[1]} +
                    {1'b0, completion_valid[2]};
                assign error_inc[c*2 +: 2] =
                    {1'b0, (completion_valid[0] & completion_error[0])} +
                    {1'b0, (completion_valid[1] & completion_error[1])} +
                    {1'b0, (completion_valid[2] & completion_error[2])};
            end

            mf_completion #(.SLOTS(SLOTS), .PORTS(COMPLETE_PORTS), .SLOT_W(SLOT_W)) completion (
                .clk(clk), .rst(rst), .admit(admit[c]), .admit_tag(c_req_tag[c*8 +: 8]),
                .admission_ready(c_req_ready[c]),
                .allocation_slot(allocation_slot[c*SLOT_W +: SLOT_W]),
                .complete_valid(completion_valid), .complete_slot(completion_slot),
                .complete_data(completion_data), .complete_error(completion_error),
                .rsp_valid(c_rsp_valid[c]), .rsp_ready(c_rsp_ready[c]),
                .rsp_tag(c_rsp_tag[c*8 +: 8]), .rsp_rdata(c_rsp_rdata[c*32 +: 32]),
                .rsp_error(c_rsp_error[c]), .occupancy(occupancy[c*32 +: 32])
            );
        end

        for (b = 0; b < BANKS; b = b + 1) begin : banks
            wire [CLIENTS-1:0] eligible;
            wire [CLIENT_W-1:0] winner;
            wire selected;
            for (c = 0; c < CLIENTS; c = c + 1) begin : eligibility
                assign eligible[c] = head_valid[c] && aligned[c] && (target_bank[c] == b);
            end
            assign bank_state[b*3 +: 3] =
                {owner_busy[b], issue_locked[b], (issue_locked[b] | owner_busy[b])};

            mf_rr_arbiter #(.CLIENTS(CLIENTS), .CLIENT_W(CLIENT_W)) arbiter (
                .clk(clk), .rst(rst), .available(!issue_locked[b] && !owner_busy[b]),
                .eligible(eligible), .grant(bank_grant[b*CLIENTS +: CLIENTS]),
                .winner(winner), .selected(selected)
            );
            mf_bank_issue #(.CLIENT_W(CLIENT_W), .SLOT_W(SLOT_W)) issue (
                .clk(clk), .rst(rst), .select_valid(selected), .select_client(winner),
                .select_slot(head_slot[winner*SLOT_W +: SLOT_W]),
                .select_write(head_write[winner]), .select_addr(head_addr[winner*16 +: 16]),
                .select_wdata(head_wdata[winner*32 +: 32]),
                .select_wstrb(head_wstrb[winner*4 +: 4]), .locked(issue_locked[b]),
                .req_valid(b_req_valid[b]), .req_ready(b_req_ready[b]),
                .req_write(b_req_write[b]), .req_addr(b_req_addr[b*16 +: 16]),
                .req_wdata(b_req_wdata[b*32 +: 32]), .req_wstrb(b_req_wstrb[b*4 +: 4]),
                .commit(bank_commit[b]), .commit_client(commit_client[b*CLIENT_W +: CLIENT_W]),
                .commit_slot(commit_slot[b*SLOT_W +: SLOT_W])
            );
            mf_response_owner #(.CLIENT_W(CLIENT_W), .SLOT_W(SLOT_W)) owner (
                .clk(clk), .rst(rst), .commit(bank_commit[b]),
                .commit_client(commit_client[b*CLIENT_W +: CLIENT_W]),
                .commit_slot(commit_slot[b*SLOT_W +: SLOT_W]), .commit_write(b_req_write[b]),
                .awaiting(owner_busy[b]), .rsp_valid(b_rsp_valid[b]), .rsp_ready(b_rsp_ready[b]),
                .rsp_rdata(b_rsp_rdata[b*32 +: 32]), .rsp_error(b_rsp_error[b]),
                .store(bank_store[b]), .store_client(store_client[b*CLIENT_W +: CLIENT_W]),
                .store_slot(store_slot[b*SLOT_W +: SLOT_W]), .store_data(store_data[b*32 +: 32]),
                .store_error(bank_error[b])
            );
        end
    endgenerate

    mf_csr #(.CLIENTS(CLIENTS), .BANKS(BANKS), .SLOTS(SLOTS)) csr (
        .clk(clk), .rst(rst), .req_valid(csr_req_valid), .req_ready(csr_req_ready),
        .req_write(csr_req_write), .req_addr(csr_req_addr), .req_wdata(csr_req_wdata),
        .req_wstrb(csr_req_wstrb), .rsp_valid(csr_rsp_valid), .rsp_ready(csr_rsp_ready),
        .rsp_rdata(csr_rsp_rdata), .rsp_error(csr_rsp_error), .irq(irq),
        .client_admit(admit), .client_complete_inc(complete_inc), .client_error_inc(error_inc),
        .client_occupancy(occupancy), .bank_issue(bank_commit), .bank_complete(bank_store),
        .bank_error(bank_error), .bank_state(bank_state),
        .invalid_request_event(|local_complete)
    );
endmodule
