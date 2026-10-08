// Horizontal RGB denoise before tone gain, with no line RAM. Retain the dark
// chroma median; ordinary-brightness flat RGB uses a rounded [1,2,1]/4 filter.
// Strong luma/color edges and line boundaries bypass exactly.
module rgb_shadow_denoise(input clk,input rst_n,input de,input hs,input vs,
 input[7:0]r,g,b,output reg o_de,o_hs,o_vs,output reg[7:0]o_r,o_g,o_b);
function automatic signed[8:0]med9(input signed[8:0]a,c,z);
 begin med9=(a<c)?((c<z)?c:((a<z)?z:a)):((a<z)?a:((c<z)?z:c));end
endfunction
function automatic[7:0]dist8(input[7:0]a,z);begin dist8=a>z?a-z:z-a;end endfunction
function automatic near16(input[7:0]a,z);
 reg[8:0]delta;begin delta={1'b0,a}-{1'b0,z}+9'd16;near16=delta<=9'd32;end
endfunction
function automatic[7:0]clip(input signed[12:0]v);begin clip=v<0?8'd0:v>255?8'd255:v[7:0];end endfunction
reg[7:0]lr=0,lg=0,lb=0,cr=0,cg=0,cb=0;
reg ld=0,cd=0,ch=0,cv=0;
wire[9:0]ls={2'b0,lr}+{1'b0,lg,1'b0}+{2'b0,lb};
wire[9:0]cs={2'b0,cr}+{1'b0,cg,1'b0}+{2'b0,cb};
wire[9:0]rs={2'b0,r}+{1'b0,g,1'b0}+{2'b0,b};
wire[7:0]ly=ls[9:2],cy=cs[9:2],ry=rs[9:2];
wire signed[8:0]lrg=$signed({1'b0,lr})-$signed({1'b0,lg});
wire signed[8:0]crg=$signed({1'b0,cr})-$signed({1'b0,cg});
wire signed[8:0]rrg=$signed({1'b0,r})-$signed({1'b0,g});
wire signed[8:0]lbg=$signed({1'b0,lb})-$signed({1'b0,lg});
wire signed[8:0]cbg=$signed({1'b0,cb})-$signed({1'b0,cg});
wire signed[8:0]rbg=$signed({1'b0,b})-$signed({1'b0,g});
wire signed[8:0]mr=med9(lrg,crg,rrg),mb=med9(lbg,cbg,rbg);
wire signed[12:0]er={{4{mr[8]}},mr},eb={{4{mb[8]}},mb};
wire signed[12:0]yy=$signed({3'b0,cy,2'b0});
wire signed[12:0]nr=(yy+(er<<<1)+er-eb)>>>2;
wire signed[12:0]ng=(yy-er-eb)>>>2;
wire signed[12:0]nb=(yy+(eb<<<1)+eb-er)>>>2;
wire near_pixels=ld&&cd&&de&&hs==ch&&vs==cv&&
 dist8(ly,cy)<=8&&dist8(ry,cy)<=8;
wire smooth=near_pixels&&cy<=48&&ly<=56&&ry<=56&&(mr!=crg||mb!=cbg);
wire smooth_rgb=near_pixels&&cy>48&&
 near16(lr,cr)&&near16(r,cr)&&near16(lg,cg)&&near16(g,cg)&&
 near16(lb,cb)&&near16(b,cb);
wire[9:0]ar={2'b0,lr}+{1'b0,cr,1'b0}+{2'b0,r}+10'd2;
wire[9:0]ag={2'b0,lg}+{1'b0,cg,1'b0}+{2'b0,g}+10'd2;
wire[9:0]ab={2'b0,lb}+{1'b0,cb,1'b0}+{2'b0,b}+10'd2;
always @(posedge clk)begin
 if(!rst_n)begin
  lr<=0;lg<=0;lb<=0;cr<=0;cg<=0;cb<=0;ld<=0;cd<=0;ch<=0;cv<=0;
  o_de<=0;o_hs<=0;o_vs<=0;o_r<=0;o_g<=0;o_b<=0;
 end else begin
  lr<=cr;lg<=cg;lb<=cb;ld<=cd;cr<=r;cg<=g;cb<=b;cd<=de;ch<=hs;cv<=vs;
  o_de<=cd;o_hs<=ch;o_vs<=cv;
  o_r<=!cd?8'd0:smooth?clip(nr):smooth_rgb?ar[9:2]:cr;
  o_g<=!cd?8'd0:smooth?clip(ng):smooth_rgb?ag[9:2]:cg;
  o_b<=!cd?8'd0:smooth?clip(nb):smooth_rgb?ab[9:2]:cb;
 end
end
endmodule
