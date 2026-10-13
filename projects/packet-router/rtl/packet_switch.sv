module packet_switch #(
    parameter integer INPUTS = 3,
    parameter integer OUTPUTS = 3,
    parameter integer PACKET_SLOTS = 2,
    parameter integer MAX_WORDS = 16
) (
    input  wire                     clk,
    input  wire                     rst,
    input  wire [INPUTS-1:0]        in_valid,
    output wire [INPUTS-1:0]        in_ready,
    input  wire [INPUTS*32-1:0]     in_data,
    input  wire [INPUTS*4-1:0]      in_tag,
    input  wire [INPUTS-1:0]        in_last,
    output wire [OUTPUTS-1:0]       out_valid,
    input  wire [OUTPUTS-1:0]       out_ready,
    output wire [OUTPUTS*32-1:0]    out_data,
    output wire [OUTPUTS-1:0]       out_last,
    input  wire                     csr_req_valid,
    output wire                     csr_req_ready,
    input  wire                     csr_req_write,
    input  wire [15:0]              csr_req_addr,
    input  wire [31:0]              csr_req_wdata,
    input  wire [3:0]               csr_req_wstrb,
    output wire                     csr_rsp_valid,
    input  wire                     csr_rsp_ready,
    output wire [31:0]              csr_rsp_rdata,
    output wire                     csr_rsp_error,
    output wire                     irq
);
    localparam integer INPUT_W = (INPUTS > 1) ? $clog2(INPUTS) : 1;
    localparam integer SLOT_W = (PACKET_SLOTS > 1) ? $clog2(PACKET_SLOTS) : 1;
    localparam integer WORD_W = (MAX_WORDS > 1) ? $clog2(MAX_WORDS) : 1;
    localparam integer LENGTH_W = $clog2(MAX_WORDS + 1);
    localparam integer COUNT_W = $clog2(PACKET_SLOTS + 1);

    wire [143:0] route_entries;
    wire route_write;
    wire [3:0] route_write_tag;
    wire [8:0] route_write_entry;
    wire [INPUTS-1:0] commit;
    wire [INPUTS-1:0] dropped_packets;
    wire [INPUTS-1:0] oversize_packets;
    wire [INPUTS-1:0] accepted_beats;
    wire [INPUTS-1:0] head_valid;
    wire [INPUTS*8-1:0] head_destinations;
    wire [INPUTS*LENGTH_W-1:0] head_lengths;
    wire [INPUTS*32-1:0] head_words;
    wire [INPUTS*32-1:0] occupancies;
    wire [INPUTS*32-1:0] completed_counts;
    wire [INPUTS*3-1:0] input_states;
    wire [INPUTS*3-1:0] input_errors;
    wire [OUTPUTS-1:0] output_busy;
    wire [OUTPUTS-1:0] transmitted_beats;
    wire [OUTPUTS-1:0] transmitted_packets;
    wire [OUTPUTS*INPUT_W-1:0] output_owners;
    wire [OUTPUTS*WORD_W-1:0] output_indices;
    wire [2:0] ingress_error_chain [0:INPUTS];
    wire [2:0] ingress_errors;
    genvar i;
    genvar o;

`ifndef SYNTHESIS
    initial begin
        if (INPUTS < 1 || INPUTS > 16 || OUTPUTS < 1 || OUTPUTS > 16 ||
            PACKET_SLOTS < 1 || PACKET_SLOTS > 16 || MAX_WORDS < 1 || MAX_WORDS > 256)
            $fatal(1, "packet_switch parameters outside supported ranges");
    end
`endif

    packet_routes routes (
        .clk(clk), .rst(rst),
        .write_valid(route_write), .write_tag(route_write_tag),
        .write_entry(route_write_entry), .entries(route_entries)
    );

    assign ingress_error_chain[0] = 3'b0;
    assign ingress_errors = ingress_error_chain[INPUTS];

    generate
        for (i = 0; i < INPUTS; i = i + 1) begin : inputs
            wire free_slot;
            wire [SLOT_W-1:0] head_slot;
            wire [SLOT_W-1:0] tail_slot;
            wire [COUNT_W-1:0] completed;
            wire [7:0] commit_destination;
            wire [LENGTH_W-1:0] commit_length;
            wire packet_active;
            wire draining;
            wire reserved;
            wire [8:0] first_route;
            reg retire;
            reg [WORD_W-1:0] read_word;
            integer selected_output;

            assign ingress_error_chain[i+1] =
                ingress_error_chain[i] | input_errors[i*3 +: 3];
            assign first_route = route_entries[in_tag[i*4 +: 4]*9 +: 9];
            assign occupancies[i*32 +: 32] = {{(32-COUNT_W){1'b0}}, completed} +
                                           {{31{1'b0}}, reserved};
            assign completed_counts[i*32 +: 32] = {{(32-COUNT_W){1'b0}}, completed};
            assign input_states[i*3 +: 3] = {reserved, draining, packet_active};

            always @* begin
                retire = 1'b0;
                read_word = 0;
                for (selected_output = 0; selected_output < OUTPUTS; selected_output = selected_output + 1) begin
                    if (output_busy[selected_output] &&
                        output_owners[selected_output*INPUT_W +: INPUT_W] == i) begin
                        read_word = output_indices[selected_output*WORD_W +: WORD_W];
                        retire = transmitted_packets[selected_output];
                    end
                end
            end

            packet_ingress #(
                .OUTPUTS(OUTPUTS), .PACKET_SLOTS(PACKET_SLOTS), .MAX_WORDS(MAX_WORDS)
            ) ingress (
                .clk(clk), .rst(rst),
                .in_valid(in_valid[i]), .in_ready(in_ready[i]),
                .in_data(in_data[i*32 +: 32]), .in_last(in_last[i]),
                .first_route(first_route), .free_slot(free_slot),
                .tail_slot(tail_slot), .commit(commit[i]),
                .commit_destination(commit_destination), .commit_length(commit_length),
                .accepted_beat(accepted_beats[i]), .dropped_packet(dropped_packets[i]),
                .oversize_packet(oversize_packets[i]), .error_events(input_errors[i*3 +: 3]),
                .packet_active(packet_active), .draining(draining), .reserved(reserved),
                .read_slot(head_slot), .read_word(read_word), .read_data(head_words[i*32 +: 32])
            );

            packet_descriptors #(
                .PACKET_SLOTS(PACKET_SLOTS), .MAX_WORDS(MAX_WORDS)
            ) descriptors (
                .clk(clk), .rst(rst), .commit(commit[i]),
                .commit_destination(commit_destination), .commit_length(commit_length),
                .retire(retire), .free_slot(free_slot), .head_valid(head_valid[i]),
                .head_destination(head_destinations[i*8 +: 8]),
                .head_length(head_lengths[i*LENGTH_W +: LENGTH_W]),
                .head_slot(head_slot), .tail_slot(tail_slot), .completed_count(completed)
            );
        end

        for (o = 0; o < OUTPUTS; o = o + 1) begin : outputs
            wire [INPUTS-1:0] eligible;
            wire grant_valid;
            wire [INPUT_W-1:0] grant_input;
            for (i = 0; i < INPUTS; i = i + 1) begin : candidates
                assign eligible[i] = head_valid[i] && (head_destinations[i*8 +: 8] == o);
            end

            packet_arbiter #(.INPUTS(INPUTS)) arbiter (
                .clk(clk), .rst(rst), .eligible(eligible),
                .grant_valid(grant_valid), .grant_input(grant_input),
                .packet_done(transmitted_packets[o]),
                .completed_input(output_owners[o*INPUT_W +: INPUT_W])
            );

            packet_output #(.INPUTS(INPUTS), .MAX_WORDS(MAX_WORDS)) stream (
                .clk(clk), .rst(rst), .grant_valid(grant_valid), .grant_input(grant_input),
                .head_lengths(head_lengths), .head_words(head_words),
                .out_valid(out_valid[o]), .out_ready(out_ready[o]),
                .out_data(out_data[o*32 +: 32]), .out_last(out_last[o]),
                .busy(output_busy[o]), .owner_input(output_owners[o*INPUT_W +: INPUT_W]),
                .word_index(output_indices[o*WORD_W +: WORD_W]),
                .transmitted_beat(transmitted_beats[o]), .packet_done(transmitted_packets[o])
            );
        end
    endgenerate

    packet_csr #(
        .INPUTS(INPUTS), .OUTPUTS(OUTPUTS), .PACKET_SLOTS(PACKET_SLOTS), .MAX_WORDS(MAX_WORDS)
    ) csr (
        .clk(clk), .rst(rst),
        .csr_req_valid(csr_req_valid), .csr_req_ready(csr_req_ready),
        .csr_req_write(csr_req_write), .csr_req_addr(csr_req_addr),
        .csr_req_wdata(csr_req_wdata), .csr_req_wstrb(csr_req_wstrb),
        .csr_rsp_valid(csr_rsp_valid), .csr_rsp_ready(csr_rsp_ready),
        .csr_rsp_rdata(csr_rsp_rdata), .csr_rsp_error(csr_rsp_error), .irq(irq),
        .route_entries(route_entries), .route_write(route_write),
        .route_write_tag(route_write_tag), .route_write_entry(route_write_entry),
        .accepted_packets(commit), .dropped_packets(dropped_packets),
        .oversize_packets(oversize_packets), .accepted_beats(accepted_beats),
        .occupancies(occupancies), .completed_counts(completed_counts),
        .input_states(input_states), .transmitted_packets(transmitted_packets),
        .transmitted_beats(transmitted_beats), .output_busy(output_busy),
        .ingress_errors(ingress_errors)
    );
endmodule
