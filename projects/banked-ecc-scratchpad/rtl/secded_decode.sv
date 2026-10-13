module secded_decode (
    input wire [38:0] code,
    output reg [31:0] data,
    output reg [38:0] repaired_code,
    output reg corrected,
    output reg uncorrectable
);
    integer p, d;
    reg [5:0] syndrome;
    reg total_parity;
    always @* begin
        syndrome = 0;
        for (p = 1; p <= 38; p = p + 1)
            if (code[p-1]) syndrome = syndrome ^ p;
        total_parity = ^code;
        corrected = 0;
        uncorrectable = 0;
        repaired_code = code;
        if (total_parity) begin
            if (syndrome == 0) begin
                repaired_code[38] = ~code[38];
                corrected = 1;
            end else if (syndrome <= 38) begin
                repaired_code[syndrome-1] = ~code[syndrome-1];
                corrected = 1;
            end else begin
                uncorrectable = 1;
            end
        end else if (syndrome != 0) begin
            uncorrectable = 1;
        end
        data = 0;
        d = 0;
        for (p = 1; p <= 38; p = p + 1) begin
            if ((p != 1) && (p != 2) && (p != 4) &&
                (p != 8) && (p != 16) && (p != 32)) begin
                data[d] = repaired_code[p-1];
                d = d + 1;
            end
        end
        if (uncorrectable) data = 0;
    end
endmodule
