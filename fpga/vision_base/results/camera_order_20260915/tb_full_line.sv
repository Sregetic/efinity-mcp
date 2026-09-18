`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg rst=0,iv=0,sof=0,eof=0,period=0;
reg[63:0] rx=0;
wire[31:0] vin={rx[9:2],rx[19:12],rx[29:22],rx[39:32]};
wire pv;wire[255:0]packed_data;
ser2par_v1 #(.I_VID_WIDTH(32),.O_VID_WIDTH(256)) packer(.clk(clk),.rst_n(rst),.i_valid(iv),.i_frame_start(sof),.i_frame_end(eof),.frame_stable(1'b1),.frame_pix_num(24'd480),.i_data(vin),.o_valid(pv),.o_data(packed_data));
reg[255:0]mem[0:255];integer wr=0,rd=0;
reg[255:0]rdata=0;reg rvalid=0;wire ren,ov;wire[15:0]pair;
always @(posedge clk)begin
 if(pv)begin mem[wr]<=packed_data;wr<=wr+1;end
 rvalid<=ren;
 if(ren)begin rdata<=mem[rd];rd<=rd+1;end
end
vid_par2ser #(.I_VID_WIDTH(256),.O_VID_WIDTH(16)) unpacker(.clk(clk),.rst_n(rst),.frame_period(period),.rd_fifo_rdvalid(rvalid),.rd_fifo_rddata(rdata),.rd_fifo_rdempty(rd>=wr),.rd_fifo_rden(ren),.tx_fifo_valid(ov),.wr_fifo_full(1'b0),.tx_fifo_wrdata(pair));
// top vout={ch0_g,ch0_b}, raw input={ch0_b,ch0_g}; low RAW byte is first pixel.
wire[15:0]raw_pair={pair[7:0],pair[15:8]};
integer n=0,errors=0,x,k;
always @(negedge clk)if(ov)begin
 if(n<16)$display("PAIR %0d : %0d %0d",n,raw_pair[7:0],raw_pair[15:8]);
 if(raw_pair[7:0]!==8'(n*2) || raw_pair[15:8]!==8'(n*2+1))errors=errors+1;
 n=n+1;
end
initial begin
 #31;rst=1;#20;period=1;#40;
 for(x=0;x<1920;x=x+4)begin
 iv=1;sof=(x==0);eof=(x==1916);
 for(k=0;k<4;k=k+1)rx[k*10+:10]=(x+k)<<2;
 #10;
 end
 iv=0;sof=0;eof=0;#20000;
 $display("RESULT pairs=%0d errors=%0d",n,errors);$finish;
end
endmodule


