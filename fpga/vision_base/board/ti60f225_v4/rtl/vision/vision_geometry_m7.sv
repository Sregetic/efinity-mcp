// M7 owns no pixel RAM: accepted Canny bits use the existing CPU bitmap port.
module vision_geometry_m7(
 input clk,rst_n,de,vs,input[11:0]x,y,
 input enabled,frozen,source_valid,invalidated,capture_start,canny_ready,
 input[31:0]capture_frame,view_frame,view_config,view_context,canny_completed,source_errors,result_frame,
 output bitmap_hold,raw_bitmap_enable,
 input cpu_clk,cpu_rst_n,input[7:0]paddr,input psel,penable,pwrite,input[31:0]pwdata,
 output reg[31:0]prdata,output pready,output current,output[2:0]count,
 output published,output primary_we,output[37:0]primary_data,
 output meta_we,output[1:0]meta_index,output[31:0]meta_data,
 output mark,output[23:0]color,output[15:0]counts,output[6:0]symbol,output reg[7:0]edge_threshold=96);
 reg[31:0]accepted_frame=0;reg seen_completed=0,seen_errors=0;
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
  if(capture_start)capture_valid<=enabled&&source_valid;
  if(canny_completed[0]!=seen_completed)begin accepted_frame<=capture_frame;accepted_valid<=capture_valid&&canny_ready;end
  if(request_sync[2]&&!request_seen)begin snapshot_ready<=0;snapshot_valid<=0;settle<=2;end
  else if(settle!=0)begin
   settle<=settle-1'b1;
   if(settle==1)begin snapshot_ready<=1;snapshot_valid<=eligible;snapshot_token<=~snapshot_token;end
  end
  if(invalidate||!enabled)begin capture_valid<=0;accepted_valid<=0;snapshot_valid<=0;end
  if(!rst_n)begin
   accepted_frame<=0;seen_completed<=0;seen_errors<=0;capture_valid<=0;accepted_valid<=0;
   request_sync<=0;request_seen<=0;settle<=0;snapshot_ready<=0;snapshot_valid<=0;snapshot_token<=0;
  end
 end
 reg publish_request=0,publish_ack=0,active_bank=0;
 reg[7:0]edge_request=96;reg edge_token=0,edge_ack=0,dma_owned=0;
 (* async_reg="true" *)reg[2:0]edge_sync=0,publish_sync=0;
 (* async_reg="true" *)reg[1:0]edge_ack_sync=0,ack_sync=0,ready_sync=0,valid_sync=0,active_sync=0,token_sync=0,result_sync=0;
 wire publish_busy=publish_request!=ack_sync[1],edge_busy=edge_token!=edge_ack_sync[1];
 reg[5:0]label_index=0;
 wire label_write=paddr==8'h80||paddr==8'h84;
 wire write_bus=psel&&penable&&pwrite,record_write=paddr>=8'h40&&paddr<8'h80;
 assign pready=!(write_bus&&((publish_busy&&(record_write||label_write||paddr==8'h38||paddr==8'h24))||(edge_busy&&paddr==8'h2c)));
 always @*begin
  prdata=0;
  case(paddr)
   0:prdata=32'h26102871;
   4:prdata={27'd0,active_sync[1],publish_busy,result_sync[1],ready_sync[1],valid_sync[1]};
   8:prdata={31'd0,token_sync[1]};
   // The descriptor is protected by bitmap_hold; the CPU returns it with its results.
   8'h18:prdata=accepted_frame;8'h1c:prdata=view_config;8'h20:prdata=view_context;
   8'h28:prdata={31'd0,dma_owned};8'h2c:prdata={24'd0,edge_request};
   8'h30:prdata={16'd480,16'd270};8'h34:prdata=canny_completed;
   8'h3c:prdata=32'h4d374c31; // M7L1: CPU-rasterized labels in the existing result RAM.
  endcase
 end
 (* syn_ramstyle="block_ram" *)reg[18:0]low[0:511],high[0:511];
 wire[6:0]write_index=label_write?7'd8+{1'b0,label_index}:{4'd0,paddr[5:3]};
 wire[8:0]write_address={1'b0,!publish_request,write_index};
 always @(posedge cpu_clk)begin
  if(write_bus&&pready&&(record_write||label_write))begin
   if(paddr[2])high[write_address]<=pwdata[18:0];else low[write_address]<=pwdata[18:0];
  end
  if(write_bus&&pready&&paddr==8'h38)label_index<=pwdata[5:0];
  if(write_bus&&pready&&paddr==8'h84)label_index<=label_index+1'b1;
  if(write_bus&&pready&&paddr==8'h2c)begin edge_request<=pwdata[7:0];edge_token<=~edge_token;end
  if(write_bus&&pready&&paddr==8'h28)dma_owned<=pwdata[0];
  if(write_bus&&pready&&paddr==8'h24)publish_request<=~publish_request;
  if(!rst_n)begin edge_request<=96;edge_token<=0;dma_owned<=0;publish_request<=0;end
 end
 always @(posedge cpu_clk)begin
  ack_sync<={ack_sync[0],publish_ack};edge_ack_sync<={edge_ack_sync[0],edge_ack};
  ready_sync<={ready_sync[0],snapshot_ready};valid_sync<={valid_sync[0],snapshot_valid};
  result_sync<={result_sync[0],!front_invalid&&enabled};
  active_sync<={active_sync[0],enabled};token_sync<={token_sync[0],snapshot_token};
  if(write_bus&&pready&&paddr==4)request<=pwdata[0];
  if(!cpu_rst_n)begin request<=0;ack_sync<=0;edge_ack_sync<=0;
   ready_sync<=0;valid_sync<=0;active_sync<=0;token_sync<=0;result_sync<=0;end
 end
 reg vq=0;reg[2:0]front_count=0,circles=0,rectangles=0,faces=0;
 reg front_more=0,publish_pulse=0,label_enable=0;reg[2:0]letters=0;reg[6:0]front_symbol=0;reg[3:0]commit_wait=0;
 assign current=enabled&&!front_invalid&&source_valid&&(!frozen||result_frame==view_frame);
 assign count=enabled&&!front_invalid?front_count:3'd0;
 assign published=publish_pulse&&snapshot_valid&&!invalidate&&enabled;
 always @(posedge clk)begin
  vq<=vs;publish_sync<={publish_sync[1:0],publish_request};edge_sync<={edge_sync[1:0],edge_token};publish_pulse<=0;
  if(vs&&!vq&&edge_sync[2]!=edge_ack)begin edge_threshold<=edge_request;edge_ack<=edge_sync[2];end
  if(vs&&!vq&&publish_sync[2]!=publish_ack&&commit_wait==0)begin
   active_bank<=publish_sync[2];front_invalid<=1;commit_wait<=12;
  end
  if(commit_wait!=0)begin
   commit_wait<=commit_wait-1'b1;
   if(commit_wait==1)begin publish_ack<=active_bank;publish_pulse<=1;front_invalid<=!snapshot_valid;end
  end
  if(!enabled||invalidate)front_invalid<=1;
  if(!rst_n)begin vq<=0;publish_sync<=0;publish_ack<=0;active_bank<=0;
   front_invalid<=1;commit_wait<=0;publish_pulse<=0;edge_sync<=0;edge_ack<=0;edge_threshold<=96;end
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
 wire[8:0]read_address={1'b0,active_bank,record_index};
 reg[18:0]lq,hq;reg[6:0]index_q=0;reg[8:0]group_q=0;reg bank_q=0;
 reg[37:0]coordinates_q=0;reg[8:0]label_xq=0;reg label_yq=0;
 always @(posedge clk)begin
  lq<=low[read_address];hq<=high[read_address];index_q<=record_index;group_q<=issue_group;bank_q<=active_bank;
  coordinates_q<=issue_box;label_xq<=label_x;label_yq<=row_y<16;
  if(commit_wait!=0&&index_q<4&&bank_q==active_bank)boxes[index_q[1:0]]<={hq,lq};
 end
 wire[37:0]record_q={hq,lq};
 assign meta_we=commit_wait!=0&&index_q>=4&&index_q<7&&bank_q==active_bank;
 assign meta_index=index_q[1:0],meta_data=record_q[31:0];
 assign primary_we=commit_wait!=0&&index_q==0&&front_count!=0&&bank_q==active_bank;
 assign primary_data=record_q;
 always @(posedge clk)begin
  if(commit_wait!=0&&index_q==7&&bank_q==active_bank)begin
   front_count<=record_q[2:0];front_more<=record_q[3];circles<=record_q[6:4];rectangles<=record_q[9:7];faces<=record_q[12:10];
   label_enable<=record_q[13];letters<=record_q[16:14];front_symbol<=record_q[23:17];
  end
  if(!rst_n)begin front_count<=0;front_more<=0;circles<=0;rectangles<=0;faces<=0;label_enable<=0;letters<=0;front_symbol<=0;end
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
 wire[2:0]kind=box_q[37:36]==0?3'd4:{1'b0,box_q[37:36]};
 reg[11:0]next_pattern;
 always @*begin
  next_pattern=object_q==3?12'd0:work_pattern;
  for(integer u=0;u<4;u=u+1)if(index_q>=8&&bank_q==active_bank&&object_q<front_count)begin
   if(border_bits[u])next_pattern[u*3+:3]=kind;
   if(in_label)next_pattern[u*3+:3]=label_bits[u]?kind:3'd5;
  end
 end
 always @(posedge clk)begin
  if(index_q>=8)begin
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
 assign mark=current&&de&&x>=2&&y>=2&&pixel_code!=0;
 assign color=pixel_code==1?24'h20ff40:pixel_code==2?24'h3090ff:pixel_code==3?24'hffe020:pixel_code==4?24'h20ffff:24'h000000;
endmodule
