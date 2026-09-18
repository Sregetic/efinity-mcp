// Common gain from max(R,G,B): lift brightness without independently changing
// RGB ratios. Gain is capped at 4x near black; (0,0,0) remains exactly black.
module rgb_chroma_tone #(
 parameter GAIN_FILE="./rtl/gamma_conrrection/chroma_tone_gain_q8.mem"
)(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,
 output reg ode,ohs,ovs,output reg[23:0]rgb,linear_rgb);
reg[15:0]gain_rom[0:255];
initial $readmemh(GAIN_FILE,gain_rom);
wire[7:0]rgmax=(r>g)?r:g;
wire[7:0]peak=(rgmax>b)?rgmax:b;
reg[7:0]peak1=0;reg[23:0]rgb1=0,rgb2=0;reg[15:0]gain2=0;
reg[2:0]sync1=0,sync2=0;
wire[23:0]pr=rgb2[23:16]*gain2+24'd128;
wire[23:0]pg=rgb2[15:8]*gain2+24'd128;
wire[23:0]pb=rgb2[7:0]*gain2+24'd128;
wire[7:0]rr=(|pr[23:16])?8'd255:pr[15:8];
wire[7:0]gg=(|pg[23:16])?8'd255:pg[15:8];
wire[7:0]bb=(|pb[23:16])?8'd255:pb[15:8];
always @(posedge clk)begin
 peak1<=peak;rgb1<={r,g,b};sync1<={de,hs,vs};
 gain2<=gain_rom[peak1];rgb2<=rgb1;sync2<=sync1;
 {ode,ohs,ovs}<=sync2;rgb<=sync2[2]?{rr,gg,bb}:24'd0;linear_rgb<=sync2[2]?rgb2:24'd0;
 if(!rst_n)begin sync1<=0;sync2<=0;{ode,ohs,ovs}<=0;rgb<=0;linear_rgb<=0;end
end
endmodule
