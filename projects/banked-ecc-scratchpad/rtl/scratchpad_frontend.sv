module scratchpad_frontend #(
    parameter integer CLIENTS = 3,
    parameter integer BANKS = 2,
    parameter integer ROWS = 5
) (
    input wire clk, rst,
    input wire [CLIENTS-1:0] client_enable,
    input wire [CLIENTS-1:0] req_valid,
    output wire [CLIENTS-1:0] req_ready,
    input wire [2*CLIENTS-1:0] req_op,
    input wire [16*CLIENTS-1:0] req_addr,
    input wire [8*CLIENTS-1:0] req_id,
    input wire [32*CLIENTS-1:0] req_wdata,
    input wire [4*CLIENTS-1:0] req_wstrb,
    output wire [CLIENTS-1:0] rsp_valid,
    input wire [CLIENTS-1:0] rsp_ready,
    output wire [8*CLIENTS-1:0] rsp_id,
    output wire [32*CLIENTS-1:0] rsp_rdata,
    output wire [2*CLIENTS-1:0] rsp_status,
    output wire [CLIENTS-1:0] rsp_corrected,
    output wire [2*CLIENTS-1:0] occupancy,
    output wire invalid_event,
    input wire [BANKS-1:0] bank_busy,
    input wire [BANKS-1:0] maintenance_eligible,
    input wire scrub_enable,
    output reg [BANKS-1:0] bank_grant,
    output reg [2*BANKS-1:0] bank_class,
    output reg [3*BANKS-1:0] bank_owner,
    output reg [3*BANKS-1:0] client_row,
    output reg [BANKS-1:0] client_write,
    output reg [32*BANKS-1:0] client_wdata,
    output reg [4*BANKS-1:0] client_wstrb,
    input wire [BANKS-1:0] bank_done,
    input wire [2*BANKS-1:0] done_class,
    input wire [3*BANKS-1:0] done_owner,
    input wire [32*BANKS-1:0] done_data,
    input wire [2*BANKS-1:0] done_status,
    input wire [BANKS-1:0] done_corrected
);
    localparam integer SLOTS = 2*CLIENTS;
    // Independently addressed ownership slots are registers, not shared-port RAM.
    (* mem2reg *) reg [1:0] slot_state [0:SLOTS-1];
    (* mem2reg *) reg [7:0] slot_id [0:SLOTS-1];
    (* mem2reg *) reg [15:0] slot_addr [0:SLOTS-1];
    (* mem2reg *) reg slot_write [0:SLOTS-1];
    (* mem2reg *) reg [31:0] slot_wdata [0:SLOTS-1];
    (* mem2reg *) reg [3:0] slot_wstrb [0:SLOTS-1];
    (* mem2reg *) reg [31:0] slot_result [0:SLOTS-1];
    (* mem2reg *) reg [1:0] slot_status [0:SLOTS-1];
    (* mem2reg *) reg slot_corrected [0:SLOTS-1];
    reg [CLIENTS-1:0] head, tail;
    reg [1:0] count [0:CLIENTS-1];
    reg [1:0] class_pointer [0:BANKS-1];
    reg [1:0] client_pointer [0:BANKS-1];
    wire [CLIENTS-1:0] invalid_accept;
    genvar g;
    generate for (g = 0; g < CLIENTS; g = g + 1) begin: client_outputs
        wire [2:0] oldest = 2*g + head[g];
        assign req_ready[g] = !rst && client_enable[g] && (count[g] < 2);
        assign rsp_valid[g] = !rst && (count[g] != 0) &&
                              (slot_state[oldest] == 3);
        assign rsp_id[8*g +: 8] = slot_id[oldest];
        assign rsp_rdata[32*g +: 32] = slot_result[oldest];
        assign rsp_status[2*g +: 2] = slot_status[oldest];
        assign rsp_corrected[g] = slot_corrected[oldest];
        assign occupancy[2*g +: 2] = count[g];
        assign invalid_accept[g] = req_valid[g] && req_ready[g] &&
            ((req_op[2*g +: 2] > 1) || (req_addr[16*g +: 16] >= BANKS*ROWS));
    end endgenerate
    assign invalid_event = |invalid_accept;

    integer b, offset, co, cc, candidate, first, second, selected;
    always @* begin
        bank_grant = 0;
        bank_class = 0;
        bank_owner = 0;
        client_row = 0;
        client_write = 0;
        client_wdata = 0;
        client_wstrb = 0;
        offset = 0;
        co = 0;
        cc = 0;
        candidate = 0;
        first = 0;
        second = 0;
        selected = -1;
        for (b = 0; b < BANKS; b = b + 1) begin
            if (!rst && !bank_busy[b]) begin
                for (offset = 0; offset < 3; offset = offset + 1) begin
                    cc = class_pointer[b] + offset;
                    if (cc >= 3) cc = cc - 3;
                    if (!bank_grant[b]) begin
                        if (cc == 0) begin
                            for (co = 0; co < CLIENTS; co = co + 1) begin
                                candidate = client_pointer[b] + co;
                                if (candidate >= CLIENTS) candidate = candidate - CLIENTS;
                                first = 2*candidate + head[candidate];
                                second = 2*candidate + (1-head[candidate]);
                                selected = -1;
                                if ((slot_state[first] == 1) &&
                                    ((slot_addr[first] % BANKS) == b))
                                    selected = first;
                                else if ((slot_state[second] == 1) &&
                                         ((slot_addr[second] % BANKS) == b))
                                    selected = second;
                                if (!bank_grant[b] && (selected >= 0)) begin
                                    bank_grant[b] = 1;
                                    bank_class[2*b +: 2] = 0;
                                    bank_owner[3*b +: 3] = selected;
                                    client_row[3*b +: 3] = slot_addr[selected] / BANKS;
                                    client_write[b] = slot_write[selected];
                                    client_wdata[32*b +: 32] = slot_wdata[selected];
                                    client_wstrb[4*b +: 4] = slot_wstrb[selected];
                                end
                            end
                        end else if ((cc == 1) && maintenance_eligible[b]) begin
                            bank_grant[b] = 1;
                            bank_class[2*b +: 2] = 1;
                        end else if ((cc == 2) && scrub_enable) begin
                            bank_grant[b] = 1;
                            bank_class[2*b +: 2] = 2;
                        end
                    end
                end
            end
        end
    end

    integer c, s, bank, owner;
    always @(posedge clk) begin
        if (rst) begin
            head <= 0;
            tail <= 0;
            for (c = 0; c < CLIENTS; c = c + 1) count[c] <= 0;
            for (s = 0; s < SLOTS; s = s + 1) begin
                slot_state[s] <= 0;
                slot_id[s] <= 0;
                slot_addr[s] <= 0;
                slot_write[s] <= 0;
                slot_wdata[s] <= 0;
                slot_wstrb[s] <= 0;
                slot_result[s] <= 0;
                slot_status[s] <= 0;
                slot_corrected[s] <= 0;
            end
            for (bank = 0; bank < BANKS; bank = bank + 1) begin
                class_pointer[bank] <= 0;
                client_pointer[bank] <= 0;
            end
        end else begin
            for (c = 0; c < CLIENTS; c = c + 1) begin
                case ({req_valid[c] && req_ready[c], rsp_valid[c] && rsp_ready[c]})
                    2'b10: count[c] <= count[c] + 1'b1;
                    2'b01: count[c] <= count[c] - 1'b1;
                    default: count[c] <= count[c];
                endcase
                if (rsp_valid[c] && rsp_ready[c]) begin
                    slot_state[2*c + head[c]] <= 0;
                    head[c] <= ~head[c];
                end
                if (req_valid[c] && req_ready[c]) begin
                    s = 2*c + tail[c];
                    tail[c] <= ~tail[c];
                    slot_id[s] <= req_id[8*c +: 8];
                    slot_addr[s] <= req_addr[16*c +: 16];
                    slot_write[s] <= (req_op[2*c +: 2] == 1);
                    slot_wdata[s] <= req_wdata[32*c +: 32];
                    slot_wstrb[s] <= req_wstrb[4*c +: 4];
                    slot_result[s] <= 0;
                    slot_corrected[s] <= 0;
                    if (req_op[2*c +: 2] > 1) begin
                        slot_state[s] <= 3;
                        slot_status[s] <= 3;
                    end else if (req_addr[16*c +: 16] >= BANKS*ROWS) begin
                        slot_state[s] <= 3;
                        slot_status[s] <= 2;
                    end else begin
                        slot_state[s] <= 1;
                        slot_status[s] <= 0;
                    end
                end
            end
            for (bank = 0; bank < BANKS; bank = bank + 1) begin
                if (bank_grant[bank]) begin
                    class_pointer[bank] <= (bank_class[2*bank +: 2] == 2) ?
                        2'd0 : bank_class[2*bank +: 2] + 1'b1;
                    if (bank_class[2*bank +: 2] == 0) begin
                        owner = bank_owner[3*bank +: 3];
                        slot_state[owner] <= 2;
                        client_pointer[bank] <= ((owner / 2) == CLIENTS-1) ?
                            0 : (owner / 2) + 1;
                    end
                end
                if (bank_done[bank] && (done_class[2*bank +: 2] == 0)) begin
                    owner = done_owner[3*bank +: 3];
                    slot_state[owner] <= 3;
                    slot_result[owner] <= done_data[32*bank +: 32];
                    slot_status[owner] <= done_status[2*bank +: 2];
                    slot_corrected[owner] <= done_corrected[bank];
                end
            end
        end
    end
endmodule
