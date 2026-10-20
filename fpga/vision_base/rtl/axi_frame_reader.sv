`timescale 1ns/1ps
// RGB565 scan/analysis DMA, 2 pixels/beat, metadata locked for the full job.
module axi_frame_reader #(parameter MAX_BURST_BEATS=16)(
 input clk,rst_n,job_valid,output job_ready,
 input[31:0]base_addr,stride_bytes,frame_id,config_id,input[15:0]width,height,
 output pixel_valid,input pixel_ready,output[31:0]pixel_data,output[1:0]pixel_keep,
 output pixel_sof,pixel_eol,pixel_eof,output[31:0]pixel_frame_id,pixel_config_id,
 output busy,output reg done,error,
 output[3:0]m_axi_arid,output[31:0]m_axi_araddr,output[7:0]m_axi_arlen,
 output[2:0]m_axi_arsize,output[1:0]m_axi_arburst,output m_axi_arvalid,input m_axi_arready,
 input[127:0]m_axi_rdata,input[1:0]m_axi_rresp,input m_axi_rlast,m_axi_rvalid,output m_axi_rready
);
 localparam IDLE=0,CMD=1,STREAM=2;
 reg[1:0]state=IDLE;reg[31:0]addr=0,stride=0,fid=0,cid=0;
 reg[15:0]w=0,h=0,x=0,y=0;
 wire req_ready,ldone,lerror,pvalid;wire[15:0]last_row=height-16'd1;
 wire[47:0]offset=stride_bytes*last_row;
 wire[63:0]end_addr={32'b0,base_addr}+{16'd0,offset}+64'(width)*2;
 wire invalid_job=width==0||height==0||base_addr[0]||stride_bytes[0]||stride_bytes<32'(width)*2||end_addr>64'h100000000;
 axi_line_reader #(.MAX_BURST_BEATS(MAX_BURST_BEATS)) line(.clk(clk),.rst_n(rst_n),.req_valid(state==CMD),.req_ready(req_ready),
  .req_addr(addr),.req_pixels(w),.pixel_valid(pvalid),.pixel_ready(pixel_ready&&state==STREAM),
  .pixel_data(pixel_data),.pixel_keep(pixel_keep),.done(ldone),.error(lerror),
  .m_axi_arid(m_axi_arid),.m_axi_araddr(m_axi_araddr),.m_axi_arlen(m_axi_arlen),
  .m_axi_arsize(m_axi_arsize),.m_axi_arburst(m_axi_arburst),.m_axi_arvalid(m_axi_arvalid),.m_axi_arready(m_axi_arready),
  .m_axi_rdata(m_axi_rdata),.m_axi_rresp(m_axi_rresp),.m_axi_rlast(m_axi_rlast),.m_axi_rvalid(m_axi_rvalid),.m_axi_rready(m_axi_rready));
 assign job_ready=state==IDLE,busy=state!=IDLE,pixel_valid=pvalid&&state==STREAM;
 assign pixel_sof=x==0&&y==0,pixel_eol={1'b0,x}+17'(pixel_keep==3?2:1)=={1'b0,w};
 assign pixel_eof=pixel_eol&&y==h-1'b1,pixel_frame_id=fid,pixel_config_id=cid;
 always @(posedge clk)begin
  done<=0;
  if(!rst_n)begin state<=IDLE;done<=0;error<=0;addr<=0;stride<=0;fid<=0;cid<=0;w<=0;h<=0;x<=0;y<=0;end
  else case(state)
   IDLE:if(job_valid)begin
    error<=invalid_job;
    if(invalid_job)done<=1;
    else begin addr<=base_addr;stride<=stride_bytes;fid<=frame_id;cid<=config_id;w<=width;h<=height;x<=0;y<=0;state<=CMD;end
   end
   CMD:if(req_ready)state<=STREAM;
   STREAM:begin
    if(pixel_valid&&pixel_ready)x<=x+16'(pixel_keep==3?2:1);
    if(ldone)begin
     error<=error|lerror;
     if(y==h-1'b1)begin done<=1;state<=IDLE;end
     else begin y<=y+1'b1;x<=0;addr<=addr+stride;state<=CMD;end
    end
   end
  endcase
 end
endmodule
