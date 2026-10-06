// Canny noise front end after4x4 area averaging: impulse median + frame noise floor.
// Constant-power-of-two scaling gives a conservative residual mean bound.
module vision_canny_denoise #(parameter W=480,H=270,CW=9,NEAR_DELTA=64)(
 input clk,rst_n,valid,input[CW-1:0]x,y,input[7:0]gray,input median_en,
 output oval,output[CW-1:0]ox,oy,output[7:0]pixel,
 output reg[7:0]noise_mean,output[10:0]noise_floor,output reg noise_valid,
 output reg frame_calibrated
);
 localparam SAMPLES=(W-2)*(H-2),SHIFT=$clog2(SAMPLES);
 wire wv;wire[CW-1:0]wx,wy;wire[71:0]window;
 vision_sparse_window #(.W(W),.CW(CW)) neighborhood(clk,rst_n,valid,x,y,gray,wv,wx,wy,window);
 // A supported thin line is structure, not an isolated impulse. Keep it when
 // its centre differs from the median, and exclude it from the noise estimate.
 function automatic near(input[7:0]a,b);begin near=(a>b?a-b:b-a)<=NEAR_DELTA;end endfunction
 wire[7:0]same={near(window[71:64],window[39:32]),near(window[63:56],window[39:32]),
  near(window[55:48],window[39:32]),near(window[47:40],window[39:32]),
  near(window[31:24],window[39:32]),near(window[23:16],window[39:32]),
  near(window[15:8],window[39:32]),near(window[7:0],window[39:32])};
 wire continuation=(same[7]&&same[0])||(same[6]&&same[1])||(same[5]&&same[2])||(same[4]&&same[3]);
 wire[7:0]median;wire[2*CW+16:0]meta;
 vision_median9 #(.META(2*CW+17)) filter(clk,window,{wx,wy,window[7:0],window[39:32],continuation},median,meta);
 reg[8:0]vp=0;
 always @(posedge clk)begin vp<={vp[7:0],wv};if(!rst_n)vp<=0;end
 assign oval=vp[8],ox=meta[2*CW+16:CW+17],oy=meta[CW+16:17];
 wire interior=ox>=2&&oy>=2;
 wire[7:0]difference=(meta[8:1]>median)?meta[8:1]-median:median-meta[8:1];
 wire keep_line=meta[0]&&difference>NEAR_DELTA;
 // Preserve ordinary weak gradients. Replace only an unsupported outlier;
 // unconditional median smoothed away real low-contrast board contours.
 wire replace_impulse=!meta[0]&&difference>NEAR_DELTA;
 assign pixel=median_en?(interior?(replace_impulse?median:meta[8:1]):8'd0):meta[16:9];
 wire[7:0]residual=keep_line?8'd0:difference;
 localparam SW=SHIFT+8;
 reg[SW-1:0]sum=0;reg measuring=0;
 wire[SW:0]total={1'b0,sum}+residual;
 wire[SW:0]rounded=(total<<1)+((1<<SHIFT)-1);
 wire[SW:0]mean_bound=rounded>>SHIFT;
 wire[11:0]floor_wide=12'd16+({4'b0,noise_mean}<<3);
 assign noise_floor=floor_wide>2047?11'd2047:floor_wide[10:0];
 always @(posedge clk)begin
  if(!rst_n)begin sum<=0;noise_mean<=0;noise_valid<=0;frame_calibrated<=0;measuring<=0;end
  else if(oval)begin
   if(ox==0&&oy==0)begin sum<=0;measuring<=1;frame_calibrated<=!median_en||noise_valid;end
   if(interior&&measuring)sum<=total[SW-1:0];
   if(ox==W-1&&oy==H-1&&measuring)begin
    noise_mean<=mean_bound>255?8'd255:mean_bound[7:0];noise_valid<=1;measuring<=0;
   end
  end
 end
endmodule
