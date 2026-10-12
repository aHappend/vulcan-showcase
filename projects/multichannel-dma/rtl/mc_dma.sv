module mc_dma #(
    parameter integer CHANNELS = 4,
    parameter integer DESC_DEPTH = 2,
    parameter integer DATA_DEPTH = 4
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        cfg_req_valid,
    input  wire        cfg_req_write,
    output wire        cfg_req_ready,
    input  wire [31:0] cfg_req_addr,
    input  wire [31:0] cfg_req_wdata,
    input  wire [3:0]  cfg_req_wstrb,
    output wire        cfg_rsp_valid,
    input  wire        cfg_rsp_ready,
    output wire [31:0] cfg_rsp_rdata,
    output wire        cfg_rsp_error,
    output wire        rd_req_valid,
    input  wire        rd_req_ready,
    output wire [31:0] rd_req_addr,
    input  wire        rd_rsp_valid,
    output wire        rd_rsp_ready,
    input  wire [31:0] rd_rsp_data,
    input  wire        rd_rsp_error,
    output wire        wr_req_valid,
    input  wire        wr_req_ready,
    output wire [31:0] wr_req_addr,
    output wire [31:0] wr_req_data,
    output wire [3:0]  wr_req_strb,
    input  wire        wr_rsp_valid,
    output wire        wr_rsp_ready,
    input  wire        wr_rsp_error,
    output wire        irq
);
    localparam integer CHANNEL_WIDTH = (CHANNELS > 1) ? $clog2(CHANNELS) : 1;
    localparam integer DESC_COUNT_WIDTH = $clog2(DESC_DEPTH + 1);
    localparam integer DATA_COUNT_WIDTH = $clog2(DATA_DEPTH + 1);
    localparam integer DESCRIPTOR_WIDTH = 76;

    wire [CHANNELS-1:0] enqueue;
    wire [CHANNELS*DESCRIPTOR_WIDTH-1:0] enqueue_data;
    wire [CHANNELS-1:0] dequeue;
    wire [CHANNELS-1:0] queue_empty;
    wire [CHANNELS-1:0] queue_full;
    wire [CHANNELS*5-1:0] queue_count;
    wire [CHANNELS*DESCRIPTOR_WIDTH-1:0] queue_heads;
    wire selected_valid;
    wire [CHANNEL_WIDTH-1:0] selected_channel;
    wire [DESCRIPTOR_WIDTH-1:0] selected_descriptor;

    reg active;
    reg [CHANNEL_WIDTH-1:0] active_channel;
    reg [8:0] active_words;
    reg active_interrupt;
    reg context_failed;
    reg [1:0] context_causes;
    reg [8:0] committed_words;

    wire read_settled;
    wire write_settled;
    wire read_error;
    wire write_error;
    wire any_error;
    wire successful_word;
    wire engines_run;
    wire discard_data;
    wire fifo_room;
    wire fifo_empty;
    wire [DATA_COUNT_WIDTH-1:0] fifo_count;
    wire fifo_push_valid;
    wire fifo_push_ready;
    wire [31:0] fifo_push_data;
    wire fifo_head_valid;
    wire fifo_head_ready;
    wire [31:0] fifo_head_data;
    wire terminal_success;
    wire terminal_failure;
    wire terminal;
    genvar channel;

    assign selected_descriptor =
        queue_heads[selected_channel*DESCRIPTOR_WIDTH +: DESCRIPTOR_WIDTH];
    assign any_error = read_error || write_error;
    assign discard_data = active && (context_failed || any_error);
    assign engines_run = active && !context_failed && !any_error && !rst;
    // Only the read engine consumes this credit, and it has one request slot.
    assign fifo_room = (fifo_count < DATA_DEPTH);
    assign terminal_success = active && !context_failed && !any_error &&
                              (committed_words == active_words) &&
                              read_settled && write_settled && fifo_empty && !rst;
    assign terminal_failure = active && context_failed &&
                              read_settled && write_settled && fifo_empty && !rst;
    assign terminal = terminal_success || terminal_failure;

    dma_registers #(
        .CHANNELS(CHANNELS),
        .DESC_DEPTH(DESC_DEPTH),
        .DATA_DEPTH(DATA_DEPTH),
        .CHANNEL_WIDTH(CHANNEL_WIDTH)
    ) registers (
        .clk(clk),
        .rst(rst),
        .cfg_req_valid(cfg_req_valid),
        .cfg_req_write(cfg_req_write),
        .cfg_req_ready(cfg_req_ready),
        .cfg_req_addr(cfg_req_addr),
        .cfg_req_wdata(cfg_req_wdata),
        .cfg_req_wstrb(cfg_req_wstrb),
        .cfg_rsp_valid(cfg_rsp_valid),
        .cfg_rsp_ready(cfg_rsp_ready),
        .cfg_rsp_rdata(cfg_rsp_rdata),
        .cfg_rsp_error(cfg_rsp_error),
        .queue_full(queue_full),
        .queue_empty(queue_empty),
        .queue_count(queue_count),
        .enqueue(enqueue),
        .enqueue_data(enqueue_data),
        .active(active),
        .active_channel(active_channel),
        .completed(terminal_success),
        .failed(terminal_failure),
        .failure_cause(context_causes),
        .event_interrupt(active_interrupt),
        .successful_word(successful_word),
        .irq(irq)
    );

    generate
        for (channel = 0; channel < CHANNELS; channel = channel + 1) begin : queues
            wire [DESC_COUNT_WIDTH-1:0] occupancy;
            dma_descriptor_queue #(
                .DEPTH(DESC_DEPTH),
                .WIDTH(DESCRIPTOR_WIDTH)
            ) descriptors (
                .clk(clk),
                .rst(rst),
                .push(enqueue[channel]),
                .push_data(enqueue_data[channel*DESCRIPTOR_WIDTH +: DESCRIPTOR_WIDTH]),
                .pop(dequeue[channel]),
                .head_data(queue_heads[channel*DESCRIPTOR_WIDTH +: DESCRIPTOR_WIDTH]),
                .empty(queue_empty[channel]),
                .full(queue_full[channel]),
                .occupancy(occupancy)
            );
            assign queue_count[channel*5 +: 5] =
                {{(5-DESC_COUNT_WIDTH){1'b0}}, occupancy};
        end
    endgenerate

    dma_scheduler #(
        .CHANNELS(CHANNELS),
        .CHANNEL_WIDTH(CHANNEL_WIDTH)
    ) scheduler (
        .clk(clk),
        .rst(rst),
        .idle(!active),
        .pending(~queue_empty),
        .terminal(terminal),
        .terminal_channel(active_channel),
        .select_valid(selected_valid),
        .select_channel(selected_channel),
        .dequeue(dequeue)
    );

    dma_read_engine read_engine (
        .clk(clk),
        .rst(rst),
        .start(selected_valid),
        .start_address(selected_descriptor[31:0]),
        .start_words(selected_descriptor[72:64]),
        .start_increment(selected_descriptor[73]),
        .run(engines_run),
        .discard(discard_data),
        .fifo_room(fifo_room),
        .data_valid(fifo_push_valid),
        .data(fifo_push_data),
        .response_error(read_error),
        .settled(read_settled),
        .rd_req_valid(rd_req_valid),
        .rd_req_ready(rd_req_ready),
        .rd_req_addr(rd_req_addr),
        .rd_rsp_valid(rd_rsp_valid),
        .rd_rsp_ready(rd_rsp_ready),
        .rd_rsp_data(rd_rsp_data),
        .rd_rsp_error(rd_rsp_error)
    );

    dma_write_engine write_engine (
        .clk(clk),
        .rst(rst),
        .start(selected_valid),
        .start_address(selected_descriptor[63:32]),
        .start_words(selected_descriptor[72:64]),
        .start_increment(selected_descriptor[74]),
        .run(engines_run),
        .data_valid(fifo_head_valid),
        .data_ready(fifo_head_ready),
        .data(fifo_head_data),
        .response_error(write_error),
        .successful_word(successful_word),
        .settled(write_settled),
        .wr_req_valid(wr_req_valid),
        .wr_req_ready(wr_req_ready),
        .wr_req_addr(wr_req_addr),
        .wr_req_data(wr_req_data),
        .wr_req_strb(wr_req_strb),
        .wr_rsp_valid(wr_rsp_valid),
        .wr_rsp_ready(wr_rsp_ready),
        .wr_rsp_error(wr_rsp_error)
    );

    dma_data_fifo #(
        .DEPTH(DATA_DEPTH)
    ) data_buffer (
        .clk(clk),
        .rst(rst),
        .flush(discard_data),
        .push_valid(fifo_push_valid),
        .push_ready(fifo_push_ready),
        .push_data(fifo_push_data),
        .head_valid(fifo_head_valid),
        .head_ready(fifo_head_ready),
        .head_data(fifo_head_data),
        .occupancy(fifo_count),
        .empty(fifo_empty)
    );

    always @(posedge clk) begin
        if (rst) begin
            active <= 1'b0;
            active_channel <= 0;
            active_words <= 0;
            active_interrupt <= 1'b0;
            context_failed <= 1'b0;
            context_causes <= 0;
            committed_words <= 0;
        end else if (selected_valid) begin
            active <= 1'b1;
            active_channel <= selected_channel;
            active_words <= selected_descriptor[72:64];
            active_interrupt <= selected_descriptor[75];
            context_failed <= 1'b0;
            context_causes <= 0;
            committed_words <= 0;
        end else if (active) begin
            if (successful_word)
                committed_words <= committed_words + 1'b1;
            if (any_error) begin
                context_failed <= 1'b1;
                context_causes <= context_causes | {write_error, read_error};
            end
            if (terminal)
                active <= 1'b0;
        end
    end
endmodule
