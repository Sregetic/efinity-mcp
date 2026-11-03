`timescale 1ns/1ps
module tb;
localparam CASES=26912;
reg clk=0;always #5 clk=~clk;
reg[71:0]p=0;reg[63:0]m=0;
wire[7:0]median,old_median,narrow_median;
wire[63:0]om,old_meta;wire narrow_meta;
vision_median9 #(.META(64))dut(clk,p,m,median,om);
median9_sort_reference #(.META(64))reference0(clk,p,m,old_median,old_meta);
vision_median9 #(.META(1))narrow(clk,p,m[0],narrow_median,narrow_meta);
reg[7:0]expected[0:CASES+7],a[0:8],temp;
reg[63:0]expected_meta[0:CASES+7];
integer n=0,checked=0,i,j,k,pattern,palette,value,position,seed=261018;
reg[7:0]low,high;reg[71:0]window;
task drive(input[71:0]pixels);
 begin
  @(negedge clk);p=pixels;m={$urandom,32'(n)};
  for(j=0;j<9;j=j+1)a[j]=pixels[j*8+:8];
  for(j=0;j<9;j=j+1)for(k=j+1;k<9;k=k+1)
   if(a[j]>a[k])begin temp=a[j];a[j]=a[k];a[k]=temp;end
  expected[n]=a[4];expected_meta[n]=m;
  @(posedge clk);#1;
  if(median!==old_median||om!==old_meta||narrow_median!==old_median||narrow_meta!==old_meta[0])
   $fatal(1,"median baseline cycle mismatch n%0d got%h/%h old%h/%h",n,median,om,old_median,old_meta);
  if(n>=8&&n-8<CASES)begin
   if(median!==expected[n-8]||om!==expected_meta[n-8])
    $fatal(1,"median sorted reference/latency mismatch n%0d",n);
   checked=checked+1;
  end
  n=n+1;
 end
endtask
initial begin
 i=$urandom(seed);
 for(palette=0;palette<4;palette=palette+1)begin
  case(palette)
   0:begin low=0;high=1;end
   1:begin low=0;high=255;end
   2:begin low=127;high=128;end
   3:begin low=254;high=255;end
  endcase
  for(pattern=0;pattern<512;pattern=pattern+1)begin
   for(i=0;i<9;i=i+1)window[i*8+:8]=pattern[i]?high:low;
   drive(window);
  end
 end
 for(value=0;value<256;value=value+1)drive({9{8'(value)}});
 for(position=0;position<9;position=position+1)for(value=0;value<256;value=value+1)begin
  window=0;window[position*8+:8]=8'(value);drive(window);
  window={9{8'hff}};window[position*8+:8]=8'(value);drive(window);
 end
 for(pattern=0;pattern<20000;pattern=pattern+1)begin
  for(i=0;i<9;i=i+1)window[i*8+:8]=$urandom_range(0,255);
  drive(window);
 end
 if(n!=CASES)$fatal(1,"median stimulus count %0d",n);
 repeat(8)drive(72'd0);
 if(checked!=CASES)$fatal(1,"median checked count %0d",checked);
 $display("PASS MEDIAN9 %0d windows: 2048 binary/boundary, 256 uniform, 4608 impulses, 20000 random; exact old pipeline, sorted reference, META64/META1, nine stages",checked);
 $finish;
end
endmodule

// Pre-optimization pipeline is the cycle/initialization compatibility oracle.
module median9_sort_reference #(parameter META=64)(input clk,input[71:0]pixels,input[META-1:0]meta,
 output[7:0]median,output[META-1:0]out_meta);
wire[71:0]v[0:9];wire[META-1:0]m[0:9];assign v[0]=pixels;assign m[0]=meta;
genvar s,k;
generate for(s=0;s<9;s=s+1)begin:stage
 reg[71:0]r=0;reg[META-1:0]mr=0;assign v[s+1]=r;assign m[s+1]=mr;
 always @(posedge clk)mr<=m[s];
 for(k=0;k<9;k=k+1)begin:lane
  if((k%2)==(s%2) && k<8)begin
   always @(posedge clk)r[k*8+:8]<=(v[s][k*8+:8]<v[s][(k+1)*8+:8])?v[s][k*8+:8]:v[s][(k+1)*8+:8];
  end else if(k>0 && ((k-1)%2)==(s%2))begin
   always @(posedge clk)r[k*8+:8]<=(v[s][k*8+:8]>v[s][(k-1)*8+:8])?v[s][k*8+:8]:v[s][(k-1)*8+:8];
  end else always @(posedge clk)r[k*8+:8]<=v[s][k*8+:8];
 end
end endgenerate
assign median=v[9][4*8+:8];assign out_meta=m[9];
endmodule
