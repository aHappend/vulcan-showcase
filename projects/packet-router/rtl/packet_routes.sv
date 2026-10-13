module packet_routes (
    input  wire         clk,
    input  wire         rst,
    input  wire         write_valid,
    input  wire [3:0]   write_tag,
    input  wire [8:0]   write_entry,
    output wire [143:0] entries
);
    reg [8:0] table_entry [0:15];
    integer tag;
    genvar g;

    generate
        for (g = 0; g < 16; g = g + 1) begin : pack_entries
            assign entries[g*9 +: 9] = table_entry[g];
        end
    endgenerate

    always @(posedge clk) begin
        if (rst) begin
            for (tag = 0; tag < 16; tag = tag + 1)
                table_entry[tag] <= 9'b0;
        end else if (write_valid) begin
            table_entry[write_tag] <= write_entry;
        end
    end
endmodule
