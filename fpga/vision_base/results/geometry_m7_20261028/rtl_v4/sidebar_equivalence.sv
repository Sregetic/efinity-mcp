`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst_n=0,de=0,hs=0,vs=0;reg[23:0]rgb=0,ui_state=0;
reg[3:0]ai_status=0;reg motion_enable=0,motion_held=0;reg[2:0]motion_direction=0;
wire ode,ohs,ovs;wire[23:0]orgb;
vision_sidebar_overlay dut(.*);
wire ref_de,ref_hs,ref_vs;wire[23:0]ref_rgb;
vision_sidebar_overlay_reference reference(.clk(clk),.rst_n(rst_n),.de(de),.hs(hs),.vs(vs),.rgb(rgb),.ui_state(ui_state),.ai_status(ai_status),
 .motion_enable(motion_enable),.motion_held(motion_held),.motion_direction(motion_direction),.ode(ref_de),.ohs(ref_hs),.ovs(ref_vs),.orgb(ref_rgb));
always @(posedge clk)begin #1;if(rst_n&&{ode,ohs,ovs,orgb}!=={ref_de,ref_hs,ref_vs,ref_rgb})$fatal(1,"hidden HUD pruning changed a sidebar pixel");end
reg[23:0]words[0:2];integer pix,frame,row,col,file,good=0,outside=0;reg[23:0]expected;reg[31:0]rng=32'h4312210;
reg[11:0]probe_x,probe_y;reg[63:0]wanted;integer choice,slot;
function inside_panel(input integer xx,yy,input[23:0]ui);
 begin inside_panel=ui[23]&&yy>=128&&((xx<144&&yy<576)||(ui[17:15]!=7&&xx>=144&&xx<304&&yy<512)||
       (ui[22]&&ui[21:18]==0&&!ui[14]&&ui[17:15]!=7&&xx>=304&&xx<464&&yy<768));end
endfunction
task tick;
 begin @(posedge clk);#1;
  if(ode!==de||ohs!==hs||ovs!==vs)$fatal(1,"RGB/sync alignment");
  if(ode&&!inside_panel(col,row,ui_state))begin
   if(orgb!==rgb)$fatal(1,"pixel changed outside sidebar at %0d,%0d",col,row);outside=outside+1;
  end
  @(negedge clk);
 end
endtask
initial begin
 words[0]=24'h838005;words[1]=24'h800005;words[2]=24'hc00006; // Golden RV32I root/IMAGE/edit-mode words.
 for(pix=65;pix<=90;pix=pix+1)if(dut.sidebar_font.glyph(pix)==0)$fatal(1,"missing uppercase UI glyph %0d",pix);
 repeat(2)@(negedge clk);rst_n=1;col=1000;row=1000;
 for(pix=0;pix<65536;pix=pix+1)begin rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);rgb=rng[23:0];de=rng[0];hs=rng[1];vs=rng[2];tick;end
 force dut.x=probe_x;force dut.y=probe_y;force reference.x=probe_x;force reference.y=probe_y;
 for(choice=0;choice<8;choice=choice+1)begin
  ui_state=24'hc00000|choice;wanted=dut.sidebar_font.mode_label(choice);
  for(slot=0;slot<8;slot=slot+1)begin
   probe_x=320+slot*16;probe_y=128+(choice+1)*64+24;col=probe_x;row=probe_y;tick;
   if(!dut.active||dut.sidebar_font.ch_q!==wanted[63-slot*8-:8])$fatal(1,"mode list name %0d slot%0d",choice,slot);
  end
  probe_x=304;probe_y=128+(choice+1)*64;col=probe_x;row=probe_y;tick;
  if(!dut.sidebar_font.marker_q)$fatal(1,"mode list selected row%0d not highlighted",choice);
 end
 ui_state=24'h800005;probe_x=320;probe_y=300;col=probe_x;row=probe_y;tick;
 if(dut.active)$fatal(1,"confirmed mode list did not collapse");
 release dut.x;release dut.y;release reference.x;release reference.y;
 de=0;hs=0;vs=0;rst_n=0;tick;rst_n=1;
 // Preview comes from the production font/compositor, on a synthetic test scene.
 for(frame=0;frame<3;frame=frame+1)begin
  ui_state=words[frame];de=0;hs=0;vs=0;tick;vs=1;tick;vs=0;tick;
  if(frame==0)file=$fopen("results/vision_features/sidebar_menu.ppm","wb");
  else if(frame==1)file=$fopen("results/vision_features/sidebar_submenu.ppm","wb");
  else file=$fopen("results/vision_features/sidebar_edit.ppm","wb");
  $fwrite(file,"P6\n1920 1080\n255\n");
  for(row=0;row<1080;row=row+1)begin
   for(col=0;col<1920;col=col+1)begin
    de=1;rgb=(col>=850&&col<1070&&row>=430&&row<650)?24'h30a0e0:((col%120==0||row%120==0)?24'h606060:24'h303c44);
    @(posedge clk);#1;
    if(!ode)$fatal(1,"DE lost");
    if(!inside_panel(col,row,ui_state))begin if(orgb!==rgb)$fatal(1,"sidebar leaked outside panels x=%0d y=%0d scan=%0d,%0d rgb=%h expected=%h",col,row,dut.x,dut.y,orgb,rgb);outside=outside+1;end
    if(col==0&&row==128&&orgb!=24'h101010)$fatal(1,"sidebar background absent");
    if(col>=16&&col<304&&inside_panel(col,row,ui_state)&&orgb==24'hffff80)good=good+1;
    $fwrite(file,"%c%c%c",orgb[23:16],orgb[15:8],orgb[7:0]);@(negedge clk);
   end
   de=0;hs=1;tick;hs=0;tick;
  end
  $fclose(file);
 end
 if(good<1000)$fatal(1,"sidebar font missing");
 $display("PASS sidebar_video outside=%0d ink=%0d exact RGB and sync, mode bypass retained",outside,good);$finish;
end
initial begin #100000000;$fatal(1,"watchdog");end
endmodule
