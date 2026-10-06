`timescale 1ns/1ps
module tb_vision_flyhash_mailbox;
 reg clk=0,cpu_clk=0;always #3.367 clk=~clk;always #5 cpu_clk=~cpu_clk;
 reg rst_n=0,cpu_rst_n=0,cmd_event=0;reg[7:0]cmd_op=0;reg[23:0]cmd_value=0;
 reg context_valid=1;reg[31:0]frame_id=11,config_id=22,epoch=33,stream_errors=0;
 wire[255:0]hash;wire[31:0]status,result_frame_id,result_config_id,result_epoch,firmware_state,full_cycles;
 wire bitmap_req,bitmap_busy;reg bitmap_ready=1;wire[11:0]bitmap_address;
 reg bitmap_valid=0;reg[31:0]bitmap_data=0;reg[1:0]feature_quarter=0;wire[127:0]feature_probe;
 reg[15:0]paddr=0;reg psel=0,penable=0,pwrite=0;reg[31:0]pwdata=0;
 wire[31:0]prdata;wire pready,pslverror;
 vision_flyhash_mailbox dut(.*);
 integer delay_n=0;reg[11:0]saved_address=0;
 always @(posedge clk)begin
  bitmap_valid<=0;
  if(bitmap_req&&bitmap_ready)begin delay_n<=4;saved_address<=bitmap_address;end
  if(delay_n>0)begin delay_n<=delay_n-1;if(delay_n==1)begin bitmap_valid<=1;bitmap_data<=32'habcdef00|saved_address;end end
 end
 task command(input[7:0]op,input[23:0]value);begin
  @(negedge clk);cmd_event=1;cmd_op=op;cmd_value=value;
  @(negedge clk);cmd_event=0;repeat(10)@(negedge cpu_clk);
 end endtask
 task write_reg(input[15:0]addr,input[31:0]data);begin
  @(negedge cpu_clk);paddr=addr;pwdata=data;pwrite=1;psel=1;penable=0;
  @(negedge cpu_clk);penable=1;do @(posedge cpu_clk);while(!pready);
  @(negedge cpu_clk);psel=0;penable=0;pwrite=0;
 end endtask
 task read_reg(input[15:0]addr,output[31:0]data);begin
  @(negedge cpu_clk);paddr=addr;pwrite=0;psel=1;penable=0;
  @(negedge cpu_clk);penable=1;do @(posedge cpu_clk);while(!pready);
  data=prdata;@(negedge cpu_clk);psel=0;penable=0;
 end endtask
 task complete(input[15:0]token);integer j;begin
  write_reg(16'h2c,token);
  for(j=0;j<8;j++)write_reg(16'h40+4*j,32'h12340000+j);
  for(j=0;j<16;j++)write_reg(16'hc0+4*j,{8'(4*j+3),8'(4*j+2),8'(4*j+1),8'(4*j)});
  write_reg(16'h24,25000);write_reg(16'h28,token);repeat(10)@(negedge clk);
 end endtask
 reg[31:0]v,tick0;reg[15:0]token,old_token;integer i;
 initial begin
  repeat(5)@(negedge cpu_clk);rst_n=1;cpu_rst_n=1;
  read_reg(16'h30,tick0);repeat(11)@(negedge cpu_clk);read_reg(16'h30,v);
  if(v-tick0!=14)$fatal(1,"APB timer is not native CPU clock cycles");
  command(8'h50,0);if(!status[28]||status[30])$fatal(1,"start before boot accepted");
  write_reg(4,1);repeat(10)@(negedge clk);
  command(8'h50,0);
  if(!status[30]||!status[29]||status[28])$fatal(1,"host start");
  for(i=0;i<64;i++)command(8'h51,(i<<8)|i);
  read_reg(8,v);token=v[15:0];if(v[22:16]!=64||!v[31]||v[30])$fatal(1,"host CPU job snapshot");
  for(i=0;i<16;i++)begin
   read_reg(16'h80+4*i,v);if(v!=={8'(4*i+3),8'(4*i+2),8'(4*i+1),8'(4*i)})$fatal(1,"host feature CDC");
  end
  complete(token-1);if(status[31])$fatal(1,"stale result published");
  complete(token);
  if(!status[31]||status[30]||status[28]||status[26:20]!=64||full_cycles!=25000||result_frame_id!=11||result_config_id!=22||result_epoch!=33)$fatal(1,"result binding/status");
  if(hash[31:0]!=32'h12340000||hash[255:224]!=32'h12340007||feature_probe[31:0]!=32'h03020100)$fatal(1,"result payload");
  command(8'h54,0);read_reg(8,v);token=v;old_token=token;
  if(!v[30]||!bitmap_busy)$fatal(1,"auto start");
  write_reg(16'h1c,123);read_reg(16'h20,v);if(v!=32'habcdef7b)$fatal(1,"bitmap handshake");
  epoch=34;repeat(12)@(negedge clk);
  if(status[30]||status[31]||!status[28])$fatal(1,"changed frame context not cancelled");
  complete(old_token);if(status[31])$fatal(1,"cancelled result published");
  command(8'h54,0);read_reg(8,v);token=v;
  bitmap_ready=0;write_reg(16'h1c,40);command(8'h52,0);read_reg(16'h20,v);
  if(v!=0||status[30])$fatal(1,"aborted bitmap read left blocked");bitmap_ready=1;
  command(8'h50,0);command(8'h51,16'h100);if(!status[28]||status[30])$fatal(1,"wrong feature index accepted");
  // A cancelled CPU job may still finish its APB stores after a new host job starts.
  command(8'h54,0);read_reg(8,v);old_token=v;command(8'h52,0);command(8'h50,0);
  for(i=0;i<4;i++)command(8'h51,(i<<8)|i);
  write_reg(16'h2c,old_token);write_reg(16'hc0,32'hffffffff);
  read_reg(16'h80,v);if(v!=32'h03020100)$fatal(1,"cancelled CPU write overwrote new host features");
  command(8'h52,0);
  command(8'h54,0);cpu_rst_n=0;repeat(12)@(negedge clk);
  if(status[30]||status[31]||status[27])$fatal(1,"CPU reset left accepted task");
  $display("PASS FlyHash mailbox async host features / bitmap backpressure / full32 cycles / nonce / context / CPU reset");$finish;
 end
 initial begin #200000;$fatal(1,"mailbox watchdog");end
endmodule
