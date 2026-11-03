// CSI-2 RAW10, four packed pixels/valid clock, native 1920x1080 BGGR.
// Regenerate active-frame VS even when the receiver presents a short FS pulse.
module camera_native_1080(input clk,rst_n,vs,hs,valid,input[39:0]data,
 output reg o_vs=0,output o_hs,o_valid,output[31:0]o_data);
reg vs_q=0,hs_q=0,line_has_data=0;
reg[10:0]lines=0;
assign o_hs=hs;
assign o_valid=valid&&hs;
assign o_data={data[9:2],data[19:12],data[29:22],data[39:32]};
always @(posedge clk)begin
 vs_q<=vs;hs_q<=hs;
 if(!rst_n)begin vs_q<=0;hs_q<=0;lines<=0;line_has_data<=0;o_vs<=0;end
 else if(vs&&!vs_q)begin lines<=0;line_has_data<=0;o_vs<=1;end
 else if(hs_q&&!hs)begin
  line_has_data<=0;
  if(line_has_data)begin lines<=lines+1'b1;if(lines==1079)o_vs<=0;end
 end else if(valid&&hs)line_has_data<=1;
end
endmodule
