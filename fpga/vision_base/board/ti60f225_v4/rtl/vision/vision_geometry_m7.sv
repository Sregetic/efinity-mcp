// M7 owns no pixel RAM: accepted Canny bits use the existing CPU bitmap port.
module vision_geometry_m7 #(parameter CLOCK_HZ=148500000,MS_CYCLES=CLOCK_HZ/1000)(
 input clk,rst_n,de,vs,input[11:0]x,y,
 input enabled,frozen,source_valid,invalidated,capture_start,canny_ready,
 input[31:0]capture_frame,view_frame,view_config,view_context,canny_completed,source_errors,result_frame,
 output bitmap_hold,raw_bitmap_enable,
 input cpu_clk,cpu_rst_n,input[7:0]paddr,input psel,penable,pwrite,input[31:0]pwdata,
 output reg[31:0]prdata,output pready,output current,output[2:0]count,
 output published,output primary_we,output[37:0]primary_data,
 output meta_we,output[1:0]meta_index,output[31:0]meta_data,
 output mark,output[23:0]color,output[15:0]counts,output[6:0]symbol,input[10:0]edge_threshold,input[2:0]selection,input selection_bank,
 input[3:0]motion_hint,input[23:0]motion_xy,motion_br,output tracking);
 reg[31:0]accepted_frame=0,capture_ms=0,accepted_ms=0;reg seen_completed=0,seen_errors=0;
 // Both counters increment by one on this clock; config/reset also invalidates the job.
 reg capture_valid=0,accepted_valid=0,front_invalid=1;
 wire invalidate=invalidated||source_errors[0]!=seen_errors;
 reg request=0;(* async_reg="true" *)reg[2:0]request_sync=0;reg request_seen=0;
 reg[1:0]settle=0;reg snapshot_ready=0,snapshot_valid=0,snapshot_token=0;
 wire eligible=accepted_valid&&canny_ready&&enabled&&source_valid&&(!frozen||accepted_frame==view_frame);
 assign bitmap_hold=request_sync[2]&&enabled&&(snapshot_ready?snapshot_valid:eligible);
 assign raw_bitmap_enable=bitmap_hold&&snapshot_ready&&snapshot_valid;
 always @(posedge clk)begin
  request_sync<={request_sync[1:0],request};request_seen<=request_sync[2];
  seen_completed<=canny_completed[0];seen_errors<=source_errors[0];
  if(capture_start)begin capture_valid<=enabled&&source_valid;capture_ms<=milliseconds;end
  if(canny_completed[0]!=seen_completed)begin accepted_frame<=capture_frame;accepted_ms<=capture_ms;accepted_valid<=capture_valid&&canny_ready;end
  if(request_sync[2]&&!request_seen)begin snapshot_ready<=0;snapshot_valid<=0;settle<=2;end
  else if(settle!=0)begin
   settle<=settle-1'b1;
   if(settle==1)begin snapshot_ready<=1;snapshot_valid<=eligible;snapshot_token<=~snapshot_token;end
  end
  if(invalidate||!enabled)begin capture_valid<=0;accepted_valid<=0;snapshot_valid<=0;end
  if(!rst_n)begin
   accepted_frame<=0;capture_ms<=0;accepted_ms<=0;seen_completed<=0;seen_errors<=0;capture_valid<=0;accepted_valid<=0;
   request_sync<=0;request_seen<=0;settle<=0;snapshot_ready<=0;snapshot_valid<=0;snapshot_token<=0;
  end
 end
 reg publish_request=0,publish_ack=0,active_bank=0;
 reg dma_owned=0;
 (* async_reg="true" *)reg[2:0]publish_sync=0;
 (* async_reg="true" *)reg[1:0]ack_sync=0,ready_sync=0,valid_sync=0,active_sync=0,token_sync=0,result_sync=0;
 wire publish_busy=publish_request!=ack_sync[1];
 reg track_request=0,track_ack=0,track_bank=0,track_alive=0,track_lines=0,line_request=0;
 (* async_reg="true" *)reg[2:0]track_sync=0;
 (* async_reg="true" *)reg[1:0]track_ack_sync=0;
 wire track_busy=track_request!=track_ack_sync[1];
 reg[6:0]track_write_index=0;
 wire track_write=paddr==8'h94||paddr==8'h98;
 localparam MW=MS_CYCLES<2?1:$clog2(MS_CYCLES);
 reg[MW-1:0]ms_div=0;reg[31:0]milliseconds=0,ms_gray=0;
 (* async_reg="true" *)reg[31:0]ms_sync0=0,ms_sync1=0;
 function automatic[31:0]from_gray(input[31:0]v);integer n;begin from_gray[31]=v[31];for(n=30;n>=0;n=n-1)from_gray[n]=from_gray[n+1]^v[n];end endfunction
 always @(posedge clk)begin
  if(!rst_n)begin ms_div<=0;milliseconds<=0;ms_gray<=0;end
  else if(ms_div==MS_CYCLES-1)begin ms_div<=0;milliseconds<=milliseconds+1'b1;ms_gray<=((milliseconds+1'b1)>>1)^(milliseconds+1'b1);end
  else ms_div<=ms_div+1'b1;
 end
 reg[5:0]label_index=0;
 wire label_write=paddr==8'h80||paddr==8'h84;
 wire write_bus=psel&&penable&&pwrite,record_write=paddr>=8'h40&&paddr<8'h80;
 assign pready=!(write_bus&&((publish_busy&&(record_write||label_write||paddr==8'h38||paddr==8'h24))||(track_busy&&(track_write||paddr==8'h90||paddr==8'h9c))));
 always @*begin
  prdata=0;
  case(paddr)
   0:prdata=32'h26103173;
   4:prdata={26'd0,publish_request,active_sync[1],publish_busy,result_sync[1],ready_sync[1],valid_sync[1]};
   8:prdata={31'd0,token_sync[1]};
   // The descriptor is protected by bitmap_hold; the CPU returns it with its results.
   8'h18:prdata=accepted_frame;8'h1c:prdata=view_config;8'h20:prdata=view_context;
   8'h28:prdata={31'd0,dma_owned};8'h2c:prdata={21'd0,edge_threshold};
   8'h30:prdata={16'd480,16'd270};8'h34:prdata=canny_completed;
   8'h3c:prdata=32'h4d374c31; // M7L1: CPU-rasterized labels in the existing result RAM.
   8'h9c:prdata={31'd0,track_busy};8'ha0:prdata=from_gray(ms_sync1);8'ha4:prdata=32'h54524b31;
   8'ha8:prdata=accepted_ms;8'hac:prdata=32'h4d544b31; // MTK1: source-timed multi-target history and per-box directions.
   8'hb0:prdata={28'd0,motion_hint};8'hb4:prdata={8'd0,motion_xy};8'hb8:prdata={8'd0,motion_br};
   8'hbc:prdata=32'h4d4c4e31;
  endcase
 end
 (* syn_ramstyle="block_ram" *)reg[18:0]low[0:511],high[0:511];
 wire[6:0]write_index=label_write?7'd8+{1'b0,label_index}:{4'd0,paddr[5:3]};
 wire[8:0]write_address=track_write?{1'b1,!track_request,track_write_index}:{1'b0,!publish_request,write_index};
 always @(posedge cpu_clk)begin
  if(write_bus&&pready&&(record_write||label_write||track_write))begin
   if(track_write?paddr==8'h98:paddr[2])high[write_address]<=pwdata[18:0];else low[write_address]<=pwdata[18:0];
  end
  if(write_bus&&pready&&paddr==8'h38)label_index<=pwdata[5:0];
  if(write_bus&&pready&&paddr==8'h84)label_index<=label_index+1'b1;
  if(write_bus&&pready&&paddr==8'h28)dma_owned<=pwdata[0];
  if(write_bus&&pready&&paddr==8'h24)publish_request<=~publish_request;
  if(write_bus&&pready&&paddr==8'h90)track_write_index<=pwdata[6:0];
  if(write_bus&&pready&&paddr==8'h9c)begin track_request<=~track_request;line_request<=pwdata[1];end
  track_ack_sync<={track_ack_sync[0],track_ack};ms_sync0<=ms_gray;ms_sync1<=ms_sync0;
  if(!rst_n)begin dma_owned<=0;publish_request<=0;track_request<=0;line_request<=0;track_write_index<=0;track_ack_sync<=0;ms_sync0<=0;ms_sync1<=0;end
 end
 always @(posedge cpu_clk)begin
  ack_sync<={ack_sync[0],publish_ack};
  ready_sync<={ready_sync[0],snapshot_ready};valid_sync<={valid_sync[0],snapshot_valid};
  result_sync<={result_sync[0],!front_invalid&&enabled};
  active_sync<={active_sync[0],enabled};token_sync<={token_sync[0],snapshot_token};
  if(write_bus&&pready&&paddr==4)request<=pwdata[0];
  if(!cpu_rst_n)begin request<=0;ack_sync<=0;
   ready_sync<=0;valid_sync<=0;active_sync<=0;token_sync<=0;result_sync<=0;end
 end
 reg vq=0;reg[2:0]front_count=0,circles=0,rectangles=0,faces=0;
 reg front_more=0,publish_pulse=0,label_enable=0;reg[2:0]letters=0;reg[6:0]front_symbol=0;reg[3:0]commit_wait=0;
 reg[11:0]object_directions=0;reg object_motion=0;
 assign current=enabled&&!front_invalid&&source_valid&&(!frozen||result_frame==view_frame);
 assign count=enabled&&!front_invalid?front_count:3'd0;
 assign published=publish_pulse&&snapshot_valid&&!invalidate&&enabled;
 always @(posedge clk)begin
  vq<=vs;publish_sync<={publish_sync[1:0],publish_request};publish_pulse<=0;
  track_sync<={track_sync[1:0],track_request};
  if(vs&&!vq&&track_sync[2]!=track_ack)begin track_bank<=track_sync[2];track_ack<=track_sync[2];track_alive<=1;track_lines<=line_request;end
  if(vs&&!vq&&publish_sync[2]!=publish_ack&&commit_wait==0)begin
   active_bank<=publish_sync[2];front_invalid<=1;commit_wait<=12;
  end
  if(commit_wait!=0)begin
   commit_wait<=commit_wait-1'b1;
   if(commit_wait==1)begin publish_ack<=active_bank;publish_pulse<=1;front_invalid<=!snapshot_valid;end
  end
  if(!enabled||invalidate)front_invalid<=1;
  if(!rst_n)begin vq<=0;publish_sync<=0;publish_ack<=0;active_bank<=0;
   front_invalid<=1;commit_wait<=0;publish_pulse<=0;track_sync<=0;track_ack<=0;track_bank<=0;track_alive<=0;track_lines<=0;end
 end
 // Reuse the display's coordinates; its RGB is centered two pixels behind them.
 wire[10:0]lx=x>=2?x[10:0]-11'd2:11'd0,ly=y>=2?y[10:0]-11'd2:11'd0;
 reg[1:0]warm_phase=0;reg warm_group=0;
 always @(posedge clk)begin warm_phase<=warm_phase+1'b1;if(warm_phase==3)warm_group<=~warm_group;
  if(!rst_n)begin warm_phase<=0;warm_group<=0;end end
 wire active_read=de&&x>=2;
 wire[1:0]slot=2'd3-(active_read?lx[1:0]:warm_phase);
 wire[8:0]issue_group=active_read?lx[10:2]+9'd2:{8'd0,warm_group};
 // Coordinates are read once at VS, freeing each raster slot for its label row.
 reg[37:0]boxes[0:3];
 wire[37:0]issue_box=boxes[slot];
 wire[8:0]label_x=issue_box[35:27]>471?9'd471:issue_box[35:27];
 wire[8:0]above_y=issue_box[26:18]>=4?issue_box[26:18]-9'd4:issue_box[26:18]+9'd1;
 wire[8:0]label_y=label_x<89&&above_y<10?9'd10:above_y;
 wire[10:0]row_y=ly-{label_y,2'b0};
 reg[6:0]record_index;
 always @*case(commit_wait)
  12:record_index=4;11:record_index=5;10:record_index=6;9:record_index=7;
  8:record_index=3;7:record_index=2;6:record_index=1;5:record_index=0;
  default:record_index=7'd8+{1'b0,slot,row_y[3:0]};
 endcase
 reg tdq=0;reg[5:0]prepare=0;reg[10:0]prepare_y=0;
 reg[10:0]track_x0=0,track_y0=0,track_x1=0,track_y1=0;
 reg[1:0]track_state=0;reg track_box=0;reg[31:0]track_view=0;reg[5:0]track_count=0;
 wire[10:0]track_label_x=track_x0>1888?11'd1888:track_x0;
 wire[10:0]track_above=track_y0>=18?track_y0-11'd18:track_y0+11'd2;
 wire[10:0]track_label_y=track_label_x<428&&track_above<40?11'd40:track_above;
 wire[10:0]track_label_row=prepare_y-track_label_y;
 wire track_read=track_alive&&!de&&prepare!=0&&commit_wait==0;
 reg[6:0]track_read_index;
 always @*begin
  case(prepare)1:track_read_index=66;2:track_read_index=0;3:track_read_index=1;
   7:track_read_index=7'd2+{3'd0,track_label_row[3:0]};default:track_read_index=7'd18+{1'b0,prepare}-7'd8;
  endcase
 end
 wire[8:0]read_address=track_read?{1'b1,track_bank,track_read_index}:{1'b0,active_bank,record_index};
 reg[18:0]lq,hq;reg[6:0]index_q=0;reg[8:0]group_q=0;reg bank_q=0;
 reg[37:0]coordinates_q=0;reg[8:0]label_xq=0;reg label_yq=0;
 reg track_read_q=0;reg[6:0]track_index_q=0;
 always @(posedge clk)begin
  lq<=low[read_address];hq<=high[read_address];index_q<=record_index;group_q<=issue_group;bank_q<=active_bank;
  coordinates_q<=issue_box;label_xq<=label_x;label_yq<=row_y<16;
  track_read_q<=track_read;track_index_q<=track_read_index;
  if(!track_read_q&&commit_wait!=0&&index_q<4&&bank_q==active_bank)boxes[index_q[1:0]]<={hq,lq};
 end
 wire[37:0]record_q={hq,lq};
 assign meta_we=!track_read_q&&commit_wait!=0&&index_q>=4&&index_q<7&&bank_q==active_bank;
 assign meta_index=index_q[1:0],meta_data=record_q[31:0];
 assign primary_we=!track_read_q&&commit_wait!=0&&index_q==0&&front_count!=0&&bank_q==active_bank;
 assign primary_data=record_q;
 always @(posedge clk)begin
  if(!track_read_q&&commit_wait!=0&&index_q==7&&bank_q==active_bank)begin
   front_count<=record_q[2:0];front_more<=record_q[3];circles<=record_q[6:4];rectangles<=record_q[9:7];faces<=record_q[12:10];
   label_enable<=record_q[13];letters<=record_q[16:14];front_symbol<=record_q[23:17];
   object_directions<=record_q[35:24];object_motion<=record_q[36];
  end
  if(!rst_n)begin front_count<=0;front_more<=0;circles<=0;rectangles<=0;faces<=0;label_enable<=0;letters<=0;front_symbol<=0;object_directions<=0;object_motion<=0;end
 end
 wire[1:0]object_q=(index_q-7'd8)>>4;
 wire[37:0]box_q=coordinates_q;
 reg[11:0]work_pattern=0,pattern0=0,pattern1=0;
 wire xin=group_q>=box_q[35:27]&&group_q<=box_q[17:9];
 wire yin=ly[10:2]>=box_q[26:18]&&ly[10:2]<=box_q[8:0];
 wire horizontal=xin&&((ly[10:2]==box_q[26:18]&&ly[1:0]==0)||(ly[10:2]==box_q[8:0]&&ly[1:0]==3));
 wire[3:0]border_bits={4{horizontal}}|({4{yin&&group_q==box_q[35:27]}}&4'b0001)|({4{yin&&group_q==box_q[17:9]}}&4'b1000);
 wire[10:0]label_dx={group_q,2'b0}-{label_xq,2'b0};
 wire in_label=label_enable&&label_yq&&label_dx<record_q[37:32];
 wire[3:0]label_bits=record_q[31:0]>>label_dx[4:0];
 wire[2:0]kind=selection[2]&&selection_bank==active_bank&&selection[1:0]==object_q?3'd6:box_q[37:36]==0?3'd4:{1'b0,box_q[37:36]};
 function automatic direction_pixel(input[2:0]d,input[10:0]dx,dy);
  reg[3:0]along,across;reg shaft,head;begin
   along=(d==2||d==3)?dx[3:0]:dy[3:0];across=(d==2||d==3)?dy[3:0]:dx[3:0];
   if(d==2||d==4)along=11-along;
   shaft=across>=5&&across<=6&&along>=1&&along<=10;
   head=along>=6&&((across+along>=15&&across+along<=16)||(along>=across+4&&along<=across+5));
   direction_pixel=dx<12&&dy<12&&((d==1&&dx>=4&&dx<=7&&dy>=4&&dy<=7)||(d>=2&&d<=5&&(shaft||head)));
  end
 endfunction
 wire[10:0]arrow_right={box_q[17:9],2'b11};
 wire[10:0]arrow_left=arrow_right>=15?arrow_right-11'd15:11'd0;
 wire[10:0]arrow_top={box_q[26:18],2'b00}+11'd3;
 wire[2:0]object_direction=object_directions[object_q*3+:3];
 reg[11:0]next_pattern;
 always @*begin
  next_pattern=object_q==3?12'd0:work_pattern;
  for(integer u=0;u<4;u=u+1)if(index_q>=8&&bank_q==active_bank&&object_q<front_count)begin
   if(border_bits[u])next_pattern[u*3+:3]=kind;
   if(in_label)next_pattern[u*3+:3]=label_bits[u]?kind:3'd5;
   if(object_motion&&direction_pixel(object_direction,{group_q,2'b00}+11'(u)-arrow_left,ly-arrow_top))next_pattern[u*3+:3]=kind;
  end
 end
 always @(posedge clk)begin
  if(!track_read_q&&index_q>=8)begin
   work_pattern<=next_pattern;
   if(object_q==0)begin
    if(group_q[0])pattern1<=next_pattern;else pattern0<=next_pattern;
   end
  end
  if(!rst_n)begin work_pattern<=0;pattern0<=0;pattern1<=0;end
 end
 // Native raster HBlank warms both initial groups; the RGB phase remains unchanged.
 wire[11:0]pattern=lx[2]?pattern1:pattern0;
 wire[2:0]pixel_code=pattern[lx[1:0]*3+:3];
 assign counts=current?{letters,faces,rectangles,circles,front_more,front_count}:16'd0;
 assign symbol=current?front_symbol:7'd0;
 // A 48-entry line FIFO reuses spare result RAM for points; it is not a video buffer.
 (* syn_ramstyle="block_ram" *)reg[12:0]line_hits[0:63];
 reg[5:0]line_count=0,hit_cursor=0,hit_index_q=0;reg[12:0]hit_q=0;
 reg[10:0]last_hit_x=0;reg[1:0]last_hit_shade=0;
 reg[37:0]track_label=0;reg line_label=0;
 wire[15:0]point_age=milliseconds[15:0]-record_q[37:22];
 wire[1:0]point_shade=point_age<1000?2'd3:point_age<2000?2'd2:2'd1;
 wire[10:0]point_x=record_q[10:0],point_y=record_q[21:11];
 wire point_on_line={1'b0,point_y}+12'd2>={1'b0,prepare_y}&&{1'b0,prepare_y}+12'd2>={1'b0,point_y};
 wire advance_hit=de&&hit_cursor<line_count&&hit_index_q==hit_cursor&&{1'b0,lx}>{1'b0,hit_q[10:0]}+12'd2;
 wire[5:0]hit_read=!de?6'd0:advance_hit?hit_cursor+1'b1:hit_cursor;
 wire point_accept=!track_lines&&track_read_q&&track_index_q>=18&&track_index_q<66&&track_index_q-18<track_count&&point_age<3000&&point_on_line;
 wire duplicate_hit=line_count!=0&&last_hit_x==point_x;
 wire line_write=point_accept&&(!duplicate_hit||point_shade>last_hit_shade);
 wire[5:0]line_write_address=duplicate_hit?line_count-1'b1:line_count;
 // One explicit write port keeps the small synchronous line FIFO in block RAM.
 always @(posedge clk)begin
  if(rst_n&&line_write)line_hits[line_write_address]<={point_shade,point_x};
  hit_q<=line_hits[hit_read];
 end
 reg[11:0]track_watchdog=3001;
 always @(posedge clk)begin
  tdq<=de;hit_index_q<=hit_read;
  if(!de)hit_cursor<=0;else if(advance_hit)hit_cursor<=hit_cursor+1'b1;
  if(ms_div==MS_CYCLES-1&&track_watchdog<3001)track_watchdog<=track_watchdog+1'b1;
  if(vs&&!vq&&track_sync[2]!=track_ack)track_watchdog<=0;
  if((!de&&tdq)||(vs&&!vq))begin prepare<=1;prepare_y<=vs?11'd0:y>=2?y[10:0]-11'd1:11'd0;line_count<=0;line_label<=0;end
  else if(track_read)prepare<=prepare==55?6'd0:prepare+1'b1;
  if(track_read_q)begin
   case(track_index_q)
    66:begin track_view<=record_q[31:0];track_count<=record_q[37:32];end
    0:begin track_x0<=record_q[10:0];track_y0<=record_q[21:11];track_state<=record_q[23:22];end
    1:begin track_x1<=record_q[10:0];track_y1<=record_q[21:11];track_box<=record_q[22];end
    default:begin
     if(track_index_q>=2&&track_index_q<18)begin track_label<=record_q;line_label<=track_label_row<16;end
     if(point_accept)begin
      if(line_count!=0&&last_hit_x==point_x)begin
       if(point_shade>last_hit_shade)last_hit_shade<=point_shade;
      end else begin line_count<=line_count+1'b1;last_hit_x<=point_x;last_hit_shade<=point_shade;end
     end
    end
   endcase
  end
  if(!rst_n)begin tdq<=0;prepare<=0;prepare_y<=0;line_count<=0;hit_cursor<=0;hit_index_q<=0;track_box<=0;track_view<=0;track_count<=0;track_watchdog<=3001;line_label<=0;track_state<=0;end
 end
 wire track_current=track_alive&&enabled&&source_valid&&track_view==view_config;
 assign tracking=track_alive&&track_watchdog<3001&&(track_box||track_count!=0);
 wire track_border=track_box&&lx>=track_x0&&lx<=track_x1&&ly>=track_y0&&ly<=track_y1&&(lx==track_x0||lx==track_x1||ly==track_y0||ly==track_y1);
 wire[10:0]track_label_dx=lx-track_label_x;
 wire track_letter=track_box&&line_label&&track_label_dx<track_label[37:32];
 // Segment intersections are prepared in HBlank; the active raster only compares compact spans.
 (* syn_ramstyle="block_ram" *)reg[16:0]inverse[0:269];
 initial begin inverse[0]=0;for(integer i=1;i<270;i=i+1)inverse[i]=(65536+i/2)/i;end
 wire segment_in=track_lines&&track_read_q&&track_index_q>=18&&track_index_q<66&&track_index_q-18<track_count;
 wire[8:0]sx0=record_q[8:0],sy0=record_q[17:9],sx1=record_q[26:18],sy1=record_q[35:27];
 wire[8:0]segment_top=sy0<sy1?sy0:sy1,segment_bottom=sy0<sy1?sy1:sy0;
 reg[2:0]segment_valid=0;reg[16:0]inverse_q=0;
 reg[5:0]segment_index0=0,segment_index1=0,segment_index2=0;
 reg[8:0]segment_x0=0,segment_end0=0,segment_dy0=0,segment_row0=0;
 reg signed[9:0]segment_dx0=0;
 reg[1:0]segment_shade0=0,segment_shade1=0,segment_shade2=0;
 reg segment_on0=0,segment_on1=0,segment_on2=0;
 reg[8:0]segment_base1=0,segment_end1=0,segment_dy1=0,segment_row1=0;
 reg[8:0]segment_base2=0,segment_end2=0,segment_dy2=0,segment_row2=0;
 reg signed[27:0]slope_q=0,step_q=0;reg signed[37:0]offset_q=0;
 reg[8:0]span_left[0:47],span_right[0:47];reg[1:0]span_shade[0:47];reg[47:0]span_valid=0;
 wire signed[37:0]offset_next=offset_q+step_q;
 wire signed[38:0]segment_a=$signed({1'b0,segment_base2})+((offset_q+38'sd32768)>>>16);
 wire signed[38:0]segment_b=$signed({1'b0,segment_base2})+((offset_next+38'sd32768)>>>16);
 wire[8:0]line_a=segment_dy2==0?segment_base2:segment_row2==segment_dy2?segment_end2:segment_a[8:0];
 wire[8:0]line_b=segment_dy2==0?segment_end2:segment_row2+1'b1>=segment_dy2?segment_end2:segment_b[8:0];
 always @(posedge clk)begin
  segment_valid<={segment_valid[1:0],segment_in};
  if(segment_in)begin
   inverse_q<=inverse[segment_bottom-segment_top];segment_index0<=track_index_q-7'd18;
   segment_x0<=sy0<=sy1?sx0:sx1;segment_end0<=sy0<=sy1?sx1:sx0;
   segment_dx0<=$signed({1'b0,sy0<=sy1?sx1:sx0})-$signed({1'b0,sy0<=sy1?sx0:sx1});
   segment_dy0<=segment_bottom-segment_top;segment_row0<=prepare_y[10:2]-segment_top;
   segment_on0<=prepare_y[10:2]>=segment_top&&prepare_y[10:2]<=segment_bottom;
   segment_shade0<=record_q[37:36];
  end
  if(segment_valid[0])begin
   slope_q<=segment_dx0*$signed({1'b0,inverse_q});segment_index1<=segment_index0;
   segment_base1<=segment_x0;segment_end1<=segment_end0;segment_dy1<=segment_dy0;segment_row1<=segment_row0;
   segment_shade1<=segment_shade0;segment_on1<=segment_on0;
  end
  if(segment_valid[1])begin
   offset_q<=slope_q*$signed({1'b0,segment_row1});step_q<=segment_row1<segment_dy1?slope_q:28'sd0;
   segment_index2<=segment_index1;segment_base2<=segment_base1;segment_end2<=segment_end1;segment_dy2<=segment_dy1;segment_row2<=segment_row1;
   segment_shade2<=segment_shade1;segment_on2<=segment_on1;
  end
  if(segment_valid[2])begin
   span_left[segment_index2]<=line_a<line_b?line_a:line_b;span_right[segment_index2]<=line_a<line_b?line_b:line_a;
   span_shade[segment_index2]<=segment_shade2;span_valid[segment_index2]<=segment_on2&&segment_shade2!=0;
  end
  if((!de&&tdq)||(vs&&!vq))span_valid<=0;
  if(!rst_n)begin segment_valid<=0;span_valid<=0;end
 end
 wire[47:0]bright_span,medium_span,dim_span;
 generate for(genvar si=0;si<48;si=si+1)begin:segments
  wire hit=span_valid[si]&&lx[10:2]>=span_left[si]&&lx[10:2]<=span_right[si];
  assign bright_span[si]=hit&&span_shade[si]==3,medium_span[si]=hit&&span_shade[si]==2,dim_span[si]=hit&&span_shade[si]==1;
 end endgenerate
 wire[1:0]line_shade=(|bright_span)?2'd3:(|medium_span)?2'd2:(|dim_span)?2'd1:2'd0;
 wire trail_pixel=track_watchdog<3001&&(track_lines?line_shade!=0:hit_cursor<line_count&&hit_index_q==hit_cursor&&{1'b0,lx}+12'd2>={1'b0,hit_q[10:0]}&&{1'b0,lx}<={1'b0,hit_q[10:0]}+12'd2);
 wire tracked_mark=track_current&&de&&x>=2&&y>=2&&(track_border||track_letter||trail_pixel);
 wire[1:0]trail_shade=track_lines?line_shade:hit_q[12:11];
 wire[23:0]trail_color=trail_shade==3?24'h40ffff:trail_shade==2?24'h289090:24'h184848;
 wire[23:0]tracked_color=track_letter?(track_label[track_label_dx[4:0]]?24'hff40ff:24'd0):track_border?(track_state==2?24'hffb040:24'hff40ff):trail_color;
 assign mark=tracked_mark||(current&&de&&x>=2&&y>=2&&pixel_code!=0);
 assign color=tracked_mark?tracked_color:pixel_code==1?24'h20ff40:pixel_code==2?24'h3090ff:pixel_code==3?24'hffe020:pixel_code==4?24'h20ffff:pixel_code==6?24'hff40ff:24'h000000;
endmodule
