`timescale 1ns/1ps
module tb;
reg core_clk=0,i_cam_ck_CLKOUT=0,run=1;always #5 core_clk=~core_clk;
always #3.5 begin if(run)i_cam_ck_CLKOUT=~i_cam_ck_CLKOUT;else i_cam_ck_CLKOUT=0;end
reg[31:0] cam_byte_ticks=0,cam_byte_gray=0;
wire[31:0]cam_byte_next=cam_byte_ticks+1'b1;
always @(posedge i_cam_ck_CLKOUT)begin
 cam_byte_ticks<=cam_byte_next;cam_byte_gray<=(cam_byte_next>>1)^cam_byte_next;
end
(* async_reg = "true" *) reg[31:0]cam_byte_gray_meta=0,cam_byte_gray_sync=0;
reg[31:0]cam_byte_core=0;
function[31:0]decode_byte_gray(input[31:0]g);
 integer j;begin for(j=0;j<32;j=j+1)decode_byte_gray[j]=^(g>>j);end
endfunction
always @(posedge core_clk)begin
 cam_byte_gray_meta<=cam_byte_gray;cam_byte_gray_sync<=cam_byte_gray_meta;
 cam_byte_core<=decode_byte_gray(cam_byte_gray_sync);
end

integer n=0,previous=0;
always @(negedge core_clk)begin
 if(cam_byte_core<previous)$fatal(1,"counter moved backwards");
 if(cam_byte_ticks-cam_byte_core>8)$fatal(1,"excess CDC lag");
 previous=cam_byte_core;n=n+1;
end
initial begin #2000;run=0;#500;run=1;#3000;run=0;#200;
 if(cam_byte_core!=cam_byte_ticks)$fatal(1,"did not settle");
 $display("BYTE GRAY CDC PASS checks=%0d count=%0d",n,cam_byte_core);$finish;end
endmodule
