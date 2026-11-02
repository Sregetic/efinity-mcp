`timescale 1ns/1ps
module tb;
reg clk=0,cpu=0,rst=0;always #5 clk=~clk;always #7 cpu=~cpu;
reg de=0,vs=0,capture=0;reg[11:0]x=0,y=0;reg[31:0]completed=0;
reg[7:0]paddr=0;reg psel=0,penable=0,pwrite=0;reg[31:0]pwdata=0;wire[31:0]prdata;wire pready,mark;wire[23:0]color;
vision_geometry_m7 #(.CLOCK_HZ(100000000))dut(.clk(clk),.rst_n(rst),.de(de),.vs(vs),.x(x),.y(y),.enabled(1'b1),.frozen(1'b0),.source_valid(1'b1),.invalidated(1'b0),.capture_start(capture),.canny_ready(1'b1),
 .capture_frame(32'd10),.view_frame(32'd10),.view_config(32'd3),.view_context(32'd1),.canny_completed(completed),.source_errors(32'd0),.result_frame(32'd10),
 .cpu_clk(cpu),.cpu_rst_n(rst),.paddr(paddr),.psel(psel),.penable(penable),.pwrite(pwrite),.pwdata(pwdata),.prdata(prdata),.pready(pready),.mark(mark),.color(color),
 .edge_threshold(11'd80),.selection(3'd0),.selection_bank(1'b0),.motion_hint(4'd0),.motion_xy(24'd0),.motion_br(24'd0));
task bus(input wr,input[7:0]a,input[31:0]v,output[31:0]q);begin
 @(negedge cpu);psel=1;penable=0;pwrite=wr;paddr=a;pwdata=v;
 @(negedge cpu);penable=1;@(posedge cpu);while(!pready)@(posedge cpu);q=prdata;
 @(negedge cpu);psel=0;penable=0;
end endtask
task wr(input[7:0]a,input[31:0]v);reg[31:0]q;begin bus(1,a,v,q);end endtask
task object_word(input integer n,input[37:0]v);begin wr('h40+n*8,v[18:0]);wr('h44+n*8,v[37:19]);end endtask
task track_word(input integer n,input[37:0]v);begin wr('h90,n);wr('h94,v[18:0]);wr('h98,v[37:19]);end endtask
task boundary;begin @(negedge clk);vs=1;repeat(20)@(negedge clk);vs=0;repeat(280)@(negedge clk);end endtask
reg[37:0]labels[0:63],boxes[0:3];reg[31:0]q,timestamp,source_ms;reg[37:0]meta;
integer i,row,col,k,dx,dy,ax,ay,along,across,direction,checks=0,trail_checks=0,arrows=0,ppm;
reg wanted;reg[11:0]right_rows[0:11];reg[1023:0]output_dir;
initial begin
 if(!$value$plusargs("output=%s",output_dir))$fatal(1,"output path required");
 $readmemh("sim/fixtures/m7_labels.mem",labels);
 right_rows[0]=0;right_rows[1]=12'h040;right_rows[2]=12'h0c0;right_rows[3]=12'h180;right_rows[4]=12'hb00;
 right_rows[5]=12'hffe;right_rows[6]=12'hffe;right_rows[7]=12'hb00;right_rows[8]=12'h180;right_rows[9]=12'h0c0;right_rows[10]=12'h040;right_rows[11]=0;
 repeat(8)@(negedge clk);rst=1;repeat(300000)@(negedge clk);
 @(negedge clk);capture=1;source_ms=dut.milliseconds;@(negedge clk);capture=0;repeat(6)@(negedge clk);completed=1;repeat(10)@(negedge clk);
 wr(4,1);repeat(20)@(negedge clk);bus(0,'hac,0,q);if(q!=32'h4d544b31)$fatal(1,"MTK1 capability");
 bus(0,'ha8,0,q);if(q!=source_ms)$fatal(1,"source time is not the capture time");
 boxes[0]={2'd2,9'd50,9'd50,9'd124,9'd124};boxes[1]={2'd2,9'd200,9'd50,9'd274,9'd124};
 boxes[2]={2'd1,9'd50,9'd175,9'd124,9'd249};boxes[3]={2'd0,9'd200,9'd175,9'd274,9'd249};
 for(i=0;i<4;i=i+1)object_word(i,boxes[i]);
 wr('h38,0);for(i=0;i<64;i=i+1)begin
  k=i<32?48+i%16:i<48?16+i%16:i%16;
  wr('h80,labels[k][18:0]);wr('h84,labels[k][37:19]);
 end
 object_word(4,10);object_word(5,3);object_word(6,1);
 meta=38'd4|(38'd1<<13)|(38'd2<<24)|(38'd3<<27)|(38'd4<<30)|(38'd5<<33)|(38'd1<<36);object_word(7,meta);wr('h24,1);
 bus(0,'ha0,0,timestamp);track_word(0,0);track_word(1,0);
 for(i=0;i<48;i=i+1)track_word(18+i,38'(100+i*30)|(38'd620<<11)|(38'((timestamp-(i%3)*1100)&65535)<<22));
 track_word(66,38'd3|(38'd48<<32));wr('h9c,1);
 repeat(10)@(negedge clk);
 if(dut.track_alive||dut.front_count)$fatal(1,"non-atomic pre-VS publication");boundary;
 if(!dut.track_alive)$fatal(1,"history not published at VS");
 if(dut.front_count!=4||dut.object_directions!={3'd5,3'd4,3'd3,3'd2})$fatal(1,"four per-box directions not latched");
 ppm=$fopen($sformatf("%0s/multi_target_overlay.ppm",output_dir),"wb");$fwrite(ppm,"P6\n1920 1080\n255\n");
 for(row=0;row<1080;row=row+1)begin
  for(col=0;col<1920;col=col+1)begin
   @(negedge clk);de=1;x=col;y=row;@(posedge clk);#1;
   for(k=0;k<4;k=k+1)begin
    ax=boxes[k][17:9]*4+3-15+2;ay=boxes[k][26:18]*4+3+2;dx=col-ax;dy=row-ay;
    if(dx>=0&&dx<12&&dy>=0&&dy<12)begin
     direction=k+2;along=k<2?dx:dy;across=k<2?dy:dx;if(direction==2||direction==4)along=11-along;
     wanted=right_rows[across][along];if(mark!==wanted)$fatal(1,"object%0d arrow pixel %0d,%0d got%b expected%b",k,dx,dy,mark,wanted);
     checks++;if(mark)arrows++;
    end
   end
   if(row>=620&&row<=624&&col>=100&&col<=1514)begin
    for(i=0;i<48;i=i+1)if(col>=100+i*30&&col<=104+i*30)begin
     if(!mark)$fatal(1,"missing target history point %0d at %0d,%0d count%0d cursor%0d hit%h prepare_y%0d view%0d alive%b",i,col,row,dut.line_count,dut.hit_cursor,dut.hit_q,dut.prepare_y,dut.track_view,dut.track_alive);trail_checks++;
     if(color!==(i%3==0?24'h40ffff:i%3==1?24'h289090:24'h184848))$fatal(1,"history fade %0d",i);
    end
   end
   $fwrite(ppm,"%c%c%c",mark?color[23:16]:8'h18,mark?color[15:8]:8'h20,mark?color[7:0]:8'h28);
  end
  @(negedge clk);de=0;repeat(280)@(negedge clk);
 end
 $fclose(ppm);if(checks!=576||arrows!=152||trail_checks!=1200)$fatal(1,"incomplete raster checks %0d %0d %0d",checks,arrows,trail_checks);
 $display("PASS MTK1 actual 1080p render: four per-box arrows, 48 history points/three fades, source capture timestamp and VS publication; arrow patches=%0d",checks);$finish;
end
initial begin #100000000;$fatal(1,"MTK1 raster timeout");end
endmodule
