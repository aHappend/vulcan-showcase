module secded_encode (
    input wire [31:0] data,
    output reg [38:0] code
);
    integer p, d, k;
    reg parity;
    always @* begin
        code = 39'b0;
        d = 0;
        for (p = 1; p <= 38; p = p + 1) begin
            if ((p != 1) && (p != 2) && (p != 4) &&
                (p != 8) && (p != 16) && (p != 32)) begin
                code[p-1] = data[d];
                d = d + 1;
            end
        end
        for (k = 0; k < 6; k = k + 1) begin
            parity = 1'b0;
            for (p = 1; p <= 38; p = p + 1)
                if ((p & (1 << k)) != 0)
                    parity = parity ^ code[p-1];
            code[(1 << k)-1] = parity;
        end
        code[38] = ^code[37:0];
    end
endmodule
