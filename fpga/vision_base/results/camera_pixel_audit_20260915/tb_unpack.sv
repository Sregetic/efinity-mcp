`timescale 1ns/1ps
module tb;
reg hdmi_tx_slow_clk=0; always #5 hdmi_tx_slow_clk=~hdmi_tx_slow_clk;
reg rgb_vs=0,rgb_de=0,rgb_hs=0; reg[47:0]rgb_datax2=0;wire pos_vs;
reg rgb_vs_r = 'd0;
always @( posedge hdmi_tx_slow_clk )
begin
  rgb_vs_r <= rgb_vs;
end
assign pos_vs = {rgb_vs_r,rgb_vs} == 2'b01;
reg vid_cnt = 'd0;
reg [7:0] hdmi_tx_rdata ;
reg [7:0] hdmi_tx_gdata ;
reg [7:0] hdmi_tx_bdata ;
reg hdmi_tx_vs;
reg hdmi_tx_hs;
reg hdmi_tx_de;
always @( posedge hdmi_tx_slow_clk )
begin
    if( pos_vs )
      vid_cnt <= 1'b1;
    else if( rgb_de )
      vid_cnt <= ~vid_cnt ;

    if( vid_cnt )
      {hdmi_tx_bdata,hdmi_tx_gdata,hdmi_tx_rdata} <= rgb_datax2[23:0];
    else 
      {hdmi_tx_bdata,hdmi_tx_gdata,hdmi_tx_rdata} <= rgb_datax2[47:24];

  hdmi_tx_vs <= rgb_vs;
  hdmi_tx_hs <= rgb_hs;
  hdmi_tx_de <= rgb_de;
end
integer x,y,n=0,errors=0; integer expected;
always @(negedge hdmi_tx_slow_clk) if(hdmi_tx_de) begin
 expected=n%32;
 if(hdmi_tx_rdata!==expected[7:0]) begin errors=errors+1; if(errors<12)$display("MISMATCH n=%0d got=%0d expected=%0d",n,hdmi_tx_rdata,expected);end
 n=n+1;
end
initial begin
 #1; rgb_vs=1; #40;rgb_vs=0;#40;
 for(y=0;y<4;y=y+1)begin
 for(x=0;x<32;x=x+2)begin
 rgb_de=1;rgb_datax2={24'(x+1),24'(x)};#20;
 end
 rgb_de=0;#80;
 end
 #40;$display("RESULT pixels=%0d errors=%0d",n,errors);$finish;
end
endmodule
