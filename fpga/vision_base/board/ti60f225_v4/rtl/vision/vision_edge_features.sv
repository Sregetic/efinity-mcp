// Frozen Canny bitmap -> exact8x8 uint8 occupancy. Reuse the32-bit probe port.
//64 small counters use FFs; bit-serial division needs no new BRAM or DSP.
module vision_edge_features #(parameter W=480,H=270,
 parameter CW=$clog2((W>H)?W:H),
 parameter COUNT_W=$clog2(((W+7)/8)*((H+7)/8)+1))(
 input clk,rst_n,job_valid,output job_ready,busy,done,
 output word_req,input word_ready,output[11:0]word_address,
 input word_valid,input[31:0]word_data,
 output feature_valid,input feature_ready,output[7:0]feature_data
);
 localparam IDLE=0,CLEAR=1,REQUEST=2,WAIT_WORD=3,BITS=4,DIV_INIT=5,DIV_STEP=6,SEND=7;
 localparam DIV_W=COUNT_W+8;
 reg[2:0]state=IDLE;
 (* syn_ramstyle="registers" *)reg[COUNT_W-1:0]counts[0:63];
 reg[5:0]cell_index=0;reg[CW-1:0]x=0,y=0;
 reg[11:0]address=0;reg[4:0]bit_index=0;reg[31:0]word=0;
 reg[DIV_W-1:0]dividend=0;reg[COUNT_W-1:0]remainder=0,divisor=0;
 reg[$clog2(DIV_W)-1:0]divbit=0;reg[7:0]quotient=0;
 reg[2:0]tile_x,tile_y;integer k;
 always @*begin
  tile_x=7;tile_y=7;
  for(k=1;k<8;k=k+1)begin
   if(tile_x==7&&x<W*k/8)tile_x=3'(k-1);
   if(tile_y==7&&y<H*k/8)tile_y=3'(k-1);
  end
 end
 wire[5:0]tile={tile_y,tile_x};
 // Each axis has only floor(size/8) or ceil(size/8) cells. Decode four
 // possible products directly; a64-entry indexed array inferred one RAM10.
 wire[7:0]wide_columns,wide_rows;genvar g;
 generate for(g=0;g<8;g=g+1)begin:area_constants
  assign wide_columns[g]=(W*(g+1)/8-W*g/8)>W/8;
  assign wide_rows[g]=(H*(g+1)/8-H*g/8)>H/8;
 end endgenerate
 wire[COUNT_W-1:0]area=wide_columns[cell_index[2:0]]?
  (wide_rows[cell_index[5:3]]?COUNT_W'((W/8+1)*(H/8+1)):COUNT_W'((W/8+1)*(H/8))):
  (wide_rows[cell_index[5:3]]?COUNT_W'((W/8)*(H/8+1)):COUNT_W'((W/8)*(H/8)));
 wire[COUNT_W:0]trial={remainder,dividend[divbit]};
 assign job_ready=state==IDLE,busy=state!=IDLE;
 assign done=state==SEND&&feature_ready&&cell_index==63;
 assign word_req=state==REQUEST,word_address=address;
 assign feature_valid=state==SEND,feature_data=quotient;
 always @(posedge clk)begin
  if(!rst_n)begin state<=IDLE;cell_index<=0;x<=0;y<=0;address<=0;bit_index<=0;word<=0;dividend<=0;remainder<=0;divisor<=0;divbit<=0;quotient<=0;end
  else case(state)
   IDLE:if(job_valid)begin cell_index<=0;x<=0;y<=0;address<=0;state<=CLEAR;end
   CLEAR:begin
    counts[cell_index]<=0;
    if(cell_index==63)begin cell_index<=0;state<=REQUEST;end else cell_index<=cell_index+1'b1;
   end
   REQUEST:if(word_ready)state<=WAIT_WORD;
   WAIT_WORD:if(word_valid)begin word<=word_data;bit_index<=0;state<=BITS;end
   BITS:begin
    if(word[bit_index])counts[tile]<=counts[tile]+1'b1;
    if(x==W-1)begin x<=0;y<=y+1'b1;end else x<=x+1'b1;
    if(x==W-1&&y==H-1)begin cell_index<=0;state<=DIV_INIT;end
    else if(bit_index==31)begin address<=address+1'b1;state<=REQUEST;end
    else bit_index<=bit_index+1'b1;
   end
   DIV_INIT:begin
    dividend<=(DIV_W'(counts[cell_index])<<8)-DIV_W'(counts[cell_index])+DIV_W'(area>>1);
    divisor<=area;remainder<=0;quotient<=0;divbit<=DIV_W-1;state<=DIV_STEP;
   end
   DIV_STEP:begin
    if(trial>={1'b0,divisor})begin
     remainder<=COUNT_W'(trial-{1'b0,divisor});
     if(divbit<8)quotient[divbit]<=1;
    end else remainder<=trial[COUNT_W-1:0];
    if(divbit==0)state<=SEND;else divbit<=divbit-1'b1;
   end
   SEND:if(feature_ready)begin
    if(cell_index==63)state<=IDLE;else begin cell_index<=cell_index+1'b1;state<=DIV_INIT;end
   end
  endcase
 end
endmodule
