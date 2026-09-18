// Single-owner runtime I2C exposure writes, followed by three-byte readback.
// Request bus is held until ack_toggle returns. Fault latches until reset.
module sensor_exposure_writer #(parameter TIMEOUT=1000000)(
 input clk,rst_n,configured,input req_toggle,input[15:0]req_value,
 input wr_done,rd_done,input[7:0]read_data,
 output reg wr_en,rd_en,output reg[15:0]addr,output reg[7:0]data,
 output reg ack_toggle,fault,busy,output reg[15:0]applied,
 output reg[23:0]readback,output reg[15:0]updates=0);
reg[2:0]rs=0;reg[3:0]state=0;reg[1:0]idx=0;
reg[15:0]held=444;reg[23:0]timer=0;reg pending_toggle=0;
wire[23:0]encoded={4'b0,held,4'b0};
function automatic[7:0]byte_at(input[23:0]v,input[1:0]i);
 begin case(i)0:byte_at=v[23:16];1:byte_at=v[15:8];default:byte_at=v[7:0];endcase end
endfunction
always @(posedge clk)begin
 rs<={rs[1:0],req_toggle};wr_en<=0;rd_en<=0;
 if(!rst_n)begin rs<=0;state<=0;idx<=0;ack_toggle<=0;fault<=0;busy<=0;applied<=444;readback<=0;timer<=0;updates<=0;end
 else if(!fault)begin
  if(busy)timer<=timer+1'b1;else timer<=0;
  if(busy&&timer>=TIMEOUT)begin fault<=1;busy<=0;state<=0;end
  else case(state)
   0:if(configured&&rs[2]!=ack_toggle)begin
      held<=req_value;pending_toggle<=rs[2];idx<=0;busy<=1;state<=1;
      if(req_value<112||req_value>1776)begin fault<=1;busy<=0;state<=0;end
     end
   1:begin addr<=16'h3e00+idx;data<=byte_at(encoded,idx);state<=2;end
   2:begin wr_en<=1;state<=3;end
   3:if(wr_done)begin if(idx==2)begin idx<=0;state<=4;end else begin idx<=idx+1'b1;state<=1;end end
   4:begin addr<=16'h3e00+idx;state<=5;end
   5:begin rd_en<=1;state<=6;end
   6:if(rd_done)begin
      case(idx)0:readback[23:16]<=read_data;1:readback[15:8]<=read_data;2:readback[7:0]<=read_data;endcase
      if(read_data!=byte_at(encoded,idx))begin fault<=1;busy<=0;state<=0;end
      else if(idx==2)begin applied<=held;ack_toggle<=pending_toggle;updates<=updates+1'b1;busy<=0;state<=0;end
      else begin idx<=idx+1'b1;state<=4;end
     end
   default:state<=0;
  endcase
 end
end
endmodule
