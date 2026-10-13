module mf_completion #(
    parameter integer SLOTS = 2,
    parameter integer PORTS = 3,
    parameter integer SLOT_W = (SLOTS > 1) ? $clog2(SLOTS) : 1
) (
    input  wire                       clk,
    input  wire                       rst,
    input  wire                       admit,
    input  wire [7:0]                 admit_tag,
    output wire                       admission_ready,
    output wire [SLOT_W-1:0]          allocation_slot,
    input  wire [PORTS-1:0]           complete_valid,
    input  wire [PORTS*SLOT_W-1:0]    complete_slot,
    input  wire [PORTS*32-1:0]        complete_data,
    input  wire [PORTS-1:0]           complete_error,
    output wire                       rsp_valid,
    input  wire                       rsp_ready,
    output wire [7:0]                 rsp_tag,
    output wire [31:0]                rsp_rdata,
    output wire                       rsp_error,
    output wire [31:0]                occupancy
);
    reg [SLOT_W-1:0] oldest, allocate;
    reg [SLOT_W:0] count;
    reg [7:0] tags [0:SLOTS-1];
    reg [31:0] data [0:SLOTS-1];
    reg errors [0:SLOTS-1];
    reg done [0:SLOTS-1];
    wire retire;
    integer i, p;

    assign admission_ready = !rst && (count < SLOTS);
    assign allocation_slot = allocate;
    assign occupancy = count;
    assign rsp_valid = !rst && (count != 0) && done[oldest];
    assign rsp_tag = rsp_valid ? tags[oldest] : 8'b0;
    assign rsp_rdata = rsp_valid ? data[oldest] : 32'b0;
    assign rsp_error = rsp_valid ? errors[oldest] : 1'b0;
    assign retire = rsp_valid && rsp_ready;

    always @(posedge clk) begin
        if (rst) begin
            oldest <= 0;
            allocate <= 0;
            count <= 0;
            for (i = 0; i < SLOTS; i = i + 1) begin
                tags[i] <= 0;
                data[i] <= 0;
                errors[i] <= 0;
                done[i] <= 0;
            end
        end else begin
            case ({admit, retire})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
            if (retire) begin
                done[oldest] <= 0;
                oldest <= (oldest == SLOTS-1) ? 0 : oldest + 1'b1;
            end
            if (admit) begin
                tags[allocate] <= admit_tag;
                data[allocate] <= 0;
                errors[allocate] <= 0;
                done[allocate] <= 0;
                allocate <= (allocate == SLOTS-1) ? 0 : allocate + 1'b1;
            end
            // Reserved slots make concurrent stores disjoint from admission/retirement.
            for (p = 0; p < PORTS; p = p + 1) begin
                if (complete_valid[p]) begin
                    data[complete_slot[p*SLOT_W +: SLOT_W]] <= complete_data[p*32 +: 32];
                    errors[complete_slot[p*SLOT_W +: SLOT_W]] <= complete_error[p];
                    done[complete_slot[p*SLOT_W +: SLOT_W]] <= 1;
                end
            end
        end
    end
endmodule
