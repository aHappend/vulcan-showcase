module sp_csr #(
    parameter integer CHANNELS = 2,
    parameter integer INPUT_DEPTH = 2,
    parameter integer OUTPUT_DEPTH = 2,
    localparam integer CH_W = (CHANNELS <= 1) ? 1 : $clog2(CHANNELS)
) (
    input wire clk, rst,
    input wire req_valid,
    output wire req_ready,
    input wire req_write,
    input wire [15:0] req_addr,
    input wire [31:0] req_wdata,
    input wire [3:0] req_wstrb,
    output wire rsp_valid,
    input wire rsp_ready,
    output reg [31:0] rsp_rdata,
    output reg rsp_error,
    output wire irq,
    input wire accept, admission_error, invalid_channel,
    input wire [CH_W-1:0] admission_channel,
    input wire retire, retirement_clipped,
    input wire [CH_W-1:0] retirement_channel,
    input wire [3:0] ingress_count, egress_count,
    input wire arithmetic_valid,
    input wire [CHANNELS-1:0] active,
    output wire [CHANNELS*16-1:0] shadow_c0, shadow_c1, shadow_c2,
    output wire [CHANNELS*32-1:0] shadow_bias,
    output wire [CHANNELS*9-1:0] shadow_control
);
    localparam integer RO = 0, C0 = 1, C1 = 2, C2 = 3, BIAS = 4,
                       CONTROL = 5, STICKY = 6, MASK = 7;
    reg [15:0] c0 [0:CHANNELS-1];
    reg [15:0] c1 [0:CHANNELS-1];
    reg [15:0] c2 [0:CHANNELS-1];
    reg [31:0] bias [0:CHANNELS-1];
    reg [8:0] control [0:CHANNELS-1];
    reg [31:0] channel_accepted [0:CHANNELS-1];
    reg [31:0] channel_retired [0:CHANNELS-1];
    reg [31:0] channel_errors [0:CHANNELS-1];
    reg [31:0] channel_clipped [0:CHANNELS-1];
    reg [31:0] global_accepted, global_retired, invalid_channels;
    reg [31:0] global_errors, global_clipped, csr_errors;
    reg [2:0] sticky, irq_mask;
    reg pending;
    reg mapped;
    reg [31:0] read_word, lane_mask, candidate, clear_word;
    reg access_error;
    integer kind, selected_channel, b, k;
    wire request = req_valid && req_ready;
    wire csr_error_event = request && access_error;
    wire [2:0] events = {csr_error_event,
                        retire && retirement_clipped,
                        accept && admission_error};
    wire [2:0] clear_mask =
        (request && req_write && !access_error && kind == STICKY) ?
        clear_word[2:0] : 3'b0;
    wire [4:0] outstanding = {1'b0, ingress_count} +
                            {1'b0, egress_count} +
                            {4'b0, arithmetic_valid};
    assign req_ready = !rst && !pending;
    assign rsp_valid = !rst && pending;
    assign irq = !rst && (|(sticky & irq_mask));

    genvar g;
    generate for (g = 0; g < CHANNELS; g = g + 1) begin: shadow_exports
        assign shadow_c0[g*16 +: 16] = c0[g];
        assign shadow_c1[g*16 +: 16] = c1[g];
        assign shadow_c2[g*16 +: 16] = c2[g];
        assign shadow_bias[g*32 +: 32] = bias[g];
        assign shadow_control[g*9 +: 9] = control[g];
    end endgenerate

    always @* begin
        mapped = 1'b1;
        kind = RO;
        selected_channel = req_addr[7:6];
        read_word = 0;
        case (req_addr)
            16'h0000: read_word = 32'h53505231;
            16'h0004: read_word = CHANNELS | (INPUT_DEPTH << 8) |
                                  (OUTPUT_DEPTH << 16) | (CH_W << 24);
            16'h0008: begin
                read_word[3:0] = ingress_count;
                read_word[7:4] = egress_count;
                read_word[8] = arithmetic_valid;
                read_word[20:16] = outstanding;
            end
            16'h000c: read_word = {{(32-CHANNELS){1'b0}}, active};
            16'h0010: read_word = global_accepted;
            16'h0014: read_word = global_retired;
            16'h0018: read_word = invalid_channels;
            16'h001c: read_word = global_errors;
            16'h0020: read_word = global_clipped;
            16'h0024: read_word = csr_errors;
            16'h0028: begin
                read_word = {29'b0, sticky};
                kind = STICKY;
            end
            16'h002c: begin
                read_word = {29'b0, irq_mask};
                kind = MASK;
            end
            default: begin
                if (req_addr[15:8] == 8'h01 &&
                    selected_channel < CHANNELS) begin
                    case (req_addr[5:0])
                        6'h00: begin
                            read_word = {16'b0, c0[selected_channel]};
                            kind = C0;
                        end
                        6'h04: begin
                            read_word = {16'b0, c1[selected_channel]};
                            kind = C1;
                        end
                        6'h08: begin
                            read_word = {16'b0, c2[selected_channel]};
                            kind = C2;
                        end
                        6'h0c: begin
                            read_word = bias[selected_channel];
                            kind = BIAS;
                        end
                        6'h10: begin
                            read_word = {23'b0, control[selected_channel]};
                            kind = CONTROL;
                        end
                        6'h14: read_word = channel_accepted[selected_channel];
                        6'h18: read_word = channel_retired[selected_channel];
                        6'h1c: read_word = channel_errors[selected_channel];
                        6'h20: read_word = channel_clipped[selected_channel];
                        default: mapped = 1'b0;
                    endcase
                end else mapped = 1'b0;
            end
        endcase
        lane_mask = 0;
        for (b = 0; b < 4; b = b + 1)
            lane_mask[b*8 +: 8] = {8{req_wstrb[b]}};
        candidate = (read_word & ~lane_mask) | (req_wdata & lane_mask);
        clear_word = req_wdata & lane_mask;
        access_error = !mapped || (req_addr[1:0] != 0);
        if (req_write) begin
            case (kind)
                RO: access_error = 1'b1;
                C0, C1, C2:
                    if (candidate[31:16] != 0) access_error = 1'b1;
                CONTROL:
                    if (candidate[31:9] != 0 || candidate[7:0] > 15)
                        access_error = 1'b1;
                MASK:
                    if (candidate[31:3] != 0) access_error = 1'b1;
                STICKY:
                    if (clear_word[31:3] != 0) access_error = 1'b1;
                default: begin end
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            pending <= 0;
            rsp_rdata <= 0;
            rsp_error <= 0;
            sticky <= 0;
            irq_mask <= 0;
            global_accepted <= 0;
            global_retired <= 0;
            invalid_channels <= 0;
            global_errors <= 0;
            global_clipped <= 0;
            csr_errors <= 0;
            for (k = 0; k < CHANNELS; k = k + 1) begin
                c0[k] <= 1;
                c1[k] <= 0;
                c2[k] <= 0;
                bias[k] <= 0;
                control[k] <= 9'h100;
                channel_accepted[k] <= 0;
                channel_retired[k] <= 0;
                channel_errors[k] <= 0;
                channel_clipped[k] <= 0;
            end
        end else begin
            if (pending && rsp_ready) pending <= 0;
            if (request) begin
                pending <= 1;
                rsp_error <= access_error;
                rsp_rdata <= (req_write || access_error) ? 32'b0 : read_word;
                if (req_write && !access_error) begin
                    case (kind)
                        C0: c0[selected_channel] <= candidate[15:0];
                        C1: c1[selected_channel] <= candidate[15:0];
                        C2: c2[selected_channel] <= candidate[15:0];
                        BIAS: bias[selected_channel] <= candidate;
                        CONTROL: control[selected_channel] <= candidate[8:0];
                        MASK: irq_mask <= candidate[2:0];
                        default: begin end
                    endcase
                end
            end
            sticky <= (sticky & ~clear_mask) | events;
            if (accept) global_accepted <= global_accepted + 32'd1;
            if (retire) global_retired <= global_retired + 32'd1;
            if (accept && invalid_channel)
                invalid_channels <= invalid_channels + 32'd1;
            if (accept && admission_error)
                global_errors <= global_errors + 32'd1;
            if (retire && retirement_clipped)
                global_clipped <= global_clipped + 32'd1;
            if (csr_error_event) csr_errors <= csr_errors + 32'd1;
            for (k = 0; k < CHANNELS; k = k + 1) begin
                if (accept && admission_channel == k) begin
                    channel_accepted[k] <= channel_accepted[k] + 32'd1;
                    if (admission_error)
                        channel_errors[k] <= channel_errors[k] + 32'd1;
                end
                if (retire && retirement_channel == k) begin
                    channel_retired[k] <= channel_retired[k] + 32'd1;
                    if (retirement_clipped)
                        channel_clipped[k] <= channel_clipped[k] + 32'd1;
                end
            end
        end
    end
endmodule
