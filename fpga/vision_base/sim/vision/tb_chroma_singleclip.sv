`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;reg rst=0,de=0;reg[7:0]r=0,g=0,b=0;
wire od,oh,ov,hit;wire[23:0]rgb,lin,plain;
rgb_chroma_tone #(.SHADOW_FILE("board/ti60f225_v4/rtl/gamma_conrrection/chroma_shadow_gain_q8.mem"),.GAIN_FILE("board/ti60f225_v4/rtl/gamma_conrrection/chroma_tone_gain_q8.mem"))dut(clk,rst,de,1'b0,1'b0,r,g,b,od,oh,ov,rgb,lin,16'd256,16'd161,16'd162,plain,hit,1'b0);
task drive(input[23:0]v);begin @(negedge clk);{r,g,b}=v;de=1;repeat(6)@(negedge clk);end endtask
integer original_span,new_span;
initial begin
 repeat(5)@(negedge clk);rst=1;repeat(5)@(negedge clk);
 // Actual RAW tile B/G/G/R=213/255/255/205, pedestal16 and current WB.
 drive({8'd197,8'd150,8'd119});
 original_span=plain[23:16]-plain[7:0];new_span=rgb[23:16]-rgb[7:0];
 if(!hit||new_span>original_span/2)$fatal(1,"single-channel clipped neutral highlight uncorrected: plain=%h corrected=%h",plain,rgb);
 drive({8'd239,8'd30,8'd20});if(hit||rgb!==plain)$fatal(1,"saturated blue object changed");
 drive({8'd30,8'd140,8'd20});if(hit||rgb!==plain)$fatal(1,"saturated green object changed");
 drive({8'd120,8'd90,8'd80});if(hit||rgb!==plain)$fatal(1,"unclipped midtone changed");
 drive(24'd0);if(rgb!==0)$fatal(1,"black lifted");
 $display("SINGLE CLIP PASS measured highlight chroma reduced; saturated colors/midtone/black preserved");$finish;
end
endmodule
