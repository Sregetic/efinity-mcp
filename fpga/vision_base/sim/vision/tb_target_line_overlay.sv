`timescale 1ns/1ps
module tb;
reg clk=0,cpu=0,rst=0;always #5 clk=~clk;always #7 cpu=~cpu;
reg de=0,vs=0;reg[11:0]x=0,y=0;reg[7:0]paddr=0;reg psel=0,penable=0,pwrite=0;reg[31:0]pwdata=0;
wire[31:0]prdata;wire pready,mark;wire[23:0]color;
vision_geometry_m7 dut(.clk(clk),.rst_n(rst),.de(de),.vs(vs),.x(x),.y(y),.enabled(1'b1),.frozen(1'b0),.source_valid(1'b1),.invalidated(1'b0),.capture_start(1'b0),.canny_ready(1'b1),
 .capture_frame(32'd0),.view_frame(32'd10),.view_config(32'd0),.view_context(32'd1),.canny_completed(32'd1),.source_errors(32'd0),.result_frame(32'd0),
 .cpu_clk(cpu),.cpu_rst_n(rst),.paddr(paddr),.psel(psel),.penable(penable),.pwrite(pwrite),.pwdata(pwdata),.prdata(prdata),.pready(pready),.mark(mark),.color(color),
 .edge_threshold(11'd80),.selection(3'd0),.selection_bank(1'b0),.motion_hint(4'd0),.motion_xy(24'd0),.motion_br(24'd0));
task wr(input[7:0]a,input[31:0]v);begin
 @(negedge cpu);psel=1;penable=0;pwrite=1;paddr=a;pwdata=v;
 @(negedge cpu);penable=1;@(posedge cpu);while(!pready)@(posedge cpu);
 @(negedge cpu);psel=0;penable=0;
end endtask
task word(input integer n,input[37:0]v);begin wr('h90,n);wr('h94,v[18:0]);wr('h98,v[37:19]);end endtask
task boundary;begin repeat(10)@(negedge clk);vs=1;repeat(20)@(negedge clk);vs=0;repeat(280)@(negedge clk);end endtask
integer xx0[0:5],yy0[0:5],xx1[0:5],yy1[0:5],shade[0:5];integer i,row,col,k,checks=0,hits=0,ppm;
integer gx,gy,xa,xb,ya,yb,delta,part,den,inv,a,b,temp,wanted;reg[23:0]rgb;reg[37:0]v;reg[1023:0]outdir;
initial begin
 if(!$value$plusargs("output=%s",outdir))$fatal(1,"output required");
 xx0[0]=6;yy0[0]=6;xx1[0]=32;yy1[0]=6;shade[0]=3;
 xx0[1]=32;yy0[1]=6;xx1[1]=32;yy1[1]=32;shade[1]=2;
 xx0[2]=6;yy0[2]=18;xx1[2]=24;yy1[2]=36;shade[2]=3;
 xx0[3]=50;yy0[3]=6;xx1[3]=36;yy1[3]=20;shade[3]=1;
 xx0[4]=60;yy0[4]=6;xx1[4]=65;yy1[4]=46;shade[4]=3;
 xx0[5]=70;yy0[5]=46;xx1[5]=70;yy1[5]=46;shade[5]=3;
 repeat(5)@(negedge clk);rst=1;
 word(0,0);word(1,0);
 for(i=0;i<6;i++)begin
  v=38'(xx0[i])|(38'(yy0[i])<<9)|(38'(xx1[i])<<18)|(38'(yy1[i])<<27)|(38'(shade[i])<<36);word(18+i,v);
 end
 for(i=6;i<48;i++)word(18+i,38'd70|(38'd46<<9)|(38'd70<<18)|(38'd46<<27)|(38'd3<<36));
 word(66,38'd48<<32);wr('h9c,3);boundary;
 if(!dut.track_lines)$fatal(1,"line packet not selected");
 ppm=$fopen($sformatf("%0s/continuous_lines.ppm",outdir),"wb");$fwrite(ppm,"P6\n320 216\n255\n");
 for(row=0;row<216;row++)begin
  for(col=0;col<320;col++)begin
   @(negedge clk);de=1;x=col;y=row;@(posedge clk);#1;gx=(col-2)>>>2;gy=(row-2)>>>2;wanted=0;
   if(col>=2&&row>=2)for(k=0;k<6;k++)begin
    if(yy0[k]<=yy1[k])begin xa=xx0[k];xb=xx1[k];ya=yy0[k];yb=yy1[k];end
    else begin xa=xx1[k];xb=xx0[k];ya=yy1[k];yb=yy0[k];end
    if(gy>=ya&&gy<=yb)begin
     den=yb-ya;part=gy-ya;delta=xb-xa;
     if(den==0)begin a=xa;b=xb;end
     else begin
      inv=(65536+den/2)/den;a=part==den?xb:xa+((delta*part*inv+32768)>>>16);
      b=part+1>=den?xb:xa+((delta*(part+1)*inv+32768)>>>16);
     end
     if(a>b)begin temp=a;a=b;b=temp;end
     if(gx>=a&&gx<=b&&shade[k]>wanted)wanted=shade[k];
    end
   end
   if(mark!==(wanted!=0))$fatal(1,"line pixel %0d,%0d got%b expected%0d spans%h",col,row,mark,wanted,dut.span_valid);
   rgb=wanted==3?24'h40ffff:wanted==2?24'h289090:24'h184848;
   if(mark&&color!==rgb)$fatal(1,"line shade %0d,%0d %h wanted%h",col,row,color,rgb);
   if(col==282&&row==186&&!dut.span_valid[47])$fatal(1,"48th segment missing");
   if(mark)hits++;checks++;$fwrite(ppm,"%c%c%c",mark?color[23:16]:8'h18,mark?color[15:8]:8'h20,mark?color[7:0]:8'h28);
  end
  @(negedge clk);de=0;repeat(280)@(negedge clk);
 end
 $fclose(ppm);word(66,0);wr('h9c,3);boundary;de=1;x=26;y=26;#1;if(mark)$fatal(1,"old segment survived empty packet");
 $display("PASS continuous line raster: horizontal/vertical/diagonal/reverse/steep, overlaps/three fades, singleton and atomic clearing; pixels=%0d hits=%0d",checks,hits);$finish;
end
initial begin #100000000;$fatal(1,"line renderer timeout");end
endmodule
