`timescale 1ns/1ps
module tb;
reg clk=0,cpu=0,rst=0;always #5 clk=~clk;always #7 cpu=~cpu;
reg de=0,vs=0;reg[11:0]x=0,y=0;reg[31:0]view=3;
reg[7:0]paddr=0;reg psel=0,penable=0,pwrite=0;reg[31:0]pwdata=0;wire[31:0]prdata;wire pready,mark;wire[23:0]color;
vision_geometry_m7 #(.CLOCK_HZ(100000000))dut(.clk(clk),.rst_n(rst),.de(de),.vs(vs),.x(x),.y(y),.enabled(1'b1),.frozen(1'b0),.source_valid(1'b1),.invalidated(1'b0),.capture_start(1'b0),.canny_ready(1'b1),
 .capture_frame(32'd0),.view_frame(32'd10),.view_config(view),.view_context(32'd1),.canny_completed(32'd1),.source_errors(32'd0),.result_frame(32'd0),
 .cpu_clk(cpu),.cpu_rst_n(rst),.paddr(paddr),.psel(psel),.penable(penable),.pwrite(pwrite),.pwdata(pwdata),.prdata(prdata),.pready(pready),.mark(mark),.color(color),
 .edge_threshold(11'd80),.selection(3'd0),.selection_bank(1'b0),.motion_hint(4'd0),.motion_xy(24'd0),.motion_br(24'd0));
task bus(input wr,input[7:0]a,input[31:0]value,output[31:0]q);begin
 @(negedge cpu);psel=1;penable=0;pwrite=wr;paddr=a;pwdata=value;
 @(negedge cpu);penable=1;@(posedge cpu);while(!pready)@(posedge cpu);q=prdata;
 @(negedge cpu);psel=0;penable=0;
end endtask
task write_reg(input[7:0]a,input[31:0]v);reg[31:0]q;begin bus(1,a,v,q);end endtask
task word(input[6:0]i,input[37:0]v);begin write_reg('h90,i);write_reg('h94,{13'd0,v[18:0]});write_reg('h98,{13'd0,v[37:19]});end endtask
reg[37:0]labels[0:63];reg[31:0]q,timestamp;integer i,row,col,output_file,checks=0,hits=0;
reg[1023:0]output_dir;reg expected;reg[23:0]wanted;integer lx,ly,dx,dy;
task boundary;begin @(negedge clk);vs=1;repeat(20)@(negedge clk);vs=0;repeat(280)@(negedge clk);end endtask
initial begin
 if(!$value$plusargs("output=%s",output_dir))$fatal(1,"output path required");
 $readmemh("sim/fixtures/m7_labels.mem",labels);
 repeat(4)@(negedge clk);rst=1;repeat(10)@(negedge clk);
 bus(0,'ha4,0,q);if(q!==32'h54524b31)$fatal(1,"track ABI");bus(0,'ha0,0,timestamp);
 word(0,38'd700|(38'd400<<11)|(38'd1<<22));word(1,38'd900|(38'd600<<11)|(38'd1<<22));
 for(i=0;i<16;i=i+1)word(2+i,labels[16+i]);
 word(18,38'd100|(38'd500<<11)|(38'((timestamp)&65535)<<22));
 word(19,38'd200|(38'd500<<11)|(38'((timestamp-1200)&65535)<<22));
 word(20,38'd300|(38'd500<<11)|(38'((timestamp-2400)&65535)<<22));
 word(21,38'd400|(38'd500<<11)|(38'((timestamp-3100)&65535)<<22));
 word(22,38'd500|(38'd400<<11)|(38'((timestamp)&65535)<<22));
 word(23,38'd500|(38'd400<<11)|(38'((timestamp-1200)&65535)<<22));
 word(24,38'd1000|(38'd700<<11)|(38'((timestamp)&65535)<<22));
 word(66,38'd3|(38'd7<<32));write_reg('h9c,1);
 repeat(10)@(negedge clk);if(dut.track_bank||dut.track_alive)$fatal(1,"track changed outside VS");
 boundary();if(!dut.track_bank||!dut.track_alive)$fatal(1,"no atomic track bank");
 output_file=$fopen($sformatf("%0s/track_overlay.ppm",output_dir),"wb");$fwrite(output_file,"P6\n1920 1080\n255\n");
 for(row=0;row<1080;row=row+1)begin
  for(col=0;col<1920;col=col+1)begin
   @(negedge clk);de=1;x=col;y=row;@(posedge clk);#1;
   lx=col-2;ly=row-2;expected=0;wanted=0;
   if(lx>=700&&lx<=900&&ly>=400&&ly<=600&&(lx==700||lx==900||ly==400||ly==600))begin expected=1;wanted=24'hff40ff;end
   if(lx>=98&&lx<=102&&ly>=498&&ly<=502)begin expected=1;wanted=24'h40ffff;end
   if(lx>=198&&lx<=202&&ly>=498&&ly<=502)begin expected=1;wanted=24'h289090;end
   if(lx>=298&&lx<=302&&ly>=498&&ly<=502)begin expected=1;wanted=24'h184848;end
   if(lx>=498&&lx<=502&&ly>=398&&ly<=402)begin expected=1;wanted=24'h40ffff;end
   if(lx>=998&&lx<=1002&&ly>=698&&ly<=702)begin expected=1;wanted=24'h40ffff;end
   dx=lx-700;dy=ly-382;
   if(dx>=0&&dx<labels[16+dy][37:32]&&dy>=0&&dy<16)begin expected=1;wanted=labels[16+dy][dx]?24'hff40ff:24'd0;end
   if(mark!==expected)$fatal(1,"track mark %0d,%0d got%b expected%b count%0d cursor%0d prep%0d",col,row,mark,expected,dut.line_count,dut.hit_cursor,dut.prepare_y);
   if(expected&&color!==wanted)$fatal(1,"track color %0d,%0d %h expected%h",col,row,color,wanted);
   checks++;if(mark)hits++;
   $fwrite(output_file,"%c%c%c",mark?color[23:16]:8'h18,mark?color[15:8]:8'h20,mark?color[7:0]:8'h28);
  end
  @(negedge clk);de=0;repeat(280)@(negedge clk);
 end
 $fclose(output_file);view=4;repeat(10)@(negedge clk);de=1;x=702;y=402;#1;if(mark)$fatal(1,"stale render transform shown");de=0;
 view=3;force dut.milliseconds=timestamp+3000;
 @(negedge clk);de=1;y=501;@(negedge clk);de=0;repeat(100)@(negedge clk);
 de=1;x=102;y=502;#1;if(mark)$fatal(1,"three-second point did not expire");de=0;release dut.milliseconds;
 // Old points never reappear after timestamp wrap if the CPU stops publishing.
 force dut.milliseconds=32'd65536;force dut.track_watchdog=12'd3001;
 boundary();de=1;x=102;y=502;#1;if(mark)$fatal(1,"expired observation resurrected");
 release dut.milliseconds;release dut.track_watchdog;
 $display("PASS track overlay atomic VS, source/render transform gate, box/label, measured dots, three fades, duplicate X and expiry; %0d actual pixels %0d marks",checks,hits);$finish;
end
initial begin #100000000;$fatal(1,"track overlay timeout");end
endmodule
