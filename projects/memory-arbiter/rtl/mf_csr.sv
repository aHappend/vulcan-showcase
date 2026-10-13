module mf_csr #(
    parameter integer CLIENTS = 3,
    parameter integer BANKS = 2,
    parameter integer SLOTS = 2
) (
    input  wire                      clk,
    input  wire                      rst,
    input  wire                      req_valid,
    output wire                      req_ready,
    input  wire                      req_write,
    input  wire [15:0]               req_addr,
    input  wire [31:0]               req_wdata,
    input  wire [3:0]                req_wstrb,
    output wire                      rsp_valid,
    input  wire                      rsp_ready,
    output wire [31:0]               rsp_rdata,
    output wire                      rsp_error,
    output wire                      irq,
    input  wire [CLIENTS-1:0]        client_admit,
    input  wire [2*CLIENTS-1:0]      client_complete_inc,
    input  wire [2*CLIENTS-1:0]      client_error_inc,
    input  wire [32*CLIENTS-1:0]     client_occupancy,
    input  wire [BANKS-1:0]          bank_issue,
    input  wire [BANKS-1:0]          bank_complete,
    input  wire [BANKS-1:0]          bank_error,
    input  wire [3*BANKS-1:0]        bank_state,
    input  wire                      invalid_request_event
);
    localparam [31:0] CAPABILITIES =
        (32'h1 << 24) | (SLOTS << 16) | (BANKS << 8) | CLIENTS;
    reg pending;
    reg [31:0] response_data;
    reg response_error;
    reg [2:0] sticky, irq_mask;
    reg [31:0] client_accepted [0:CLIENTS-1];
    reg [31:0] client_completed [0:CLIENTS-1];
    reg [31:0] client_errors [0:CLIENTS-1];
    reg [31:0] bank_issued [0:BANKS-1];
    reg [31:0] bank_completed [0:BANKS-1];
    reg [31:0] bank_errors [0:BANKS-1];
    reg mapped, writable;
    reg [31:0] read_data;
    wire invalid_access, accept;
    wire [2:0] clear_bits, new_events;
    integer c, b, i;

    assign req_ready = !rst && !pending;
    assign accept = req_valid && req_ready;
    assign rsp_valid = !rst && pending;
    assign rsp_rdata = rsp_valid ? response_data : 32'b0;
    assign rsp_error = rsp_valid ? response_error : 1'b0;
    assign irq = !rst && (|(sticky & irq_mask));
    assign invalid_access = (req_addr[1:0] != 0) || !mapped || (req_write && !writable);
    assign clear_bits = (accept && req_write && !invalid_access &&
                         req_addr == 16'h0008 && req_wstrb[0]) ? req_wdata[2:0] : 3'b0;
    assign new_events = {accept && invalid_access, |bank_error, invalid_request_event};

    always @* begin
        mapped = 1;
        writable = 0;
        read_data = 0;
        case (req_addr)
            16'h0000: read_data = CAPABILITIES;
            16'h0004: read_data = 32'h0000003f;
            16'h0008: begin
                read_data = {29'b0, sticky};
                writable = 1;
            end
            16'h000c: begin
                read_data = {29'b0, irq_mask};
                writable = 1;
            end
            16'h0010: read_data = {29'b0, (sticky & irq_mask)};
            default: begin
                mapped = 0;
                for (c = 0; c < CLIENTS; c = c + 1) begin
                    if (req_addr == 16'h0100 + 32*c) begin
                        mapped = 1;
                        read_data = client_accepted[c];
                    end
                    if (req_addr == 16'h0104 + 32*c) begin
                        mapped = 1;
                        read_data = client_completed[c];
                    end
                    if (req_addr == 16'h0108 + 32*c) begin
                        mapped = 1;
                        read_data = client_errors[c];
                    end
                    if (req_addr == 16'h010c + 32*c) begin
                        mapped = 1;
                        read_data = client_occupancy[c*32 +: 32];
                    end
                end
                for (b = 0; b < BANKS; b = b + 1) begin
                    if (req_addr == 16'h0400 + 32*b) begin
                        mapped = 1;
                        read_data = bank_issued[b];
                    end
                    if (req_addr == 16'h0404 + 32*b) begin
                        mapped = 1;
                        read_data = bank_completed[b];
                    end
                    if (req_addr == 16'h0408 + 32*b) begin
                        mapped = 1;
                        read_data = bank_errors[b];
                    end
                    if (req_addr == 16'h040c + 32*b) begin
                        mapped = 1;
                        read_data = {29'b0, bank_state[b*3 +: 3]};
                    end
                end
            end
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            pending <= 0;
            response_data <= 0;
            response_error <= 0;
            sticky <= 0;
            irq_mask <= 0;
            for (i = 0; i < CLIENTS; i = i + 1) begin
                client_accepted[i] <= 0;
                client_completed[i] <= 0;
                client_errors[i] <= 0;
            end
            for (i = 0; i < BANKS; i = i + 1) begin
                bank_issued[i] <= 0;
                bank_completed[i] <= 0;
                bank_errors[i] <= 0;
            end
        end else begin
            sticky <= (sticky & ~clear_bits) | new_events;
            for (i = 0; i < CLIENTS; i = i + 1) begin
                client_accepted[i] <= client_accepted[i] + client_admit[i];
                client_completed[i] <= client_completed[i] + client_complete_inc[i*2 +: 2];
                client_errors[i] <= client_errors[i] + client_error_inc[i*2 +: 2];
            end
            for (i = 0; i < BANKS; i = i + 1) begin
                bank_issued[i] <= bank_issued[i] + bank_issue[i];
                bank_completed[i] <= bank_completed[i] + bank_complete[i];
                bank_errors[i] <= bank_errors[i] + bank_error[i];
            end
            if (rsp_valid && rsp_ready)
                pending <= 0;
            if (accept) begin
                pending <= 1;
                response_error <= invalid_access;
                response_data <= (!req_write && !invalid_access) ? read_data : 32'b0;
                if (req_write && !invalid_access &&
                    req_addr == 16'h000c && req_wstrb[0])
                    irq_mask <= req_wdata[2:0];
            end
        end
    end
endmodule
