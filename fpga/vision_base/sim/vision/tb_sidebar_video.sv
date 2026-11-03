`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst_n=0,de=0,hs=0,vs=0;reg[23:0]rgb=0,ui_state=0;
reg[3:0]ai_status=0;reg motion_enable=0,motion_held=0;reg[2:0]motion_direction=0;
reg[27:0]target_classes=0;wire ode,ohs,ovs;wire[23:0]orgb;
vision_sidebar_overlay dut(.*);
reg[23:0]words[0:5];integer pix,frame,row,col,file,good=0,outside=0;reg[23:0]expected;reg[31:0]rng=32'h4312210;
reg probing=0;
reg[11:0]probe_x,probe_y;
always @(probe_x or probe_y or probing)begin
 if(probing)begin force dut.x=probe_x;force dut.y=probe_y;end
 else begin release dut.x;release dut.y;end
end
reg[63:0]wanted;integer choice,slot;
function inside_panel(input integer xx,yy,input[23:0]ui);
 integer item,group,count;
 begin
  item=ui[21:18]|(ui[14]<<4);group=item<3?0:item<9?1:item<13?3:2;count=group==0?3:group==1?6:group==2?6:4;
  inside_panel=ui[23]&&yy>=128&&((xx<144&&yy<576)||(ui[17:15]!=7&&xx>=144&&xx<304&&yy<128+(count+3)*64)||
       (ui[22]&&item==0&&ui[17:15]!=7&&xx>=304&&xx<464&&yy<704)||
       (ui[22]&&item==13&&ui[10]&&xx>=304&&xx<464&&yy<128+((ui[4:2]?ui[4:2]:1)+2)*64));
 end
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
 words[0]=24'h838005;words[1]=24'h800005;words[2]=24'hcc03c0;words[3]=24'hb00002;words[4]=24'hf40453;words[5]=24'hb00001; // Golden RV32I root/IMAGE/edit-mode words.
 for(pix=65;pix<=90;pix=pix+1)if(dut.sidebar_font.glyph(pix)==0)$fatal(1,"missing uppercase UI glyph %0d",pix);
 repeat(2)@(negedge clk);rst_n=1;col=1000;row=1000;
 for(pix=0;pix<65536;pix=pix+1)begin rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);rgb=rng[23:0];de=rng[0];hs=rng[1];vs=rng[2];tick;end
 probing=1;
 for(choice=0;choice<7;choice=choice+1)begin
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
 // The retired model label is blank; the only selectable labels are FOMO and M7.
 for(choice=0;choice<3;choice=choice+1)begin
  ui_state=24'hb00000|choice;wanted=choice==2?dut.sidebar_font.ZH_M7:choice==1?"FOMO    ":"        ";
  for(slot=0;slot<8;slot=slot+1)begin
   probe_x=160+slot*16;probe_y=128+4*64+36;col=probe_x;row=probe_y;tick;
   if(dut.sidebar_font.ch_q!==wanted[63-slot*8-:8])$fatal(1,"model label%0d slot%0d",choice,slot);
  end
 end
 // Real target rows:1..4 items, same class order as the CPU snapshot, selected border.
 target_classes=28'h080c101;
 for(choice=0;choice<=4;choice++)begin
  ui_state=24'hf40440|(choice<<2)|(choice?choice-1:0);
  for(slot=0;slot<8;slot++)begin
   probe_x=320+slot*16;probe_y=128+24;col=probe_x;row=probe_y;tick;
   if(!dut.active||dut.sidebar_font.ch_q!==dut.sidebar_font.ZH_CHOOSE[63-slot*8-:8])$fatal(1,"target chooser header");
  end
  if(choice)begin
   wanted=choice==1?dut.sidebar_font.ZH_CIRCLE:choice==2?dut.sidebar_font.ZH_RECTANGLE:choice==3?dut.sidebar_font.ZH_FACE:"A       ";
   for(slot=0;slot<6;slot++)begin
    probe_x=352+slot*16;probe_y=128+choice*64+24;col=probe_x;row=probe_y;tick;
    if(!dut.active||dut.sidebar_font.ch_q!==wanted[63-slot*8-:8])$fatal(1,"target chooser class row%0d slot%0d",choice,slot);
   end
   probe_x=304;probe_y=128+choice*64;col=probe_x;row=probe_y;tick;
   if(!dut.sidebar_font.marker_q)$fatal(1,"target chooser selected row");
  end
 end
 // Live view edits finish/back; they must not advertise a deferred commit/cancel.
 for(choice=3;choice<=8;choice++)begin
  ui_state=24'hc00000|(choice<<18)|24'd960;
  for(slot=0;slot<8;slot++)begin
   probe_x=160+slot*16;probe_y=128+8*64+12;col=probe_x;row=probe_y;tick;
   if(dut.sidebar_font.ch_q!==dut.sidebar_font.ZH_FINISH[63-slot*8-:8])$fatal(1,"view finish text %0d",choice);
   probe_y=128+8*64+36;row=probe_y;tick;
   if(dut.sidebar_font.ch_q!==dut.sidebar_font.ZH_BACK[63-slot*8-:8])$fatal(1,"view back text %0d",choice);
  end
 end
 // A lost live target leaves all four choices visible, with no selected-row marker.
 ui_state=24'hf40440|(4<<2)|32;
 for(choice=1;choice<=4;choice++)begin
  probe_x=304;probe_y=128+choice*64;col=probe_x;row=probe_y;tick;
  if(dut.sidebar_font.marker_q)$fatal(1,"lost target retained a selected-row marker");
 end
 probing=0;
 de=0;hs=0;vs=0;rst_n=0;tick;rst_n=1;
 // Preview comes from the production font/compositor, on a synthetic test scene.
 for(frame=0;frame<6;frame=frame+1)begin
  ui_state=words[frame];target_classes=frame==4?28'h040c09e:28'h080c101;de=0;hs=0;vs=0;tick;vs=1;tick;vs=0;tick;
  if(frame==0)file=$fopen("results/vision_features/sidebar_menu.ppm","wb");
  else if(frame==1)file=$fopen("results/vision_features/sidebar_submenu.ppm","wb");
  else if(frame==2)file=$fopen("results/vision_features/sidebar_edit.ppm","wb");
  else if(frame==3)file=$fopen("results/target_chooser_20261030/model_menu.ppm","wb");
  else if(frame==4)file=$fopen("results/target_chooser_20261030/target_menu.ppm","wb");
  else file=$fopen("results/target_chooser_20261030/fomo_menu.ppm","wb");
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
initial begin #150000000;$fatal(1,"watchdog");end
endmodule
