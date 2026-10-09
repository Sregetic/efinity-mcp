// Common gain from max(R,G,B): lift brightness without independently changing
// RGB ratios. Gain is capped at 4x near black; (0,0,0) remains exactly black.
module rgb_chroma_tone #(
 parameter SHADOW_FILE="./rtl/gamma_conrrection/chroma_shadow_gain_q8.mem",
 parameter GAIN_FILE="./rtl/gamma_conrrection/chroma_tone_gain_q8.mem"
)(input clk,rst_n,de,hs,vs,input[7:0]r,g,b,
 output reg ode,ohs,ovs,output reg[23:0]rgb,linear_rgb,
 input[15:0]gain_r,gain_g,gain_b,output reg[23:0]plain_rgb,output reg highlight_active,input shadow_boost,input freeze_tone,output reg shadow_frame=0);
reg[15:0]gain_rom[0:511];
initial begin
 $readmemh(GAIN_FILE,gain_rom,0,255);
 $readmemh(SHADOW_FILE,gain_rom,256,511);
end
reg[2:0]shadow_sync=0;reg vs_q=0,shadow1=0;
always @(posedge clk)begin
 shadow_sync<={shadow_sync[1:0],shadow_boost};vs_q<=vs;
 if(vs&&!vs_q&&!freeze_tone)shadow_frame<=shadow_sync[2];
 if(!rst_n)begin shadow_sync<=0;shadow_frame<=0;vs_q<=0;end
end
wire[7:0]rgmax=(r>g)?r:g;
wire[7:0]peak=(rgmax>b)?rgmax:b;
reg[7:0]peak1=0;reg[23:0]rgb1=0,rgb2=0;reg[15:0]gain2=0;
reg[2:0]sync1=0,sync2=0,sync3=0;
reg[23:0]toned3=0,linear3=0;reg[3:0]alpha2=0,alpha3=0;
// Thresholds refer to RAW8 minus its 16-count pedestal, scaled by the actual
// pre-debayer gains. Register config arithmetic separately from pixel checks.
reg[71:0]cr=0,cg=0,cb=0,lr=0,lg=0,lb=0;
function automatic[143:0]thresholds(input[15:0]gain);
 reg[16:0]gwide,clip_base,light_base,offset[0:7],c,l;
 reg disabled;integer n;
 begin
  // 144 is the smallest coefficient: above gain 453 every threshold is 256.
  // Keep exact 16-bit gain behavior while doing the shared arithmetic in 17 bits.
  disabled=(gain==0||gain>16'd453);gwide={8'd0,gain[8:0]};
  clip_base=(gwide<<8)-(gwide<<5)-gwide; // 223 * gain
  light_base=(gwide<<7)+(gwide<<4);     // 144 * gain
  offset[0]=0;offset[1]=gwide;offset[2]=gwide<<1;
  offset[3]=gwide+(gwide<<1);offset[4]=gwide<<2;
  offset[5]=gwide+(gwide<<2);offset[6]=(gwide<<1)+(gwide<<2);
  offset[7]=(gwide<<3)-gwide;
  for(n=0;n<8;n=n+1)begin
   c=clip_base+(offset[n]<<1);l=light_base+(offset[n]<<3);
   thresholds[n*9+:9]=(disabled||c>17'd65280)?9'd256:c[16:8];
   thresholds[72+n*9+:9]=(disabled||l>17'd65280)?9'd256:l[16:8];
  end
 end
endfunction
function automatic[3:0]score(input[7:0]v,input[71:0]thresholds);
 integer j;begin score=0;for(j=0;j<8;j=j+1)if({1'b0,v}>=thresholds[j*9+:9])score=j+1;end
endfunction
function automatic[3:0]min3(input[3:0]a,b,c);begin min3=(a<b)?((a<c)?a:c):((b<c)?b:c);end endfunction
function automatic[3:0]max3(input[3:0]a,b,c);begin max3=(a>b)?((a>c)?a:c):((b>c)?b:c);end endfunction
wire[3:0]a_clip=score(rgb1[23:16],cr),b_clip=score(rgb1[15:8],cg),c_clip=score(rgb1[7:0],cb);
// A neutral highlight may clip only green before R/B. Require all channels
// to be bright, but do not require two distinct color channels to clip.
wire[3:0]near_clip=max3(a_clip,b_clip,c_clip);
wire[3:0]all_bright=min3(score(rgb1[23:16],lr),score(rgb1[15:8],lg),score(rgb1[7:0],lb));
wire[7:0]peak3a=(toned3[23:16]>toned3[15:8])?toned3[23:16]:toned3[15:8];
wire[7:0]peak3=(peak3a>toned3[7:0])?peak3a:toned3[7:0];
function automatic[7:0]blend(input[7:0]v,peak,input[3:0]a);
 reg[11:0]delta;begin delta=(peak-v)*a+12'd4;blend=v+(delta>>3);end
endfunction
wire[23:0]pr=rgb2[23:16]*gain2+24'd128;
wire[23:0]pg=rgb2[15:8]*gain2+24'd128;
wire[23:0]pb=rgb2[7:0]*gain2+24'd128;
wire[7:0]rr=(|pr[23:16])?8'd255:pr[15:8];
wire[7:0]gg=(|pg[23:16])?8'd255:pg[15:8];
wire[7:0]bb=(|pb[23:16])?8'd255:pb[15:8];
always @(posedge clk)begin
  {lr,cr}<=thresholds(gain_r);{lg,cg}<=thresholds(gain_g);{lb,cb}<=thresholds(gain_b);
 shadow1<=shadow_frame;peak1<=peak;rgb1<={r,g,b};sync1<={de,hs,vs};
 gain2<=gain_rom[{shadow1,peak1}];rgb2<=rgb1;sync2<=sync1;
 alpha2<=(near_clip<all_bright)?near_clip:all_bright;
 toned3<={rr,gg,bb};linear3<=rgb2;sync3<=sync2;alpha3<=alpha2;
 {ode,ohs,ovs}<=sync3;
 rgb<=sync3[2]?{blend(toned3[23:16],peak3,alpha3),blend(toned3[15:8],peak3,alpha3),blend(toned3[7:0],peak3,alpha3)}:24'd0;
 plain_rgb<=sync3[2]?toned3:24'd0;linear_rgb<=sync3[2]?linear3:24'd0;
 highlight_active<=sync3[2]&&alpha3!=0;
 if(!rst_n)begin sync1<=0;sync2<=0;sync3<=0;{ode,ohs,ovs}<=0;rgb<=0;plain_rgb<=0;linear_rgb<=0;highlight_active<=0;end
end
endmodule
