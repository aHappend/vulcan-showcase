module scaler_coordinates (
    input  wire [5:0] input_width,
    input  wire [5:0] input_height,
    input  wire [5:0] output_width,
    input  wire [5:0] output_height,
    input  wire [5:0] output_x,
    input  wire [5:0] output_y,
    output reg  [5:0] x0,
    output reg  [5:0] x1,
    output reg  [5:0] y0,
    output reg  [5:0] y1,
    input  wire [7:0] p00,
    input  wire [7:0] p01,
    input  wire [7:0] p10,
    input  wire [7:0] p11,
    output reg  [7:0] pixel
);
    reg [17:0] numerator_x, numerator_y;
    reg [12:0] coordinate_x, coordinate_y;
    reg [7:0] fraction_x, fraction_y;
    reg [8:0] weight_x0, weight_x1, weight_y0, weight_y1;
    reg [16:0] horizontal0, horizontal1;
    reg [26:0] vertical, rounded, narrowed;

    always @* begin
        numerator_x = ({12'b0, output_x} *
                       {12'b0, (input_width - 6'd1)}) << 8;
        numerator_y = ({12'b0, output_y} *
                       {12'b0, (input_height - 6'd1)}) << 8;
        coordinate_x = 13'd0;
        coordinate_y = 13'd0;
        if (output_width > 6'd1)
            coordinate_x = numerator_x / (output_width - 6'd1);
        if (output_height > 6'd1)
            coordinate_y = numerator_y / (output_height - 6'd1);
        x0 = {1'b0, coordinate_x[12:8]};
        y0 = {1'b0, coordinate_y[12:8]};
        x1 = x0;
        y1 = y0;
        if (x0 + 6'd1 < input_width)
            x1 = x0 + 6'd1;
        if (y0 + 6'd1 < input_height)
            y1 = y0 + 6'd1;
        fraction_x = coordinate_x[7:0];
        fraction_y = coordinate_y[7:0];
    end

    always @* begin
        weight_x1 = {1'b0, fraction_x};
        weight_x0 = 9'd256 - weight_x1;
        weight_y1 = {1'b0, fraction_y};
        weight_y0 = 9'd256 - weight_y1;
        horizontal0 = {9'b0, p00} * {8'b0, weight_x0} +
                      {9'b0, p01} * {8'b0, weight_x1};
        horizontal1 = {9'b0, p10} * {8'b0, weight_x0} +
                      {9'b0, p11} * {8'b0, weight_x1};
        vertical = {10'b0, horizontal0} * {18'b0, weight_y0} +
                   {10'b0, horizontal1} * {18'b0, weight_y1};
        rounded = vertical + 27'd32768;
        narrowed = rounded >> 16;
        if (narrowed > 27'd255)
            pixel = 8'd255;
        else
            pixel = narrowed[7:0];
    end
endmodule
