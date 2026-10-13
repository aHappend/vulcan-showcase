module scaler_rows #(
    parameter integer MAX_WIDTH = 16
) (
    input  wire clk,
    input  wire rst,
    input  wire start_frame,
    input  wire cancel_work,
    input  wire receiving,
    input  wire all_reserved,
    input  wire [5:0] input_width,
    input  wire [5:0] needed_y0,
    input  wire [5:0] needed_y1,
    input  wire [5:0] sample_x0,
    input  wire [5:0] sample_x1,
    input  wire input_fire,
    input  wire [7:0] input_pixel,
    output reg  input_space,
    output wire samples_ready,
    output reg  [7:0] p00,
    output reg  [7:0] p01,
    output reg  [7:0] p10,
    output reg  [7:0] p11
);
    reg [7:0] row0 [0:MAX_WIDTH-1];
    reg [7:0] row1 [0:MAX_WIDTH-1];
    reg used0, used1, complete0, complete1;
    reg [5:0] tag0, tag1, input_x, input_y;
    wire live0 = used0 && (tag0 == needed_y0 || tag0 == needed_y1);
    wire live1 = used1 && (tag1 == needed_y0 || tag1 == needed_y1);
    wire match00 = used0 && complete0 && tag0 == needed_y0;
    wire match01 = used1 && complete1 && tag1 == needed_y0;
    wire match10 = used0 && complete0 && tag0 == needed_y1;
    wire match11 = used1 && complete1 && tag1 == needed_y1;
    wire wanted = !all_reserved &&
                  (input_y == needed_y0 || input_y == needed_y1);
    reg bank;
    reg bank_available;

    assign samples_ready = (match00 || match01) && (match10 || match11);

    always @* begin
        bank = 1'b0;
        bank_available = 1'b1;
        if (used0 && tag0 == input_y)
            bank = 1'b0;
        else if (used1 && tag1 == input_y)
            bank = 1'b1;
        else if (!live0)
            bank = 1'b0;
        else if (!live1)
            bank = 1'b1;
        else
            bank_available = 1'b0;

        input_space = 1'b0;
        if (receiving) begin
            if (all_reserved || input_y < needed_y0)
                input_space = 1'b1;
            else if (wanted)
                input_space = bank_available;
        end

        p00 = 8'd0;
        p01 = 8'd0;
        p10 = 8'd0;
        p11 = 8'd0;
        if (samples_ready) begin
            if (match00) begin
                p00 = row0[sample_x0];
                p01 = row0[sample_x1];
            end else begin
                p00 = row1[sample_x0];
                p01 = row1[sample_x1];
            end
            if (match10) begin
                p10 = row0[sample_x0];
                p11 = row0[sample_x1];
            end else begin
                p10 = row1[sample_x0];
                p11 = row1[sample_x1];
            end
        end
    end

    always @(posedge clk) begin
        if (rst || start_frame) begin
            used0 <= 1'b0;
            used1 <= 1'b0;
            complete0 <= 1'b0;
            complete1 <= 1'b0;
            tag0 <= 6'd0;
            tag1 <= 6'd0;
            input_x <= 6'd0;
            input_y <= 6'd0;
        end else if (cancel_work) begin
            used0 <= 1'b0;
            used1 <= 1'b0;
            complete0 <= 1'b0;
            complete1 <= 1'b0;
        end else if (receiving && input_fire) begin
            if (input_x == input_width - 6'd1) begin
                input_x <= 6'd0;
                input_y <= input_y + 6'd1;
            end else
                input_x <= input_x + 6'd1;
            if (wanted && bank_available) begin
                if (!bank) begin
                    row0[input_x] <= input_pixel;
                    if (input_x == 6'd0) begin
                        used0 <= 1'b1;
                        tag0 <= input_y;
                        complete0 <= 1'b0;
                    end
                    if (input_x == input_width - 6'd1)
                        complete0 <= 1'b1;
                end else begin
                    row1[input_x] <= input_pixel;
                    if (input_x == 6'd0) begin
                        used1 <= 1'b1;
                        tag1 <= input_y;
                        complete1 <= 1'b0;
                    end
                    if (input_x == input_width - 6'd1)
                        complete1 <= 1'b1;
                end
            end
        end
    end
endmodule
