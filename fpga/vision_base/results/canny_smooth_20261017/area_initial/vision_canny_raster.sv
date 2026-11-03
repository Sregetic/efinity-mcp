// Reconstruct the accepted Canny graph on its 4x HDMI grid. Each coarse edge
// is a node; segments join only existing 8-connected neighbors. No live RGB
// is mixed with the retained Canny frame. Detection remains W x H.
module vision_canny_raster #(parameter W=480,H=270,CW=9,
 parameter COVERAGE_FILE="./rtl/vision/canny_coverage_q5.mem")(
 input clk,rst_n,vblank,de,input[11:0]x,y,input bitmap,ready,
 output[CW-1:0]fetch_x,fetch_y,output pixel,
 output reg[31:0]coarse_edges,display_edges,output[7:0]coverage
);
 wire[CW:0]rx={1'b0,x[10:2]}+2,ry={1'b0,y[10:2]}+1;
 wire fit_slot=de&&x[1:0]==1&&y[1:0]==0;
 wire[CW:0]fit_rx={1'b0,x[10:2]}+8,fit_ry={1'b0,y[10:2]}+5;
 assign fetch_x=fit_slot?fit_rx[CW-1:0]:rx[CW-1:0];
 assign fetch_y=fit_slot?fit_ry[CW-1:0]:ry[CW-1:0];
 reg rq=0,vq=0;reg[CW-1:0]qx=0,qy=0;
 reg fit_rq=0;reg[CW-1:0]fit_qx=0;
 reg[1:0]ux=0,uy=0;reg[CW-1:0]tx=0,ty=0;
 always @(posedge clk)begin
  rq<=de&&x[1:0]==0&&y[1:0]==0&&rx<W&&ry<H;
  fit_rq<=fit_slot&&fit_rx<W&&fit_ry<H;fit_qx<=fit_rx[CW-1:0];
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
 reg[79:0]coverage_rom[0:511],coverage_word;
 initial $readmemh(COVERAGE_FILE,coverage_rom);
 wire[8:0]next_tile=de&&x[1:0]==0?(y[1:0]==0?fresh:row_q):tile;
 always @(posedge clk)coverage_word<=coverage_rom[next_tile];
 wire[4:0]curve_level=coverage_word[5*{uy,ux}+:5];
 wire fit_enable;wire[7:0]fit_coverage;
 vision_canny_line_fit #(.W(W),.H(H),.CW(CW)) line_fit(
  .clk(clk),.rst_n(rst_n),.valid(fit_rq),.ix(fit_qx),.bitmap(bitmap),
  .de(de),.x(x),.ux(ux),.uy(uy),.tx(tx),.ty(ty),.enable(fit_enable),.coverage(fit_coverage));
 assign coverage=!in_canvas?8'd0:fit_enable?fit_coverage:{curve_level,curve_level[4:2]};
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

// Nine connected samples per major axis; four clocks share the tracing logic.
module vision_canny_line_fit #(parameter W=480,H=270,CW=9)(
 input clk,rst_n,valid,input[CW-1:0]ix,input bitmap,
 input de,input[11:0]x,input[1:0]ux,uy,input[CW-1:0]tx,ty,
 output enable,output[7:0]coverage);
 reg[9:0]columns[0:W-1],column_q;
 reg d=0;reg[CW-1:0]xx=0;reg bit_q=0;
 wire[10:0]vertical={column_q,bit_q};
 reg[10:0]left_columns[0:9];reg[120:0]window;
 reg window_valid=0;reg[CW-1:0]window_x=0;
 integer r,c,j;
 always @(posedge clk)begin
  if(valid)begin column_q<=columns[ix];xx<=ix;bit_q<=bitmap;end
  d<=valid;window_valid<=d;
  if(d)begin
   columns[xx]<={column_q[8:0],bit_q};window_x<=xx;
   for(j=9;j>0;j=j-1)left_columns[j]<=left_columns[j-1];
   left_columns[0]<=vertical;
   for(r=0;r<11;r=r+1)for(c=0;c<11;c=c+1)
    window[120-r*11-c]<=c==10?vertical[10-r]:left_columns[9-c][10-r];
  end
  if(!rst_n)begin d<=0;window_valid<=0;end
 end
 wire nw=window[72],n=window[71],ne=window[70],w=window[61];
 wire center=window[60],e=window[59],sw=window[50],s=window[49],se=window[48];
 wire junction=center&&((n&&s&&((w&&!(nw&&sw))||(e&&!(ne&&se))))||
                        (w&&e&&((n&&!(nw&&ne))||(s&&!(sw&&se)))));
 wire h_candidate=!junction&&(center||n||s);
 wire v_candidate=!junction&&(center||w||e);
 wire signed[1:0]h_origin=center?2'sd0:n?-2'sd1:2'sd1;
 wire signed[1:0]v_origin=center?2'sd0:w?-2'sd1:2'sd1;
 reg[120:0]job_window;reg busy=0;reg[1:0]step=0;
 reg[CW-1:0]job_x=0;
 reg signed[3:0]hl=0,hr=0,vl=0,vr=0;
 reg signed[1:0]origin_h=0,origin_v=0;
 reg valid_h=0,valid_v=0;
 reg signed[6:0]sum_h=0,sum_v=0;
 reg signed[7:0]weight_h=0,weight_v=0;
 function automatic[4:0]walk(input[120:0]map,input horizontal,
  input signed[3:0]major,previous);
  reg signed[4:0]minor;reg[3:0]row,col;reg[6:0]address;integer k;
  begin
   walk=0;
   for(k=2;k>=0;k=k-1)begin
    minor=$signed(previous)+(k==1?-5'sd1:k==2?5'sd1:5'sd0);
    row=(horizontal?minor:$signed(major))+5'sd5;
    col=(horizontal?$signed(major):minor)+5'sd5;
    address=7'd120-({3'b0,row}<<3)-({3'b0,row}<<1)-row-col;
    if(minor>=-5&&minor<=5&&map[address])walk={1'b1,minor[3:0]};
   end
  end
 endfunction
 wire signed[3:0]distance=$signed({2'b0,step})+4'sd1;
 wire[4:0]whl=walk(job_window,1'b1,-distance,hl),whr=walk(job_window,1'b1,distance,hr);
 wire[4:0]wvl=walk(job_window,1'b0,-distance,vl),wvr=walk(job_window,1'b0,distance,vr);
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
 wire good_h=valid_h&&whl[4]&&whr[4]&&residual_h>=-6&&residual_h<=6;
 wire good_v=valid_v&&wvl[4]&&wvr[4]&&residual_v>=-6&&residual_v<=6;
 wire[7:0]abs_h=next_wh<0?-next_wh:next_wh,abs_v=next_wv<0?-next_wv:next_wv;
 wire choose_h=good_h&&(!good_v||abs_h<=abs_v);
 reg result_valid=0,result_horizontal=0,done=0;reg[CW-1:0]result_x=0;
 reg signed[6:0]result_sum=0;reg signed[7:0]result_weight=0;
 always @(posedge clk)begin
  done<=0;
  if(busy)begin
   hl<=nhl;hr<=nhr;vl<=nvl;vr<=nvr;
   valid_h<=valid_h&&whl[4]&&whr[4];valid_v<=valid_v&&wvl[4]&&wvr[4];
   sum_h<=next_h;sum_v<=next_v;weight_h<=next_wh;weight_v<=next_wv;step<=step+1'b1;
   if(step==3)begin
    busy<=0;done<=1;result_x<=job_x;result_valid<=good_h||good_v;result_horizontal<=choose_h;
    result_sum<=choose_h?next_h:next_v;result_weight<=choose_h?next_wh:next_wv;
   end
  end
  if(window_valid)begin
   job_window<=window;job_x<=window_x-5;busy<=1;step<=0;
   origin_h<=h_origin;origin_v<=v_origin;
   hl<=h_origin;hr<=h_origin;vl<=v_origin;vr<=v_origin;
   valid_h<=h_candidate;valid_v<=v_candidate;
   sum_h<=h_origin;sum_v<=v_origin;weight_h<=0;weight_v<=0;
  end
  if(!rst_n)begin busy<=0;done<=0;end
 end
 wire signed[12:0]sum_wide={{6{result_sum[6]}},result_sum};
 wire signed[12:0]center_scaled=(sum_wide<<<6)-(sum_wide<<<3)+sum_wide+13'sd4;
 wire signed[11:0]weight_wide={{4{result_weight[7]}},result_weight};
 wire signed[11:0]slope_scaled=(weight_wide<<<4)+weight_wide+12'sd32;
 wire signed[5:0]slope=slope_scaled>>>6;
 wire signed[9:0]slope_wide={{4{slope[5]}},slope};
 wire signed[9:0]start=10'sd32+(center_scaled>>>3)-(slope_wide<<<1);
 reg[17:0]rows[0:W-1],row_q=0,active=0;
 wire[CW-1:0]cache_x=!de?0:(x[1:0]==3?x[10:2]+1'b1:x[10:2]);
 always @(posedge clk)begin
  if(done)rows[result_x]<={result_valid,result_horizontal,start,slope};
  if(cache_x<W)row_q<=rows[cache_x];
  if(de&&x[1:0]==0)active<=row_q;
  if(!rst_n)begin row_q<=0;active<=0;end
 end
 // shortcut: endpoints, junctions and the unprimed border retain the curve raster.
 assign enable=active[17]&&tx>=13&&tx<W-5&&ty>=10&&ty<H-5;
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
 assign coverage=absolute_error<16?8'd255-{absolute_error[3:0],4'b0}:8'd0;
endmodule
