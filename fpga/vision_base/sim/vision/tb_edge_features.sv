`timescale 1ns/1ps
module tb_edge_features #(parameter W=65,H=51,
 parameter WORD_FILE="results/project_light_20261005/features_65x51.words.mem",
 parameter GOLD_FILE="results/project_light_20261005/features_65x51.gold.mem");
 localparam WORDS=(W*H+31)/32;
 reg clk=0,rst_n=0,job_valid=0,word_ready=0,word_valid=0,feature_ready=0;
 always #5 clk=~clk;
 wire job_ready,busy,done,word_req,feature_valid;wire[11:0]word_address;wire[7:0]feature_data;
 reg[31:0]word_data=0,words[0:8*WORDS-1];reg[7:0]gold[0:511];
 vision_edge_features #(.W(W),.H(H))dut(.*);
 integer cycle=0,frame=0,received=0,requested=0,wait_cycles=0;
 reg pending=0;reg[11:0]address=0;reg stalled=0;reg[7:0]stalled_data=0;
 always @(negedge clk)begin
  cycle=cycle+1;word_ready=!pending&&cycle%5!=2;feature_ready=cycle%4!=1;word_valid=0;
  if(pending)begin
   if(wait_cycles==0)begin word_data=words[frame*WORDS+address];word_valid=1;pending=0;end
   else wait_cycles=wait_cycles-1;
  end
 end
 always @(posedge clk)if(rst_n)begin
  if(word_req&&word_ready)begin
   if(word_address!=requested)$fatal(1,"word order");
   address=word_address;requested=requested+1;pending=1;wait_cycles=cycle%13+1;
  end
  if(stalled&&(!feature_valid||feature_data!=stalled_data))$fatal(1,"unstable feature backpressure");
  stalled=feature_valid&&!feature_ready;stalled_data=feature_data;
  if(feature_valid&&feature_ready)begin
   if(feature_data!==gold[frame*64+received])$fatal(1,"feature mismatch frame%0d index%0d got%0d expected%0d",frame,received,feature_data,gold[frame*64+received]);
   received=received+1;
   if(done!=(received==64))$fatal(1,"done boundary");
  end
 end
 initial begin
  $readmemh(WORD_FILE,words);$readmemh(GOLD_FILE,gold);
  repeat(4)@(negedge clk);rst_n=1;
  for(frame=0;frame<8;frame=frame+1)begin
   @(negedge clk);received=0;requested=0;job_valid=1;
   @(negedge clk);job_valid=0;wait(!busy);#1;
   if(received!=64||requested!=WORDS)$fatal(1,"job extent");
  end
  $display("PASS edge features %0dx%0d 8 planes, exact64 occupancies, uneven tiles, padding, read latency, feature backpressure; cycles=%0d",W,H,cycle);$finish;
 end
 initial begin #100000000;$fatal(1,"feature watchdog");end
endmodule
