module font_banks(input clk,input[6:0]glyph,input[3:0]row,col,output ink);
 (* syn_ramdecomp="area" *)reg[4:0]b0[0:1935],b1[0:1935],b2[0:1935];
 reg[14:0]q;reg[3:0]position;
 initial begin $readmemh("F:/Project/fpga/vision_base/results/xlr_recover_20261022/font_bank0.mem",b0);$readmemh("F:/Project/fpga/vision_base/results/xlr_recover_20261022/font_bank1.mem",b1);$readmemh("F:/Project/fpga/vision_base/results/xlr_recover_20261022/font_bank2.mem",b2); end
 always @(posedge clk)begin q<={b0[{glyph,row}],b1[{glyph,row}],b2[{glyph,row}]};position<=col;end
 assign ink=position!=15&&q[14-position];
endmodule
