// Hardware key synchronizer/debounce/long-press detector, shared by both builds.
module vision_keys #(parameter DEBOUNCE=2970000,LONG_PRESS=148500000)(
 input clk,rst_n,input[2:0]keys_n,output reg[2:0]short_p,long_p
);
 localparam DW=$clog2(DEBOUNCE),HW=$clog2(LONG_PRESS);
 reg[2:0]sync0=7,sync1=7,stable=7,long_sent=0;
 reg[DW-1:0]db[0:2];reg[HW-1:0]held[0:2];integer i;
 always @(posedge clk)begin
  sync0<=keys_n;sync1<=sync0;short_p<=0;long_p<=0;
  if(!rst_n)begin
   sync0<=7;sync1<=7;stable<=7;long_sent<=0;
   for(i=0;i<3;i=i+1)begin db[i]<=0;held[i]<=0;end
  end else for(i=0;i<3;i=i+1)begin
   if(sync1[i]==stable[i])db[i]<=0;
   else if(db[i]==DEBOUNCE-1)begin
    db[i]<=0;stable[i]<=sync1[i];
    if(sync1[i])begin if(!long_sent[i])short_p[i]<=1;held[i]<=0;long_sent[i]<=0;end
   end else db[i]<=db[i]+1'b1;
   if(!stable[i]&&!long_sent[i]&&!sync1[i])begin
    if(held[i]==LONG_PRESS-1)begin long_p[i]<=1;long_sent[i]<=1;end else held[i]<=held[i]+1'b1;
   end
  end
 end
endmodule
