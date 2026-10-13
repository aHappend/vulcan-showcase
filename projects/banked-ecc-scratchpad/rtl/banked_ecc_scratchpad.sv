module banked_ecc_scratchpad #(
    parameter integer CLIENTS = 3,
    parameter integer BANKS = 2,
    parameter integer ROWS = 5
) (
    input wire clk, rst,
    input wire [((CLIENTS > 0) ? CLIENTS : 1)-1:0] req_valid,
    output wire [((CLIENTS > 0) ? CLIENTS : 1)-1:0] req_ready,
    input wire [2*((CLIENTS > 0) ? CLIENTS : 1)-1:0] req_op,
    input wire [16*((CLIENTS > 0) ? CLIENTS : 1)-1:0] req_addr,
    input wire [8*((CLIENTS > 0) ? CLIENTS : 1)-1:0] req_id,
    input wire [32*((CLIENTS > 0) ? CLIENTS : 1)-1:0] req_wdata,
    input wire [4*((CLIENTS > 0) ? CLIENTS : 1)-1:0] req_wstrb,
    output wire [((CLIENTS > 0) ? CLIENTS : 1)-1:0] rsp_valid,
    input wire [((CLIENTS > 0) ? CLIENTS : 1)-1:0] rsp_ready,
    output wire [8*((CLIENTS > 0) ? CLIENTS : 1)-1:0] rsp_id,
    output wire [32*((CLIENTS > 0) ? CLIENTS : 1)-1:0] rsp_rdata,
    output wire [2*((CLIENTS > 0) ? CLIENTS : 1)-1:0] rsp_status,
    output wire [((CLIENTS > 0) ? CLIENTS : 1)-1:0] rsp_corrected,
    input wire maint_valid,
    output wire maint_ready,
    input wire [15:0] maint_addr,
    input wire [38:0] maint_mask,
    output wire maint_rsp_valid,
    input wire maint_rsp_ready,
    output wire [1:0] maint_rsp_status,
    input wire csr_valid,
    output wire csr_ready,
    input wire csr_write,
    input wire [7:0] csr_addr,
    input wire [31:0] csr_wdata,
    input wire [3:0] csr_wstrb,
    output wire csr_rsp_valid,
    input wire csr_rsp_ready,
    output wire [31:0] csr_rdata,
    output wire csr_error,
    output wire irq,
    output wire [((BANKS > 0) ? BANKS : 1)-1:0] bank_busy
);
    generate
        if ((CLIENTS < 1) || (CLIENTS > 4) ||
            (BANKS < 1) || (BANKS > 4) || (ROWS < 1) || (ROWS > 8)) begin: invalid_parameters
`ifndef SYNTHESIS
            initial begin
                if ((CLIENTS < 1) || (CLIENTS > 4))
                    $fatal(1, "PARAMETER ERROR: CLIENTS legal range 1..4");
                if ((BANKS < 1) || (BANKS > 4))
                    $fatal(1, "PARAMETER ERROR: BANKS legal range 1..4");
                if ((ROWS < 1) || (ROWS > 8))
                    $fatal(1, "PARAMETER ERROR: ROWS legal range 1..8");
            end
`endif
            assign req_ready = 0;
            assign rsp_valid = 0;
            assign rsp_id = 0;
            assign rsp_rdata = 0;
            assign rsp_status = 0;
            assign rsp_corrected = 0;
            assign maint_ready = 0;
            assign maint_rsp_valid = 0;
            assign maint_rsp_status = 0;
            assign csr_ready = 0;
            assign csr_rsp_valid = 0;
            assign csr_rdata = 0;
            assign csr_error = 0;
            assign irq = 0;
            assign bank_busy = 0;
        end else begin: legal
            wire [CLIENTS-1:0] client_enable;
            wire scrub_enable, maintenance_enable;
            wire [2*CLIENTS-1:0] occupancy;
            wire client_invalid, maintenance_invalid, maintenance_occupied;
            wire [BANKS-1:0] busy, grant, done, maintenance_eligible;
            wire [2*BANKS-1:0] service_class, done_class;
            wire [3*BANKS-1:0] service_owner, done_owner, client_row, scrub_rows;
            wire [BANKS-1:0] client_write, done_corrected;
            wire [32*BANKS-1:0] client_wdata, done_data;
            wire [4*BANKS-1:0] client_wstrb;
            wire [2*BANKS-1:0] done_status;
            wire [2:0] maintenance_row;
            wire [38:0] maintenance_mask;
            wire [BANKS-1:0] correction_events, uncorrectable_events, scrub_events, scrub_busy;
            reg [3:0] accepted_sum, completed_sum, corrected_sum, uncorrectable_sum, scrub_sum;
            assign bank_busy = rst ? {BANKS{1'b0}} : busy;

            scratchpad_frontend #(.CLIENTS(CLIENTS), .BANKS(BANKS), .ROWS(ROWS)) frontend (
                .clk(clk), .rst(rst), .client_enable(client_enable),
                .req_valid(req_valid), .req_ready(req_ready), .req_op(req_op),
                .req_addr(req_addr), .req_id(req_id), .req_wdata(req_wdata),
                .req_wstrb(req_wstrb), .rsp_valid(rsp_valid), .rsp_ready(rsp_ready),
                .rsp_id(rsp_id), .rsp_rdata(rsp_rdata), .rsp_status(rsp_status),
                .rsp_corrected(rsp_corrected), .occupancy(occupancy),
                .invalid_event(client_invalid), .bank_busy(busy),
                .maintenance_eligible(maintenance_eligible), .scrub_enable(scrub_enable),
                .bank_grant(grant), .bank_class(service_class), .bank_owner(service_owner),
                .client_row(client_row), .client_write(client_write),
                .client_wdata(client_wdata), .client_wstrb(client_wstrb),
                .bank_done(done), .done_class(done_class), .done_owner(done_owner),
                .done_data(done_data), .done_status(done_status), .done_corrected(done_corrected)
            );
            scratchpad_maintenance #(.BANKS(BANKS), .ROWS(ROWS)) maintenance (
                .clk(clk), .rst(rst), .maintenance_enable(maintenance_enable),
                .maint_valid(maint_valid), .maint_ready(maint_ready),
                .maint_addr(maint_addr), .maint_mask(maint_mask),
                .maint_rsp_valid(maint_rsp_valid), .maint_rsp_ready(maint_rsp_ready),
                .maint_rsp_status(maint_rsp_status), .occupied(maintenance_occupied),
                .invalid_event(maintenance_invalid), .eligible(maintenance_eligible),
                .maintenance_row(maintenance_row), .maintenance_mask(maintenance_mask),
                .scrub_rows(scrub_rows), .bank_grant(grant), .bank_class(service_class),
                .bank_done(done), .done_class(done_class)
            );
            scratchpad_csr #(.CLIENTS(CLIENTS), .BANKS(BANKS)) csr (
                .clk(clk), .rst(rst), .csr_valid(csr_valid), .csr_ready(csr_ready),
                .csr_write(csr_write), .csr_addr(csr_addr), .csr_wdata(csr_wdata),
                .csr_wstrb(csr_wstrb), .csr_rsp_valid(csr_rsp_valid),
                .csr_rsp_ready(csr_rsp_ready), .csr_rdata(csr_rdata), .csr_error(csr_error),
                .client_enable(client_enable), .scrub_enable(scrub_enable),
                .maintenance_enable(maintenance_enable), .irq(irq),
                .occupancy(occupancy), .bank_busy(busy),
                .maintenance_occupied(maintenance_occupied), .scrub_busy(scrub_busy),
                .accepted_events(accepted_sum), .completed_events(completed_sum),
                .corrected_events(corrected_sum), .uncorrectable_events(uncorrectable_sum),
                .scrub_events(scrub_sum), .invalid_event(client_invalid | maintenance_invalid)
            );
            for (genvar b = 0; b < BANKS; b = b + 1) begin: banks
                wire [1:0] selected_class = service_class[2*b +: 2];
                wire [2:0] selected_row = (selected_class == 0) ?
                    client_row[3*b +: 3] : ((selected_class == 1) ?
                    maintenance_row : scrub_rows[3*b +: 3]);
                scratchpad_bank #(.ROWS(ROWS)) bank (
                    .clk(clk), .rst(rst), .grant(grant[b]),
                    .service_class(selected_class), .service_owner(service_owner[3*b +: 3]),
                    .service_row(selected_row), .service_write(client_write[b]),
                    .service_wdata(client_wdata[32*b +: 32]),
                    .service_wstrb(client_wstrb[4*b +: 4]), .service_mask(maintenance_mask),
                    .busy(busy[b]), .done(done[b]), .done_class(done_class[2*b +: 2]),
                    .done_owner(done_owner[3*b +: 3]), .done_data(done_data[32*b +: 32]),
                    .done_status(done_status[2*b +: 2]), .done_corrected(done_corrected[b]),
                    .correction_event(correction_events[b]),
                    .uncorrectable_event(uncorrectable_events[b]),
                    .scrub_event(scrub_events[b]), .scrub_busy(scrub_busy[b])
                );
            end
            integer i;
            always @* begin
                accepted_sum = 0;
                completed_sum = 0;
                corrected_sum = 0;
                uncorrectable_sum = 0;
                scrub_sum = 0;
                for (i = 0; i < CLIENTS; i = i + 1) begin
                    accepted_sum = accepted_sum + (req_valid[i] && req_ready[i]);
                    completed_sum = completed_sum + (rsp_valid[i] && rsp_ready[i]);
                end
                for (i = 0; i < BANKS; i = i + 1) begin
                    corrected_sum = corrected_sum + correction_events[i];
                    uncorrectable_sum = uncorrectable_sum + uncorrectable_events[i];
                    scrub_sum = scrub_sum + scrub_events[i];
                end
            end
        end
    endgenerate
endmodule
