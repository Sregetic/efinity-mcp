// Exact eight-connected hysteresis: every strong seed starts a breadth-first flood.
// Each weak pixel is promoted/enqueued at most once. No fixed iteration cutoff.
module vision_hysteresis #(parameter W=240,H=135,AW=$clog2(W*H))(
 input clk,rst_n,vblank,input class_valid,input[7:0]class_x,class_y,input[1:0]classification,input class_last,
 input[7:0]display_x,display_y,
 output capture_enable,output reg ready=0,output busy,output pixel,
 output reg[31:0]completed=0,output reg fault=0,output[3:0]debug_state,output[AW:0]debug_queue);
localparam N=W*H;
localparam CLEAR=0,WAIT_FRAME=1,CAPTURE=2,POP=3,POP_WAIT=4,NREAD=5,NCHECK=6,PUBLISH=7;
reg[3:0]state=CLEAR;reg[AW-1:0]clear_addr=0;reg[AW:0]head=0,tail=0;

reg front=0;wire[15:0]queue_q;wire[1:0]map_q;reg[7:0]px=0,py=0;reg[2:0]neighbor=0;
reg signed[9:0]nx,ny;reg in_bounds;reg[AW-1:0]naddr;
wire[AW-1:0]class_addr=class_y*W+class_x;
wire[AW-1:0]display_addr=display_y*W+display_x;
always @*begin
 nx=$signed({2'b0,px});ny=$signed({2'b0,py});
 case(neighbor)
 0:begin nx=nx-1;ny=ny-1;end 1:ny=ny-1;2:begin nx=nx+1;ny=ny-1;end
 3:nx=nx-1;4:nx=nx+1;5:begin nx=nx-1;ny=ny+1;end 6:ny=ny+1;7:begin nx=nx+1;ny=ny+1;end
 endcase
 in_bounds=nx>=0&&nx<W&&ny>=0&&ny<H;naddr=ny*W+nx;
end
assign capture_enable=state==CAPTURE;assign busy=state!=WAIT_FRAME;
assign debug_state=state;assign debug_queue=tail;
wire clearing=state==CLEAR;
wire storing=state==CAPTURE&&class_valid;
wire promoting=state==NCHECK&&map_q==1;
wire[AW-1:0]write_addr=clearing?clear_addr:(storing?class_addr:naddr);
wire[1:0]map_data=clearing?2'd0:(storing?classification:2'd2);
wire enqueue=(storing&&classification==2)||promoting;
wire[15:0]queue_data=storing?{class_y,class_x}:{ny[7:0],nx[7:0]};
wire edge_we=clearing||enqueue;wire e0,e1;
vision_canny_ram #(.BITS(2),.AW(AW)) map_ram(clk,rst_n&&(clearing||storing||promoting),write_addr,map_data,naddr,map_q);
vision_canny_ram #(.BITS(16),.AW(AW)) queue_ram(clk,rst_n&&enqueue&&tail<N,tail[AW-1:0],queue_data,head[AW-1:0],queue_q);
vision_canny_ram #(.BITS(1),.AW(AW)) edge_ram0(clk,rst_n&&edge_we&&front,write_addr,!clearing,display_addr,e0);
vision_canny_ram #(.BITS(1),.AW(AW)) edge_ram1(clk,rst_n&&edge_we&&!front,write_addr,!clearing,display_addr,e1);
assign pixel=ready?(front?e1:e0):1'b0;
always @(posedge clk)begin



 if(!rst_n)begin state<=CLEAR;clear_addr<=0;head<=0;tail<=0;front<=0;ready<=0;completed<=0;fault<=0;end
 else case(state)
 CLEAR:begin


  if(clear_addr==N-1)begin clear_addr<=0;head<=0;tail<=0;state<=WAIT_FRAME;end else clear_addr<=clear_addr+1'b1;
 end
 WAIT_FRAME:if(vblank)state<=CAPTURE;
 CAPTURE:begin
  if(class_valid)begin

   if(classification==2)begin
    if(tail<N)begin tail<=tail+1'b1;end else fault<=1;

   end
  end
  if(class_last)state<=POP;
 end
 POP:if(head==tail)state<=PUBLISH;else begin head<=head+1'b1;state<=POP_WAIT;end
 POP_WAIT:begin px<=queue_q[7:0];py<=queue_q[15:8];neighbor<=0;state<=NREAD;end
 NREAD:begin
  if(in_bounds)state<=NCHECK;
  else if(neighbor==7)state<=POP;else neighbor<=neighbor+1'b1;
 end
 NCHECK:begin
  if(map_q==1)begin

   if(tail<N)begin tail<=tail+1'b1;end else fault<=1;

  end
  if(neighbor==7)state<=POP;else begin neighbor<=neighbor+1'b1;state<=NREAD;end
 end
 PUBLISH:if(vblank)begin front<=~front;ready<=1;completed<=completed+1'b1;state<=CLEAR;clear_addr<=0;end
 default:state<=CLEAR;
 endcase
end
endmodule

// Port A writes the back plane or reads the published front plane. Port B
// always serves the HDMI/JTAG reader. No third port and no additional plane.
module vision_canny_edge_ram #(parameter AW=17)(input clk,we,input[AW-1:0]aa,input wd,
 output reg qa,input[AW-1:0]ba,output reg qb);
reg mem[0:(1<<AW)-1];
always @(posedge clk)begin if(we)mem[aa]<=wd;qa<=mem[aa];end
always @(posedge clk)qb<=mem[ba];
endmodule

module vision_canny_ram #(parameter BITS=8,AW=15)(input clk,we,input[AW-1:0]wa,input[BITS-1:0]wd,input[AW-1:0]ra,output reg[BITS-1:0]q);
reg[BITS-1:0]mem[0:(1<<AW)-1];
always @(posedge clk)begin if(we)mem[wa]<=wd;q<=mem[ra];end
endmodule
