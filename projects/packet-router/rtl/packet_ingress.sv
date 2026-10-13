module packet_ingress #(
    parameter integer OUTPUTS = 3,
    parameter integer PACKET_SLOTS = 2,
    parameter integer MAX_WORDS = 16,
    parameter integer SLOT_W = (PACKET_SLOTS > 1) ? $clog2(PACKET_SLOTS) : 1,
    parameter integer WORD_W = (MAX_WORDS > 1) ? $clog2(MAX_WORDS) : 1,
    parameter integer LENGTH_W = $clog2(MAX_WORDS + 1),
    parameter integer TRACK_W = $clog2(MAX_WORDS + 2)
) (
    input  wire                 clk,
    input  wire                 rst,
    input  wire                 in_valid,
    output wire                 in_ready,
    input  wire [31:0]          in_data,
    input  wire                 in_last,
    input  wire [8:0]           first_route,
    input  wire                 free_slot,
    input  wire [SLOT_W-1:0]    tail_slot,
    output wire                 commit,
    output wire [7:0]           commit_destination,
    output wire [LENGTH_W-1:0]  commit_length,
    output wire                 accepted_beat,
    output wire                 dropped_packet,
    output wire                 oversize_packet,
    output wire [2:0]           error_events,
    output wire                 packet_active,
    output wire                 draining,
    output wire                 reserved,
    input  wire [SLOT_W-1:0]    read_slot,
    input  wire [WORD_W-1:0]    read_word,
    output wire [31:0]          read_data
);
    reg active;
    reg slot_reserved;
    reg [TRACK_W-1:0] words;
    reg [7:0] destination;
    reg [31:0] storage [0:PACKET_SLOTS*MAX_WORDS-1];

    wire route_enabled = first_route[8];
    wire route_valid = route_enabled && (first_route[7:0] < OUTPUTS);
    wire packet_route_valid = active ? slot_reserved : route_valid;
    wire [TRACK_W-1:0] next_words =
        !active ? {{(TRACK_W-1){1'b0}}, 1'b1} :
        (words < MAX_WORDS+1) ? words + 1'b1 : words;
    wire exceeds_limit = next_words > MAX_WORDS;
    wire write_word = accepted_beat && packet_route_valid && !exceeds_limit;
    wire first_oversize = accepted_beat && active && (words == MAX_WORDS);

    assign in_ready = !rst && (active || !route_valid || free_slot);
    assign accepted_beat = in_valid && in_ready;
    assign commit = accepted_beat && in_last && packet_route_valid && !exceeds_limit;
    assign commit_destination = active ? destination : first_route[7:0];
    assign commit_length = next_words[LENGTH_W-1:0];
    assign dropped_packet = accepted_beat && in_last && (!packet_route_valid || exceeds_limit);
    assign oversize_packet = accepted_beat && in_last && exceeds_limit;
    assign error_events[0] = accepted_beat && !active && !route_enabled;
    assign error_events[1] = accepted_beat && !active && route_enabled && !route_valid;
    assign error_events[2] = first_oversize;
    assign packet_active = active;
    assign draining = active && !slot_reserved;
    assign reserved = slot_reserved;
    assign read_data = storage[read_slot*MAX_WORDS + read_word];

    always @(posedge clk) begin
        if (rst) begin
            active <= 1'b0;
            slot_reserved <= 1'b0;
            words <= 0;
            destination <= 0;
        end else if (accepted_beat) begin
            if (write_word)
                storage[tail_slot*MAX_WORDS + (active ? words : 0)] <= in_data;
            if (!active)
                destination <= first_route[7:0];
            if (in_last) begin
                active <= 1'b0;
                slot_reserved <= 1'b0;
                words <= 0;
            end else begin
                active <= 1'b1;
                slot_reserved <= packet_route_valid && !exceeds_limit;
                words <= next_words;
            end
        end
    end
endmodule
