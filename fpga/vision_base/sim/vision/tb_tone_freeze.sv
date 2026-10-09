`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,vs=0,shadow=0,freeze_tone=0;wire latched;
rgb_chroma_tone #(.SHADOW_FILE("board/ti60f225_v4/rtl/gamma_conrrection/chroma_shadow_gain_q8.mem"),.GAIN_FILE("board/ti60f225_v4/rtl/gamma_conrrection/chroma_tone_gain_q8.mem"))dut(
 .clk(clk),.rst_n(rst),.de(1'b0),.hs(1'b0),.vs(vs),.r(8'd0),.g(8'd0),.b(8'd0),.gain_r(16'd256),.gain_g(16'd256),.gain_b(16'd256),
 .shadow_boost(shadow),.freeze_tone(freeze_tone),.shadow_frame(latched));
task frame;begin @(negedge clk);vs=1;repeat(3)@(negedge clk);vs=0;repeat(8)@(negedge clk);end endtask
integer i;
initial begin
 repeat(4)@(negedge clk);rst=1;shadow=1;repeat(8)@(negedge clk);frame();if(!latched)$fatal(1,"live tone did not update");
 freeze_tone=1;shadow=0;repeat(8)@(negedge clk);for(i=0;i<20;i++)frame();if(!latched)$fatal(1,"frozen tone followed live camera");
 freeze_tone=0;frame();if(latched)$fatal(1,"live tone did not resume");
 $display("PASS tone gain remains latched across20 frozen frames and resumes at live VS");$finish;
end
endmodule
