module dma_scheduler #(
    parameter integer CHANNELS = 4,
    parameter integer CHANNEL_WIDTH = (CHANNELS > 1) ? $clog2(CHANNELS) : 1
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     idle,
    input  wire [CHANNELS-1:0]      pending,
    input  wire                     terminal,
    input  wire [CHANNEL_WIDTH-1:0] terminal_channel,
    output reg                      select_valid,
    output reg [CHANNEL_WIDTH-1:0]  select_channel,
    output reg [CHANNELS-1:0]       dequeue
);
    reg [CHANNEL_WIDTH-1:0] round_robin;
    integer offset;
    integer candidate;
    reg found;

    always @* begin
        select_valid = 1'b0;
        select_channel = 0;
        dequeue = 0;
        found = 1'b0;
        candidate = 0;
        for (offset = 0; offset < CHANNELS; offset = offset + 1) begin
            candidate = round_robin + offset;
            if (candidate >= CHANNELS)
                candidate = candidate - CHANNELS;
            if (!found && pending[candidate]) begin
                found = 1'b1;
                if (idle && !rst) begin
                    select_valid = 1'b1;
                    select_channel = candidate;
                    dequeue[candidate] = 1'b1;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (rst)
            round_robin <= 0;
        else if (terminal) begin
            if (terminal_channel == CHANNELS - 1)
                round_robin <= 0;
            else
                round_robin <= terminal_channel + 1'b1;
        end
    end
endmodule
