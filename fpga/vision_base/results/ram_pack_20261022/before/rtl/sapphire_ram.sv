// Sapphire's emitted RAM ABI bound to the existing Efinity synchronous RAM.
`ifndef SAPPHIRE_SMALL_RAM_LOGIC
`define SAPPHIRE_SMALL_RAM_LOGIC 0
`endif
module Ram_1w_1rs #(
 parameter wordCount=1024,wordWidth=32,clockCrossing=0,technology="auto",readUnderWrite="dontCare",
 parameter wrAddressWidth=10,wrDataWidth=32,wrMaskWidth=1,wrMaskEnable=0,
 parameter rdAddressWidth=10,rdDataWidth=32
)(input wr_clk,wr_en,input[wrMaskWidth-1:0]wr_mask,
 input[wrAddressWidth-1:0]wr_addr,input[wrDataWidth-1:0]wr_data,
 input rd_clk,rd_en,input[rdAddressWidth-1:0]rd_addr,output[rdDataWidth-1:0]rd_data);
 localparam LANES=wrMaskEnable?wrMaskWidth:1,LANE_WIDTH=wrDataWidth/LANES;
 // Mode2 only moves the emitted 16x8 UART and 64x6 AXI metadata FIFOs.
 genvar i;generate if((`SAPPHIRE_SMALL_RAM_LOGIC==1&&wordCount<=64)||
                     (`SAPPHIRE_SMALL_RAM_LOGIC==2&&wordCount*wrDataWidth<=512))begin:small_logic
  (* syn_ramstyle="registers" *)reg[wrDataWidth-1:0]memory[0:wordCount-1];
  reg[rdDataWidth-1:0]q;integer j;
  always @(posedge wr_clk)if(wr_en)for(j=0;j<LANES;j=j+1)
   if(!wrMaskEnable||wr_mask[j])memory[wr_addr][j*LANE_WIDTH+:LANE_WIDTH]<=wr_data[j*LANE_WIDTH+:LANE_WIDTH];
  always @(posedge rd_clk)if(rd_en)q<=memory[rd_addr];
  assign rd_data=q;
 end else begin:block_ram
 for(i=0;i<LANES;i=i+1)begin:lane
  simple_dual_port_ram #(.DATA_WIDTH(LANE_WIDTH),.ADDR_WIDTH(wrAddressWidth),.OUTPUT_REG("FALSE")) ram(
   .wclk(wr_clk),.we(wr_en&&(!wrMaskEnable||wr_mask[i])),.waddr(wr_addr),.wdata(wr_data[i*LANE_WIDTH+:LANE_WIDTH]),
   .rclk(rd_clk),.re(rd_en),.raddr(rd_addr),.rdata(rd_data[i*LANE_WIDTH+:LANE_WIDTH]));
 end
 end endgenerate
endmodule

// The generated UART push buffer is an unmasked4x8 asynchronous-read RAM.
module Ram_1w_1ra #(
 parameter wordCount=4,wordWidth=8,technology="auto",readUnderWrite="dontCare",
 parameter wrAddressWidth=2,wrDataWidth=8,wrMaskWidth=1,wrMaskEnable=0,
 parameter rdAddressWidth=2,rdDataWidth=8
)(input clk,wr_en,input[wrMaskWidth-1:0]wr_mask,input[wrAddressWidth-1:0]wr_addr,
 input[wrDataWidth-1:0]wr_data,input[rdAddressWidth-1:0]rd_addr,output[rdDataWidth-1:0]rd_data);
 reg[wordWidth-1:0]memory[0:wordCount-1];
 always @(posedge clk)if(wr_en)memory[wr_addr]<=wr_data;
 assign rd_data=memory[rd_addr];
endmodule
