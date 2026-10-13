module streaming_bilinear_scaler #(
    parameter integer MAX_WIDTH = 16,
    parameter integer MAX_HEIGHT = 12
) (
    input  wire clk,
    input  wire rst,
    input  wire s_valid,
    output wire s_ready,
    input  wire [7:0] s_data,
    input  wire s_sof,
    input  wire s_eof,
    output wire m_valid,
    input  wire m_ready,
    output wire [7:0] m_data,
    output wire m_sof,
    output wire m_eof,
    output wire [5:0] m_x,
    output wire [5:0] m_y,
    output wire [31:0] m_frame_id,
    input  wire csr_valid,
    output wire csr_ready,
    input  wire csr_write,
    input  wire [7:0] csr_addr,
    input  wire [31:0] csr_wdata,
    input  wire [3:0] csr_wstrb,
    output wire csr_rvalid,
    input  wire csr_rready,
    output wire [31:0] csr_rdata,
    output wire csr_error,
    output wire irq
);
    generate
        if (MAX_WIDTH < 1 || MAX_WIDTH > 32) begin : invalid_width
            initial $fatal(1, "PARAMETER_ERROR_MAX_WIDTH: expected 1..32");
            assign s_ready = 1'b0;
            assign m_valid = 1'b0;
            assign m_data = 8'd0;
            assign m_sof = 1'b0;
            assign m_eof = 1'b0;
            assign m_x = 6'd0;
            assign m_y = 6'd0;
            assign m_frame_id = 32'd0;
            assign csr_ready = 1'b0;
            assign csr_rvalid = 1'b0;
            assign csr_rdata = 32'd0;
            assign csr_error = 1'b0;
            assign irq = 1'b0;
        end else if (MAX_HEIGHT < 1 || MAX_HEIGHT > 32) begin : invalid_height
            initial $fatal(1, "PARAMETER_ERROR_MAX_HEIGHT: expected 1..32");
            assign s_ready = 1'b0;
            assign m_valid = 1'b0;
            assign m_data = 8'd0;
            assign m_sof = 1'b0;
            assign m_eof = 1'b0;
            assign m_x = 6'd0;
            assign m_y = 6'd0;
            assign m_frame_id = 32'd0;
            assign csr_ready = 1'b0;
            assign csr_rvalid = 1'b0;
            assign csr_rdata = 32'd0;
            assign csr_error = 1'b0;
            assign irq = 1'b0;
        end else begin : legal
            wire [5:0] iw, ih, ow, oh;
            wire [31:0] frame_id;
            wire busy, receiving, draining, start_frame, cancel_work;
            wire input_space, samples_ready, all_reserved, production_fault;
            wire [5:0] cursor_x, cursor_y, x0, x1, y0, y1;
            wire [7:0] p00, p01, p10, p11, pixel;
            wire input_fire = s_valid && s_ready;
            wire output_fire = m_valid && m_ready;

            assign s_ready = !rst && (draining || (receiving && input_space));

            scaler_frame_control #(
                .MAX_WIDTH(MAX_WIDTH), .MAX_HEIGHT(MAX_HEIGHT)
            ) frame_control (
                .clk(clk), .rst(rst),
                .csr_valid(csr_valid), .csr_ready(csr_ready),
                .csr_write(csr_write), .csr_addr(csr_addr),
                .csr_wdata(csr_wdata), .csr_wstrb(csr_wstrb),
                .csr_rvalid(csr_rvalid), .csr_rready(csr_rready),
                .csr_rdata(csr_rdata), .csr_error(csr_error), .irq(irq),
                .input_fire(input_fire), .input_sof(s_sof), .input_eof(s_eof),
                .output_fire(output_fire), .output_slot_valid(m_valid),
                .all_reserved(all_reserved), .production_fault(production_fault),
                .busy(busy), .receiving(receiving), .draining(draining),
                .start_frame(start_frame), .cancel_work(cancel_work),
                .input_width(iw), .input_height(ih),
                .output_width(ow), .output_height(oh), .frame_id(frame_id)
            );

            scaler_rows #(.MAX_WIDTH(MAX_WIDTH)) row_storage (
                .clk(clk), .rst(rst), .start_frame(start_frame),
                .cancel_work(cancel_work), .receiving(receiving),
                .all_reserved(all_reserved), .input_width(iw),
                .needed_y0(y0), .needed_y1(y1),
                .sample_x0(x0), .sample_x1(x1),
                .input_fire(input_fire), .input_pixel(s_data),
                .input_space(input_space), .samples_ready(samples_ready),
                .p00(p00), .p01(p01), .p10(p10), .p11(p11)
            );

            scaler_coordinates arithmetic (
                .input_width(iw), .input_height(ih),
                .output_width(ow), .output_height(oh),
                .output_x(cursor_x), .output_y(cursor_y),
                .x0(x0), .x1(x1), .y0(y0), .y1(y1),
                .p00(p00), .p01(p01), .p10(p10), .p11(p11), .pixel(pixel)
            );

            scaler_output output_reservation (
                .clk(clk), .rst(rst), .start_frame(start_frame),
                .cancel_work(cancel_work), .enable_work(busy),
                .samples_ready(samples_ready), .pixel(pixel),
                .output_width(ow), .output_height(oh), .frame_id(frame_id),
                .cursor_x(cursor_x), .cursor_y(cursor_y),
                .all_reserved(all_reserved), .production_fault(production_fault),
                .m_valid(m_valid), .m_ready(m_ready), .m_data(m_data),
                .m_sof(m_sof), .m_eof(m_eof), .m_x(m_x), .m_y(m_y),
                .m_frame_id(m_frame_id)
            );
        end
    endgenerate
endmodule
