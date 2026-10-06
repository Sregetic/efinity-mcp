`timescale 1ns/1ps
// Initial integer FlyHash encoder: 64 uint8 -> 256 KC x6 connections -> top13.
// Serial ROM/feature reads, no multiplier/divider, one job at a time.
module flyhash_encoder #(parameter PROJECTION_FILE="../models/flyhash_projection.mem")(
 input clk,rst_n,job_valid,output job_ready,input[31:0]frame_id,config_id,
 input feature_valid,output feature_ready,input[7:0]feature_data,
 output reg done,output busy,output reg[255:0]hash,
 output reg[31:0]result_frame_id,result_config_id,cycles,
 input[1:0]feature_quarter,output[127:0]feature_probe
);
 localparam IDLE=0,LOAD=1,INDEX=2,FEATURE=3,ADD=4,INSERT=5,EMIT=6;
 reg[2:0]state=IDLE;
 //64 bytes need parallel debug access; FF storage releases the previous BRAM.
 (* syn_ramstyle="registers" *)reg[7:0]features[0:63];reg[5:0]projection[0:1535];
 genvar p;generate for(p=0;p<16;p=p+1)begin:feature_debug
  assign feature_probe[p*8+:8]=features[{feature_quarter,4'(p)}];
 end endgenerate
 initial $readmemh(PROJECTION_FILE,projection);
 reg[5:0]load_index=0,projection_index=0;reg[7:0]fdata=0,neuron=0;
 reg[2:0]fan=0;reg[10:0]acc=0,score=0;
 reg[10:0]best_score[0:12];reg[7:0]best_id[0:12];reg[3:0]count=0,emit_index=0;
 reg[255:0]mask=0;reg[31:0]fid=0,cid=0,elapsed=0;
 wire[10:0]projection_addr=(11'(neuron)<<2)+(11'(neuron)<<1)+fan;
 always @(posedge clk)projection_index<=projection[projection_addr];
 always @(posedge clk)fdata<=features[projection_index];
 reg[3:0]position;integer i,j;
 always_comb begin
  position=13;
  for(i=0;i<13;i=i+1)if(position==13&&(i>=count||score>best_score[i]))position=4'(i);
 end
 assign job_ready=state==IDLE,feature_ready=state==LOAD,busy=state!=IDLE;
 always @(posedge clk)begin
  done<=0;
  if(!rst_n)begin
   state<=IDLE;done<=0;hash<=0;result_frame_id<=0;result_config_id<=0;cycles<=0;
   load_index<=0;neuron<=0;fan<=0;acc<=0;score<=0;count<=0;emit_index<=0;mask<=0;fid<=0;cid<=0;elapsed<=0;
  end else begin
   // Count computation only, not host/producer gaps while loading features.
   if(state>=INDEX)elapsed<=elapsed+1'b1;
   case(state)
    IDLE:if(job_valid)begin fid<=frame_id;cid<=config_id;load_index<=0;elapsed<=0;state<=LOAD;count<=0;mask<=0;end
    LOAD:if(feature_valid)begin
     features[load_index]<=feature_data;
     if(load_index==63)begin state<=INDEX;neuron<=0;fan<=0;acc<=0;end
     else load_index<=load_index+1'b1;
    end
    INDEX:state<=FEATURE;
    FEATURE:state<=ADD;
    ADD:begin
     if(fan==5)begin score<=acc+fdata;state<=INSERT;end
     else begin acc<=acc+fdata;fan<=fan+1'b1;state<=INDEX;end
    end
    INSERT:begin
     for(j=12;j>0;j=j-1)if(j>position)begin best_score[j]<=best_score[j-1];best_id[j]<=best_id[j-1];end
     if(position<13)begin best_score[position]<=score;best_id[position]<=neuron;end
     if(count<13)count<=count+1'b1;
     if(neuron==255)begin emit_index<=0;state<=EMIT;end
     else begin neuron<=neuron+1'b1;fan<=0;acc<=0;state<=INDEX;end
    end
    EMIT:begin
     mask[best_id[emit_index]]<=1;
     if(emit_index==12)begin
      hash<=mask|(256'b1<<best_id[emit_index]);result_frame_id<=fid;result_config_id<=cid;
      cycles<=elapsed+1'b1;done<=1;state<=IDLE;
     end else emit_index<=emit_index+1'b1;
    end
   endcase
  end
 end
endmodule
