`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst_n=0,de=0,hs=0,vs=0;reg[23:0]rgb=0,ui_state=0;
reg[3:0]ai_status=0;reg motion_enable=0,motion_held=0;reg[2:0]motion_direction=0;
wire ode,ohs,ovs;wire[23:0]orgb;
vision_sidebar_overlay dut(.*);
reg[23:0]vectors[0:11];reg[63:0]names[0:5],wanted;reg[11:0]probe_x,probe_y;
integer direction,hold_state,slot,frame,row,col,file,checked=0,ink_count=0;reg in_overlay;
reg[1023:0]vector_file,output_dir;
task tick;
 begin @(posedge clk);#1;
  if({ode,ohs,ovs}!=={de,hs,vs})$fatal(1,"motion UI sync changed");
  @(negedge clk);
 end
endtask
initial begin
 if(!$value$plusargs("vectors=%s",vector_file))$fatal(1,"missing RV32I vectors");
 if(!$value$plusargs("output=%s",output_dir))$fatal(1,"missing output folder");
 $readmemh(vector_file,vectors);
 if(vectors[6]!=24'h804001)$fatal(1,"motion ON firmware ABI");
 names[0]=dut.sidebar_font.ZH_UNKNOWN;names[1]=dut.sidebar_font.ZH_STILL;
 names[2]=dut.sidebar_font.ZH_LEFT;names[3]=dut.sidebar_font.ZH_RIGHT;
 names[4]=dut.sidebar_font.ZH_MOVE_UP;names[5]=dut.sidebar_font.ZH_MOVE_DOWN;
 repeat(3)@(negedge clk);rst_n=1;motion_enable=1;
 force dut.x=probe_x;force dut.y=probe_y;
 for(direction=0;direction<6;direction=direction+1)for(hold_state=0;hold_state<2;hold_state=hold_state+1)begin
  motion_direction=direction;motion_held=hold_state;
  vs=1;tick;vs=0;tick;
  wanted={dut.sidebar_font.ZH_MOTION[63:48],names[direction][63:48],hold_state?dut.sidebar_font.ZH_HOLD[63:48]:16'h2020,16'h2020};
  for(slot=0;slot<8;slot=slot+1)begin
   probe_x=16+slot*16;probe_y=104;tick;
   if(!dut.active||dut.sidebar_font.ch_q!==wanted[63-slot*8-:8])$fatal(1,"Chinese direction/HOLD %0d %0d %0d",direction,hold_state,slot);
   checked=checked+1;
  end
 end
 motion_enable=0;tick;if(dut.active)$fatal(1,"disabled hint visible");
 release dut.x;release dut.y;rst_n=0;tick;rst_n=1;
 for(frame=0;frame<2;frame=frame+1)begin
  ui_state=frame==0?vectors[6]:24'd0;motion_enable=1;motion_direction=frame==0?3:4;motion_held=frame!=0;
  de=0;vs=1;tick;vs=0;tick;
  file=$fopen($sformatf("%0s/motion_%0d.ppm",output_dir,frame),"wb");
  if(!file)$fatal(1,"preview file");$fwrite(file,"P6\n1920 1080\n255\n");
  for(row=0;row<1080;row=row+1)begin
   for(col=0;col<1920;col=col+1)begin
    de=1;rgb=(col>=850&&col<1070&&row>=430&&row<650)?24'h30a0e0:((col%120==0||row%120==0)?24'h606060:24'h303c44);
    @(posedge clk);#1;
    in_overlay=frame==0?(row>=128&&row<576&&col<304):(col<160&&row>=96&&row<120);
    if(!ode||ohs!==hs||ovs!==vs)$fatal(1,"preview sync");
    if(!in_overlay)begin if(orgb!==rgb)$fatal(1,"motion UI changed image outside overlay %0d,%0d",col,row);checked=checked+1;end
    if(in_overlay&&orgb==24'hffff80)ink_count=ink_count+1;
    $fwrite(file,"%c%c%c",orgb[23:16],orgb[15:8],orgb[7:0]);@(negedge clk);
   end
   de=0;hs=1;tick;hs=0;tick;
  end
  $fclose(file);
 end
 if(ink_count<1000)$fatal(1,"motion font absent");
 $display("PASS motion_sidebar Chinese six states/HOLD and RV32I item16, %0d exact outside pixels/characters, %0d ink pixels",checked,ink_count);$finish;
end
initial begin #100000000;$fatal(1,"motion sidebar timeout");end
endmodule
