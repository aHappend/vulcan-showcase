module dma_read_engine (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [31:0] start_address,
    input  wire [8:0]  start_words,
    input  wire        start_increment,
    input  wire        run,
    input  wire        discard,
    input  wire        fifo_room,
    output wire        data_valid,
    output wire [31:0] data,
    output wire        response_error,
    output wire        settled,
    output wire        rd_req_valid,
    input  wire        rd_req_ready,
    output wire [31:0] rd_req_addr,
    input  wire        rd_rsp_valid,
    output wire        rd_rsp_ready,
    input  wire [31:0] rd_rsp_data,
    input  wire        rd_rsp_error
);
    reg request_held;
    reg response_pending;
    reg [31:0] next_address;
    reg [31:0] held_address;
    reg [8:0] remaining;
    reg increment;
    wire create_request;
    wire request_fire;
    wire response_fire;

    assign rd_req_valid = request_held && !rst;
    assign rd_req_addr = held_address;
    // The engine reserves a FIFO slot before asserting each read request.
    assign rd_rsp_ready = response_pending && !rst;
    assign request_fire = rd_req_valid && rd_req_ready;
    assign response_fire = rd_rsp_valid && rd_rsp_ready;
    assign response_error = response_fire && rd_rsp_error;
    assign data_valid = response_pending && rd_rsp_valid &&
                        !rd_rsp_error && !discard && !rst;
    assign data = rd_rsp_data;
    assign settled = !request_held && !response_pending;
    assign create_request = run && fifo_room && (remaining != 0) &&
                            !request_held && !response_pending && !rst;

    always @(posedge clk) begin
        if (rst) begin
            request_held <= 1'b0;
            response_pending <= 1'b0;
            next_address <= 0;
            held_address <= 0;
            remaining <= 0;
            increment <= 1'b0;
        end else if (start) begin
            request_held <= 1'b0;
            response_pending <= 1'b0;
            next_address <= start_address;
            held_address <= 0;
            remaining <= start_words;
            increment <= start_increment;
        end else begin
            if (create_request) begin
                request_held <= 1'b1;
                held_address <= next_address;
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
