module lz4_block_decoder #(
    parameter integer MAX_COMPRESSED_BYTES = 512,
    parameter integer MAX_DECOMPRESSED_BYTES = 1024,
    parameter integer HISTORY_BYTES = 1024
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        abort,
    input  wire        cmd_valid,
    output wire        cmd_ready,
    input  wire [12:0] cmd_compressed_bytes,
    input  wire [12:0] cmd_decompressed_bytes,
    input  wire        s_valid,
    output wire        s_ready,
    input  wire [7:0]  s_data,
    input  wire        s_last,
    output wire        m_valid,
    input  wire        m_ready,
    output wire [7:0]  m_data,
    output wire        m_first,
    output wire        m_last,
    output wire        status_valid,
    input  wire        status_ready,
    output wire [4:0]  status_code,
    output wire [12:0] status_compressed_bytes,
    output wire [12:0] status_decompressed_bytes,
    output wire        busy
);

    generate
        if (MAX_COMPRESSED_BYTES < 1 || MAX_COMPRESSED_BYTES > 4096 ||
            MAX_DECOMPRESSED_BYTES < 1 || MAX_DECOMPRESSED_BYTES > 4096 ||
            HISTORY_BYTES < 1 || HISTORY_BYTES > 4096) begin : g_invalid
            initial begin
                if (MAX_COMPRESSED_BYTES < 1 || MAX_COMPRESSED_BYTES > 4096)
                    $fatal(1, "PARAMETER ERROR MAX_COMPRESSED_BYTES must be in 1..4096");
                if (MAX_DECOMPRESSED_BYTES < 1 || MAX_DECOMPRESSED_BYTES > 4096)
                    $fatal(1, "PARAMETER ERROR MAX_DECOMPRESSED_BYTES must be in 1..4096");
                if (HISTORY_BYTES < 1 || HISTORY_BYTES > 4096)
                    $fatal(1, "PARAMETER ERROR HISTORY_BYTES must be in 1..4096");
            end
            assign cmd_ready = 1'b0;
            assign s_ready = 1'b0;
            assign m_valid = 1'b0;
            assign m_data = 8'b0;
            assign m_first = 1'b0;
            assign m_last = 1'b0;
            assign status_valid = 1'b0;
            assign status_code = 5'b0;
            assign status_compressed_bytes = 13'b0;
            assign status_decompressed_bytes = 13'b0;
            assign busy = 1'b0;
        end else begin : g_decoder
            localparam integer HISTORY_ADDR_BITS =
                (HISTORY_BYTES > 1) ? $clog2(HISTORY_BYTES) : 1;

            localparam [4:0]
                OK = 0,
                ERR_COMPRESSED_BOUND = 1,
                ERR_DECOMPRESSED_BOUND = 2,
                ERR_HISTORY_BOUND = 3,
                ERR_INPUT_LENGTH = 4,
                ERR_TRUNCATED_TOKEN = 5,
                ERR_TRUNCATED_LITERAL_EXTENSION = 6,
                ERR_TRUNCATED_LITERALS = 7,
                ERR_TRUNCATED_OFFSET = 8,
                ERR_TRUNCATED_MATCH_EXTENSION = 9,
                ERR_ZERO_OFFSET = 10,
                ERR_OFFSET_RANGE = 11,
                ERR_LENGTH_OVERFLOW = 12,
                ERR_OUTPUT_LIMIT = 13,
                ERR_HISTORY_LIMIT = 14,
                ERR_DECLARED_OUTPUT = 15,
                ERR_END_RULE = 16,
                ABORTED = 17;

            localparam [4:0]
                IDLE = 0,
                TOKEN = 1,
                LITERAL_EXTENSION = 2,
                LITERAL_RESERVE = 3,
                LITERAL_FETCH = 4,
                LITERAL_COMMIT = 5,
                AFTER_LITERALS = 6,
                OFFSET_LOW = 7,
                OFFSET_HIGH = 8,
                MATCH_EXTENSION = 9,
                MATCH_RESERVE = 10,
                COPY_FETCH = 11,
                COPY_COMMIT = 12,
                FINALIZE = 13,
                TERMINAL = 14;

            reg [4:0] state;
            reg [12:0] compressed_length;
            reg [12:0] decompressed_length;
            reg [12:0] consumed;
            reg [12:0] produced;
            reg [3:0] match_nibble;
            reg [15:0] segment_length;
            reg [15:0] remaining;
            reg [15:0] literal_length;
            reg [7:0] offset_low;
            reg [15:0] match_offset;
            reg seen_match;
            reg [12:0] last_match_start;
            reg pending;
            reg [7:0] output_data;
            reg output_first;
            reg output_last;
            reg [4:0] terminal_code;
            reg [12:0] terminal_consumed;
            reg [12:0] terminal_produced;
            reg [7:0] history [0:HISTORY_BYTES-1];

            wire input_state =
                state == TOKEN || state == LITERAL_EXTENSION ||
                state == LITERAL_FETCH || state == OFFSET_LOW ||
                state == OFFSET_HIGH || state == MATCH_EXTENSION;
            wire input_transfer = s_valid && s_ready;
            wire output_transfer = m_valid && m_ready;
            wire exhausted = consumed == compressed_length;
            wire expected_last = ({1'b0, consumed} + 14'd1) ==
                                 {1'b0, compressed_length};
            wire marker_error = input_transfer && (s_last != expected_last);
            wire [16:0] extended_length =
                {1'b0, segment_length} + {9'b0, s_data};
            wire [16:0] prospective_end =
                {4'b0, produced} + {1'b0, segment_length};
            wire [15:0] incoming_offset = {s_data, offset_low};
            wire [15:0] copy_position = {3'b0, produced} - match_offset;
            wire [HISTORY_ADDR_BITS-1:0] read_address =
                copy_position[HISTORY_ADDR_BITS-1:0];
            wire [HISTORY_ADDR_BITS-1:0] write_address =
                produced[HISTORY_ADDR_BITS-1:0];

            assign cmd_ready = state == IDLE && !rst && !abort;
            assign s_ready = input_state && !exhausted && !rst && !abort;
            assign m_valid = pending && !rst && !abort;
            assign m_data = output_data;
            assign m_first = output_first;
            assign m_last = output_last;
            assign status_valid = state == TERMINAL && !rst;
            assign status_code = terminal_code;
            assign status_compressed_bytes = terminal_consumed;
            assign status_decompressed_bytes = terminal_produced;
            assign busy = state != IDLE && !rst;

            task finish;
                input [4:0] code;
                begin
                    terminal_code <= code;
                    terminal_consumed <= consumed;
                    terminal_produced <= produced;
                    state <= TERMINAL;
                end
            endtask

            // Memory changes only when a byte becomes publicly owned by the consumer.
            always @(posedge clk) begin
                if (output_transfer)
                    history[write_address] <= output_data;
            end

            always @(posedge clk) begin
                if (rst) begin
                    state <= IDLE;
                    compressed_length <= 0;
                    decompressed_length <= 0;
                    consumed <= 0;
                    produced <= 0;
                    match_nibble <= 0;
                    segment_length <= 0;
                    remaining <= 0;
                    literal_length <= 0;
                    offset_low <= 0;
                    match_offset <= 0;
                    seen_match <= 0;
                    last_match_start <= 0;
                    pending <= 0;
                    output_data <= 0;
                    output_first <= 0;
                    output_last <= 0;
                    terminal_code <= OK;
                    terminal_consumed <= 0;
                    terminal_produced <= 0;
                end else if (abort && state != TERMINAL) begin
                    pending <= 0;
                    if (state != IDLE)
                        finish(ABORTED);
                end else if (marker_error) begin
                    terminal_code <= ERR_INPUT_LENGTH;
                    terminal_consumed <= consumed + 13'd1;
                    terminal_produced <= produced;
                    consumed <= consumed + 13'd1;
                    state <= TERMINAL;
                end else begin
                    if (input_transfer)
                        consumed <= consumed + 13'd1;

                    case (state)
                        IDLE: begin
                            if (cmd_valid && cmd_ready) begin
                                compressed_length <= cmd_compressed_bytes;
                                decompressed_length <= cmd_decompressed_bytes;
                                consumed <= 0;
                                produced <= 0;
                                match_nibble <= 0;
                                segment_length <= 0;
                                remaining <= 0;
                                literal_length <= 0;
                                offset_low <= 0;
                                match_offset <= 0;
                                seen_match <= 0;
                                last_match_start <= 0;
                                pending <= 0;
                                output_data <= 0;
                                output_first <= 0;
                                output_last <= 0;
                                terminal_consumed <= 0;
                                terminal_produced <= 0;
                                terminal_code <= OK;
                                if (cmd_compressed_bytes == 0 ||
                                    cmd_compressed_bytes > MAX_COMPRESSED_BYTES) begin
                                    terminal_code <= ERR_COMPRESSED_BOUND;
                                    state <= TERMINAL;
                                end else if (cmd_decompressed_bytes >
                                             MAX_DECOMPRESSED_BYTES) begin
                                    terminal_code <= ERR_DECOMPRESSED_BOUND;
                                    state <= TERMINAL;
                                end else if (cmd_decompressed_bytes >
                                             HISTORY_BYTES) begin
                                    terminal_code <= ERR_HISTORY_BOUND;
                                    state <= TERMINAL;
                                end else begin
                                    state <= TOKEN;
                                end
                            end
                        end
                        TOKEN: begin
                            if (exhausted)
                                finish(ERR_TRUNCATED_TOKEN);
                            else if (input_transfer) begin
                                match_nibble <= s_data[3:0];
                                segment_length <= {12'b0, s_data[7:4]};
                                if (s_data[7:4] == 4'd15)
                                    state <= LITERAL_EXTENSION;
                                else
                                    state <= LITERAL_RESERVE;
                            end
                        end
                        LITERAL_EXTENSION, MATCH_EXTENSION: begin
                            if (exhausted) begin
                                if (state == LITERAL_EXTENSION)
                                    finish(ERR_TRUNCATED_LITERAL_EXTENSION);
                                else
                                    finish(ERR_TRUNCATED_MATCH_EXTENSION);
                            end else if (input_transfer) begin
                                if (extended_length > 17'd65535) begin
                                    terminal_code <= ERR_LENGTH_OVERFLOW;
                                    terminal_consumed <= consumed + 13'd1;
                                    terminal_produced <= produced;
                                    state <= TERMINAL;
                                end else begin
                                    segment_length <= extended_length[15:0];
                                    if (s_data != 8'd255) begin
                                        if (state == LITERAL_EXTENSION)
                                            state <= LITERAL_RESERVE;
                                        else
                                            state <= MATCH_RESERVE;
                                    end
                                end
                            end
                        end
                        LITERAL_RESERVE, MATCH_RESERVE: begin
                            if (prospective_end > MAX_DECOMPRESSED_BYTES)
                                finish(ERR_OUTPUT_LIMIT);
                            else if (prospective_end > HISTORY_BYTES)
                                finish(ERR_HISTORY_LIMIT);
                            else if (prospective_end > {4'b0, decompressed_length})
                                finish(ERR_DECLARED_OUTPUT);
                            else begin
                                remaining <= segment_length;
                                if (state == LITERAL_RESERVE) begin
                                    literal_length <= segment_length;
                                    if (segment_length == 0)
                                        state <= AFTER_LITERALS;
                                    else
                                        state <= LITERAL_FETCH;
                                end else begin
                                    seen_match <= 1;
                                    last_match_start <= produced;
                                    state <= COPY_FETCH;
                                end
                            end
                        end
                        LITERAL_FETCH: begin
                            if (exhausted)
                                finish(ERR_TRUNCATED_LITERALS);
                            else if (input_transfer) begin
                                output_data <= s_data;
                                output_first <= produced == 0;
                                output_last <= ({1'b0, produced} + 14'd1) ==
                                               {1'b0, decompressed_length};
                                pending <= 1;
                                state <= LITERAL_COMMIT;
                            end
                        end
                        LITERAL_COMMIT, COPY_COMMIT: begin
                            if (output_transfer) begin
                                pending <= 0;
                                produced <= produced + 13'd1;
                                remaining <= remaining - 16'd1;
                                if (state == LITERAL_COMMIT) begin
                                    if (remaining == 1)
                                        state <= AFTER_LITERALS;
                                    else
                                        state <= LITERAL_FETCH;
                                end else begin
                                    if (remaining == 1)
                                        state <= TOKEN;
                                    else
                                        state <= COPY_FETCH;
                                end
                            end
                        end
                        AFTER_LITERALS: begin
                            if (exhausted)
                                state <= FINALIZE;
                            else
                                state <= OFFSET_LOW;
                        end
                        OFFSET_LOW: begin
                            if (exhausted)
                                finish(ERR_TRUNCATED_OFFSET);
                            else if (input_transfer) begin
                                offset_low <= s_data;
                                state <= OFFSET_HIGH;
                            end
                        end
                        OFFSET_HIGH: begin
                            if (exhausted)
                                finish(ERR_TRUNCATED_OFFSET);
                            else if (input_transfer) begin
                                if (incoming_offset == 0 ||
                                    incoming_offset > {3'b0, produced}) begin
                                    if (incoming_offset == 0)
                                        terminal_code <= ERR_ZERO_OFFSET;
                                    else
                                        terminal_code <= ERR_OFFSET_RANGE;
                                    terminal_consumed <= consumed + 13'd1;
                                    terminal_produced <= produced;
                                    state <= TERMINAL;
                                end else begin
                                    match_offset <= incoming_offset;
                                    segment_length <= {12'b0, match_nibble} + 16'd4;
                                    if (match_nibble == 15)
                                        state <= MATCH_EXTENSION;
                                    else
                                        state <= MATCH_RESERVE;
                                end
                            end
                        end
                        COPY_FETCH: begin
                            // A new read follows the previous commit, including for overlap.
                            output_data <= history[read_address];
                            output_first <= produced == 0;
                            output_last <= ({1'b0, produced} + 14'd1) ==
                                           {1'b0, decompressed_length};
                            pending <= 1;
                            state <= COPY_COMMIT;
                        end
                        FINALIZE: begin
                            if (produced != decompressed_length)
                                finish(ERR_DECLARED_OUTPUT);
                            else if ((produced >= 5 && literal_length < 5) ||
                                     (seen_match &&
                                      ({1'b0, produced} <
                                       {1'b0, last_match_start} + 14'd12)))
                                finish(ERR_END_RULE);
                            else
                                finish(OK);
                        end
                        TERMINAL: begin
                            if (status_ready)
                                state <= IDLE;
                        end
                        default: begin
                            finish(ERR_END_RULE);
                        end
                    endcase
                end
            end
        end
    endgenerate
endmodule
