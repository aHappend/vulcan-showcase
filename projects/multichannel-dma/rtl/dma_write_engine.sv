module dma_write_engine (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [31:0] start_address,
    input  wire [8:0]  start_words,
    input  wire        start_increment,
    input  wire        run,
    input  wire        data_valid,
    output wire        data_ready,
    input  wire [31:0] data,
    output wire        response_error,
    output wire        successful_word,
    output wire        settled,
    output wire        wr_req_valid,
    input  wire        wr_req_ready,
    output wire [31:0] wr_req_addr,
    output wire [31:0] wr_req_data,
    output wire [3:0]  wr_req_strb,
    input  wire        wr_rsp_valid,
    output wire        wr_rsp_ready,
    input  wire        wr_rsp_error
);
    reg request_held;
    reg response_pending;
    reg [31:0] next_address;
    reg [31:0] held_address;
    reg [31:0] held_data;
    reg [8:0] remaining;
    reg increment;
    wire take_word;
    wire request_fire;
    wire response_fire;

    assign wr_req_valid = request_held && !rst;
    assign wr_req_addr = held_address;
    assign wr_req_data = held_data;
    assign wr_req_strb = 4'hf;
    assign wr_rsp_ready = response_pending && !rst;
    assign request_fire = wr_req_valid && wr_req_ready;
    assign response_fire = wr_rsp_valid && wr_rsp_ready;
    assign response_error = response_fire && wr_rsp_error;
    assign successful_word = response_fire && !wr_rsp_error;
    assign settled = !request_held && !response_pending;
    assign data_ready = run && (remaining != 0) && !request_held &&
                        !response_pending && !rst;
    assign take_word = data_valid && data_ready;

    always @(posedge clk) begin
        if (rst) begin
            request_held <= 1'b0;
            response_pending <= 1'b0;
            next_address <= 0;
            held_address <= 0;
            held_data <= 0;
            remaining <= 0;
            increment <= 1'b0;
        end else if (start) begin
            request_held <= 1'b0;
            response_pending <= 1'b0;
            next_address <= start_address;
            held_address <= 0;
            held_data <= 0;
            remaining <= start_words;
            increment <= start_increment;
        end else begin
            if (take_word) begin
                request_held <= 1'b1;
                held_address <= next_address;
                held_data <= data;
            end
            if (request_fire) begin
                request_held <= 1'b0;
                response_pending <= 1'b1;
                remaining <= remaining - 1'b1;
                if (increment)
                    next_address <= next_address + 32'd4;
            end
            if (response_fire)
                response_pending <= 1'b0;
        end
    end
endmodule
