`timescale 1ns/1ps
module tb;
reg clk=0,cpu=0,rst=0;always #5 clk=~clk;always #7 cpu=~cpu;
reg de=0,vs=0;reg[11:0]x=0,y=0;reg[31:0]view=0;
reg[7:0]paddr=0;reg psel=0,penable=0,pwrite=0;reg[31:0]pwdata=0;wire[31:0]prdata;wire pready,mark;wire[23:0]color;
vision_geometry_m7 #(.CLOCK_HZ(100000000))dut(.clk(clk),.rst_n(rst),.de(de),.vs(vs),.x(x),.y(y),.enabled(1'b1),.frozen(1'b0),.source_valid(1'b1),.invalidated(1'b0),.capture_start(1'b0),.canny_ready(1'b1),
 .capture_frame(32'd0),.view_frame(32'd10),.view_config(view),.view_context(32'd1),.canny_completed(32'd1),.source_errors(32'd0),.result_frame(32'd0),
 .cpu_clk(cpu),.cpu_rst_n(rst),.paddr(paddr),.psel(psel),.penable(penable),.pwrite(pwrite),.pwdata(pwdata),.prdata(prdata),.pready(pready),.mark(mark),.color(color),
 .edge_threshold(11'd80),.selection(3'd0),.selection_bank(1'b0),.motion_hint(4'd0),.motion_xy(24'd0),.motion_br(24'd0));
task write_reg(input[7:0]a,input[31:0]value);begin
 @(negedge cpu);psel=1;penable=0;pwrite=1;paddr=a;pwdata=value;
 @(negedge cpu);penable=1;@(posedge cpu);while(!pready)@(posedge cpu);
 @(negedge cpu);psel=0;penable=0;
end endtask
reg[37:0]packet[0:66];reg[23:0]backdrop[0:2073599];reg[23:0]pixel;
reg[1023:0]packet_file,background_file,output_dir;integer now_ms,i,row,col,file,mask,hits=0,lines=0;
initial begin
 if(!$value$plusargs("packet=%s",packet_file)||!$value$plusargs("background=%s",background_file)||!$value$plusargs("output=%s",output_dir)||!$value$plusargs("time_ms=%d",now_ms))$fatal(1,"render paths/time required");
 if($value$plusargs("lines=%d",lines))begin end
 $readmemh(packet_file,packet);$readmemh(background_file,backdrop);view=packet[66][31:0];
 repeat(4)@(negedge clk);rst=1;
 for(i=0;i<67;i++)begin write_reg('h90,i);write_reg('h94,{13'd0,packet[i][18:0]});write_reg('h98,{13'd0,packet[i][37:19]});end
 write_reg('h9c,lines?3:1);force dut.milliseconds=now_ms;
 repeat(10)@(negedge clk);if(dut.track_alive)$fatal(1,"track update before frame boundary");
 @(negedge clk);vs=1;repeat(20)@(negedge clk);vs=0;repeat(280)@(negedge clk);
 if(!dut.track_alive)$fatal(1,"track request not committed at frame boundary");
 file=$fopen($sformatf("%0s/follow_overlay.ppm",output_dir),"wb");mask=$fopen($sformatf("%0s/follow_overlay.mask",output_dir),"wb");$fwrite(file,"P6\n1920 1080\n255\n");
 for(row=0;row<1080;row++)begin
  for(col=0;col<1920;col++)begin
   @(negedge clk);de=1;x=col;y=row;@(posedge clk);#1;
   pixel=mark?color:backdrop[row*1920+col];if(mark)hits++;
   $fwrite(file,"%c%c%c",pixel[23:16],pixel[15:8],pixel[7:0]);$fwrite(mask,"%c",{7'd0,mark});
  end
  @(negedge clk);de=0;repeat(280)@(negedge clk);
 end
 $fclose(file);$fclose(mask);if(hits<400)$fatal(1,"follow overlay absent");
 $display("PASS RV32 packet on actual ROI pixels, %0d selected label/box/trajectory marks",hits);$finish;
end
initial begin #100000000;$fatal(1,"follow render timeout");end
endmodule
