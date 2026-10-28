// Reconstruct the accepted Canny graph on its 4x HDMI grid. Each coarse edge
// is a node; segments join only existing 8-connected neighbors. No live RGB
// is mixed with the retained Canny frame. Detection remains W x H.
module vision_canny_raster_reference #(parameter W=480,H=270,CW=9,
 parameter INDEX_FILE="./rtl/vision/canny_coverage_index.mem",
 parameter PALETTE_FILE="./rtl/vision/canny_coverage_palette.mem")(
 input clk,rst_n,vblank,de,input[11:0]x,y,input bitmap,ready,
 output reg[CW-1:0]fetch_x,fetch_y,output pixel,
 output reg[31:0]coarse_edges,display_edges,output[7:0]coverage
);
 wire[CW:0]rx={1'b0,x[10:2]}+2,ry={1'b0,y[10:2]}+1;
 // Vblank primes rows0..4 and the next row's first8 columns; no frame RAM.
 reg prefill=0,fit_primed=0;reg[CW-1:0]prefill_x=0;reg[2:0]prefill_y=0;
 reg[1:0]prefill_phase=0;reg[11:0]next_line_y=0;
 always @(posedge clk)begin
  if(de)next_line_y<=y+1'b1;
  if(vblank)begin prefill<=ready;fit_primed<=0;prefill_x<=0;prefill_y<=0;prefill_phase<=0;next_line_y<=0;end
  else if(prefill)begin
   prefill_phase<=prefill_phase+1'b1;
   if(prefill_phase==3)begin
    if(prefill_y==5&&prefill_x==7)begin prefill<=0;fit_primed<=1;end
    else if(prefill_x==W-1)begin prefill_x<=0;prefill_y<=prefill_y+1'b1;end
    else prefill_x<=prefill_x+1'b1;
   end
  end
  if(!rst_n)begin prefill<=0;fit_primed<=0;next_line_y<=0;end
 end
 wire[11:0]next_x=de?x+1'b1:12'd0,next_y=de?y:next_line_y;
 wire[CW:0]linear_x={1'b0,next_x[10:2]}+8;
 wire wrap_left=linear_x>=W&&next_y[1:0]==3;
 wire next_fit=next_x[1:0]==1&&((next_y[1:0]==0&&linear_x<W+5)||wrap_left);
 wire[CW:0]next_fit_x=wrap_left?linear_x-W:linear_x;
 wire[CW:0]next_fit_y={1'b0,next_y[10:2]}+5+wrap_left;
 wire prefill_advance=prefill_phase==3;
 wire[CW-1:0]prefill_next_x=prefill_advance?(prefill_x==W-1?CW'(0):prefill_x+1'b1):prefill_x;
 wire[2:0]prefill_next_y=prefill_y+(prefill_advance&&prefill_x==W-1);
 reg request_fit=0,request_zero=0;
 // Issue one clock ahead so the accepted bitmap bank decoder starts at registers.
 always @(posedge clk)begin
  if(prefill)begin
   fetch_x<=prefill_next_x;fetch_y<=prefill_next_y;
   request_fit<=prefill_phase==1;request_zero<=0;
  end else begin
   fetch_x<=next_fit?next_fit_x[CW-1:0]:next_x[10:2]+2;
   fetch_y<=next_fit?next_fit_y[CW-1:0]:next_y[10:2]+1;
   request_fit<=next_fit;request_zero<=next_fit_x>=W||next_fit_y>=H;
  end
  if(!rst_n)begin fetch_x<=0;fetch_y<=0;request_fit<=0;request_zero<=0;end
 end
 reg rq=0,vq=0;reg[CW-1:0]qx=0,qy=0;
 reg fit_rq=0,fit_zero_q=0,fit_first_q=0;reg[CW-1:0]fit_qx=0;
 reg[1:0]ux=0,uy=0;reg[CW-1:0]tx=0,ty=0;
 always @(posedge clk)begin
  rq<=de&&x[1:0]==0&&y[1:0]==0&&rx<W&&ry<H;
  fit_rq<=request_fit;fit_qx<=fetch_x;fit_zero_q<=request_zero;fit_first_q<=fetch_y==0;
  qx<=fetch_x;qy<=fetch_y;vq<=de;ux<=x[1:0];uy<=y[1:0];tx<=x[10:2];ty<=y[10:2];
  if(!rst_n)begin rq<=0;fit_rq<=0;vq<=0;ux<=0;uy<=0;tx<=0;ty<=0;end
 end
 wire wv;wire[CW-1:0]wx,wy;wire[8:0]neighbors;
 vision_sparse_window #(.W(W),.BPP(1),.CW(CW)) window0(
  clk,rst_n,rq,qx,qy,bitmap,wv,wx,wy,neighbors);
 reg[8:0]rows[0:W-1],row_q=0,fresh=0,tile=0;
 // The unfetched column1 is static Canny padding, not a previous-line tap.
 wire[8:0]valid_neighbors=wx==3?neighbors&9'b011011011:neighbors;
 wire[CW-1:0]cache_x=!de?0:(x[1:0]==3?x[10:2]+1'b1:x[10:2]);
 always @(posedge clk)begin
  if(cache_x<W)row_q<=rows[cache_x];
  if(wv)begin rows[wx-1'b1]<=valid_neighbors;fresh<=valid_neighbors;end
  // Fresh window arrives at phase3; first-row cache read/write can collide.
  // The remaining three rows reuse the completed cache instead.
  if(de&&x[1:0]==0)tile<=y[1:0]==0?fresh:row_q;
  if(!rst_n)begin row_q<=0;fresh<=0;tile<=0;end
 end
 wire center=tile[4],nw=tile[8],n=tile[7],ne=tile[6],w=tile[5];
 wire e=tile[3],sw=tile[2],s=tile[1],se=tile[0];
 wire node=ux==2&&uy==2;
 wire horizontal=uy==2&&((w&&ux<=2)||(e&&ux>=2));
 wire vertical=ux==2&&((n&&uy<=2)||(s&&uy>=2));
 wire descending=ux==uy&&((nw&&ux<=2)||(se&&ux>=2));
 wire ascending={1'b0,ux}+{1'b0,uy}==4&&((ne&&ux>=2)||(sw&&ux<=2));
 // NE/SW neighbor connections also cross the top-left corner of this cell.
 wire bridge=n&&w&&ux==0&&uy==0;
 wire in_canvas=ready&&vq&&tx>=2&&ty>=2&&tx<W-2&&ty<H-2;
 assign pixel=in_canvas&&
              ((center&&(node||horizontal||vertical||descending||ascending))||bridge);
 // Coverage is independent of the unchanged binary recognition graph.
 (* syn_ramstyle="logic" *)reg[5:0]coverage_index[0:511];
 reg[4:0]coverage_palette[0:1023],curve_level;
 initial begin $readmemh(INDEX_FILE,coverage_index);$readmemh(PALETTE_FILE,coverage_palette);end
 wire[8:0]next_tile=de&&x[1:0]==0?(y[1:0]==0?fresh:row_q):tile;
 always @(posedge clk)curve_level<=coverage_palette[{coverage_index[next_tile],y[1:0],x[1:0]}];
 wire fit_enable;wire[7:0]fit_coverage;
 vision_canny_line_fit_reference #(.W(W),.H(H),.CW(CW)) line_fit(
  .clk(clk),.rst_n(rst_n),.valid(fit_rq),.ix(fit_qx),.bitmap(fit_zero_q?1'b0:bitmap),.first_row(fit_first_q),
  .de(de),.x(x),.ux(ux),.uy(uy),.tx(tx),.ty(ty),.enable(fit_enable),.coverage(fit_coverage));
 assign coverage=!in_canvas?8'd0:(fit_primed&&fit_enable)?fit_coverage:{curve_level,curve_level[4:2]};
 reg[31:0]coarse_count=0,display_count=0;
 always @(posedge clk)begin
  if(!rst_n)begin coarse_count<=0;display_count<=0;coarse_edges<=0;display_edges<=0;end
  else if(vblank)begin coarse_edges<=coarse_count;display_edges<=display_count;coarse_count<=0;display_count<=0;end
  else begin
   if(rq&&bitmap&&ready)coarse_count<=coarse_count+1'b1;
   if(pixel)display_count<=display_count+1'b1;
  end
 end
endmodule

// Nine connected samples, or five near turns; four clocks share the tracer.
module vision_canny_line_fit_reference #(parameter W=480,H=270,CW=9)(
 input clk,rst_n,valid,input[CW-1:0]ix,input bitmap,first_row,
 input de,input[11:0]x,input[1:0]ux,uy,input[CW-1:0]tx,ty,
 output enable,output[7:0]coverage);
 reg[9:0]columns[0:W-1],column_q;
 reg d=0;reg[CW-1:0]xx=0;reg bit_q=0,first_q=0;
 wire[10:0]vertical={first_q?10'd0:column_q,bit_q};
 reg[10:0]left_columns[0:9];reg[120:0]window;
 reg window_valid=0;reg[CW-1:0]window_x=0;
 integer r,c,j;
 always @(posedge clk)begin
  if(valid)begin column_q<=ix<W?columns[ix]:10'd0;xx<=ix;bit_q<=ix<W?bitmap:1'b0;first_q<=first_row;end
  d<=valid;window_valid<=d&&xx>=5;
  if(d)begin
   if(xx<W)columns[xx]<=first_q?{9'd0,bit_q}:{column_q[8:0],bit_q};window_x<=xx;
   for(j=9;j>0;j=j-1)left_columns[j]<=left_columns[j-1];
   left_columns[0]<=vertical;
   for(r=0;r<11;r=r+1)for(c=0;c<11;c=c+1)
    window[120-r*11-c]<=c==10?vertical[10-r]:(xx>=10-c?left_columns[9-c][10-r]:1'b0);
  end
  if(!rst_n)begin d<=0;window_valid<=0;end
 end
 wire nw=window[72],n=window[71],ne=window[70],w=window[61];
 wire center=window[60],e=window[59],sw=window[50],s=window[49],se=window[48];
 wire short_n=n&&!(nw||ne||window[83]||window[82]||window[81]);
 wire short_s=s&&!(sw||se||window[39]||window[38]||window[37]);
 wire short_w=w&&!(nw||sw||window[73]||window[62]||window[51]);
 wire short_e=e&&!(ne||se||window[69]||window[58]||window[47]);
 wire junction=center&&((n&&s&&((w&&!short_w&&!(nw&&sw))||(e&&!short_e&&!(ne&&se))))||
                        (w&&e&&((n&&!short_n&&!(nw&&ne))||(s&&!short_s&&!(sw&&se)))));
 wire[8:0]core={nw,n,ne,w,center,e,sw,s,se};
 wire spur=core==9'b111010000||core==9'b000010111||core==9'b100110100||core==9'b001011001;
 wire h_candidate=!junction&&!spur&&(center||n||s)&&!(center&&n&&s&&!w&&!e);
 wire v_candidate=!junction&&!spur&&(center||w||e)&&!(center&&w&&e&&!n&&!s);
 wire signed[1:0]h_origin=center?2'sd0:n?-2'sd1:2'sd1;
 wire signed[1:0]v_origin=center?2'sd0:w?-2'sd1:2'sd1;
 reg[120:0]job_window;reg busy=0;reg[1:0]step=0;
 reg[CW-1:0]job_x=0;
 reg signed[3:0]hl=0,hr=0,vl=0,vr=0;
 reg[10:0]prior_hl,prior_hr,prior_vl,prior_vr;
 reg signed[1:0]origin_h=0,origin_v=0;
 reg valid_h=0,valid_v=0;
 reg signed[6:0]sum_h=0,sum_v=0;
 reg signed[7:0]weight_h=0,weight_v=0;
 // Select one row/column before walking, rather than twelve full-window muxes.
 function automatic[10:0]trace_line(input[120:0]map,input[1:0]phase,
  input horizontal,positive);
  integer i;
  begin
   for(i=0;i<11;i=i+1)case(phase)
    0:trace_line[i]=horizontal?(positive?map[120-i*11-6]:map[120-i*11-4]):
                               (positive?map[120-6*11-i]:map[120-4*11-i]);
    1:trace_line[i]=horizontal?(positive?map[120-i*11-7]:map[120-i*11-3]):
                               (positive?map[120-7*11-i]:map[120-3*11-i]);
    2:trace_line[i]=horizontal?(positive?map[120-i*11-8]:map[120-i*11-2]):
                               (positive?map[120-8*11-i]:map[120-2*11-i]);
    3:trace_line[i]=horizontal?(positive?map[120-i*11-9]:map[120-i*11-1]):
                               (positive?map[120-9*11-i]:map[120-1*11-i]);
   endcase
  end
 endfunction
 function automatic[4:0]walk(input[10:0]line,input signed[3:0]previous,input[10:0]prior_line);
  reg[14:0]padded,prior_padded;reg[4:0]nearby,prior_nearby;
  begin
   padded={2'b0,line,2'b0};nearby=padded>>($signed(previous)+5);
   prior_padded={2'b0,prior_line,2'b0};prior_nearby=prior_padded>>($signed(previous)+5);
   walk=0;walk[4]=|nearby;
   if(nearby[2])walk[3:0]=previous;
   else if(nearby[1])walk[3:0]=previous-4'sd1;
   else if(nearby[3])walk[3:0]=previous+4'sd1;
   else if(nearby[0]&&prior_nearby[1])walk[3:0]=previous-4'sd2;
   else if(nearby[4]&&prior_nearby[3])walk[3:0]=previous+4'sd2;
   else walk[4]=0;
  end
 endfunction
 wire[4:0]whl=walk(trace_line(job_window,step,1'b1,1'b0),hl,prior_hl);
 wire[4:0]whr=walk(trace_line(job_window,step,1'b1,1'b1),hr,prior_hr);
 wire[4:0]wvl=walk(trace_line(job_window,step,1'b0,1'b0),vl,prior_vl);
 wire[4:0]wvr=walk(trace_line(job_window,step,1'b0,1'b1),vr,prior_vr);
 wire signed[3:0]nhl=whl[3:0],nhr=whr[3:0],nvl=wvl[3:0],nvr=wvr[3:0];
 wire signed[6:0]next_h=sum_h+{{3{nhl[3]}},nhl}+{{3{nhr[3]}},nhr};
 wire signed[6:0]next_v=sum_v+{{3{nvl[3]}},nvl}+{{3{nvr[3]}},nvr};
 wire signed[4:0]delta_h={nhr[3],nhr}-{nhl[3],nhl},delta_v={nvr[3],nvr}-{nvl[3],nvl};
 function automatic signed[7:0]weighted(input signed[4:0]delta,input[1:0]phase);
  reg signed[7:0]v;begin v={{3{delta[4]}},delta};
   case(phase)0:weighted=v;1:weighted=v<<<1;2:weighted=(v<<<1)+v;default:weighted=v<<<2;endcase
  end
 endfunction
 wire signed[7:0]next_wh=weight_h+weighted(delta_h,step),next_wv=weight_v+weighted(delta_v,step);
 wire signed[6:0]residual_h=next_h-(origin_h[1]?-7'sd9:origin_h[0]?7'sd9:7'sd0);
 wire signed[6:0]residual_v=next_v-(origin_v[1]?-7'sd9:origin_v[0]?7'sd9:7'sd0);
 wire good_h=valid_h&&whl[4]&&whr[4]&&residual_h>=-9&&residual_h<=9;
 wire good_v=valid_v&&wvl[4]&&wvr[4]&&residual_v>=-9&&residual_v<=9;
 wire[7:0]abs_h=next_wh<0?-next_wh:next_wh,abs_v=next_wv<0?-next_wv:next_wv;
 wire choose_h=good_h&&(!good_v||abs_h<=abs_v);
 wire signed[6:0]short_residual_h=next_h-(origin_h[1]?-7'sd5:origin_h[0]?7'sd5:7'sd0);
 wire signed[6:0]short_residual_v=next_v-(origin_v[1]?-7'sd5:origin_v[0]?7'sd5:7'sd0);
 wire short_h=valid_h&&whl[4]&&whr[4]&&short_residual_h>=-5&&short_residual_h<=5&&abs_h<=18;
 wire short_v=valid_v&&wvl[4]&&wvr[4]&&short_residual_v>=-5&&short_residual_v<=5&&abs_v<=18;
 wire short_choose_h=short_h&&(!short_v||abs_h<=abs_v);
 reg short_valid=0,short_horizontal=0;reg signed[6:0]short_sum=0;reg signed[7:0]short_weight=0;
 reg result_valid=0,result_horizontal=0,done=0;reg[CW-1:0]result_x=0;
 reg result_short=0;reg signed[6:0]result_sum=0;reg signed[7:0]result_weight=0;
 always @(posedge clk)begin
  done<=0;
  if(busy)begin
   hl<=nhl;hr<=nhr;vl<=nvl;vr<=nvr;
   prior_hl<=trace_line(job_window,step,1'b1,1'b0);prior_hr<=trace_line(job_window,step,1'b1,1'b1);
   prior_vl<=trace_line(job_window,step,1'b0,1'b0);prior_vr<=trace_line(job_window,step,1'b0,1'b1);
   valid_h<=valid_h&&whl[4]&&whr[4];valid_v<=valid_v&&wvl[4]&&wvr[4];
   sum_h<=next_h;sum_v<=next_v;weight_h<=next_wh;weight_v<=next_wv;step<=step+1'b1;
   if(step==1)begin
    short_valid<=short_h||short_v;short_horizontal<=short_choose_h;
    short_sum<=short_choose_h?next_h:next_v;short_weight<=short_choose_h?next_wh:next_wv;
   end
   if(step==3)begin
    busy<=0;done<=1;result_x<=job_x;result_valid<=good_h||good_v||short_valid;
    result_short<=!(good_h||good_v);result_horizontal<=(good_h||good_v)?choose_h:short_horizontal;
    result_sum<=(good_h||good_v)?(choose_h?next_h:next_v):short_sum;
    result_weight<=(good_h||good_v)?(choose_h?next_wh:next_wv):short_weight;
   end
  end
  if(window_valid)begin
   job_window<=window;job_x<=window_x-5;busy<=1;step<=0;
   origin_h<=h_origin;origin_v<=v_origin;
   hl<=h_origin;hr<=h_origin;vl<=v_origin;vr<=v_origin;
   // A two-cell turn must pass through an accepted intermediate node.
   for(integer k=0;k<11;k=k+1)begin
    prior_hl[k]<=window[120-k*11-5];prior_hr[k]<=window[120-k*11-5];
    prior_vl[k]<=window[120-5*11-k];prior_vr[k]<=window[120-5*11-k];
   end
   valid_h<=h_candidate;valid_v<=v_candidate;
   sum_h<=h_origin;sum_v<=v_origin;weight_h<=0;weight_v<=0;
   short_valid<=0;
  end
  if(!rst_n)begin busy<=0;done<=0;end
 end
 // Keep the center offset outside the DSP: wide ABC cascade bias loses its sign on hardware.
 wire signed[6:0]center_factor=result_short?7'sd51:7'sd57;
 wire signed[5:0]slope_factor=result_short?6'sd13:6'sd17;
 (* syn_use_dsp="yes" *)wire signed[13:0]center_product=($signed(result_sum)*center_factor)+(result_short?14'sd2:14'sd4);
 (* syn_use_dsp="yes" *)wire signed[13:0]slope_product=($signed(result_weight)*slope_factor)+(result_short?14'sd4:14'sd32);
 wire signed[13:0]fit_center=result_short?(center_product>>>2):(center_product>>>3);
 wire signed[13:0]fit_slope=result_short?(slope_product>>>3):(slope_product>>>6);
 reg signed[9:0]center_q=0;reg signed[5:0]slope=0;
 reg write_pending=0,write_valid=0,write_horizontal=0;reg[CW-1:0]write_x=0;
 always @(posedge clk)begin
  center_q<=10'sd32+fit_center[9:0];
  slope<=fit_slope[5:0];
  write_pending<=done;write_x<=result_x;write_valid<=result_valid;write_horizontal<=result_horizontal;
  if(!rst_n)write_pending<=0;
 end
 wire signed[9:0]slope_wide={{4{slope[5]}},slope};
 wire signed[9:0]start=center_q-(slope_wide<<<1);
 reg[17:0]rows[0:W-1],row_q=0,active=0;
 wire[CW-1:0]cache_x=!de?0:(x[1:0]==3?x[10:2]+1'b1:x[10:2]);
 always @(posedge clk)begin
  if(write_pending)rows[write_x]<={write_valid,write_horizontal,start,slope};
  if(cache_x<W)row_q<=rows[cache_x];
  if(de&&x[1:0]==0)active<=row_q;
  if(!rst_n)begin row_q<=0;active<=0;end
 end
 // shortcut: very short endpoints and real junctions retain the local curve.
 assign enable=active[17]&&tx>=2&&tx<W-2&&ty>=2&&ty<H-2;
 wire[1:0]major=active[16]?ux:uy,minor=active[16]?uy:ux;
 wire signed[9:0]line_start=active[15:6];
 wire signed[9:0]line_slope={{4{active[5]}},active[5:0]};
 reg signed[9:0]position;
 always @*case(major)
  0:position=line_start;1:position=line_start+line_slope;
  2:position=line_start+(line_slope<<<1);default:position=line_start+(line_slope<<<1)+line_slope;
 endcase
 wire signed[10:0]error=$signed({5'b0,minor,4'b0})-$signed(position);
 wire[10:0]absolute_error=error<0?-error:error;
 // Average two within-pixel samples instead of point-sampling the fitted line.
 wire[5:0]slope_magnitude=active[5]?-active[5:0]:active[5:0];
 wire[3:0]sample_offset=slope_magnitude[5:2];
 wire[4:0]outer_limit=5'd16+sample_offset,inner_limit=5'd16-sample_offset;
 wire[4:0]ramp=outer_limit-absolute_error[4:0];
 wire[3:0]core_distance=absolute_error<sample_offset?sample_offset:absolute_error[3:0];
 assign coverage=absolute_error>=outer_limit?8'd0:
                 absolute_error>inner_limit?{ramp,3'b0}-8'd1:8'd255-{core_distance,4'b0};
endmodule
