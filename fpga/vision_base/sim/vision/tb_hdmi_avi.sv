`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=1,island=0;
wire[23:0]header;wire[55:0]sub0,sub1,sub2,sub3;
wire hb;wire[3:0]d1,d2;wire[4:0]counter;
auxiliary_video_information_info_frame avi(
 .video_format(2'b00),.video_VIC(7'd16),.header(header),
 .sub0(sub0),.sub1(sub1),.sub2(sub2),.sub3(sub3));
packet_assembler packet(clk,rst,island,header,sub0,sub1,sub2,sub3,hb,d1,d2,counter);
reg[31:0]received_header;reg[63:0]received_sub[0:3];
integer packets=0,i,j,sum;

// Polynomial division of the transmitted bit sequence by x^8+x^7+x^6+1.
// This checks the complete wire-order codeword, independently of DUT registers.
function automatic[7:0]residue(input[63:0]word,input integer bits);
 reg[8:0]r;integer k;
 begin
  r=0;
  for(k=0;k<bits;k=k+1)begin
   r={r[7:0],word[k]};if(r[8])r=r^9'h1c1;
  end
  residue=r[7:0];
 end
endfunction

task check_packet;
 begin
  received_header=0;for(j=0;j<4;j=j+1)received_sub[j]=0;
  for(i=0;i<32;i=i+1)begin
   #1;if(counter!==i[4:0])$fatal(1,"packet counter expected %0d got %0d",i,counter);
   received_header[i]=hb;
   for(j=0;j<4;j=j+1)begin received_sub[j][2*i]=d1[j];received_sub[j][2*i+1]=d2[j];end
   @(posedge clk);@(negedge clk);
  end
  if(received_header[23:0]!==24'h0d0282)$fatal(1,"AVI header %h",received_header);
  // PB0 checksum, RGB + active aspect, 16:9, full RGB, VIC16, no repetition/bars.
  if(received_sub[0][55:0]!==56'h0000100828101f)$fatal(1,"AVI payload %h",received_sub[0]);
  for(j=1;j<4;j=j+1)if(received_sub[j][55:0]!==0)$fatal(1,"reserved payload nonzero");
  sum=8'h82+8'h02+8'h0d;
  for(j=0;j<7;j=j+1)sum=sum+received_sub[0][8*j+:8]+received_sub[1][8*j+:8];
  if((sum&255)!=0)$fatal(1,"AVI checksum sum=%h",sum);
  if(residue({32'd0,received_header},32)!==0)$fatal(1,"header BCH residual");
  for(j=0;j<4;j=j+1)if(residue(received_sub[j],64)!==0)$fatal(1,"subpacket BCH %0d",j);
  packets=packets+1;
 end
endtask

initial begin
 repeat(2)@(negedge clk);rst=0;island=1;
 check_packet();check_packet(); // Consecutive packets in one data island.
 island=0;repeat(3)@(negedge clk);island=1;check_packet();
 repeat(9)@(negedge clk);rst=1;@(negedge clk);rst=0;check_packet();
 island=0;
 $display("HDMI AVI PASS %0d packets: VIC16 RGB full 16:9, checksum, all BCH codewords, consecutive/idle/reset",packets);
 $finish;
end
initial begin #100000;$fatal(1,"HDMI AVI test timeout");end
endmodule
