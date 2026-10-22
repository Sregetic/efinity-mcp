`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst_n=0,de=0,hs=0,vs=0;reg[23:0]rgb=0,ui_state=0;
reg[3:0]ai_status=0;reg motion_enable=0,motion_held=0;reg[2:0]motion_direction=0;
wire ode,ohs,ovs;wire[23:0]orgb;
vision_sidebar_overlay dut(.*);
reg[23:0]words[0:2];integer pix,frame,row,col,file,good=0,outside=0;reg[23:0]expected;reg[31:0]rng=32'h4312210;
function inside_panel(input integer xx,yy,input[23:0]ui);
 begin inside_panel=ui[23]&&yy>=128&&((xx<144&&yy<576)||(ui[17:15]!=7&&xx>=144&&xx<304&&yy<512));end
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
