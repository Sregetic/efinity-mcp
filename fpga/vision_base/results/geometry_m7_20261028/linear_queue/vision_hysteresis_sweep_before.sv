// Exact 8-connected hysteresis without a full-frame coordinate queue.
// Forward/backward in-place sweeps continue until no weak pixel is promoted.
// REUSE_CAPTURE_MAP: every mutable coordinate MUST be written each capture.
// Coordinates omitted on all frames are static zero padding initialized by CLEAR.
// Both output planes initialize once; capture overwrites zeros as well as edges.
module vision_hysteresis_sweep #(parameter W=480,H=270,CW=9,AW=$clog2(W*H),REUSE_CAPTURE_MAP=0,MIN_COMPONENT=1,PROBE=0,ALLOW_DISCARD=0,HISTORY=0)(
 input clk,rst_n,vblank,class_valid,input[CW-1:0]class_x,class_y,input[1:0]classification,input class_last,
 input[CW-1:0]display_x,display_y,
 output capture_enable,output reg ready=0,output busy,output pixel,
 output reg[31:0]completed=0,output reg fault=0,output[3:0]debug_state,output[AW:0]debug_queue,
 input display_de,probe_req,input[11:0]probe_address,
 output reg probe_ack,output reg[31:0]probe_data,output reg[11:0]probe_read_address,output probe_busy,input frame_discard,
 output reg[31:0]last_cycles,sweep_passes,weak_visits,
 input[CW-1:0]history_x,history_y,output history_pixel);
localparam N=W*H;
localparam CLEAR=0,WAIT_FRAME=1,CAPTURE=2,CUR_READ=3,CUR_CHECK=4,NREAD=5,NCHECK=6,ADVANCE=7,PUBLISH=8;
localparam PRUNE_READ=9,PRUNE_CHECK=10,PRUNE_NODE=11,PRUNE_NREAD=12,PRUNE_NCHECK=13,PRUNE_COMMIT=14,PRUNE_QWAIT=15;
reg[3:0]state=CLEAR;reg[AW-1:0]clear_addr=0;
reg front=0,reverse=0,changed=0;reg[CW-1:0]px=0,py=0;reg[2:0]neighbor=0;
// Conservative16x16 weak-presence mask. Promotion only removes weak pixels;
// a tile captured without any weak pixel can be skipped on every sweep.
localparam TILE_COLS=(W+15)/16,TILE_ROWS=(H+15)/16;
(* syn_ramstyle="block_ram" *)reg[TILE_COLS-1:0]weak_tiles[0:TILE_ROWS-1];
reg[TILE_ROWS-1:0]tile_rows_valid=0;
wire[TILE_COLS-1:0]tile_value;
wire empty_tile=!tile_rows_valid[py>>4]||!tile_value[px>>4];
wire clear_tiles=!rst_n||(state==WAIT_FRAME&&vblank)||(state==PUBLISH&&vblank);
wire[CW-1:0]tile_end=px|CW'(15),tile_start=px&~CW'(15);
wire scan_row_end=reverse?(empty_tile?tile_start==0:px==0):(empty_tile?tile_end>=W-1:px==W-1);
wire scan_end=scan_row_end&&(reverse?py==0:py==H-1);
wire[CW-1:0]scan_next_x=scan_row_end?(reverse?CW'(W-1):CW'(0)):
                          (reverse?(empty_tile?tile_start-1'b1:px-1'b1):(empty_tile?tile_end+1'b1:px+1'b1));
wire[CW-1:0]scan_next_y=scan_row_end?(reverse?py-1'b1:py+1'b1):py;
// Bounded flood search: reaching MIN_COMPONENT proves a component is large.
// Map3/edge0 denotes this search; map3/edge1 denotes a previously kept component.
// Restore queued edge bits on keep, so unvisited tails still find the kept part.
wire[1:0]map_q;
localparam QW=$clog2(MIN_COMPONENT+1);
reg[QW-1:0]head=0,tail=0,erase_index=0;
reg[CW-1:0]bx=0,by=0;reg keep_component=0,commit_fetch=0;
reg signed[CW+1:0]pnx,pny;reg prune_bounds;
always @*begin
 pnx=$signed({2'b0,bx});pny=$signed({2'b0,by});
 case(neighbor)
  0:begin pnx=pnx-1;pny=pny-1;end 1:pny=pny-1;
  2:begin pnx=pnx+1;pny=pny-1;end 3:pnx=pnx-1;4:pnx=pnx+1;
  5:begin pnx=pnx-1;pny=pny+1;end 6:pny=pny+1;
  7:begin pnx=pnx+1;pny=pny+1;end
 endcase
 prune_bounds=pnx>=0&&pnx<W&&pny>=0&&pny<H;
end
wire[AW-1:0]prune_neighbor_addr=pny*W+pnx;
wire[2*CW-1:0]queue_q;
wire[QW-1:0]queue_read=state==PRUNE_COMMIT?erase_index+1'b1:
 (state==PRUNE_QWAIT&&commit_fetch?QW'(0):head);
wire queue_seed=state==PRUNE_CHECK&&map_q==2;
wire queue_push=state==PRUNE_NCHECK&&prune_bounds&&map_q==2;
vision_canny_ram #(.BITS(2*CW),.AW(QW)) prune_queue(clk,rst_n&&(queue_seed||queue_push),queue_seed?QW'(0):tail,
 queue_seed?{py,px}:{pny[CW-1:0],pnx[CW-1:0]},queue_read,queue_q);
wire[AW-1:0]erase_addr=queue_q[2*CW-1:CW]*W+queue_q[CW-1:0];
reg[31:0]work_cycles=0;
// Only the read-only skip path may consume the prefetched next pixel.
// Flood erase commits can collide with that address and require a fresh read.
task prune_next(input prefetched);
 begin
  if(px==W-1&&py==H-1)state<=PUBLISH;
  else begin if(px==W-1)begin px<=0;py<=py+1'b1;end else px<=px+1'b1;state<=prefetched?PRUNE_CHECK:PRUNE_READ;end
 end
endtask
task advance_scan;begin
  if(scan_end)begin
   sweep_passes<=sweep_passes+1;
   if(changed)begin reverse<=~reverse;changed<=0;state<=CUR_READ;end
   else if(MIN_COMPONENT>1)begin px<=0;py<=0;state<=PRUNE_READ;end else state<=PUBLISH;
  end else begin
   px<=scan_next_x;py<=scan_next_y;
   state<=CUR_CHECK;
  end

end endtask
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
wire[CW-1:0]bounded_tile_end=tile_end<W?tile_end:CW'(W-1);
wire[CW-1:0]scan_step=empty_tile?(reverse?px-tile_start+1'b1:bounded_tile_end-px+1'b1):CW'(1);
wire[AW-1:0]next_scan_addr=reverse?scan_addr-scan_step:scan_addr+scan_step;
always @*begin
 nx=$signed({2'b0,px});ny=$signed({2'b0,py});
 case(neighbor)
 0:begin nx=nx-1;ny=ny-1;end 1:ny=ny-1;2:begin nx=nx+1;ny=ny-1;end
 3:nx=nx-1;4:nx=nx+1;5:begin nx=nx-1;ny=ny+1;end 6:ny=ny+1;7:begin nx=nx+1;ny=ny+1;end
 endcase
 in_bounds=nx>=0&&nx<W&&ny>=0&&ny<H;
end
wire e0,e1;
// Borrow the existing front-plane read port only inside horizontal blanking.
// The caller supplies a continuous1920-pixel DE and >=34 blank clocks/line.
// Freeze publication in the caller while dumping a complete frame over JTAG.
reg probe_seen=0,probe_dq=0;reg[1:0]probe_state=0;
reg[AW-1:0]probe_base=0;reg[5:0]probe_index=0;reg[31:0]probe_pack=0;
wire[AW-1:0]edge_read_addr=(PROBE&&probe_state==2)?probe_base+probe_index:display_addr;
assign probe_busy=PROBE&&probe_state!=0;
always @(posedge clk)begin
 if(!rst_n)begin probe_seen<=0;probe_dq<=0;probe_state<=0;probe_ack<=0;probe_data<=0;probe_read_address<=0;probe_base<=0;probe_index<=0;probe_pack<=0;end
 else if(PROBE)begin
  probe_dq<=display_de;
  if(probe_req!=probe_seen)begin
   probe_seen<=probe_req;probe_read_address<=probe_address;probe_base<=AW'(probe_address)<<5;probe_state<=1;
  end
  case(probe_state)
   1:if(probe_dq&&!display_de)begin probe_index<=0;probe_pack<=0;probe_state<=2;end
   2:begin
    if(probe_index!=0)probe_pack[probe_index-1'b1]<=front?e1:e0;
    if(probe_index==32)probe_state<=3;else probe_index<=probe_index+1'b1;
   end
   3:begin probe_data<=probe_pack;probe_ack<=probe_seen;probe_state<=0;end
  endcase
 end
end
wire clearing=state==CLEAR,storing=state==CAPTURE&&class_valid;
wire promoting=state==NCHECK&&in_bounds&&map_q==2;
wire prune_seed=state==PRUNE_CHECK&&map_q==2;
wire prune_mark=state==PRUNE_NCHECK&&prune_bounds&&map_q==2;
wire prune_commit=state==PRUNE_COMMIT;
wire[AW-1:0]write_addr=prune_mark?prune_neighbor_addr:(prune_commit?erase_addr:(clearing?clear_addr:(storing?class_addr:scan_addr)));
wire[1:0]write_data=(prune_seed||prune_mark)?2'd3:(prune_commit?(keep_component?2'd3:2'd0):(clearing?2'd0:(storing?classification:2'd2)));
// Read the next neighbor while checking the current one; prefetch each center.
wire skip_center=state==CUR_CHECK&&(empty_tile||map_q!=1);
wire skip_prune=state==PRUNE_CHECK&&map_q!=2;
wire[AW-1:0]read_addr=(state==PRUNE_NREAD||state==PRUNE_NCHECK)?prune_neighbor_addr:((state==NREAD||state==NCHECK)?fetch_addr:
                              (skip_prune?scan_addr+1'b1:((state==ADVANCE||skip_center)?next_scan_addr:scan_addr)));
// Prefetch the same next center as map_ram, without adding a scan cycle.
wire[CW-1:0]tile_read_row=state==CAPTURE?(class_y>>4):
                        ((state==ADVANCE||skip_center)?(scan_next_y>>4):(py>>4));
reg[CW-1:0]tile_read_row_q=0,tile_write_row=0,tile_write_col=0,tile_last_row=0;
reg tile_pending=0,tile_last_we=0;
reg[TILE_COLS-1:0]tile_q,tile_last_data=0;
wire tile_we=tile_pending&&!clear_tiles;
wire[TILE_COLS-1:0]tile_data=(tile_rows_valid[tile_write_row]?tile_value:{TILE_COLS{1'b0}})|
                             (TILE_COLS'(1)<<tile_write_col);
// Forward read/write collisions, including consecutive weak samples in one row.
assign tile_value=(tile_last_we&&tile_last_row==tile_read_row_q)?tile_last_data:tile_q;
always @(posedge clk)begin
 tile_q<=weak_tiles[tile_read_row];
 if(tile_we)weak_tiles[tile_write_row]<=tile_data;
end
// Clear row validity in the data path instead of resetting the RAM contents.
(* syn_keep="true" *)wire[TILE_ROWS-1:0]tile_rows_d=clear_tiles?{TILE_ROWS{1'b0}}:
 (tile_we?(tile_rows_valid|(TILE_ROWS'(1)<<tile_write_row)):tile_rows_valid);
always @(posedge clk)begin
 tile_rows_valid<=tile_rows_d;
 tile_read_row_q<=tile_read_row;
 tile_pending<=!clear_tiles&&storing&&classification==1;
 tile_write_row<=class_y>>4;tile_write_col<=class_x>>4;
 tile_last_we<=tile_we;
 if(tile_we)begin tile_last_row<=tile_write_row;tile_last_data<=tile_data;end
end
// Write only the back plane; publish the completed plane at vblank.
wire edge_we=clearing||storing||promoting||prune_seed||prune_mark||prune_commit;
wire edge_data=promoting||(storing&&classification==2)||(prune_commit&&keep_component);
wire[AW-1:0]back_port_addr=state==PRUNE_NREAD?prune_neighbor_addr:write_addr;
vision_canny_ram #(.BITS(2),.AW(AW)) map_ram(clk,rst_n&&(clearing||storing||promoting||prune_seed||prune_mark||prune_commit),write_addr,write_data,read_addr,map_q);
// The front plane's write port is idle during CAPTURE. Read history there;
// display and the blanking-time JTAG probe keep their independent read port.
wire[AW-1:0]history_addr=history_y*W+history_x;wire h0,h1;
vision_canny_edge_ram #(.AW(AW)) edge_ram0(clk,rst_n&&edge_we&&(front||(clearing&&!ready)),
 (HISTORY&&!front&&ready)?history_addr:back_port_addr,edge_data,h0,edge_read_addr,e0);
vision_canny_edge_ram #(.AW(AW)) edge_ram1(clk,rst_n&&edge_we&&(!front||(clearing&&!ready)),
 (HISTORY&&front&&ready)?history_addr:back_port_addr,edge_data,h1,edge_read_addr,e1);
wire back_edge=front?h0:h1;
assign history_pixel=HISTORY&&ready&&(front?h1:h0);
assign pixel=ready?(front?e1:e0):1'b0;
assign capture_enable=state==CAPTURE;assign busy=state!=WAIT_FRAME;assign debug_state=state;assign debug_queue=0;
always @(posedge clk)begin
 if(!rst_n)begin work_cycles<=0;last_cycles<=0;sweep_passes<=0;weak_visits<=0;state<=CLEAR;clear_addr<=0;front<=0;ready<=0;completed<=0;fault<=0;px<=0;py<=0;reverse<=0;changed<=0;neighbor<=0;head<=0;tail<=0;erase_index<=0;bx<=0;by<=0;keep_component<=0;commit_fetch<=0;end
 else begin
 if((state>=CUR_READ&&state<=PRUNE_COMMIT&&state!=PUBLISH)||state==PRUNE_QWAIT)work_cycles<=work_cycles+1;
 if(state==CUR_CHECK&&map_q==1)weak_visits<=weak_visits+1;
 if(state==PUBLISH)last_cycles<=work_cycles;
 case(state)
 CLEAR:if(clear_addr==N-1)begin clear_addr<=0;state<=WAIT_FRAME;end else clear_addr<=clear_addr+1'b1;
 WAIT_FRAME:if(vblank)state<=CAPTURE;
 CAPTURE:begin
  if(class_valid&&(class_x>=W||class_y>=H))fault<=1;
  if(class_last)begin work_cycles<=0;sweep_passes<=0;weak_visits<=0;px<=0;py<=0;reverse<=0;changed<=0;state<=CUR_READ;end
 end
 CUR_READ:state<=CUR_CHECK;
 CUR_CHECK:if(!empty_tile&&map_q==1)begin neighbor<=0;state<=NREAD;end else advance_scan();
 NREAD:if(in_bounds)state<=NCHECK;else if(neighbor==7)state<=ADVANCE;else neighbor<=neighbor+1'b1;
 NCHECK:if(in_bounds&&map_q==2)begin changed<=1;state<=ADVANCE;end
        else if(neighbor==7)state<=ADVANCE;else begin neighbor<=neighbor+1'b1;state<=NCHECK;end
 ADVANCE:advance_scan();
 PRUNE_READ:state<=PRUNE_CHECK;
 PRUNE_CHECK:if(map_q==2)begin
  head<=0;tail<=1;keep_component<=0;commit_fetch<=0;erase_index<=0;state<=PRUNE_NODE;
 end else prune_next(1'b1);
 PRUNE_NODE:begin
  if(head==tail)begin erase_index<=0;commit_fetch<=1;end else commit_fetch<=0;
  state<=PRUNE_QWAIT;
 end
 PRUNE_QWAIT:if(commit_fetch)state<=PRUNE_COMMIT;
 else begin bx<=queue_q[CW-1:0];by<=queue_q[2*CW-1:CW];neighbor<=0;state<=PRUNE_NREAD;end
 PRUNE_NREAD:state<=PRUNE_NCHECK;
 PRUNE_NCHECK:begin
  if(prune_bounds&&map_q==2)begin tail<=tail+1'b1;end
  if((prune_bounds&&map_q==3&&back_edge)||(prune_bounds&&map_q==2&&tail==MIN_COMPONENT-1))begin
   keep_component<=1;erase_index<=0;commit_fetch<=1;state<=PRUNE_QWAIT;
  end else if(neighbor==7)begin head<=head+1'b1;state<=PRUNE_NODE;end
  else begin neighbor<=neighbor+1'b1;state<=PRUNE_NREAD;end
 end
 PRUNE_COMMIT:if(erase_index==tail-1'b1)prune_next(1'b0);
 else erase_index<=erase_index+1'b1;
 PUBLISH:if(vblank)begin
  // A frame classified below its newly measured noise floor is retried; it
  // never replaces the last accepted front plane. The next capture uses that floor.
  if(!ALLOW_DISCARD||!frame_discard)begin front<=~front;ready<=1;completed<=completed+1'b1;end
  state<=REUSE_CAPTURE_MAP?CAPTURE:CLEAR;clear_addr<=0;
 end
 default:begin fault<=1;state<=CLEAR;end
 endcase
 end
end
endmodule

