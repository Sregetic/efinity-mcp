module gamma_correction
#(parameter DATA_WIDTH = 10, parameter GAMMA_CURVE = "2P2.mem")
(
    input i_pclk, i_rstn, i_valid, i_hs, i_vs,
    input [DATA_WIDTH-1:0] i_red, i_green, i_blue,
    output reg [DATA_WIDTH-1:0] o_red, o_green, o_blue,
    output reg o_valid, o_hs, o_vs
);
// Immutable curve: synchronous ROM reads replace the continuously rewritten,
// three-read-port register array. Independent arrays permit ROM replication.
reg [9:0] red_lut [0:1023];
reg [9:0] green_lut [0:1023];
reg [9:0] blue_lut [0:1023];
initial begin
    $readmemh(GAMMA_CURVE, red_lut);
    $readmemh(GAMMA_CURVE, green_lut);
    $readmemh(GAMMA_CURVE, blue_lut);
end
wire [9:0] red_addr, green_addr, blue_addr;
generate
    if (DATA_WIDTH == 10) begin : ten_bit
        assign red_addr = i_red;
        assign green_addr = i_green;
        assign blue_addr = i_blue;
    end else begin : eight_bit
        // Preserve the original address expansion and output truncation.
        assign red_addr = {i_red, i_red[7:6]};
        assign green_addr = {i_green, i_green[7:6]};
        assign blue_addr = {i_blue, i_blue[7:6]};
    end
endgenerate
reg [9:0] red_q, green_q, blue_q;
// No data reset on ROM read registers, so block RAM inference stays possible.
// The delayed valid flag masks data during reset and blanking.
always @(posedge i_pclk) begin
    red_q <= red_lut[red_addr];
    green_q <= green_lut[green_addr];
    blue_q <= blue_lut[blue_addr];
    if (!i_rstn) begin
        o_valid <= 1'b0;
        o_hs <= 1'b0;
        o_vs <= 1'b0;
    end else begin
        o_valid <= i_valid;
        o_hs <= i_hs;
        o_vs <= i_vs;
    end
end
// Retain one-clock latency and zero RGB during blanking.
always @* begin
    o_red = {DATA_WIDTH{1'b0}};
    o_green = {DATA_WIDTH{1'b0}};
    o_blue = {DATA_WIDTH{1'b0}};
    if (o_valid) begin
        if (DATA_WIDTH == 10) begin
            o_red = red_q;
            o_green = green_q;
            o_blue = blue_q;
        end else begin
            o_red = red_q[9:2];
            o_green = green_q[9:2];
            o_blue = blue_q[9:2];
        end
    end
end
endmodule
