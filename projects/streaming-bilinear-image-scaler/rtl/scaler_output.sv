module scaler_output (
    input  wire clk,
    input  wire rst,
    input  wire start_frame,
    input  wire cancel_work,
    input  wire enable_work,
    input  wire samples_ready,
    input  wire [7:0] pixel,
    input  wire [5:0] output_width,
    input  wire [5:0] output_height,
    input  wire [31:0] frame_id,
    output reg  [5:0] cursor_x,
    output reg  [5:0] cursor_y,
    output reg  all_reserved,
    output wire production_fault,
    output reg  m_valid,
    input  wire m_ready,
    output reg  [7:0] m_data,
    output reg  m_sof,
    output reg  m_eof,
    output reg  [5:0] m_x,
    output reg  [5:0] m_y,
    output reg  [31:0] m_frame_id
);
    reg [11:0] reserved_pixels;
    wire [11:0] target_pixels =
        {6'b0, output_width} * {6'b0, output_height};
    wire want_reservation = enable_work && !all_reserved && samples_ready &&
                            (!m_valid || m_ready);
    assign production_fault = want_reservation &&
                              reserved_pixels >= target_pixels;
    wire reserve_pixel = want_reservation && !cancel_work && !production_fault;

    always @(posedge clk) begin
        if (rst || start_frame) begin
            cursor_x <= 6'd0;
            cursor_y <= 6'd0;
            all_reserved <= 1'b0;
            reserved_pixels <= 12'd0;
            m_valid <= 1'b0;
            m_data <= 8'd0;
            m_sof <= 1'b0;
            m_eof <= 1'b0;
            m_x <= 6'd0;
            m_y <= 6'd0;
            m_frame_id <= 32'd0;
        end else begin
            if (m_valid && m_ready)
                m_valid <= 1'b0;
            if (cancel_work)
                all_reserved <= 1'b1;
            if (reserve_pixel) begin
                m_valid <= 1'b1;
                m_data <= pixel;
                m_sof <= cursor_x == 6'd0 && cursor_y == 6'd0;
                m_eof <= cursor_x == output_width - 6'd1 &&
                         cursor_y == output_height - 6'd1;
                m_x <= cursor_x;
                m_y <= cursor_y;
                m_frame_id <= frame_id;
                reserved_pixels <= reserved_pixels + 12'd1;
                if (cursor_x == output_width - 6'd1) begin
                    cursor_x <= 6'd0;
                    if (cursor_y == output_height - 6'd1)
                        all_reserved <= 1'b1;
                    else
                        cursor_y <= cursor_y + 6'd1;
                end else
                    cursor_x <= cursor_x + 6'd1;
            end
        end
    end
endmodule
