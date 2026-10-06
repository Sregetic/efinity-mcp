// Independent timing capacity test. Does not alter the HDMI pixel clock.
module sobel_timing_top(input CLK_25M,clk,fb,output pll_rstn,output reg result=0);
assign pll_rstn=1'b1;
reg[71:0]stimulus=72'h123456789abcdefabc;
reg[10:0]threshold=11'h135;
wire[10:0]mag;wire[1:0]direction;wire[59:0]meta;wire edge_pixel;
always @(posedge clk)begin
 stimulus<={stimulus[70:0],stimulus[71]^stimulus[65]^stimulus[24]^stimulus[18]};
 threshold<={threshold[9:0],threshold[10]^threshold[8]};
 result<=^{mag,direction,meta,edge_pixel};
end
vision_sobel #(.META(60)) dut(clk,stimulus,stimulus[59:0],mag,direction,meta,threshold,edge_pixel);
endmodule

