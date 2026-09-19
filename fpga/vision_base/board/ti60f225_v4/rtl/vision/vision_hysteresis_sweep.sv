// Exact 8-connected hysteresis without a full-frame coordinate queue.
// Forward/backward in-place sweeps continue until no weak pixel is promoted.
// REUSE_CAPTURE_MAP: every mutable coordinate MUST be written each capture.
// Coordinates omitted on all frames are static zero padding initialized by CLEAR.
// Both output planes initialize once; capture overwrites zeros as well as edges.
module vision_hysteresis_sweep #(parameter W=480,H=270,CW=9,AW=$clog2(W*H),REUSE_CAPTURE_MAP=0)(
 input clk,rst_n,vblank,class_valid,input[CW-1:0]class_x,class_y,input[1:0]classification,input class_last,
 input[CW-1:0]display_x,display_y,
 output capture_enable,output reg ready=0,output busy,output pixel,
 output reg[31:0]completed=0,output reg fault=0,output[3:0]debug_state,output[AW:0]debug_queue);
localparam N=W*H;
localparam CLEAR=0,WAIT_FRAME=1,CAPTURE=2,CUR_READ=3,CUR_CHECK=4,NREAD=5,NCHECK=6,ADVANCE=7,PUBLISH=8;
reg[3:0]state=CLEAR;reg[AW-1:0]clear_addr=0;
reg front=0,reverse=0,changed=0;reg[CW-1:0]px=0,py=0;reg[2:0]neighbor=0;
reg signed[CW+1:0]nx,ny;reg in_bounds;
wire[AW-1:0]scan_addr=py*W+px,class_addr=class_y*W+class_x,display_addr=display_y*W+display_x;
reg signed[CW+1:0]fetch_x,fetch_y;
wire[2:0]fetch_neighbor=(state==NCHECK)?neighbor+3'd1:neighbor;
always @*begin
 fetch_x=$signed({2'b0,px});fetch_y=$signed({2'b0,py});
 case(fetch_neighbor)
 0:begin fetch_x=fetch_x-1;fetch_y=fetch_y-1;end
 1:fetch_y=fetch_y-1;
 2:begin fetch_x=fetch_x+1;fetch_y=fetch_y-1;end
 3:fetch_x=fetch_x-1;4:fetch_x=fetch_x+1;
 5:begin fetch_x=fetch_x-1;fetch_y=fetch_y+1;end
 6:fetch_y=fetch_y+1;
 7:begin fetch_x=fetch_x+1;fetch_y=fetch_y+1;end
 endcase
end
wire[AW-1:0]fetch_addr=fetch_y*W+fetch_x;
wire[AW-1:0]next_scan_addr=reverse?scan_addr-1'b1:scan_addr+1'b1;
always @*begin
 nx=$signed({2'b0,px});ny=$signed({2'b0,py});
 case(neighbor)
 0:begin nx=nx-1;ny=ny-1;end 1:ny=ny-1;2:begin nx=nx+1;ny=ny-1;end
 3:nx=nx-1;4:nx=nx+1;5:begin nx=nx-1;ny=ny+1;end 6:ny=ny+1;7:begin nx=nx+1;ny=ny+1;end
 endcase
 in_bounds=nx>=0&&nx<W&&ny>=0&&ny<H;
end
wire[1:0]map_q;wire e0,e1;
wire clearing=state==CLEAR,storing=state==CAPTURE&&class_valid;
wire promoting=state==NCHECK&&in_bounds&&map_q==2;
wire[AW-1:0]write_addr=clearing?clear_addr:(storing?class_addr:scan_addr);
wire[1:0]write_data=clearing?2'd0:(storing?classification:2'd2);
// Read the next neighbor while checking the current one; prefetch each center.
wire[AW-1:0]read_addr=(state==NREAD||state==NCHECK)?fetch_addr:
                              ((state==ADVANCE)?next_scan_addr:scan_addr);
// Write only the back plane; publish the completed plane at vblank.
wire edge_we=clearing||storing||promoting;
wire edge_data=promoting||(storing&&classification==2);
vision_canny_ram #(.BITS(2),.AW(AW)) map_ram(clk,rst_n&&(clearing||storing||promoting),write_addr,write_data,read_addr,map_q);
vision_canny_ram #(.BITS(1),.AW(AW)) edge_ram0(clk,rst_n&&edge_we&&(front||(clearing&&!ready)),write_addr,edge_data,display_addr,e0);
vision_canny_ram #(.BITS(1),.AW(AW)) edge_ram1(clk,rst_n&&edge_we&&(!front||(clearing&&!ready)),write_addr,edge_data,display_addr,e1);
assign pixel=ready?(front?e1:e0):1'b0;
assign capture_enable=state==CAPTURE;assign busy=state!=WAIT_FRAME;assign debug_state=state;assign debug_queue=0;
always @(posedge clk)begin
 if(!rst_n)begin state<=CLEAR;clear_addr<=0;front<=0;ready<=0;completed<=0;fault<=0;px<=0;py<=0;reverse<=0;changed<=0;neighbor<=0;end
 else case(state)
 CLEAR:if(clear_addr==N-1)begin clear_addr<=0;state<=WAIT_FRAME;end else clear_addr<=clear_addr+1'b1;
 WAIT_FRAME:if(vblank)state<=CAPTURE;
 CAPTURE:begin
  if(class_valid&&(class_x>=W||class_y>=H))fault<=1;
  if(class_last)begin px<=0;py<=0;reverse<=0;changed<=0;state<=CUR_READ;end
 end
 CUR_READ:state<=CUR_CHECK;
 CUR_CHECK:if(map_q==1)begin neighbor<=0;state<=NREAD;end else state<=ADVANCE;
 NREAD:if(in_bounds)state<=NCHECK;else if(neighbor==7)state<=ADVANCE;else neighbor<=neighbor+1'b1;
 NCHECK:if(in_bounds&&map_q==2)begin changed<=1;state<=ADVANCE;end
        else if(neighbor==7)state<=ADVANCE;else begin neighbor<=neighbor+1'b1;state<=NCHECK;end
 ADVANCE:begin
  if((!reverse&&px==W-1&&py==H-1)||(reverse&&px==0&&py==0))begin
   if(changed)begin reverse<=~reverse;changed<=0;state<=CUR_READ;end else state<=PUBLISH;
  end else begin
   if(!reverse)begin if(px==W-1)begin px<=0;py<=py+1'b1;end else px<=px+1'b1;end
   else begin if(px==0)begin px<=W-1;py<=py-1'b1;end else px<=px-1'b1;end
   state<=CUR_CHECK;
  end
 end
 PUBLISH:if(vblank)begin front<=~front;ready<=1;completed<=completed+1'b1;state<=REUSE_CAPTURE_MAP?CAPTURE:CLEAR;clear_addr<=0;end
 default:begin fault<=1;state<=CLEAR;end
 endcase
end
endmodule

