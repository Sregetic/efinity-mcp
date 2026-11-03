`timescale 1ns/1ps
module tb_flyhash_encoder;
 reg clk=0,rst_n=0,job_valid=0,feature_valid=0;always #5 clk=~clk;
 reg[31:0]frame_id=0,config_id=0;reg[7:0]feature_data=0;
 wire job_ready,feature_ready,done,busy;wire[255:0]hash;
 wire[31:0]result_frame_id,result_config_id,cycles;
 reg[1:0]feature_quarter=0;wire[127:0]feature_probe;integer q,k;
 reg[7:0]vectors[0:2047];reg[255:0]expected[0:31];integer n,i,last_cycles;
 flyhash_encoder #(.PROJECTION_FILE("models/flyhash_projection.mem"))dut(.*);
 initial begin
  $readmemh("results/flyhash_20261004/features.mem",vectors);
  $readmemh("results/flyhash_20261004/expected.mem",expected);
  repeat(4)@(negedge clk);rst_n=1;
  for(n=0;n<32;n=n+1)begin
   @(negedge clk);frame_id=n+1;config_id=2210+n;job_valid=1;
   @(negedge clk);job_valid=0;frame_id=9999;config_id=9999;
   for(i=0;i<64;i=i+1)begin
    if(!feature_ready)$fatal(1,"feature input not ready");
    feature_valid=1;feature_data=vectors[n*64+i];@(negedge clk);
    if(i%7==0)begin feature_valid=0;@(negedge clk);end
   end
   feature_valid=0;wait(done);#1;
   if(hash!==expected[n]||result_frame_id!=n+1||result_config_id!=2210+n||busy)$fatal(1,"FlyHash vector%0d got%h expected%h",n,hash,expected[n]);
   last_cycles=cycles;
   for(q=0;q<4;q=q+1)begin
    feature_quarter=q;#1;
    for(k=0;k<16;k=k+1)if(feature_probe[k*8+:8]!==vectors[n*64+q*16+k])$fatal(1,"feature debug bank/order");
   end
   if(cycles>5200)$fatal(1,"encoder cycle budget");
  end
  @(negedge clk);rst_n=0;@(negedge clk);if(hash!=0||done)$fatal(1,"stale reset");
  $display("PASS tb_flyhash_encoder 32 vectors, 13 winners, ties, metadata lock, reset; cycles=%0d",last_cycles);$finish;
 end
 initial begin #3000000;$fatal(1,"FlyHash watchdog");end
endmodule
