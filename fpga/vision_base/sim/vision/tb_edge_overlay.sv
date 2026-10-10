`timescale 1ns/1ps
module tb;
reg clk=0,rst=1,shape=1,cp=0,cr=1;reg[2:0]mode=0;
wire de,hs,vs;wire[7:0]r,g,b;wire[63:0]status;
vision_display #(.EDGE_STRENGTH(0)) dut(clk,rst,1'b0,1'b0,1'b0,8'd0,8'd0,8'd0,mode,11'd64,1'b1,2'd0,3'd0,
 cp,cr,,,de,hs,vs,r,g,b,,,shape,8'd32,status,,11'd128,11'd128,8'd0,1'b0,1'b0,32'd0,32'd0,32'd0,352'd0,1'b0,1'b0,16'd0,,,,,15'd0);
always #5 clk=~clk;
task check_pixel(input[2:0]m,input[23:0]wanted);
 begin @(negedge clk);mode=m;repeat(2)@(posedge clk);#1;if({r,g,b}!==wanted)$fatal(1,"mode%0d pixel=%h expected%h",m,{r,g,b},wanted);end
endtask
integer i;
initial begin
 force dut.fd=1;force dut.border=0;force dut.x=700;force dut.y=300;
 force dut.fr=8'h12;force dut.fg=8'h34;force dut.fb=8'h56;force dut.gray=8'd90;force dut.edge1=1;
 force dut.shape_valid=1;force dut.shape_class=2;
 force dut.sx0=700;force dut.sx1=800;force dut.sy0=300;force dut.sy1=400;
 check_pixel(0,24'h123456);check_pixel(1,24'h5a5a5a);
 for(i=2;i<8;i=i+1)check_pixel(i,24'h3090ff);
 mode=2;#1;if(dut.shape0.gray!==255)$fatal(1,"Sobel classifier input not edge mask");
 mode=5;cp=0;#1;if(dut.shape0.gray!==0)$fatal(1,"Canny classifier uses RGB/Sobel instead of displayed plane");
 cp=1;#1;if(dut.shape0.gray!==255)$fatal(1,"Canny classifier mask mismatch");
 cr=0;#1;if(dut.shape0.gray!==0)$fatal(1,"unready Canny accepted");cr=1;
 shape=0;check_pixel(5,24'hffffff);check_pixel(0,24'h123456);
 force dut.x=100;force dut.y=26;shape=1;
 for(i=2;i<8;i=i+1)begin mode=i;@(posedge clk);#1;if(!dut.osd)$fatal(1,"shape text absent in edge mode%0d",i);end
 mode=0;@(posedge clk);#1;if(dut.osd)$fatal(1,"RGB mode acquired extra HUD");
 $display("PASS edge overlay M2..M7, edge-derived recognition, RGB/gray unchanged, shape switch and HUD");$finish;
end
endmodule
