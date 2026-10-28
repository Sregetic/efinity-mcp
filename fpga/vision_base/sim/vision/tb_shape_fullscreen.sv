`timescale 1ns/1ps
module tb;
reg clk=0,rst=0,sde=0,svs=0;reg[11:0]sx=0,sy=0;reg[7:0]sg=220;
wire[63:0]status;integer cases=0;
vision_display dut(.clk(clk),.rst_n(rst),.de(1'b0),.hs(1'b0),.vs(1'b0),.r(8'd0),.g(8'd0),.b(8'd0),
 .mode(3'd7),.threshold(11'd96),.median_en(1'b1),.memory_mode(2'd0),.history_index(3'd0),
 .canny_pixel(1'b0),.canny_ready(1'b1),.canny_coverage(8'd0),.shape_enable(1'b1),.shape_threshold(8'd32),
 .shape_status(status),.canny_effective_threshold(11'd96),.canny_requested_threshold(11'd96),
 .analysis_enabled(1'b0),.analysis_context_changed(1'b0),.frame_id(32'd1),.render_config_id(32'd1),
 .analysis_context(32'd0),.analysis_result(352'd0),.analysis_match(1'b0),.analysis_identity_match(1'b0),
 .analysis_age(16'd0),.ui_state(24'd0),.motion_enable(1'b0));
always #5 clk=~clk;
task boundary;begin @(negedge clk);sde=0;svs=1;@(negedge clk);svs=0;repeat(6)@(negedge clk);end endtask
task frame(input integer kind,x0,y0,x1,y1);integer x,y,dx,dy;reg foreground;begin
 for(y=0;y<1080;y=y+1)begin
  for(x=0;x<1920;x=x+1)begin
   foreground=0;
   if(kind==1)begin dx=x-x0;dy=y-y0;foreground=dx*dx+dy*dy<=x1*x1;end
   else if(kind==2)foreground=x>=x0&&x<=x1&&y>=y0&&y<=y1;
   else if(kind==3)foreground=x>=x0&&x<=x1&&y>=y0&&y<=y1&&(x<=x0+1||x>=x1-1||y<=y0+1||y>=y1-1);
   @(negedge clk);sde=1;sx=x;sy=y;sg=foreground?20:220;
  end
  @(negedge clk);sde=0;
 end
 boundary;
end endtask
task verify(input integer kind,x0,y0,x1,y1,wanted);begin
 frame(kind,x0,y0,x1,y1);
 if(!status[62]||status[61:60]!=wanted)$fatal(1,"fullscreen object outside old center: got class%0d valid%0d flags%h wanted%0d box%0d,%0d-%0d,%0d",status[61:60],status[62],status[51:48],wanted,status[47:36],status[35:24],status[23:12],status[11:0]);
 if(kind!=1&&status[47:0]!={12'(x0),12'(y0),12'(x1),12'(y1)})$fatal(1,"full-view box coordinate mismatch");
 cases=cases+1;$display("PASS fullscreen case%0d class%0d box%0d,%0d-%0d,%0d",cases,wanted,status[47:36],status[35:24],status[23:12],status[11:0]);
end endtask
initial begin
 force dut.fd=sde;force dut.fv=svs;force dut.x=sx;force dut.y=sy;force dut.gray=sg;
 repeat(4)@(negedge clk);rst=1;boundary;frame(0,0,0,0,0);
 verify(2,64,80,224,208,2);verify(3,1660,64,1850,200,2);
 verify(2,48,820,224,1024,2);verify(3,1640,836,1840,1030,2);
 verify(1,300,500,72,0,1);verify(1,1600,500,80,0,1);
 verify(2,80,80,1840,1000,2);
 verify(2,5,100,80,180,2);verify(2,1810,100,1918,200,2);
 verify(2,500,5,600,100,2);verify(2,900,1000,1000,1078,2);
 verify(2,800,420,1120,660,2);
 if(dut.shape0.X0!=4||dut.shape0.Y0!=4||dut.shape0.X1!=1920||dut.shape0.Y1!=1080)$fatal(1,"production full-view extent mismatch");
 $display("PASS full-screen production display/classifier %0d cases, full-width area and original center",cases);$finish;
end
endmodule
