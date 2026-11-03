// function0: signed INT8 dot4. function1: signed32 product high32 (shift32).
module vision_int8_cfu(input clk,rst_n,cmd_valid,output cmd_ready,
 input[9:0]function_id,input[31:0]a,b,
 output reg rsp_valid=0,input rsp_ready,output reg[31:0]result=0);
 wire signed[15:0]p0=$signed(a[7:0])*$signed(b[7:0]);
 wire signed[15:0]p1=$signed(a[15:8])*$signed(b[15:8]);
 wire signed[15:0]p2=$signed(a[23:16])*$signed(b[23:16]);
 wire signed[15:0]p3=$signed(a[31:24])*$signed(b[31:24]);
 wire signed[17:0]dot={{2{p0[15]}},p0}+{{2{p1[15]}},p1}+{{2{p2[15]}},p2}+{{2{p3[15]}},p3};
 wire signed[63:0]wide_product=$signed(a)*$signed(b);
 assign cmd_ready=(function_id==0||function_id==1)&&(!rsp_valid||rsp_ready);
 always @(posedge clk)begin
  if(!rst_n)begin rsp_valid<=0;result<=0;end
  else if(cmd_valid&&cmd_ready)begin result<=function_id==0?{{14{dot[17]}},dot}:wide_product[63:32];rsp_valid<=1;end
  else if(rsp_ready)rsp_valid<=0;
 end
endmodule
