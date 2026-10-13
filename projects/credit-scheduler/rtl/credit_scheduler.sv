module credit_scheduler #(
    parameter integer QUEUES = 3,
    parameter integer DEPTH = 2
) (
    input  wire clk,
    input  wire rst,
    input  wire [QUEUES-1:0] in_valid,
    output wire [QUEUES-1:0] in_ready,
    output wire [QUEUES-1:0] in_reject,
    input  wire [QUEUES*8-1:0] in_cost,
    input  wire [QUEUES*16-1:0] in_tag,
    output wire dispatch_valid,
    input  wire dispatch_ready,
    output wire [1:0] dispatch_queue,
    output wire [7:0] dispatch_cost,
    output wire [15:0] dispatch_tag,
    input  wire [QUEUES-1:0] completion_valid,
    output wire [QUEUES-1:0] completion_ready,
    output wire [QUEUES-1:0] completion_error,
    input  wire csr_req_valid,
    output wire csr_req_ready,
    input  wire csr_req_write,
    input  wire [31:0] csr_req_addr,
    input  wire [31:0] csr_req_wdata,
    input  wire [3:0] csr_req_wstrb,
    output wire csr_rsp_valid,
    input  wire csr_rsp_ready,
    output wire [31:0] csr_rsp_rdata,
    output wire csr_rsp_error,
    output wire irq
);
    localparam integer N = (QUEUES >= 1 && QUEUES <= 4) ? QUEUES : 1;
    localparam integer L = (DEPTH >= 1 && DEPTH <= 8) ? DEPTH : 1;
    localparam integer PW = (L > 1) ? $clog2(L) : 1;
    localparam [2:0] WR_NONE = 0, WR_ENABLE = 1, WR_QUANTUM = 2,
                     WR_LIMIT = 3, WR_MASK = 4, WR_CLEAR = 5;

    generate
        if (QUEUES < 1 || QUEUES > 4 || DEPTH < 1 || DEPTH > 8) begin : bad_parameters
            initial $fatal(1, "credit_scheduler: illegal parameters QUEUES=%0d DEPTH=%0d; require QUEUES 1..4, DEPTH 1..8", QUEUES, DEPTH);
        end
    endgenerate

    reg enabled [0:N-1];
    reg [7:0] quantum [0:N-1];
    reg [3:0] credit_limit [0:N-1];
    reg [3:0] occupancy [0:N-1];
    reg [9:0] deficit [0:N-1];
    reg [3:0] outstanding [0:N-1];
    reg [31:0] accepted_count [0:N-1];
    reg [31:0] dispatched_count [0:N-1];
    reg [31:0] completed_count [0:N-1];
    reg [31:0] error_count [0:N-1];
    wire [7:0] head_cost [0:N-1];
    wire [15:0] head_tag [0:N-1];
    wire [N-1:0] push, pop, valid_return, reserved;
    wire [N-1:0] ingress_error_event, return_error_event;
    wire [3:0] free_credit [0:N-1];

    reg [1:0] visit;
    reg serve;
    reg held_valid;
    reg [1:0] held_queue;
    reg [7:0] held_cost;
    reg [15:0] held_tag;
    reg response_valid;
    reg [31:0] response_data;
    reg response_error;
    reg [2:0] sticky, irq_mask;

    wire dispatch_fire = dispatch_valid && dispatch_ready;
    wire csr_fire = csr_req_valid && csr_req_ready;
    wire [31:0] byte_mask = {{8{csr_req_wstrb[3]}}, {8{csr_req_wstrb[2]}},
                             {8{csr_req_wstrb[1]}}, {8{csr_req_wstrb[0]}}};
    wire [31:0] strobed_data = csr_req_wdata & byte_mask;
    reg [31:0] csr_read_data, candidate;
    reg csr_access_error;
    reg [2:0] write_kind;
    reg [1:0] write_queue;
    reg configuration_change;
    wire suppress_schedule = csr_fire && csr_req_write &&
                             !csr_access_error && configuration_change;
    wire [2:0] clear_mask = (csr_fire && csr_req_write &&
                            !csr_access_error && write_kind == WR_CLEAR) ?
                            strobed_data[2:0] : 3'b000;
    wire [2:0] current_events = {csr_fire && csr_access_error,
                                |return_error_event, |ingress_error_event};

    assign dispatch_valid = !rst && held_valid;
    assign dispatch_queue = held_queue;
    assign dispatch_cost = held_cost;
    assign dispatch_tag = held_tag;
    assign csr_req_ready = !rst && !response_valid;
    assign csr_rsp_valid = !rst && response_valid;
    assign csr_rsp_rdata = response_data;
    assign csr_rsp_error = !rst && response_error;
    assign irq = !rst && |(sticky & irq_mask);

    genvar g;
    generate
        for (g = 0; g < N; g = g + 1) begin : queues
            reg [7:0] cost_memory [0:L-1];
            reg [15:0] tag_memory [0:L-1];
            reg [PW-1:0] read_pointer, write_pointer;
            wire [7:0] incoming_cost = in_cost[g*8 +: 8];
            wire [15:0] incoming_tag = in_tag[g*16 +: 16];
            wire [10:0] refill = {1'b0, deficit[g]} + {3'b000, quantum[g]};
            wire [4:0] next_outstanding = {1'b0, outstanding[g]} +
                                         {4'b0000, pop[g]} -
                                         {4'b0000, valid_return[g]};
            wire [4:0] free_wide = {1'b0, credit_limit[g]} -
                                  {1'b0, outstanding[g]} -
                                  {4'b0000, reserved[g]};
            wire [1:0] error_increment = {1'b0, ingress_error_event[g]} +
                                         {1'b0, return_error_event[g]};

            assign head_cost[g] = cost_memory[read_pointer];
            assign head_tag[g] = tag_memory[read_pointer];
            assign reserved[g] = held_valid && held_queue == g;
            assign pop[g] = dispatch_fire && held_queue == g;
            assign in_ready[g] = !rst && ((incoming_cost == 0) ||
                                  (enabled[g] && (occupancy[g] < L || pop[g])));
            assign in_reject[g] = in_valid[g] && in_ready[g] && incoming_cost == 0;
            assign ingress_error_event[g] = in_reject[g];
            assign push[g] = in_valid[g] && in_ready[g] && incoming_cost != 0;
            assign completion_ready[g] = !rst;
            assign completion_error[g] = !rst && completion_valid[g] &&
                                         outstanding[g] == 0;
            assign return_error_event[g] = completion_error[g];
            assign valid_return[g] = !rst && completion_valid[g] &&
                                     outstanding[g] != 0;
            assign free_credit[g] = free_wide[3:0];

            always @(posedge clk) begin
                if (rst) begin
                    enabled[g] <= 0;
                    quantum[g] <= 8'd16;
                    credit_limit[g] <= 4'd2;
                    occupancy[g] <= 0;
                    deficit[g] <= 0;
                    outstanding[g] <= 0;
                    read_pointer <= 0;
                    write_pointer <= 0;
                    accepted_count[g] <= 0;
                    dispatched_count[g] <= 0;
                    completed_count[g] <= 0;
                    error_count[g] <= 0;
                end else begin
                    if (push[g]) begin
                        cost_memory[write_pointer] <= incoming_cost;
                        tag_memory[write_pointer] <= incoming_tag;
                        if (write_pointer == L-1)
                            write_pointer <= 0;
                        else
                            write_pointer <= write_pointer + 1'b1;
                        accepted_count[g] <= accepted_count[g] + 32'd1;
                    end
                    if (pop[g]) begin
                        if (read_pointer == L-1)
                            read_pointer <= 0;
                        else
                            read_pointer <= read_pointer + 1'b1;
                        dispatched_count[g] <= dispatched_count[g] + 32'd1;
                    end
                    case ({push[g], pop[g]})
                        2'b10: occupancy[g] <= occupancy[g] + 4'd1;
                        2'b01: occupancy[g] <= occupancy[g] - 4'd1;
                        default: begin end
                    endcase
                    outstanding[g] <= next_outstanding[3:0];
                    if (valid_return[g])
                        completed_count[g] <= completed_count[g] + 32'd1;
                    error_count[g] <= error_count[g] + {30'b0, error_increment};

                    if (pop[g]) begin
                        if (occupancy[g] == 1 && !push[g])
                            deficit[g] <= 0;
                        else
                            deficit[g] <= deficit[g] - {2'b00, held_cost};
                    end else if (!held_valid && !suppress_schedule && visit == g) begin
                        if (occupancy[g] == 0)
                            deficit[g] <= 0;
                        else if (enabled[g] && !serve)
                            deficit[g] <= refill > 11'd1023 ? 10'd1023 : refill[9:0];
                    end

                    if (csr_fire && csr_req_write && !csr_access_error && write_queue == g) begin
                        case (write_kind)
                            WR_ENABLE: enabled[g] <= candidate[0];
                            WR_QUANTUM: quantum[g] <= candidate[7:0];
                            WR_LIMIT: credit_limit[g] <= candidate[3:0];
                            default: begin end
                        endcase
                    end
                end
            end
        end
    endgenerate

    integer q;
    always @* begin
        csr_read_data = 0;
        csr_access_error = 1;
        candidate = 0;
        write_kind = WR_NONE;
        write_queue = 0;
        configuration_change = 0;
        case (csr_req_addr)
            32'h000: begin
                csr_read_data = 32'h43534452;
                csr_access_error = csr_req_write;
            end
            32'h004: begin
                csr_read_data = 32'h0FFF0000 | (DEPTH << 8) | QUEUES;
                csr_access_error = csr_req_write;
            end
            32'h008: begin
                csr_read_data = 32'h200A1008;
                csr_access_error = csr_req_write;
            end
            32'h00C: begin
                csr_read_data = {29'b0, sticky};
                csr_access_error = csr_req_write && |(strobed_data & 32'hFFFFFFF8);
                write_kind = WR_CLEAR;
            end
            32'h010: begin
                csr_read_data = {29'b0, irq_mask};
                candidate = (csr_read_data & ~byte_mask) | strobed_data;
                csr_access_error = csr_req_write && |candidate[31:3];
                write_kind = WR_MASK;
            end
            32'h014: begin
                csr_read_data = {15'b0, serve, 6'b0, visit, 6'b0, irq, held_valid};
                csr_access_error = csr_req_write;
            end
            32'h018: begin
                csr_read_data = 32'd1023;
                csr_access_error = csr_req_write;
            end
            default: begin end
        endcase
        for (q = 0; q < N; q = q + 1) begin
            if (csr_req_addr >= 32'h100 + 64*q &&
                csr_req_addr < 32'h140 + 64*q) begin
                write_queue = q;
                case (csr_req_addr - (32'h100 + 64*q))
                    32'h00: begin
                        csr_read_data = {31'b0, enabled[q]};
                        candidate = (csr_read_data & ~byte_mask) | strobed_data;
                        csr_access_error = csr_req_write && |candidate[31:1];
                        write_kind = WR_ENABLE;
                        configuration_change = candidate != csr_read_data;
                    end
                    32'h04: begin
                        csr_read_data = {24'b0, quantum[q]};
                        candidate = (csr_read_data & ~byte_mask) | strobed_data;
                        csr_access_error = csr_req_write &&
                                           (|candidate[31:8] || candidate[7:0] == 0);
                        write_kind = WR_QUANTUM;
                        configuration_change = candidate != csr_read_data;
                    end
                    32'h08: begin
                        csr_read_data = {28'b0, credit_limit[q]};
                        candidate = (csr_read_data & ~byte_mask) | strobed_data;
                        csr_access_error = csr_req_write &&
                            (|candidate[31:4] || candidate[3:0] == 0 ||
                             {1'b0, candidate[3:0]} <
                             ({1'b0, outstanding[q]} + {4'b0, reserved[q]}));
                        write_kind = WR_LIMIT;
                        configuration_change = candidate != csr_read_data;
                    end
                    32'h0C: begin
                        csr_read_data = {28'b0, occupancy[q]};
                        csr_access_error = csr_req_write;
                    end
                    32'h10: begin
                        csr_read_data = {22'b0, deficit[q]};
                        csr_access_error = csr_req_write;
                    end
                    32'h14: begin
                        csr_read_data = {28'b0, outstanding[q]};
                        csr_access_error = csr_req_write;
                    end
                    32'h18: begin
                        csr_read_data = {28'b0, free_credit[q]};
                        csr_access_error = csr_req_write;
                    end
                    32'h1C: begin
                        csr_read_data = accepted_count[q];
                        csr_access_error = csr_req_write;
                    end
                    32'h20: begin
                        csr_read_data = dispatched_count[q];
                        csr_access_error = csr_req_write;
                    end
                    32'h24: begin
                        csr_read_data = completed_count[q];
                        csr_access_error = csr_req_write;
                    end
                    32'h28: begin
                        csr_read_data = error_count[q];
                        csr_access_error = csr_req_write;
                    end
                    32'h2C: begin
                        csr_read_data = {31'b0, reserved[q]};
                        csr_access_error = csr_req_write;
                    end
                    default: begin end
                endcase
            end
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            visit <= 0;
            serve <= 0;
            held_valid <= 0;
            held_queue <= 0;
            held_cost <= 0;
            held_tag <= 0;
            response_valid <= 0;
            response_data <= 0;
            response_error <= 0;
            sticky <= 0;
            irq_mask <= 0;
        end else begin
            sticky <= (sticky & ~clear_mask) | current_events;
            if (response_valid && csr_rsp_ready)
                response_valid <= 0;
            if (csr_fire) begin
                response_valid <= 1;
                response_data <= (csr_req_write || csr_access_error) ? 32'b0 : csr_read_data;
                response_error <= csr_access_error;
                if (csr_req_write && !csr_access_error && write_kind == WR_MASK)
                    irq_mask <= candidate[2:0];
            end
            if (held_valid) begin
                if (dispatch_fire)
                    held_valid <= 0;
            end else if (!suppress_schedule) begin
                if (occupancy[visit] == 0 || !enabled[visit]) begin
                    visit <= visit == N-1 ? 2'b00 : visit + 2'd1;
                    serve <= 0;
                end else if (!serve) begin
                    serve <= 1;
                end else if ({2'b00, head_cost[visit]} <= deficit[visit] &&
                             outstanding[visit] < credit_limit[visit]) begin
                    held_valid <= 1;
                    held_queue <= visit;
                    held_cost <= head_cost[visit];
                    held_tag <= head_tag[visit];
                end else begin
                    visit <= visit == N-1 ? 2'b00 : visit + 2'd1;
                    serve <= 0;
                end
            end
        end
    end
endmodule
