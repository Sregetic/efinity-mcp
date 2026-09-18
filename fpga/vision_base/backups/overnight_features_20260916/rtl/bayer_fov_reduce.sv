// 2560x1440 -> 1920x1080, separable area filtering on each Bayer sublattice.
// Per 4 same-color samples, emit (3a+b)/4, (b+c)/2, (c+3d)/4.
module bayer_fov_reduce(input clk,input rst_n,input vs,input hs,input valid,input [31:0] data,
 output reg o_vs=0,output reg o_hs=0,output reg o_valid=0,output reg [31:0] o_data=0);
function automatic [7:0] blend(input [7:0] a,input [7:0] b,input [1:0] phase);
 reg[9:0] t;
 begin
 case(phase)
  0:t=({2'b0,a}<<1)+{2'b0,a}+{2'b0,b}+10'd2;
  1:t=({2'b0,a}<<1)+({2'b0,b}<<1)+10'd2;
  default:t={2'b0,a}+({2'b0,b}<<1)+{2'b0,b}+10'd2;
 endcase
 blend=t[9:2];
 end
endfunction
reg[47:0] line0[0:639],line1[0:639],line2[0:639],line3[0:639];
reg[47:0] line4[0:639],line5[0:639],line6[0:639],line7[0:639];
reg[47:0] q0,q1,q2,q3,q4,q5,q6,q7;
reg vs_q=0,hs_q=0,odd=0;
reg[31:0] first=0;
reg[8:0] wr_group=0;
reg[2:0] wr_row=0;
reg[7:0] wr_seq=0,rd_seq=0;
reg overrun=0;
wire[9:0] wr_addr=(wr_seq[0]?10'd320:10'd0)+wr_group;
wire[47:0] horizontal={blend(first[31:24],first[15:8],0),blend(first[23:16],first[7:0],0),
 blend(first[15:8],data[31:24],1),blend(first[7:0],data[23:16],1),
 blend(data[31:24],data[15:8],2),blend(data[23:16],data[7:0],2)};
always @(posedge clk)begin
 vs_q<=vs;hs_q<=hs;
 if(!rst_n || (vs && !vs_q))begin wr_seq<=0;wr_row<=0;wr_group<=0;odd<=0;overrun<=0;end
 else if(hs_q && !hs)begin
  wr_group<=0;odd<=0;
  if(wr_row==7)begin
   if((wr_seq-rd_seq)>=1)overrun<=1;
   wr_seq<=wr_seq+1'b1;
  end
  wr_row<=wr_row+1'b1;
 end else if(valid && hs)begin
  odd<=~odd;
  if(!odd)first<=data;
  else begin
   wr_group<=wr_group+1'b1;
   case(wr_row)
    0:line0[wr_addr]<=horizontal;1:line1[wr_addr]<=horizontal;
    2:line2[wr_addr]<=horizontal;3:line3[wr_addr]<=horizontal;
    4:line4[wr_addr]<=horizontal;5:line5[wr_addr]<=horizontal;
    6:line6[wr_addr]<=horizontal;7:line7[wr_addr]<=horizontal;
   endcase
  end
 end
end
reg[2:0] state=0,out_row=0;
reg[8:0] rd_group=0;
reg[15:0] half=0;
reg half_valid=0,spill_valid=0;
reg[31:0] spill=0;
wire[9:0] rd_addr=(rd_seq[0]?10'd320:10'd0)+rd_group;
always @(posedge clk)begin
 q0<=line0[rd_addr];q1<=line1[rd_addr];q2<=line2[rd_addr];q3<=line3[rd_addr];
 q4<=line4[rd_addr];q5<=line5[rd_addr];q6<=line6[rd_addr];q7<=line7[rd_addr];
end
reg[47:0] a,b;
always @*begin
 case(out_row)
 0:begin a=q0;b=q2;end 1:begin a=q1;b=q3;end
 2:begin a=q2;b=q4;end 3:begin a=q3;b=q5;end
 4:begin a=q4;b=q6;end default:begin a=q5;b=q7;end
 endcase
end
wire[47:0] filtered;
genvar k;
generate for(k=0;k<6;k=k+1)begin:g_filter
 assign filtered[8*k+:8]=blend(a[8*k+:8],b[8*k+:8],out_row[2:1]);
end endgenerate
// Regenerate an active-high output frame. Input VS may be a short pulse;
// keep the output frame open until all180 eight-line blocks have drained.
always @(posedge clk)begin
 if(!rst_n)o_vs<=0;
 else if(vs && !vs_q)o_vs<=1;
 else if(rd_seq==8'd180 && state==0)o_vs<=0;
end
// READ(1), EMIT(2), FLUSH(3), line gap(4). Memory read is one cycle.
always @(posedge clk)begin
 o_valid<=0;
 if(!rst_n || (vs && !vs_q))begin
  state<=0;out_row<=0;rd_group<=0;rd_seq<=0;o_hs<=0;half_valid<=0;spill_valid<=0;
 end else case(state)
 0:begin o_hs<=0;if(rd_seq!=wr_seq)begin state<=1;out_row<=0;rd_group<=0;end end
 1:begin
  o_hs<=1;
  if(spill_valid)begin o_valid<=1;o_data<=spill;spill_valid<=0;end
  state<=2;
 end
 2:begin
  o_valid<=1;
  if(!half_valid)begin o_data<=filtered[47:16];half<=filtered[15:0];half_valid<=1;end
  else begin o_data<={half,filtered[47:32]};spill<=filtered[31:0];spill_valid<=1;half_valid<=0;end
  if(rd_group==319)state<=3;else begin rd_group<=rd_group+1'b1;state<=1;end
 end
 3:begin o_valid<=spill_valid;o_data<=spill;spill_valid<=0;state<=4;end
 4:begin
  o_hs<=0;rd_group<=0;
  if(out_row==5)begin rd_seq<=rd_seq+1'b1;state<=0;end
  else begin out_row<=out_row+1'b1;state<=1;end
 end
 default:state<=0;
 endcase
end
endmodule
