`timescale 1ns/1ps
module tb_vision_ai_bridge;
reg clk=0,video_clk=0,rst_n=0,vs=0,frame_ok=1,geometry_done=0;
always #5 clk=~clk;always #7 video_clk=~video_clk;
reg[31:0]view_frame=11,view_config=4,geometry_frame=11,geometry_config=4,geometry_context=0;
reg[87:0]signature=1;reg[63:0]geometry_status=64'hc200100120200220;
reg[7:0]paddr=0;reg psel=0,penable=0,pwrite=0;reg[31:0]pwdata=0;
wire[31:0]prdata,context_id;wire pready,pslverror,enabled,context_changed,result_match,result_identity_match;wire[351:0]result;wire[15:0]result_age;
vision_ai_bridge dut(.*);
task boundary;
 begin @(negedge video_clk);vs=1;repeat(2)@(negedge video_clk);vs=0;repeat(5)@(negedge video_clk);end
endtask
task write(input[7:0]a,input[31:0]v);
 begin @(negedge clk);paddr=a;pwdata=v;psel=1;penable=1;pwrite=1;
 @(posedge clk);while(!pready)@(posedge clk);@(negedge clk);psel=0;penable=0;pwrite=0;end
endtask
task publish(input[31:0]model);
 begin
 write(8'h80,32'h203);write(8'h84,11);write(8'h88,321);write(8'h8c,4);
 write(8'h90,model);write(8'h94,context_id);write(8'h98,32'h012c0280);write(8'h9c,32'h01c20320);write(8'ha0,32'h12345678);
 write(8'ha4,32'h00670abc);write(8'ha8,32'h00003c28);
 write(8,1);
 end
endtask
initial begin
 repeat(4)@(negedge clk);rst_n=1;write(4,1);repeat(3)@(negedge video_clk);boundary;
 if(!enabled||context_id!=1)$fatal(1,"frame boundary enable/context");
 geometry_context=context_id;@(negedge video_clk);geometry_done=1;@(negedge video_clk);geometry_done=0;
 repeat(10)@(negedge clk);paddr=8'h10;#1;if(prdata!=1)$fatal(1,"geometry CDC sequence");
 paddr=8'h14;#1;if(prdata!=11)$fatal(1,"geometry frame");paddr=8'h1c;#1;if(prdata!=geometry_context)$fatal(1,"geometry context");
 publish(1);repeat(6)@(negedge video_clk);
 if(result!=0)$fatal(1,"result applied outside VS");
 paddr=8'h80;psel=1;penable=1;pwrite=1;pwdata=32'hffffffff;#1;
 if(pready)$fatal(1,"producer overwrote held packet");psel=0;penable=0;pwrite=0;
 boundary;if(!result_match||result_age!=0||result[159:128]!=1||result[287:256]!=32'h12345678)$fatal(1,"atomic publication");
 if(result[351:288]!=64'h00003c2800670abc)$fatal(1,"timings separated from VS packet");
 view_frame=12;#1;if(result_match||result_age!=1)$fatal(1,"stale box accepted");
 view_frame=11;view_config=5;#1;if(result_match)$fatal(1,"render config mismatch accepted");view_config=4;
 signature=2;boundary;if(result_match)$fatal(1,"processing context mismatch accepted");
 publish(2);repeat(6)@(negedge video_clk);boundary;
 if(!result_match||result[159:128]!=2)$fatal(1,"model/frame packet mixed");
 geometry_context=1;@(negedge video_clk);geometry_done=1;@(negedge video_clk);geometry_done=0;
 repeat(8)@(negedge clk);paddr=8'h10;#1;if(prdata!=1)$fatal(1,"old processing geometry accepted");
 geometry_context=context_id;@(negedge video_clk);geometry_done=1;@(negedge video_clk);geometry_done=0;
 repeat(8)@(negedge clk);paddr=8'h10;#1;if(prdata!=2)$fatal(1,"fresh geometry lost");
 frame_ok=0;#1;if(result_match)$fatal(1,"failed scan accepted");
 if(!result_identity_match)$fatal(1,"ROI top blanking falsely invalidated completed task identity");
 $display("PASS tb_vision_ai_bridge asynchronous geometry, held packet/backpressure, VS commit, source/config/context/model, age and failed scan");$finish;
end
initial begin #100000;$fatal(1,"watchdog");end
endmodule
