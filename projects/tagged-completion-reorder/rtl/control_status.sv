module control_status #(
    parameter integer CLIENTS = 3
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
    output reg [1:0] csr_error,
    output wire admission_enable, selection_enable,
    output reg [CLIENTS-1:0] client_enable,
    input wire [CLIENTS-1:0] accept_events, issue_events, retire_events,
    input wire completion_event,
    input wire [3:0] completion_errors,
    input wire [4:0] owned_count,
    input wire [CLIENTS*3-1:0] occupancies,
    input wire reservation_valid,
    output wire irq
);
    reg [1:0] control;
    reg [4:0] irq_mask, sticky;
    reg response_valid;
    reg [31:0] accepted, issued, completed, retired, errors;
    reg [31:0] client_accepted [0:CLIENTS-1];
    reg [31:0] client_issued [0:CLIENTS-1];
    reg [31:0] client_retired [0:CLIENTS-1];
    reg [31:0] read_data, allowed_mask, byte_mask;
    reg address_valid, writable;
    reg [1:0] request_error;
    reg [4:0] clear_mask;
    reg [4:0] total_occupancy;
    reg [2:0] accept_count, issue_count, retire_count;
    wire csr_fire = csr_valid && csr_ready;
    wire csr_error_event = csr_fire && (request_error != 0);
    wire [4:0] error_events = {csr_error_event, completion_errors};
    wire [1:0] error_count = {1'b0, |completion_errors} +
                                  {1'b0, csr_error_event};
    integer client, byte_index, reset_index;

    assign admission_enable = control[0];
    assign selection_enable = control[1];
    assign csr_ready = !rst && (!response_valid || csr_rsp_ready);
    assign csr_rsp_valid = !rst && response_valid;
    assign irq = |(sticky & irq_mask);

    always @* begin
        total_occupancy = 5'b0;
        accept_count = 3'b0;
        issue_count = 3'b0;
        retire_count = 3'b0;
        for (client = 0; client < CLIENTS; client = client + 1) begin
            total_occupancy = total_occupancy + occupancies[client*3 +: 3];
            accept_count = accept_count + accept_events[client];
            issue_count = issue_count + issue_events[client];
            retire_count = retire_count + retire_events[client];
        end
        byte_mask = 32'b0;
        for (byte_index = 0; byte_index < 4; byte_index = byte_index + 1)
            byte_mask[byte_index*8 +: 8] = {8{csr_wstrb[byte_index]}};
        read_data = 32'b0;
        allowed_mask = 32'b0;
        address_valid = 1'b1;
        writable = 1'b0;
        case (csr_addr)
            8'h00: begin
                read_data = {30'b0, control};
                writable = 1'b1;
                allowed_mask = 32'h00000003;
            end
            8'h04: begin
                read_data = {{(32-CLIENTS){1'b0}}, client_enable};
                writable = 1'b1;
                allowed_mask = (32'h1 << CLIENTS) - 1;
            end
            8'h08: begin
                read_data = {27'b0, irq_mask};
                writable = 1'b1;
                allowed_mask = 32'h0000001f;
            end
            8'h0c: begin
                read_data = {27'b0, sticky};
                writable = 1'b1;
                allowed_mask = 32'h0000001f;
            end
            8'h10: read_data = {15'b0, reservation_valid, 3'b0,
                               total_occupancy, 3'b0, owned_count};
            8'h14: read_data = accepted;
            8'h18: read_data = issued;
            8'h1c: read_data = completed;
            8'h20: read_data = retired;
            8'h24: read_data = errors;
            default: begin
                address_valid = 1'b0;
                for (client = 0; client < CLIENTS; client = client + 1) begin
                    if (csr_addr == 8'h40 + client*16) begin
                        address_valid = 1'b1;
                        read_data = {29'b0, occupancies[client*3 +: 3]};
                    end
                    if (csr_addr == 8'h44 + client*16) begin
                        address_valid = 1'b1;
                        read_data = client_accepted[client];
                    end
                    if (csr_addr == 8'h48 + client*16) begin
                        address_valid = 1'b1;
                        read_data = client_issued[client];
                    end
                    if (csr_addr == 8'h4c + client*16) begin
                        address_valid = 1'b1;
                        read_data = client_retired[client];
                    end
                end
            end
        endcase
        request_error = 2'b0;
        if (!address_valid) request_error = 2'd1;
        else if (csr_write &&
                 (!writable || (|(csr_wdata & byte_mask & ~allowed_mask))))
            request_error = 2'd2;
        clear_mask = 5'b0;
        if (csr_fire && csr_write && request_error == 0 && csr_addr == 8'h0c)
            clear_mask = csr_wdata[4:0] & byte_mask[4:0];
    end

    always @(posedge clk) begin
        if (rst) begin
            control <= 2'b11;
            client_enable <= {CLIENTS{1'b1}};
            irq_mask <= 5'b0;
            sticky <= 5'b0;
            response_valid <= 1'b0;
            csr_rdata <= 32'b0;
            csr_error <= 2'b0;
            accepted <= 32'b0;
            issued <= 32'b0;
            completed <= 32'b0;
            retired <= 32'b0;
            errors <= 32'b0;
            for (reset_index = 0; reset_index < CLIENTS; reset_index = reset_index + 1) begin
                client_accepted[reset_index] <= 32'b0;
                client_issued[reset_index] <= 32'b0;
                client_retired[reset_index] <= 32'b0;
            end
        end else begin
            accepted <= accepted + accept_count;
            issued <= issued + issue_count;
            completed <= completed + completion_event;
            retired <= retired + retire_count;
            errors <= errors + error_count;
            sticky <= (sticky & ~clear_mask) | error_events;
            for (reset_index = 0; reset_index < CLIENTS; reset_index = reset_index + 1) begin
                client_accepted[reset_index] <= client_accepted[reset_index] +
                                                accept_events[reset_index];
                client_issued[reset_index] <= client_issued[reset_index] +
                                              issue_events[reset_index];
                client_retired[reset_index] <= client_retired[reset_index] +
                                               retire_events[reset_index];
            end
            if (csr_rsp_ready) response_valid <= 1'b0;
            if (csr_fire) begin
                response_valid <= 1'b1;
                csr_error <= request_error;
                csr_rdata <= (request_error != 0 || csr_write) ? 32'b0 : read_data;
                if (csr_write && request_error == 0) begin
                    case (csr_addr)
                        8'h00: control <= (control & ~byte_mask[1:0]) |
                                           (csr_wdata[1:0] & byte_mask[1:0]);
                        8'h04: client_enable <=
                            (client_enable & ~byte_mask[CLIENTS-1:0]) |
                            (csr_wdata[CLIENTS-1:0] & byte_mask[CLIENTS-1:0]);
                        8'h08: irq_mask <= (irq_mask & ~byte_mask[4:0]) |
                                            (csr_wdata[4:0] & byte_mask[4:0]);
                        default: begin end
                    endcase
                end
            end
        end
    end
endmodule
