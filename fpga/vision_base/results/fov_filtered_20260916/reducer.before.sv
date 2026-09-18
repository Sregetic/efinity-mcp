// Full-FOV diagnostic: retain three of every four Bayer 2x2 blocks.
// MSB-first RAW8 words. Spatial selection is nearest-block, not filtered resizing.
module bayer_fov_reduce(input clk,input rst_n,input vs,input hs,input valid,input [31:0] data,
 output reg o_vs=0,output reg o_hs=0,output reg o_valid=0,output reg [31:0] o_data=0);
reg vs_q=0,hs_q=0;
reg [10:0] y=0;reg beat_odd=0,have_half=0;reg[15:0] half=0;
wire keep_row=(y[2:1]!=2'b11);
always @(posedge clk)begin
 vs_q<=vs;hs_q<=hs;o_vs<=vs;o_hs<=hs && keep_row;o_valid<=0;
 if(!rst_n || (vs && !vs_q))begin y<=0;beat_odd<=0;have_half<=0;half<=0;o_hs<=0;end
 else if(hs_q && !hs)begin y<=y+1'b1;beat_odd<=0;have_half<=0;end
 else if(valid && hs)begin
  beat_odd<=~beat_odd;
  if(keep_row)begin
   if(!beat_odd)begin
    o_valid<=1;
    if(have_half)begin o_data<={half,data[31:16]};half<=data[15:0];end
    else o_data<=data;
   end else if(have_half)begin o_valid<=1;o_data<={half,data[31:16]};have_half<=0;end
   else begin half<=data[31:16];have_half<=1;end
  end
 end
end
endmodule
