module lcd_rgb_pack(input clk,rst_n,enable,source,input vs,hs,de,input[23:0]rgb,
 output reg ovs,ohs,valid,output reg[63:0]data,
 output reg[31:0]frames,output reg[15:0]line_pairs,output reg fault);
reg[23:0]first=0;reg phase=0,vq=0,dq=0,src=0,armed=0;reg[15:0]pairs=0;
wire[23:0]bgr={rgb[7:0],rgb[15:8],rgb[23:16]};
always @(posedge clk)begin
 vq<=vs;dq<=de;src<=source;valid<=0;ovs<=vs;ohs<=hs;
 if(!rst_n||!enable||source!=src)begin phase<=0;armed<=0;pairs<=0;ovs<=0;ohs<=0;end
 else begin
  if(vs&&!vq)begin armed<=1;frames<=frames+1'b1;end
  if(de&&armed)begin phase<=~phase;if(!phase)first<=bgr;else begin data<={16'b0,bgr,first};valid<=1;pairs<=pairs+1'b1;end end
  else phase<=0;
  if(dq&&!de&&armed)begin line_pairs<=pairs;if(pairs!=960||phase)fault<=1;pairs<=0;end
 end
 if(!rst_n)begin frames<=0;line_pairs<=0;fault<=0;vq<=0;dq<=0;src<=0;data<=0;end
end
endmodule
