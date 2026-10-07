// Shared decoder for the source pool's range flag plus RGB555 payload.
module vision_packed_rgb(input[15:0]pixel,output[23:0]rgb);
 assign rgb=pixel[15]?{pixel[14:10],pixel[14:12],pixel[9:5],pixel[9:7],pixel[4:0],pixel[4:2]}:
  {2'b0,pixel[14:10],1'b0,2'b0,pixel[9:5],1'b0,2'b0,pixel[4:0],1'b0};
endmodule
