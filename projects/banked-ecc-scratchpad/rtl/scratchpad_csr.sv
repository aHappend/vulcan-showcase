module scratchpad_csr #(
    parameter integer CLIENTS = 3,
    parameter integer BANKS = 2
) (
    input wire clk, rst,
    input wire csr_valid,
    output wire csr_ready,
    input wire csr_write,
    input wire [7:0] csr_addr,
    input wire [31:0] csr_wdata,
    input wire [3:0] csr_wstrb,
    output wire csr_rsp_valid,
    input wire csr_rsp_ready,
    output reg [31:0] csr_rdata,
    output reg csr_error,
    output wire [CLIENTS-1:0] client_enable,
    output wire scrub_enable,
    output wire maintenance_enable,
    output wire irq,
    input wire [2*CLIENTS-1:0] occupancy,
    input wire [BANKS-1:0] bank_busy,
    input wire maintenance_occupied,
    input wire [BANKS-1:0] scrub_busy,
    input wire [3:0] accepted_events,
    input wire [3:0] completed_events,
    input wire [3:0] corrected_events,
    input wire [3:0] uncorrectable_events,
    input wire [3:0] scrub_events,
    input wire invalid_event
);
    localparam [31:0] CLIENT_MASK = (1 << CLIENTS)-1;
    localparam [31:0] CONTROL_MASK = CLIENT_MASK | 32'h00000300;
    reg response;
    reg [31:0] control;
    reg [3:0] irq_mask, sticky;
    reg [31:0] accepted_count, completed_count, corrected_count;
    reg [31:0] uncorrectable_count, scrub_count;
    reg [31:0] snapshot, state_snapshot, byte_mask;
    reg access_error;
    wire transfer = csr_valid && csr_ready;
    wire [3:0] events = {transfer && access_error, invalid_event,
                        (uncorrectable_events != 0), (corrected_events != 0)};
    wire [3:0] clear_bits = (transfer && csr_write && !access_error &&
        (csr_addr == 8'h1c) && csr_wstrb[0]) ? csr_wdata[3:0] : 4'b0;
    assign csr_ready = !rst && !response;
    assign csr_rsp_valid = !rst && response;
    assign client_enable = control[CLIENTS-1:0];
    assign scrub_enable = control[8];
    assign maintenance_enable = control[9];
    assign irq = !rst && (|(sticky & irq_mask));
    integer c, b, lane;
    always @* begin
        byte_mask = 0;
        for (lane = 0; lane < 4; lane = lane + 1)
            if (csr_wstrb[lane]) byte_mask[8*lane +: 8] = 8'hff;
        state_snapshot = 0;
        for (c = 0; c < CLIENTS; c = c + 1)
            state_snapshot[2*c +: 2] = occupancy[2*c +: 2];
        for (b = 0; b < BANKS; b = b + 1) begin
            state_snapshot[8+b] = bank_busy[b];
            state_snapshot[16+b] = scrub_busy[b];
        end
        state_snapshot[12] = maintenance_occupied;
        snapshot = 0;
        access_error = 0;
        case (csr_addr)
            8'h00: snapshot = control;
            8'h04: begin snapshot = state_snapshot; access_error = csr_write; end
            8'h08: begin snapshot = accepted_count; access_error = csr_write; end
            8'h0c: begin snapshot = completed_count; access_error = csr_write; end
            8'h10: begin snapshot = corrected_count; access_error = csr_write; end
            8'h14: begin snapshot = uncorrectable_count; access_error = csr_write; end
            8'h18: begin snapshot = scrub_count; access_error = csr_write; end
            8'h1c: snapshot = {28'b0, sticky};
            8'h20: snapshot = {28'b0, irq_mask};
            default: access_error = 1;
        endcase
        if (access_error || csr_write) snapshot = 0;
    end
    always @(posedge clk) begin
        if (rst) begin
            response <= 0;
            csr_rdata <= 0;
            csr_error <= 0;
            control <= CLIENT_MASK;
            irq_mask <= 0;
            sticky <= 0;
            accepted_count <= 0;
            completed_count <= 0;
            corrected_count <= 0;
            uncorrectable_count <= 0;
            scrub_count <= 0;
        end else begin
            accepted_count <= accepted_count + accepted_events;
            completed_count <= completed_count + completed_events;
            corrected_count <= corrected_count + corrected_events;
            uncorrectable_count <= uncorrectable_count + uncorrectable_events;
            scrub_count <= scrub_count + scrub_events;
            sticky <= (sticky & ~clear_bits) | events;
            if (csr_rsp_valid && csr_rsp_ready) response <= 0;
            if (transfer) begin
                response <= 1;
                csr_rdata <= snapshot;
                csr_error <= access_error;
                if (csr_write && !access_error) begin
                    if (csr_addr == 8'h00)
                        control <= ((control & ~byte_mask) |
                                    (csr_wdata & byte_mask)) & CONTROL_MASK;
                    if ((csr_addr == 8'h20) && csr_wstrb[0])
                        irq_mask <= csr_wdata[3:0];
                end
            end
        end
    end
endmodule
