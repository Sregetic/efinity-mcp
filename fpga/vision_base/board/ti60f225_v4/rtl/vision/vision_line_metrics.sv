// Timestamp actual camera and direct-branch transactions in their common clock.
// Semantic latency compares center(x-2,y-2), not just delayed VS/control wires.
module vision_line_metrics #(parameter MEASURE_DISPLAY=1)(input clk,rst_n,input input_de,input_vs,input[31:0]input_frame,
 input output_de,output_vs,input[11:0]output_x,output_y,input[15:0]gray,input[1:0]edges,
 input display_de,display_vs,display_live,input[31:0]display_source_frame,
 output reg[31:0]completed_frame,last_pixels,last_edges,pipeline_cycles,semantic_min,semantic_max,
 output reg[31:0]last_gray_sum,display_min,display_max,display_samples,display_unmatched);
 reg[31:0]tick=0,vs_tick=0,input_frame_q=0,output_frame_q=0,pixels=0,edge_count=0,gray_sum=0;
 reg[31:0]row_tick[0:3];reg[11:0]input_x=0,input_y=0;
 reg[31:0]frame_tick[0:7],frame_tag[0:7];reg display_vq=0,display_first=1;
 reg dq=0,vq=0,ovq=0,started=0;
 wire[31:0]semantic=tick-row_tick[(output_y-12'd2)&3];
 wire[31:0]display_latency=tick-frame_tick[display_source_frame[2:0]];
 integer i;
 always @(posedge clk)begin
  tick<=tick+1'b1;dq<=input_de;vq<=input_vs;ovq<=output_vs;display_vq<=display_vs;
  if(!rst_n)begin
   tick<=0;vs_tick<=0;input_frame_q<=0;output_frame_q<=0;input_x<=0;input_y<=0;dq<=0;vq<=0;ovq<=0;started<=0;
   pixels<=0;edge_count<=0;gray_sum<=0;completed_frame<=0;last_pixels<=0;last_edges<=0;last_gray_sum<=0;pipeline_cycles<=0;semantic_min<=32'hffffffff;semantic_max<=0;
   for(i=0;i<4;i=i+1)row_tick[i]<=0;
   for(i=0;i<8;i=i+1)begin frame_tick[i]<=0;frame_tag[i]<=0;end
   display_vq<=0;display_first<=1;display_min<=32'hffffffff;display_max<=0;display_samples<=0;display_unmatched<=0;
  end else begin
   if(input_vs&&!vq)begin input_y<=0;input_frame_q<=input_frame;vs_tick<=tick;frame_tick[input_frame[2:0]]<=tick;frame_tag[input_frame[2:0]]<=input_frame;end
   else if(dq&&!input_de)input_y<=input_y+1'b1;
   if(input_de)begin
    input_x<=input_x+12'd2;
    if(input_x==2)row_tick[input_y[1:0]]<=tick;
   end else input_x<=0;
   if(output_vs&&!ovq)begin
    pipeline_cycles<=tick-vs_tick;output_frame_q<=input_frame_q;started<=1;
    if(started)begin completed_frame<=output_frame_q;last_pixels<=pixels;last_edges<=edge_count;last_gray_sum<=gray_sum;end
    pixels<=0;edge_count<=0;gray_sum<=0;
   end else if(output_de)begin
    pixels<=pixels+32'd2;edge_count<=edge_count+{31'd0,edges[0]}+{31'd0,edges[1]};
    gray_sum<=gray_sum+{24'd0,gray[7:0]}+{24'd0,gray[15:8]};
    if(output_x==4&&output_y>=4)begin
     if(semantic<semantic_min)semantic_min<=semantic;
     if(semantic>semantic_max)semantic_max<=semantic;
    end
   end
   if(display_vs&&!display_vq)display_first<=1;
   if(display_de&&display_first)begin
    display_first<=0;
    if(MEASURE_DISPLAY&&display_live)begin
     if(frame_tag[display_source_frame[2:0]]==display_source_frame&&display_source_frame!=0)begin
      display_samples<=display_samples+1'b1;
      if(display_latency<display_min)display_min<=display_latency;
      if(display_latency>display_max)display_max<=display_latency;
     end else display_unmatched<=display_unmatched+1'b1;
    end
   end
  end
 end
endmodule
