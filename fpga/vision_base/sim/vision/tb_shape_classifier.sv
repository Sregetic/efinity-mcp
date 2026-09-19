`timescale 1ns/1ps
module tb;
reg clk=0,rst_n=0,de=0,vs=0;reg[11:0]x=0,y=0;reg[7:0]gray=0,threshold=48;
wire[1:0]kind;wire valid;wire[11:0]x0,y0,x1,y1;wire[7:0]bg;wire[3:0]flags;
vision_shape_classifier #(.X0(16),.Y0(16),.X1(112),.Y1(112),.MIN_AREA(128),.MIN_SIZE(16)) dut(
 .clk(clk),.rst_n(rst_n),.de(de),.vs(vs),.x(x),.y(y),.gray(gray),.diff_threshold(threshold),
 .shape_class(kind),.shape_valid(valid),.box_x0(x0),.box_y0(y0),.box_x1(x1),.box_y1(y1),.background(bg),.reject_flags(flags));
always #5 clk=~clk;
task boundary;begin
 @(negedge clk);de=0;vs=1;@(negedge clk);vs=0;
 repeat(4)@(negedge clk);
end endtask
integer checks=0;
task frame(input integer shape,input integer invert,input integer noise);integer px,py,dx,dy,g;reg fg;begin
 for(py=0;py<128;py=py+1)begin
  for(px=0;px<128;px=px+1)begin
   dx=px-64;dy=py-64;fg=0;
   case(shape)
   1:fg=dx*dx+dy*dy<=484;
   2:fg=px>=40&&px<=87&&py>=40&&py<=87;
   3:fg=px>=36&&px<=91&&py>=54&&py<=73;
   4:fg=px>=54&&px<=73&&py>=36&&py<=91;
   5:fg=py>=44&&py<=84&&px>=44&&px<=py;
   6:fg=((px>=36&&px<=50)||(px>=78&&px<=92))&&py>=44&&py<=84;
   7:fg=px>=16&&px<=50&&py>=50&&py<=80;
   8:fg=px>=60&&px<=63&&py>=60&&py<=63;
   9:fg=dx*dx+dy*dy<=484&&dx*dx+dy*dy>=324;
   10:fg=px>=36&&px<=91&&py>=54&&py<=73;
   11:fg=px>=70&&px<=97&&py>=40&&py<=67;
   13:fg=px>=36&&px<=91&&py>=54&&py<=73;
   14:fg=dx*dx+dy*dy<=484;
   12:fg=(dx<0?-dx:dx)+(dy<0?-dy:dy)<=25;
   endcase
   g=fg?(invert?220:20):(invert?20:220);
   if(noise)g=g+((px*7+py*3)%7)-3;
   if(shape==10&&!fg)g=(px<64)?220:100;
   if(shape==13&&px==17&&py==17)g=0;
   if(shape==14&&!fg)g=200+px/4;
   @(negedge clk);de=1;x=px;y=py;gray=g;
   // DE bubbles must not split an object run or duplicate area.
   if(noise&&px%17==0)begin @(negedge clk);de=0;end
  end
  @(negedge clk);de=0;
 end
 boundary;
end endtask
task verify_case(input integer shape,input integer invert,input integer noise,input integer wanted,input integer wantvalid);begin
 repeat(3)frame(shape,invert,noise);
 if(valid!==wantvalid[0]||kind!==wanted[1:0])begin
  $display("FAIL shape=%0d invert=%0d noise=%0d got=%0d valid=%0d flags=%h bg=%0d box=%0d,%0d-%0d,%0d",shape,invert,noise,kind,valid,flags,bg,x0,y0,x1,y1);$fatal;
 end
 if(shape==3&&{x0,y0,x1,y1}!={12'd36,12'd54,12'd91,12'd73})$fatal(1,"rectangle coordinate mismatch");
 if(shape==11&&{x0,y0,x1,y1}!={12'd70,12'd40,12'd97,12'd67})$fatal(1,"moving box mismatch");
 checks=checks+1;$display("PASS shape=%0d invert=%0d noise=%0d class=%0d valid=%0d flags=%h",shape,invert,noise,kind,valid,flags);
end endtask
initial begin
 repeat(4)@(negedge clk);rst_n=1;boundary;
 verify_case(13,0,0,2,1);verify_case(14,0,0,1,1);
 verify_case(0,0,0,0,0);
 verify_case(1,0,0,1,1);verify_case(1,1,1,1,1);
 verify_case(2,0,0,2,1);verify_case(3,0,1,2,1);verify_case(4,1,0,2,1);
 verify_case(5,0,0,3,1);verify_case(6,0,0,0,0);verify_case(7,0,0,0,0);
 verify_case(8,0,0,0,0);verify_case(9,0,0,0,0);verify_case(10,0,0,0,0);
 verify_case(11,0,0,2,1);verify_case(12,0,0,3,1);verify_case(0,0,0,0,0);
 @(negedge clk);rst_n=0;repeat(4)@(negedge clk);
 if(valid||kind!=0)$fatal(1,"reset stale result");
 $display("PASS shape classifier %0d cases and reset",checks);$finish;
end
endmodule
