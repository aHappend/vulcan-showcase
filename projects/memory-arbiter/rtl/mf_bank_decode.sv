module mf_bank_decode #(
    parameter integer BANKS = 2
) (
    input  wire [15:0] addr,
    output wire        aligned,
    output wire        bank
);
    assign aligned = (addr[1:0] == 2'b00);
    assign bank = (BANKS == 2) ? addr[2] : 1'b0;
endmodule
