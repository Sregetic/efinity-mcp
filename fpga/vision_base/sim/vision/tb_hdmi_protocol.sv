`timescale 1ns/1ps
// Run the real protected vendor dvi_encoder RTL using ModelSim and EFX_SRL8.
module tb_hdmi_protocol;
reg clk=0;always #3.367 clk=~clk;
reg rst=1;integer x=0,y=1124,cycles=0;
always @(posedge clk)begin
 if(rst)begin x<=0;y<=1124;end
 else if(x==2199)begin x<=0;y<=(y==1124)?0:y+1;end else x<=x+1;
end
wire de=x<1920&&y<1080,hs=x>=2008&&x<2052,vs=y>=1084&&y<1089;
wire[7:0]r=x[7:0],g=y[7:0],b=x[7:0]^y[7:0];
wire[9:0]d0,d1,d2,dc;
dvi_encoder dut(.pixelclk(clk),.rst_p(rst),.i_bdata(b),.i_gdata(g),.i_rdata(r),
 .i_hs(hs),.i_vs(vs),.i_de(de),.video_format(2'd0),.video_VIC(7'd16),
 .audio_L(24'd0),.audio_R(24'd0),.audio_valid(1'b0),.audio_N(20'd6144),
 .audio_CTS(20'd148500),.audio_sample_frequency(4'd2),.audio_word_length(4'd2),
 .tmds_data0(d0),.tmds_data1(d1),.tmds_data2(d2),.tmds_clk(dc));

function automatic integer control(input[9:0]v);
 case(v)10'b1101010100:control=0;10'b0010101011:control=1;
 10'b0101010100:control=2;10'b1010101011:control=3;default:control=-1;endcase
endfunction
function automatic integer terc(input[9:0]v);
 case(v)
 10'b1010011100:terc=0;10'b1001100011:terc=1;10'b1011100100:terc=2;10'b1011100010:terc=3;
 10'b0101110001:terc=4;10'b0100011110:terc=5;10'b0110001110:terc=6;10'b0100111100:terc=7;
 10'b1011001100:terc=8;10'b0100111001:terc=9;10'b0110011100:terc=10;10'b1011000110:terc=11;
 10'b1010001110:terc=12;10'b1001110001:terc=13;10'b0101100011:terc=14;10'b1011000011:terc=15;
 default:terc=-1;endcase
endfunction
function automatic[7:0]pixel(input[9:0]v);
 reg[7:0]q;integer n;
 begin q=v[9]?~v[7:0]:v[7:0];pixel[0]=q[0];
 for(n=1;n<8;n=n+1)pixel[n]=v[8]?(q[n]^q[n-1]):~(q[n]^q[n-1]);end
endfunction
function automatic[7:0]residue(input[63:0]word,input integer bits);
 reg[8:0]rem;integer n;
 begin rem=0;for(n=0;n<bits;n=n+1)begin rem={rem[7:0],word[n]};if(rem[8])rem=rem^9'h1c1;end residue=rem[7:0];end
endfunction

reg[23:0]expected[0:4095];integer wp=0,rp=0;
localparam CTRL=0,VG2=1,VIDEO=2,DG2=3,DATA=4,TG2=5,AFTER_DI=6;
integer state=CTRL,control_run=0,preamble=0,preamble_type=0;
integer c0,c1,c2,t0,t1,t2,chars=0,packets=0,avi=0,video_pixels=0,video_lines=0,line_pixels=0,j,sum;
reg[31:0]header=0;reg[63:0]sub[0:3];
wire video_guard=d0==10'b1011001100&&d1==10'b0100110011&&d2==10'b1011001100;
wire island_guard=d1==10'b0100110011&&d2==10'b0100110011&&terc(d0)>=12;
task packet_check;
 begin
  if(residue({32'd0,header},32)!==0)$fatal(1,"wire header BCH at cycle %0d",cycles);
  for(j=0;j<4;j=j+1)if(residue(sub[j],64)!==0)$fatal(1,"wire subpacket BCH %0d",j);
  if(header[7:0]==8'h82)begin
   if(header[23:0]!==24'h0d0282||sub[0][55:0]!==56'h0000100828101f)$fatal(1,"wire AVI fields header=%h body=%h",header,sub[0]);
   for(j=1;j<4;j=j+1)if(sub[j][55:0]!==0)$fatal(1,"wire AVI reserved bytes");
   sum=8'h82+2+13;for(j=0;j<7;j=j+1)sum=sum+sub[0][8*j+:8]+sub[1][8*j+:8];
   if((sum&255)!=0)$fatal(1,"wire AVI checksum");avi=avi+1;
  end
  packets=packets+1;
 end
endtask

always @(negedge clk)if(!rst)begin
 cycles=cycles+1;
 if(de)begin expected[wp%4096]={r,g,b};wp=wp+1;if(wp-rp>=4096)$fatal(1,"video queue exceeds one-line latency");end
 if(cycles>32)begin
  if(dc!==10'b1111100000)$fatal(1,"TMDS clock word");
  c0=control(d0);c1=control(d1);c2=control(d2);t0=terc(d0);t1=terc(d1);t2=terc(d2);
  case(state)
   CTRL,AFTER_DI:begin
    if(c0>=0&&c1>=0&&c2>=0)begin
     control_run=control_run+1;
     if(c1==1&&(c2==0||c2==1))begin
      if(preamble_type!=c2+1)preamble=0;preamble_type=c2+1;preamble=preamble+1;
     end else begin preamble=0;preamble_type=0;end
    end else begin
     if(control_run<12||preamble!=8)$fatal(1,"HDMI preamble/control length cycle=%0d control=%0d pre=%0d",cycles,control_run,preamble);
     if(video_guard&&preamble_type==1)state=VG2;
     else if(island_guard&&preamble_type==2)state=DG2;
     else $fatal(1,"HDMI leading guard cycle=%0d words=%h/%h/%h",cycles,d0,d1,d2);
     control_run=0;preamble=0;preamble_type=0;
    end
   end
   VG2:begin if(!video_guard)$fatal(1,"second video guard");state=VIDEO;line_pixels=0;end
   VIDEO:begin
    if(c0>=0&&c1>=0&&c2>=0)begin
     if(line_pixels!=1920)$fatal(1,"video line length %0d",line_pixels);
     video_lines=video_lines+1;state=CTRL;control_run=1;preamble=0;preamble_type=0;
    end else begin
     if(rp>=wp||{pixel(d2),pixel(d1),pixel(d0)}!==expected[rp%4096])$fatal(1,"RGB stream pixel=%0d got=%h expected=%h",rp,{pixel(d2),pixel(d1),pixel(d0)},expected[rp%4096]);
     rp=rp+1;line_pixels=line_pixels+1;video_pixels=video_pixels+1;
    end
   end
   DG2:begin if(!island_guard)$fatal(1,"second data guard");state=DATA;chars=0;header=0;for(j=0;j<4;j=j+1)sub[j]=0;end
   DATA:begin
    if(island_guard)begin if(chars==0||chars%32!=0)$fatal(1,"data island packet length %0d",chars);state=TG2;end
    else begin
     if(t0<0||t1<0||t2<0)$fatal(1,"illegal TERC4 data");
     if(((t0>>3)&1)!=(chars==0?0:1))$fatal(1,"data island first-character flag chars=%0d ch0=%h",chars,t0);
     header[chars%32]=(t0>>2)&1;
     for(j=0;j<4;j=j+1)begin sub[j][2*(chars%32)]=(t1>>j)&1;sub[j][2*(chars%32)+1]=(t2>>j)&1;end
     chars=chars+1;if(chars%32==0)packet_check();
    end
   end
   TG2:begin if(!island_guard)$fatal(1,"second trailing guard");state=AFTER_DI;control_run=0;end
  endcase
 end
 if(cycles==2*2200*1125+2200)begin
  if(avi<2||video_pixels!=2*1920*1080)$fatal(1,"HDMI coverage AVI=%0d pixels=%0d",avi,video_pixels);
  $display("HDMI PROTOCOL PASS AVI=%0d packets=%0d RGB_pixels=%0d lines=%0d preambles/guards/TERC4/BCH/checksum",avi,packets,video_pixels,video_lines);$finish;
 end
end
initial begin repeat(4)@(negedge clk);rst=0;end
initial begin #40000000;$fatal(1,"HDMI protocol simulation timeout");end
endmodule
