module scratchpad_maintenance #(
    parameter integer BANKS = 2,
    parameter integer ROWS = 5
) (
    input wire clk, rst,
    input wire maintenance_enable,
    input wire maint_valid,
    output wire maint_ready,
    input wire [15:0] maint_addr,
    input wire [38:0] maint_mask,
    output wire maint_rsp_valid,
    input wire maint_rsp_ready,
    output reg [1:0] maint_rsp_status,
    output reg occupied,
    output wire invalid_event,
    output wire [BANKS-1:0] eligible,
    output wire [2:0] maintenance_row,
    output wire [38:0] maintenance_mask,
    output wire [3*BANKS-1:0] scrub_rows,
    input wire [BANKS-1:0] bank_grant,
    input wire [2*BANKS-1:0] bank_class,
    input wire [BANKS-1:0] bank_done,
    input wire [2*BANKS-1:0] done_class
);
    reg pending, response;
    reg [15:0] address;
    reg [38:0] mask;
    reg [2:0] cursor [0:BANKS-1];
    assign maint_ready = !rst && maintenance_enable && !occupied;
    assign maint_rsp_valid = !rst && response;
    assign invalid_event = maint_valid && maint_ready && (maint_addr >= BANKS*ROWS);
    assign maintenance_row = address / BANKS;
    assign maintenance_mask = mask;
    genvar g;
    generate for (g = 0; g < BANKS; g = g + 1) begin: bank_cursors
        assign eligible[g] = pending && ((address % BANKS) == g);
        assign scrub_rows[3*g +: 3] = cursor[g];
    end endgenerate
    integer b;
    always @(posedge clk) begin
        if (rst) begin
            occupied <= 0;
            pending <= 0;
            response <= 0;
            address <= 0;
            mask <= 0;
            maint_rsp_status <= 0;
            for (b = 0; b < BANKS; b = b + 1) cursor[b] <= 0;
        end else begin
            if (maint_rsp_valid && maint_rsp_ready) begin
                occupied <= 0;
                response <= 0;
            end
            if (maint_valid && maint_ready) begin
                occupied <= 1;
                address <= maint_addr;
                mask <= maint_mask;
                maint_rsp_status <= (maint_addr >= BANKS*ROWS) ? 2'd2 : 2'd0;
                pending <= (maint_addr < BANKS*ROWS);
                response <= (maint_addr >= BANKS*ROWS);
            end
            for (b = 0; b < BANKS; b = b + 1) begin
                if (bank_grant[b] && (bank_class[2*b +: 2] == 1))
                    pending <= 0;
                if (bank_done[b] && (done_class[2*b +: 2] == 1))
                    response <= 1;
                if (bank_done[b] && (done_class[2*b +: 2] == 2))
                    cursor[b] <= (cursor[b] == ROWS-1) ? 3'd0 : cursor[b] + 1'b1;
            end
        end
    end
endmodule
