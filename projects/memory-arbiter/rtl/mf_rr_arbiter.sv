module mf_rr_arbiter #(
    parameter integer CLIENTS = 3,
    parameter integer CLIENT_W = (CLIENTS > 1) ? $clog2(CLIENTS) : 1
) (
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  available,
    input  wire [CLIENTS-1:0]    eligible,
    output reg  [CLIENTS-1:0]    grant,
    output reg  [CLIENT_W-1:0]   winner,
    output wire                  selected
);
    reg [CLIENT_W-1:0] next_client;
    reg found;
    integer offset, index;

    assign selected = |grant;

    always @* begin
        grant = 0;
        winner = 0;
        found = 0;
        index = 0;
        for (offset = 0; offset < CLIENTS; offset = offset + 1) begin
            index = next_client + offset;
            if (index >= CLIENTS)
                index = index - CLIENTS;
            if (!rst && available && !found && eligible[index]) begin
                grant[index] = 1'b1;
                winner = index;
                found = 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (rst)
            next_client <= 0;
        else if (selected)
            next_client <= (winner == CLIENTS-1) ? 0 : winner + 1'b1;
    end
endmodule
