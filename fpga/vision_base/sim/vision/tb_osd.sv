`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg[11:0]x=8,y=4;reg[2:0]mode=2;reg[10:0]threshold=96;wire active,ink;
reg[23:0]ui=0;
reg fusion=0,matched=1;reg[351:0]packet=0;reg[15:0]age=0;
vision_osd dut(x,y,mode,threshold,1'b1,2'd0,3'd0,1'b1,2'd0,1'b0,1'b0,active,ink,11'd16,fusion,packet,matched,age,clk,ui,13'd0);
task character(input integer position,input[7:0]wanted);
begin @(negedge clk);x=8+12*position;@(posedge clk);#1;if(dut.ch_q!==wanted||!active)$fatal(1,"OSD character %0d: %c expected %c",position,dut.ch_q,wanted);end
endtask
task side_character(input integer line,input integer offset,input integer position,input[7:0]wanted);
begin @(negedge clk);y=128+line*64+offset;x=144+16+16*position;@(posedge clk);#1;if(dut.ch_q!==wanted||!active)$fatal(1,"sidebar character %0d: %c expected %c",position,dut.ch_q,wanted);end
endtask
task side_word(input integer line,input integer offset,input[63:0]wanted);
 integer slot;
 begin for(slot=0;slot<8;slot=slot+1)side_character(line,offset,slot,wanted[63-8*slot-:8]);end
endtask
integer j,expected,m,k,g,item,line,py,px,font_pixels=0;reg[7:0]forced_code;reg expected_ink;
reg[63:0]mode_names[0:7],labels[0:16],groups[0:3],statuses[0:6],tests[0:3],runs[0:3];reg[255:0]cn_pattern;
initial begin
 for(j=0;j<2048;j=j+1)begin expected=((j/1000)<<12)|(((j/100)%10)<<8)|(((j/10)%10)<<4)|(j%10);if(dut.decimal(j)!==expected[15:0])$fatal(1,"decimal %0d",j);end
 character(0,"S");character(1,"O");character(2,"B");character(3,"E");character(4,"L");
 character(10,"0");character(11,"0");character(12,"9");character(13,"6");
 mode=5;threshold=2047;
 character(0,"C");character(1,"A");character(2,"N");character(3,"N");character(4,"Y");
 character(10,"2");character(11,"0");character(12,"4");character(13,"7");
 threshold=16;character(10,"0");character(11,"0");character(12,"1");character(13,"6");
 threshold=24;character(10,"0");character(11,"0");character(12,"2");character(13,"4");
 character(29,"R");character(30,"0");character(31,"0");character(32,"1");character(33,"6");
 fusion=1;y=40;packet[10:8]=2;character(3,"T");character(4,"E");character(5,"S");character(6,"T");
 packet[0]=1;matched=0;character(3,"O");character(4,"L");character(5,"D");
 age=16'h1a2b;character(15,"1");character(16,"A");character(17,"2");character(18,"B");
 y=58;packet[63:32]=32'h12345678;character(1,"1");character(8,"8");
 packet[127:96]=32'h76543210;character(11,"7");character(18,"0");
 y=76;packet[95:64]=32'hdeadbeef;packet[287:256]=32'h807f01ff;
 character(1,"D");character(8,"F");character(11,"F");character(12,"F");character(23,"8");character(24,"0");
 @(negedge clk);x=428;@(posedge clk);#1;if(active)$fatal(1,"OSD extent");
 fusion=0;mode=0;y=4;ui=(3<<11)|1408;
 character(0,"P");character(1,"A");character(2,"N");character(4,"X");character(9,"V");
 character(10,"1");character(11,"4");character(12,"0");character(13,"8");
 matched=1;ui=(8<<11)|1;character(0,"A");character(1,"I");character(3,"F");character(4,"I");character(5,"X");
 y=40;packet[12:11]=2;packet[14:13]=2;packet[31:16]=16'h1234;packet[1]=1;
 character(3,"D");character(4,"O");character(5,"N");character(6,"E");
 character(11,"P");character(12,"A");character(13,"S");character(14,"S");
 character(17,"1");character(20,"4");character(28,"T");character(31,"T");
 matched=0;character(3,"O");character(4,"L");character(5,"D");matched=1;
 packet[14:13]=3;character(11,"F");character(12,"A");character(13,"I");character(14,"L");
 y=76;packet[303:288]=16'h0abc;packet[319:304]=16'h0067;packet[335:320]=16'h3c28;
 character(0,"U");character(1,"S");character(4,"0");character(7,"C");character(13,"7");character(16,"3");character(19,"8");
 ui=9<<11;y=4;character(0,"S");character(4,"T");character(7,"T");
 ui=10<<11;character(0,"N");character(1,"N");character(3,"B");character(6,"E");
 ui=(10<<11)|1;character(3,"F");character(4,"O");character(5,"M");character(6,"O");
 y=76;packet[159:128]=2;character(0,"M");character(1,"S");
 fusion=0;packet[0]=0;ui=24'h800000|(11<<18);packet[14:13]=2;
 tests[0]=dut.ZH_TEST_NONE;tests[1]=dut.ZH_TEST_WAIT;tests[2]=dut.ZH_TEST_PASS;tests[3]=dut.ZH_TEST_FAIL;
 runs[0]=dut.ZH_AI_IDLE;runs[1]=dut.ZH_AI_RUN;runs[2]=dut.ZH_AI_DONE;runs[3]=dut.ZH_AI_ERROR;
 for(m=0;m<4;m=m+1)begin
  ui=24'h800000|(11<<18);packet[14:13]=m;side_word(5,24,tests[m]);
  ui=24'h800000|(9<<18);packet[12:11]=m;side_word(5,24,runs[m]);
 end
 packet[0]=1;packet[12:11]=2;matched=0;side_word(5,24,dut.ZH_AI_OLD);packet[0]=0;matched=1;
 mode_names[0]=dut.ZH_CAMERA;mode_names[1]=dut.ZH_GRAY;mode_names[2]=dut.ZH_SOBEL;mode_names[3]=dut.ZH_SPLIT;
 mode_names[4]=dut.ZH_SOBEL_OVERLAY;mode_names[5]=dut.ZH_CANNY;mode_names[6]=dut.ZH_CANNY_OVERLAY;mode_names[7]=dut.ZH_SHAPE;
 for(m=0;m<8;m=m+1)begin
  ui=24'hc00000|m;
  side_word(1,36,mode_names[m]);
 end
 labels[0]=dut.ZH_MODE;labels[1]=dut.ZH_THRESHOLD;labels[2]=dut.ZH_MEDIAN;labels[3]=dut.ZH_ZOOM;
 labels[4]=dut.ZH_PAN_X;labels[5]=dut.ZH_PAN_Y;labels[6]=dut.ZH_SIZE;labels[7]=dut.ZH_POS_X;
 labels[8]=dut.ZH_POS_Y;labels[9]=dut.ZH_AI_MODE;labels[10]=dut.ZH_RUN;labels[11]=dut.ZH_SELFTEST;
 labels[12]=dut.ZH_MODEL;labels[13]=dut.ZH_CENTER;labels[14]=dut.ZH_TARGET_ZOOM;labels[15]=dut.ZH_FULLVIEW;labels[16]=dut.ZH_MOTION;
 groups[0]=dut.ZH_IMAGE;groups[1]=dut.ZH_VIEW;groups[2]=dut.ZH_TARGET;groups[3]=dut.ZH_AI;
 for(item=0;item<17;item=item+1)begin
  ui=24'h800000|((item&15)<<18)|((item>>4)<<14);line=item<3?item+1:item<9?item-2:item<13?item-8:item-12;
  side_word(line,12,labels[item]);
 end
 for(g=0;g<4;g=g+1)begin
  ui=24'h838000|(g<<18);
  for(k=0;k<8;k=k+1)begin
   @(negedge clk);x=16+16*k;y=128+(g+1)*64+24;@(posedge clk);#1;
   if(dut.ch_q!==groups[g][63-8*k-:8]||!active)$fatal(1,"Chinese root category %0d",g);
  end
 end
 ui=24'h800000|(2<<18)|1;side_word(3,36,dut.ZH_ON);
 ui=24'h800000|(2<<18);side_word(3,36,dut.ZH_OFF);
 ui=24'h800000|(9<<18);side_word(1,36,dut.ZH_OFF);
 ui=24'h800000|(9<<18)|1;side_word(1,36,dut.ZH_FIXED);
 ui=24'h800000|(9<<18)|2;side_word(1,36,dut.ZH_AUTO);
 ui=24'h800000|(12<<18)|1;side_word(4,36,"FOMO    ");
 ui=24'h800000|(12<<18);side_word(4,36,dut.ZH_BASE);
 ui=24'h800000|(14<<18);side_word(2,36,dut.ZH_AUTO);
 for(m=1;m<=8;m=m*2)begin ui=24'h800000|(14<<18)|m;side_word(2,36,{8'd48+m[7:0],dut.ZH_TIMES[63:56],48'h202020202020});end
 ui=24'h800000|(3<<18)|960;side_word(1,36,{dut.ZH_WIDTH[63:56],"0960",dut.ZH_PIXELS[63:48],8'd32});
 ui=24'h800000|(4<<18)|320;side_word(2,36,{"0320",dut.ZH_PIXELS[63:48],16'h2020});
 statuses[0]=dut.ZH_READY;statuses[1]=dut.ZH_WAIT;statuses[2]=dut.ZH_DONE;statuses[3]=dut.ZH_NO_TARGET;
 statuses[4]=dut.ZH_BUSY;statuses[5]=dut.ZH_STALE;statuses[6]=dut.ZH_ERROR;
 for(m=0;m<7;m=m+1)begin ui=24'h800000|(13<<18)|(m<<15);side_word(5,24,statuses[m]);end
 ui=24'h800000|(13<<18);side_word(1,36,dut.ZH_ENTER);side_word(6,12,dut.ZH_ENTER);side_word(6,36,dut.ZH_BACK);
 ui=24'hc00000|(13<<18);side_word(0,24,dut.ZH_EDIT);side_word(1,36,dut.ZH_CONFIRM);side_word(6,36,dut.ZH_CANCEL);
 @(negedge clk);ui=24'h838005;x=16;y=100;@(posedge clk);#1;if(active)$fatal(1,"sidebar covered original status HUD");
 @(negedge clk);x=144;y=228;@(posedge clk);#1;if(active)$fatal(1,"root opened child without confirm");
 @(negedge clk);x=143;@(posedge clk);#1;if(!active)$fatal(1,"root width");
 @(negedge clk);ui=24'h800005;x=303;y=511;@(posedge clk);#1;if(!active)$fatal(1,"child extent");
 @(negedge clk);x=304;@(posedge clk);#1;if(active)$fatal(1,"child width");
 @(negedge clk);x=160;y=512;@(posedge clk);#1;if(active)$fatal(1,"image group height");
 @(negedge clk);ui=24'h8c0780;y=703;@(posedge clk);#1;if(!active)$fatal(1,"view group height");
 // Exercise every Chinese pixel through the real synchronous ROM/mixed-font mux.
 ui=24'h800005;force dut.ch=forced_code;
 for(j=0;j<dut.CHINESE_GLYPHS;j=j+1)begin
  forced_code=128+j;cn_pattern=dut.chinese_glyph(j);
  for(py=0;py<16;py=py+1)for(px=0;px<16;px=px+1)begin
   @(negedge clk);x=160+px;y=204+py;@(posedge clk);#1;
   if(!active||ink!==cn_pattern[255-py*16-px])$fatal(1,"Chinese pixel %0d:%0d,%0d",j,px,py);
   font_pixels=font_pixels+1;
  end
  @(negedge clk);y=220;@(posedge clk);#1;if(ink)$fatal(1,"Chinese vertical bleed");
 end
 // Original ASCII glyph pixels stay exact, including blank/unused codes.
 ui=0;mode=0;fusion=0;
 for(j=0;j<128;j=j+1)begin
  forced_code=j;
  for(py=0;py<16;py=py+1)for(px=0;px<12;px=px+1)begin
   @(negedge clk);x=8+px;y=4+py;@(posedge clk);#1;
   expected_ink=px<10&&py<14?((dut.glyph(j)>>(34-(py/2)*5-px/2))&1):0;
   if(!active||ink!==expected_ink)$fatal(1,"Legacy font pixel %0d:%0d,%0d",j,px,py);
   font_pixels=font_pixels+1;
  end
 end
 release dut.ch;
 $display("PASS OSD Chinese 4 groups/17 labels/8 modes/statuses/units and %0d font pixels, legacy HUD exact, widths144/304 row64",font_pixels);$finish;
end
endmodule
