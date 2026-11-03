`timescale 1ns/1ps
module tb_raw_frontend;
 parameter W=64,H=12,SLOW_SOURCE=0,PREFILL_WORDS=W/8;
 reg input_clk=0,isp_clk=0;always #5 input_clk=~input_clk;always #3.367 isp_clk=~isp_clk;
 reg rst_n=0,vs=0,valid=0;reg[31:0]data=0;
 wire out_vs,out_de,frame_bad;wire[15:0]out_data;wire[31:0]frame_id,overflow_count;
 vision_raw_frontend #(.W(W),.H(H),.FIFO_AW(W>64?9:6),.PREFILL_WORDS(PREFILL_WORDS)) dut(.*);
 reg rv=0,rd=0;reg[15:0]rp=0;
 wire av,ad,aval;wire[47:0]rgb;
 wire bv,bd,bval;wire[47:0]reference_rgb;
 debayer_top_2to1 actual(.in_pclk(isp_clk),.in_rstn(rst_n&&!frame_bad),.raw_vs_i(out_vs),.raw_hs_i(out_de),.raw_de_i(out_de),.raw_valid_i(out_de),
  .raw_datax4_i({out_data[7:0],out_data[15:8]}),.r_gain(16'd336),.g_gain(16'd256),.b_gain(16'd504),.rgb_vs_o(av),.rgb_de_o(ad),.rgb_valid_o(aval),.rgb_datax2_o(rgb));
 debayer_top_2to1 reference(.in_pclk(isp_clk),.in_rstn(rst_n),.raw_vs_i(rv),.raw_hs_i(rd),.raw_de_i(rd),.raw_valid_i(rd),
  .raw_datax4_i({rp[7:0],rp[15:8]}),.r_gain(16'd336),.g_gain(16'd256),.b_gain(16'd504),.rgb_vs_o(bv),.rgb_de_o(bd),.rgb_valid_o(bval),.rgb_datax2_o(reference_rgb));
 function automatic[7:0]raw(input integer f,y,x);raw=16+((f*9+y*5+x*3)%96);endfunction
 reg[47:0]expected[0:2*W*H/2-1];integer written=0,checked=0,pairs=0,frames=0,expected_id=1,rx=0,ry=0;
 always @(posedge isp_clk)begin
  if(SLOW_SOURCE&&rst_n&&frame_bad)$fatal(1,"native RAW row underrun after %0d pairs",pairs);
  if(bval&&bd)begin expected[written]<=reference_rgb;written<=written+1;end
  if(out_vs)begin frames<=frames+1;rx=0;ry=0;if(frame_id!=expected_id)$fatal(1,"RAW source tag");end
  if(out_de)begin
   if(out_data!=={raw(expected_id,ry,rx),raw(expected_id,ry,rx+1)})$fatal(1,"RAW order x%0d y%0d",rx,ry);
   pairs<=pairs+1;
   if(rx==W-2)begin rx=0;ry=ry+1;end else rx=rx+2;
  end
  if(aval&&ad)begin
   if(checked%(W*H/2)>=W&&checked%(W/2)>=2&&rgb!==expected[checked])$fatal(1,"ISP differs after CDC/serialization at%0d",checked);
   checked<=checked+1;
  end
 end
 integer f,y,x;
 initial begin
  repeat(8)@(negedge isp_clk);rst_n=1;
  // Legacy ser2par/vid_par2ser preserves words and emits their MSB16 first.
  // The FOV 4PPC word is {x0,x1,x2,x3}, not {x3,x2,x1,x0}.
  // Build full-width raster rows independently, then feed FOV bubbles.
  for(f=1;f<=2;f=f+1)begin
   @(negedge isp_clk);rv=1;@(negedge isp_clk);rv=0;repeat(8)@(negedge isp_clk);
   for(y=0;y<H;y=y+1)begin
    for(x=0;x<W;x=x+2)begin rd=1;rp={raw(f,y,x),raw(f,y,x+1)};@(negedge isp_clk);end
    rd=0;repeat(4)@(negedge isp_clk);
   end
   repeat(12)@(negedge isp_clk);
  end
  if(written!=W*H)$fatal(1,"reference raster size");
  for(f=1;f<=2;f=f+1)begin
   expected_id=f;@(negedge input_clk);vs=1;@(negedge input_clk);vs=0;repeat(5)@(negedge input_clk);
   for(y=0;y<H;y=y+1)begin
    for(x=0;x<W;x=x+4)begin
     valid=1;data={raw(f,y,x),raw(f,y,x+1),raw(f,y,x+2),raw(f,y,x+3)};@(negedge input_clk);
     if(SLOW_SOURCE)begin valid=0;repeat(2+(x%16==0))@(negedge input_clk);end
     else if(x%12==0)begin valid=0;@(negedge input_clk);end
    end
    valid=0;repeat(2)@(negedge input_clk);
    if(y%6==5)repeat(W>64?W*2:W*4)@(negedge input_clk);
   end
   valid=0;wait(checked==f*W*H/2);repeat(10)@(negedge isp_clk);
  end
  if(frame_bad||overflow_count||pairs!=W*H||frames!=2)$fatal(1,"RAW FIFO/raster continuity");
  $display("PASS RAW 4PPC->2PPC async rows %0d pixels, bubbles/order/frame tags, ISP reference equivalence",pairs*2);$finish;
 end
 initial begin #1000000;$fatal(1,"RAW frontend watchdog");end
endmodule
