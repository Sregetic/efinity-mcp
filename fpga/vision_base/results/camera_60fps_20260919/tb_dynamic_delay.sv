`timescale 1ns/1ps
module tb;
reg core_clk=0,i_cam_ck_CLKOUT=0,run=1;reg[31:0]feature_command=0;reg feature_command_toggle=0;
always #5 core_clk=~core_clk;always #6.35 begin if(run)i_cam_ck_CLKOUT=~i_cam_ck_CLKOUT;else i_cam_ck_CLKOUT=0;end
wire cam_d0_DLY_RST,cam_d0_DLY_ENA,cam_d0_DLY_INC,cam_d1_DLY_RST,cam_d1_DLY_ENA,cam_d1_DLY_INC;
wire cam_d2_DLY_RST,cam_d2_DLY_ENA,cam_d2_DLY_INC,cam_d3_DLY_RST,cam_d3_DLY_ENA,cam_d3_DLY_INC;
reg[2:0]phy_cmd_sync=0;reg phy_cmd_seen=0;
reg[2:0]phy_state=0;reg[5:0]phy_target=17,phy_applied=17,phy_count=0;
reg[7:0]phy_updates=0;reg phy_dly_rst=0,phy_dly_ena=0;
wire[31:0]phy_status_byte={8'hd1,phy_updates,2'b0,phy_applied,7'b0,(phy_state!=0)};
(* async_reg = "true" *) reg[31:0]phy_status_meta=0,phy_status_core=0;
always @(posedge core_clk)begin phy_status_meta<=phy_status_byte;phy_status_core<=phy_status_meta;end
assign {cam_d3_DLY_RST,cam_d2_DLY_RST,cam_d1_DLY_RST,cam_d0_DLY_RST}={4{phy_dly_rst}};
assign {cam_d3_DLY_ENA,cam_d2_DLY_ENA,cam_d1_DLY_ENA,cam_d0_DLY_ENA}={4{phy_dly_ena}};
assign {cam_d3_DLY_INC,cam_d2_DLY_INC,cam_d1_DLY_INC,cam_d0_DLY_INC}=4'b1111;
always @(posedge i_cam_ck_CLKOUT)begin
 phy_cmd_sync<={phy_cmd_sync[1:0],feature_command_toggle};phy_cmd_seen<=phy_cmd_sync[2];
 case(phy_state)
 0:if(phy_cmd_sync[2]!=phy_cmd_seen&&feature_command[31:24]==19)begin
    phy_target<=feature_command[5:0];phy_count<=0;phy_dly_rst<=1;phy_state<=1;
   end
 1:begin phy_dly_rst<=0;if(phy_target==0)phy_state<=3;else begin phy_dly_ena<=1;phy_state<=2;end end
 2:begin phy_count<=phy_count+1'b1;if(phy_count==phy_target-1'b1)begin phy_dly_ena<=0;phy_state<=3;end end
 3:begin phy_applied<=phy_target;phy_updates<=phy_updates+1'b1;phy_state<=0;end
 default:begin phy_dly_rst<=0;phy_dly_ena<=0;phy_state<=0;end
 endcase
end
reg[2:0]link_cmd_sync=0;reg link_cmd_seen=0;reg[17:0]link_reset_timer=0;
wire link_reset=link_reset_timer!=0;
always @(posedge core_clk)begin
 link_cmd_sync<={link_cmd_sync[1:0],feature_command_toggle};link_cmd_seen<=link_cmd_sync[2];
 if(link_cmd_sync[2]!=link_cmd_seen&&feature_command[31:24]==20)link_reset_timer<=18'd200000;
 else if(link_reset_timer!=0)link_reset_timer<=link_reset_timer-1'b1;
end

reg[5:0]actual_delay=17;
always @(posedge i_cam_ck_CLKOUT)begin
 if(cam_d0_DLY_RST)actual_delay<=0;else if(cam_d0_DLY_ENA)actual_delay<=actual_delay+1'b1;
end
task set_delay(input[5:0]v);
reg[7:0]seq;
begin seq=phy_updates;@(negedge i_cam_ck_CLKOUT);feature_command={8'd19,18'b0,v};feature_command_toggle=~feature_command_toggle;
 wait(phy_updates!=seq);@(negedge i_cam_ck_CLKOUT);
 if(actual_delay!=v||phy_applied!=v||phy_state!=0||phy_dly_ena||phy_dly_rst)$fatal(1,"delay mismatch expected%0d got%0d",v,actual_delay);
end endtask
initial begin
 #100;set_delay(17);set_delay(0);set_delay(1);set_delay(63);set_delay(8);
 run=0;#100;feature_command={8'd19,18'b0,6'd9};feature_command_toggle=~feature_command_toggle;
 #100;if(actual_delay!=8)$fatal(1,"changed with clock stopped");run=1;
 wait(phy_applied==9);#100;if(actual_delay!=9)$fatal(1,"gated-clock resume failed");
 feature_command={8'd20,24'd0};feature_command_toggle=~feature_command_toggle;wait(link_reset);wait(!link_reset);
 $display("DYNAMIC DELAY PASS 0/1/8/17/63 taps, exact pulse count, gated-clock resume, bounded reset");$finish;
end
initial begin #3000000;$fatal(1,"timeout");end
endmodule
