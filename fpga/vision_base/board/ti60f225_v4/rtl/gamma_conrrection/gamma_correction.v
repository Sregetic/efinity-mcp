// Fixed-curve, one-pixel-per-clock gamma lookup. Supported input widths: 8/10.
// Two initialized dual-port ROMs provide three independent RGB read ports.
// No runtime table copy: the curve is part of the FPGA configuration image.
module gamma_correction #(
    parameter DATA_WIDTH = 10,
    parameter GAMMA_CURVE = "2P2.mem"
)(
    input i_pclk,
    input i_rstn,
    input i_valid,
    input i_hs,
    input i_vs,
    input [DATA_WIDTH-1:0] i_red,
    input [DATA_WIDTH-1:0] i_green,
    input [DATA_WIDTH-1:0] i_blue,
    output reg [DATA_WIDTH-1:0] o_red,
    output reg [DATA_WIDTH-1:0] o_green,
    output reg [DATA_WIDTH-1:0] o_blue,
    output reg o_valid,
    output reg o_hs,
    output reg o_vs
);
    wire [9:0] addr_r, addr_g, addr_b;
    wire [9:0] gamma_r, gamma_g, gamma_b;

    generate
        if (DATA_WIDTH == 10) begin: input_10bit
            assign addr_r = i_red;
            assign addr_g = i_green;
            assign addr_b = i_blue;
        end else begin: input_8bit
            // Preserve the legacy bit replication, NOT simply input << 2.
            assign addr_r = {i_red, i_red[7:6]};
            assign addr_g = {i_green, i_green[7:6]};
            assign addr_b = {i_blue, i_blue[7:6]};
        end
    endgenerate

    // OUTPUT_REG=FALSE keeps the synchronous RAM read at ONE clock edge.
    // Using TRUE here would add a cycle and break legacy_delay1/2/3 in top.
    true_dual_port_ram #(
        .DATA_WIDTH(10), .ADDR_WIDTH(10),
        .WRITE_MODE_1("READ_FIRST"), .WRITE_MODE_2("READ_FIRST"),
        .OUTPUT_REG_1("FALSE"), .OUTPUT_REG_2("FALSE"),
        .RAM_INIT_FILE(GAMMA_CURVE)
    ) rom_rg (
        .we1(1'b0), .we2(1'b0), .clka(i_pclk), .clkb(i_pclk),
        .din1(10'b0), .din2(10'b0), .addr1(addr_r), .addr2(addr_g),
        .dout1(gamma_r), .dout2(gamma_g)
    );
    true_dual_port_ram #(
        .DATA_WIDTH(10), .ADDR_WIDTH(10),
        .WRITE_MODE_1("READ_FIRST"), .WRITE_MODE_2("READ_FIRST"),
        .OUTPUT_REG_1("FALSE"), .OUTPUT_REG_2("FALSE"),
        .RAM_INIT_FILE(GAMMA_CURVE)
    ) rom_b (
        .we1(1'b0), .we2(1'b0), .clka(i_pclk), .clkb(i_pclk),
        .din1(10'b0), .din2(10'b0), .addr1(addr_b), .addr2(10'b0),
        .dout1(gamma_b), .dout2()
    );

    // Control is sampled on the same edge as each ROM address. Synchronous,
    // active-low reset and HS/VS propagation match the original module.
    always @(posedge i_pclk) begin
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

    // Mask registered ROM outputs, rather than adding another output register.
    // Blanking and reset must output black even while the ROM continues reading.
    always @* begin
        o_red = {DATA_WIDTH{1'b0}};
        o_green = {DATA_WIDTH{1'b0}};
        o_blue = {DATA_WIDTH{1'b0}};
        if (o_valid) begin
            if (DATA_WIDTH == 10) begin
                o_red = gamma_r;
                o_green = gamma_g;
                o_blue = gamma_b;
            end else begin
                o_red = gamma_r[9:2];
                o_green = gamma_g[9:2];
                o_blue = gamma_b[9:2];
            end
        end
    end
endmodule
