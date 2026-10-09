// Unthrottled 1/2PPC input -> leased 2PPC packed RGB capture. Overflow aborts the
// writer after its advertised AXI burst; an incomplete source is never published.
module vision_rgb_capture #(parameter W=1920,H=1080,FIFO_AW=10,INPUT_PPC=1,PAIR_DENOISE=0)(
 input rst_n,video_clk,vs,de,input[23:0]rgb,input[31:0]raw_id,
 input[23:0]rgb_upper,input source_abort,
 input clk,enable,freeze_source,
 output capture_valid,input capture_ready,output reg[31:0]capture_config_id,
 output capture_pixel_valid,input capture_pixel_ready,output[31:0]capture_pixel_data,
 output capture_pixel_sof,capture_pixel_eol,capture_pixel_eof,
 output capture_abort,input capture_done,capture_error,
 output active,output reg[31:0]completed,discarded
);
 localparam DATA=0,EOL=1,EOF=2,HEADER=3,ABORT=7;
 reg request=0;reg[2:0]state=0;reg first=1,aborted=0;
 reg[2:0]req_sync=0;reg seen=0,vq=0,taking=0,phase=0;
 reg[11:0]x=0,y=0;reg[15:0]left=0;
 reg pv=0;reg[34:0]pd=0;wire pr,mv,mr;wire[34:0]md;
 // Packed16 linear RGB: bit15=range, bits14:10/9:5/4:0=R/G/B.
 // Low range0..63 has two-count steps (error<=1); high range uses equal RGB555
 // quantization. Keep mid-dark values out of coarse eight-count steps before tone.
 // ponytail: bright-source RGB555 at16-bit bandwidth; RGB888 needs a wider DMA budget.
 // The16-bit frame pool and scaler copy this opaque pixel unchanged.
 // Exact nearest normalized RGB555: round(v*31/255).
 // Shift/add divide by255 is exact over these numerators; no multiplier/DSP.
 function automatic[4:0]quant5(input[7:0]v);
  reg[12:0]n,q;begin n=({v,5'b0}-{5'b0,v})+13'd127;q=n+(n>>8)+13'd1;quant5=q[12:8];end
 endfunction
 function automatic[15:0]pack_pixel(input[23:0]v);
  begin pack_pixel=|{v[23:22],v[15:14],v[7:6]}?{1'b1,quant5(v[23:16]),quant5(v[15:8]),quant5(v[7:0])}:
   {1'b0,v[21:17],v[13:9],v[5:1]};end
 endfunction
 // Remove flat-field sensor variation before the irreversible RGB555 packing.
 // Both samples stay distinct (3:1 / 1:3); high-contrast boundaries bypass it.
 // ponytail: one adjacent 2PPC pair, no line RAM; not spatial/temporal zero noise.
 function automatic[7:0]mix31(input[7:0]a,input[4:0]delta,input upper);
  reg signed[5:0]d;reg signed[2:0]q;
  begin d=upper?$signed({1'b0,delta})-6'sd6:6'sd10-$signed({1'b0,delta});q=d>>>2;mix31=$signed({1'b0,a})+q;end
 endfunction
 wire[8:0]dr={1'b0,rgb[23:16]}-{1'b0,rgb_upper[23:16]}+9'd8;
 wire[8:0]dg={1'b0,rgb[15:8]}-{1'b0,rgb_upper[15:8]}+9'd8;
 wire[8:0]db={1'b0,rgb[7:0]}-{1'b0,rgb_upper[7:0]}+9'd8;
 wire flat_pair=PAIR_DENOISE&&INPUT_PPC==2&&dr<=16&&dg<=16&&db<=16;
 // Gate proves each delta is0..16, so the exact quarter-step needs only3 bits.
 wire[23:0]lower_clean=flat_pair?{mix31(rgb[23:16],dr[4:0],0),mix31(rgb[15:8],dg[4:0],0),mix31(rgb[7:0],db[4:0],0)}:rgb;
 wire[23:0]upper_clean=flat_pair?{mix31(rgb_upper[23:16],dr[4:0],1),mix31(rgb_upper[15:8],dg[4:0],1),mix31(rgb_upper[7:0],db[4:0],1)}:rgb_upper;
 wire[15:0]pixel=pack_pixel(lower_clean),upper_pixel=pack_pixel(upper_clean);
 stream_cdc #(.WIDTH(35),.AW(FIFO_AW)) fifo(rst_n,video_clk,pv,pr,pd,clk,mv,mr,md,,);
 always @(posedge video_clk)begin
  req_sync<={req_sync[1:0],request};vq<=vs;
  if(!rst_n)begin req_sync<=0;seen<=0;vq<=0;taking<=0;phase<=0;x<=0;y<=0;pv<=0;pd<=0;left<=0;end
  else begin
   if(pv&&pr)pv<=0;
   if(vs&&!vq&&req_sync[2]!=seen)begin
    seen<=req_sync[2];taking<=1;phase<=0;x<=0;y<=0;
    pv<=1;pd<={3'(HEADER),raw_id};
   end
   if(taking&&de)begin
    if(INPUT_PPC==2)begin
     pv<=1;pd<={(x==W-2?(y==H-1?3'(EOF):3'(EOL)):3'(DATA)),upper_pixel,pixel};
    end else begin
     if(!phase)begin left<=pixel;phase<=1;end
     else begin phase<=0;pv<=1;pd<={(x==W-1?(y==H-1?3'(EOF):3'(EOL)):3'(DATA)),pixel,left};end
    end
    if(x==W-INPUT_PPC)begin x<=0;y<=y+1'b1;end else x<=x+INPUT_PPC;
    if(x==W-INPUT_PPC&&y==H-1)taking<=0;
   end
   // Hold the termination marker until space returns. Already queued pixels
   // precede it, so the core drains the precise failed capture before rearming.
   if((pv&&!pr)||(INPUT_PPC==2&&source_abort&&taking))begin taking<=0;pv<=1;pd<={3'(ABORT),32'd0};end
  end
 end
 assign active=state!=0;
 assign capture_valid=state==2;
 assign capture_pixel_valid=state==3&&mv&&md[34:32]<=EOF;
 assign capture_pixel_data=md[31:0];
 assign capture_pixel_sof=first;
 assign capture_pixel_eol=md[34:32]==EOL||md[34:32]==EOF;
 assign capture_pixel_eof=md[34:32]==EOF;
 assign capture_abort=aborted;
 assign mr=(state==1)||(state==3&&(md[34:32]==ABORT||capture_pixel_ready));
 always @(posedge clk)begin
  if(!rst_n)begin state<=0;request<=0;first<=1;aborted<=0;capture_config_id<=0;completed<=0;discarded<=0;end
  else case(state)
   0:if(enable&&!freeze_source)begin request<=~request;state<=1;end
   1:if(mv)begin
    if(md[34:32]==ABORT)begin discarded<=discarded+1'b1;state<=0;end
    else begin capture_config_id<=md[31:0];state<=2;first<=1;aborted<=0;end
   end
   2:if(capture_ready)state<=3;
   3:if(mv&&mr)begin
    if(md[34:32]==ABORT)begin aborted<=1;state<=4;end
    else begin first<=0;if(md[34:32]==EOF)state<=4;end
   end
   4:if(capture_done)begin
    completed<=completed+1'b1;if(capture_error)discarded<=discarded+1'b1;
    aborted<=0;state<=0;
   end
  endcase
 end
endmodule
