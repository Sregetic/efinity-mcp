// Default SC431HAI: VTS1500, half-line limit2950. Other sensors supply their
// register-unit range from the selected initialization profile.
// RAW8 metering on 2 pixels/clock, before black correction and white balance.
// Center-weighted, highlight-constrained, with 1/16 steps and 8 fresh-frame settling.
module camera_auto_exposure #(
 parameter CX0=224,CX1=736,CY0=288,CY1=800,parameter SAMPLE_BITS=4,SETTLE=8,
 parameter EXPOSURE_MIN=112,EXPOSURE_MAX=2950,EXPOSURE_INITIAL=444)(
 input clk,rst_n,vs,de,input[15:0]pixels,input[31:0]capture_id,
 input enable,input[15:0]manual_value,input ack_toggle,fault,
 output reg req_toggle,output reg[15:0]request,
 output reg[31:0]center_sum,output reg[15:0]center_count,total_count,clip_count,
 output reg[1:0]decision,output reg shadow_boost=0);
reg[11:0]x=0,y=0;reg vq=0,dq=0;reg[31:0]sum=0,last_capture=0;
reg[15:0]nc=0,nt=0,nh=0;reg[2:0]as=0,fs=0;reg[7:0]settle=SETTLE;
reg[1:0]evaluate=0;reg[3:0]limits=0;reg eval_total=0,eval_started=0,eval_ready=0,eval_enable=0;reg[15:0]eval_manual=0;
reg started=0;wire fresh=capture_id!=last_capture;
wire[8:0]pair_sum={1'b0,pixels[15:8]}+{1'b0,pixels[7:0]};
wire sample_point=(x[SAMPLE_BITS-1:0]==0)&&(y[SAMPLE_BITS-1:0]==0);
wire[15:0]step_size=(request>>4)<4?16'd4:(request>>4);
wire[16:0]up={1'b0,request}+step_size;
wire[15:0]down=(request>step_size+EXPOSURE_MIN)?request-step_size:EXPOSURE_MIN;
always @(posedge clk)begin
 // Snapshot at VS, register comparisons, then update the I2C request two clocks later.
 evaluate<={evaluate[0],1'b0};
 limits<={(center_sum<center_count*32'd52&&clip_count<(total_count>>3)),
          ((center_sum>center_count*32'd76)||((clip_count>(total_count>>2))&&(center_sum>center_count*32'd44))||(clip_count>(total_count>>1))),
          (center_sum>center_count*32'd60),(center_sum<center_count*32'd48)};
 vq<=vs;dq<=de;as<={as[1:0],ack_toggle};fs<={fs[1:0],fault};
 if(!rst_n)begin x<=0;y<=0;vq<=0;dq<=0;sum<=0;nc<=0;nt<=0;nh<=0;req_toggle<=0;request<=EXPOSURE_INITIAL;as<=0;fs<=0;started<=0;settle<=SETTLE;last_capture<=0;center_sum<=0;center_count<=0;total_count<=0;clip_count<=0;decision<=0;shadow_boost<=0;evaluate<=0;limits<=0;eval_total<=0;eval_started<=0;eval_ready<=0;eval_enable<=0;eval_manual<=0;end
 else begin
  if(de)x<=x+1'b1;else x<=0;
  if(vs&&!vq)begin
   y<=0;center_sum<=sum;center_count<=nc;total_count<=nt;clip_count<=nh;
   sum<=0;nc<=0;nt<=0;nh<=0;
   evaluate[0]<=fresh&&nc!=0&&!fs[2];eval_total<=nt!=0;eval_started<=started;
   eval_ready<=as[2]==req_toggle;eval_enable<=enable;eval_manual<=manual_value;
   if(!started)begin started<=1;req_toggle<=~req_toggle;end
   else if(fresh&&nt!=0&&nc!=0&&!fs[2])last_capture<=capture_id;
  end else begin
   if(dq&&!de)y<=y+1'b1;
   if(de&&sample_point)begin
    nt<=nt+1'b1;
    if(pixels[15:8]>=250||pixels[7:0]>=250)nh<=nh+1'b1;
    if(x>=CX0&&x<CX1&&y>=CY0&&y<CY1)begin sum<=sum+pair_sum[8:1];nc<=nc+1'b1;end
   end
  end
  if(evaluate[1])begin
   if(limits[0])shadow_boost<=1;else if(limits[1])shadow_boost<=0;
   if(eval_started&&eval_total)begin
    if(!eval_ready)settle<=SETTLE;
    else if(settle!=0)settle<=settle-1'b1;
    else begin
     settle<=SETTLE;decision<=0;
     if(!eval_enable)begin
      if(eval_manual>=EXPOSURE_MIN&&eval_manual<=EXPOSURE_MAX&&eval_manual!=request)begin request<=eval_manual;req_toggle<=~req_toggle;end
     end else if(limits[2])begin
      if(request>EXPOSURE_MIN)begin request<=down;req_toggle<=~req_toggle;decision<=2;end
     end else if(limits[3])begin
      if(request<EXPOSURE_MAX)begin request<=up>EXPOSURE_MAX?EXPOSURE_MAX:up[15:0];req_toggle<=~req_toggle;decision<=1;end
     end
    end
   end
  end
 end
end
endmodule
