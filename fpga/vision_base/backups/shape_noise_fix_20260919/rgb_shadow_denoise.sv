// Three-pixel horizontal median, restricted to flat dark neighborhoods.
// Bright pixels and strong boundaries pass unchanged. No transfer-curve change.
module rgb_shadow_denoise(input clk,input rst_n,input de,input hs,input vs,
 input[7:0] r,g,b,output reg o_de,o_hs,o_vs,output reg[7:0]o_r,o_g,o_b);
function automatic[7:0] med(input[7:0]a,c,z);
 begin med=(a<c)?((c<z)?c:((a<z)?z:a)):((a<z)?a:((c<z)?z:c));end
endfunction
function automatic[7:0] delta(input[7:0]a,z);
 begin delta=(a>z)?a-z:z-a;end
endfunction
reg[7:0] lr=0,lg=0,lb=0,cr=0,cg=0,cb=0;
reg ld=0,cd=0,ch=0,cv=0;
wire flat_dark=ld && cd && de && (hs==ch) && (vs==cv)
 && cr<=32 && cg<=32 && cb<=32
 && lr<=32 && lg<=32 && lb<=32 && r<=32 && g<=32 && b<=32
 && delta(lr,r)<=4 && delta(lg,g)<=4 && delta(lb,b)<=4;
always @(posedge clk)begin
 if(!rst_n)begin
  lr<=0;lg<=0;lb<=0;cr<=0;cg<=0;cb<=0;ld<=0;cd<=0;ch<=0;cv<=0;
  o_de<=0;o_hs<=0;o_vs<=0;o_r<=0;o_g<=0;o_b<=0;
 end else begin
  lr<=cr;lg<=cg;lb<=cb;ld<=cd;cr<=r;cg<=g;cb<=b;cd<=de;ch<=hs;cv<=vs;
  o_de<=cd;o_hs<=ch;o_vs<=cv;
  o_r<=!cd?8'd0:(flat_dark?med(lr,cr,r):cr);
  o_g<=!cd?8'd0:(flat_dark?med(lg,cg,g):cg);
  o_b<=!cd?8'd0:(flat_dark?med(lb,cb,b):cb);
 end
end
endmodule
