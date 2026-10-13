module packet_descriptors #(
    parameter integer PACKET_SLOTS = 2,
    parameter integer MAX_WORDS = 16,
    parameter integer SLOT_W = (PACKET_SLOTS > 1) ? $clog2(PACKET_SLOTS) : 1,
    parameter integer COUNT_W = $clog2(PACKET_SLOTS + 1),
    parameter integer LENGTH_W = $clog2(MAX_WORDS + 1)
) (
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 commit,
    input  wire [7:0]           commit_destination,
    input  wire [LENGTH_W-1:0]  commit_length,
    input  wire                 retire,
    output wire                 free_slot,
    output wire                 head_valid,
    output wire [7:0]           head_destination,
    output wire [LENGTH_W-1:0]  head_length,
    output wire [SLOT_W-1:0]    head_slot,
    output wire [SLOT_W-1:0]    tail_slot,
    output wire [COUNT_W-1:0]   completed_count
);
    reg [SLOT_W-1:0] head;
    reg [SLOT_W-1:0] tail;
    reg [COUNT_W-1:0] count;
    reg [7:0] destinations [0:PACKET_SLOTS-1];
    reg [LENGTH_W-1:0] lengths [0:PACKET_SLOTS-1];

    assign free_slot = !rst && (count < PACKET_SLOTS);
    assign head_valid = !rst && (count != 0);
    assign head_destination = head_valid ? destinations[head] : 8'b0;
    assign head_length = head_valid ? lengths[head] : {LENGTH_W{1'b0}};
    assign head_slot = head;
    assign tail_slot = tail;
    assign completed_count = count;

    always @(posedge clk) begin
        if (rst) begin
            head <= 0;
            tail <= 0;
            count <= 0;
        end else begin
            case ({commit, retire})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
            if (commit) begin
                destinations[tail] <= commit_destination;
                lengths[tail] <= commit_length;
                if (tail == PACKET_SLOTS-1)
                    tail <= 0;
                else
                    tail <= tail + 1'b1;
            end
            if (retire) begin
                if (head == PACKET_SLOTS-1)
                    head <= 0;
                else
                    head <= head + 1'b1;
            end
        end
    end
endmodule
