module vision_osd(input[11:0]x,y,input[2:0]mode,input[10:0]threshold,input median_en,input[1:0]memory_mode,input[2:0]history_index,input canny_ready,input[1:0]shape_class,input shape_valid,input shape_enable,output reg active=0,output ink,input[10:0]requested_threshold,input fusion_enabled,input[287:0]fusion_result,input fusion_match,input[15:0]fusion_age,input clk);
function automatic[34:0]glyph(input[7:0]ch);
 begin case(ch)
8'd48:glyph=35'b01110100011001110101110011000101110;
8'd49:glyph=35'b00100011000010000100001000010001110;
8'd50:glyph=35'b01110100010000100010001000100011111;
8'd51:glyph=35'b11110000010000101110000010000111110;
8'd52:glyph=35'b00010001100101010010111110001000010;
8'd53:glyph=35'b11111100001000011110000010000111110;
8'd54:glyph=35'b01110100001000011110100011000101110;
8'd55:glyph=35'b11111000010001000100010000100001000;
8'd56:glyph=35'b01110100011000101110100011000101110;
8'd57:glyph=35'b01110100011000101111000010000101110;
8'd65:glyph=35'b01110100011000111111100011000110001;
8'd66:glyph=35'b11110100011000111110100011000111110;
8'd67:glyph=35'b01111100001000010000100001000001111;
8'd68:glyph=35'b11110100011000110001100011000111110;
8'd69:glyph=35'b11111100001000011110100001000011111;
8'd70:glyph=35'b11111100001000011110100001000010000;
8'd71:glyph=35'b01110100011000010111100011000101110;
8'd72:glyph=35'b10001100011000111111100011000110001;
8'd73:glyph=35'b11111001000010000100001000010011111;
8'd75:glyph=35'b10001100101010011000101001001010001;
8'd76:glyph=35'b10000100001000010000100001000011111;
8'd77:glyph=35'b10001110111010110101100011000110001;
8'd78:glyph=35'b10001110011010110011100011000110001;
8'd79:glyph=35'b01110100011000110001100011000101110;
8'd80:glyph=35'b11110100011000111110100001000010000;
8'd81:glyph=35'b01110100011000110001101011001001101;
8'd82:glyph=35'b11110100011000111110101001001010001;
8'd83:glyph=35'b01111100001000001110000010000111110;
8'd84:glyph=35'b11111001000010000100001000010000100;
8'd85:glyph=35'b10001100011000110001100011000101110;
8'd86:glyph=35'b10001100011000110001100010101000100;
8'd87:glyph=35'b10001100011000110101101011101110001;
8'd89:glyph=35'b10001100010101000100001000010000100;
8'd90:glyph=35'b11111000010001000100010001000011111;
8'd58:glyph=35'b00000001000010000000001000010000000;
 default:glyph=0;endcase end
endfunction
function automatic[7:0]hexchar(input[3:0]n);begin hexchar=n<10?8'd48+n:8'd55+n;end endfunction
reg[7:0]ch;reg[5:0]idx,bitidx;reg[2:0]row;reg[6:0]origin;reg[31:0]status_text;
wire[11:0]local_x=x-12'd8,local_y=y-origin;
wire[3:0]column=local_x%12'd12;
reg[7:0]ch_q=32;reg[5:0]bitidx_q=0;reg ink_region_q=0;
wire[34:0]bits=glyph(ch_q);
always @*begin
 row=y>=76?4:y>=58?3:y>=40?2:y>=22?1:0;origin=4+18*row;
 idx=local_x/12'd12;ch=32;status_text=32'h4e4f4e45; // NONE
 case(fusion_result[10:8])
  1:status_text=32'h57414954;2:status_text=32'h54455354;3:status_text=32'h4f4b2020;
  4:status_text=32'h44494646;5:status_text=32'h554e4b4e;6:status_text=32'h45525220;
 endcase
 if(fusion_result[0]&&!fusion_match)status_text=32'h4f4c4420; // OLD, never a fresh box
 if(row==0)begin
  if(idx<8)case(mode)
   0:ch=(64'h43414d4552412020>>(56-idx*8)); // CAMERA
   1:ch=(64'h4752415920202020>>(56-idx*8));
   2:ch=(64'h534f42454c202020>>(56-idx*8));
   3:ch=(64'h53504c4954202020>>(56-idx*8));
   4:ch=(64'h534f42454c204f56>>(56-idx*8));
   5:ch=(64'h43414e4e59202020>>(56-idx*8));
   6:ch=(64'h43414e4e59204f56>>(56-idx*8));
   7:ch=(64'h5348415045202020>>(56-idx*8));
  endcase
  else case(idx)
   9:ch="T";10:ch=48+threshold/1000;11:ch=48+(threshold/100)%10;
   12:ch=48+(threshold/10)%10;13:ch=48+threshold%10;
   15:ch="M";16:ch="E";17:ch="D";18:ch=median_en?"1":"0";
   20:ch="F";21:ch=hexchar({2'b0,memory_mode});23:ch="I";24:ch=hexchar({1'b0,history_index});
   26:ch="C";27:ch=canny_ready?"1":"0";
   29:ch=(mode==5||mode==6)?"R":" ";
   30:ch=(mode==5||mode==6)?48+requested_threshold/1000:32;
   31:ch=(mode==5||mode==6)?48+(requested_threshold/100)%10:32;
   32:ch=(mode==5||mode==6)?48+(requested_threshold/10)%10:32;
   33:ch=(mode==5||mode==6)?48+requested_threshold%10:32;
   default:ch=32;
  endcase
 end
 else if(row==1&&shape_enable)begin
  case(idx)
   0:ch="S";1:ch="H";2:ch="A";3:ch="P";4:ch="E";5:ch=":";
   7:ch=!shape_valid?"N":shape_class==1?"C":shape_class==2?"R":"O";
   8:ch=!shape_valid?"O":shape_class==1?"I":shape_class==2?"E":"T";
   9:ch=!shape_valid?"N":shape_class==1?"R":shape_class==2?"C":"H";
   10:ch=!shape_valid?"E":shape_class==1?"C":shape_class==2?"T":"E";
   11:ch=!shape_valid?" ":shape_class==1?"L":shape_class==2?" ":"R";
   12:ch=(shape_valid&&shape_class==1)?"E":" ";
   default:ch=32;
  endcase
 end
 if(fusion_enabled&&row==2)begin
  if(idx==0)ch="A";else if(idx==1)ch="I";
  else if(idx>=3&&idx<=6)ch=status_text>>(24-8*(idx-3));
  else if(idx==8)ch="C";else if(idx==9)ch=hexchar({2'b0,fusion_result[7:6]});
  else if(idx==11)ch="G";else if(idx==12)ch=hexchar({2'b0,fusion_result[5:4]});
  else if(idx==14)ch="A";else if(idx>=15&&idx<=18)ch=hexchar(fusion_age>>(16-4*(idx-14)));
 end
 if(fusion_enabled&&row==3)begin
  if(idx==0)ch="F";else if(idx>=1&&idx<=8)ch=hexchar(fusion_result[63:32]>>(32-4*idx));
  else if(idx==10)ch="R";else if(idx>=11&&idx<=18)ch=hexchar(fusion_result[127:96]>>(32-4*(idx-10)));
  else if(idx==20)ch="M";else if(idx>=21&&idx<=24)ch=hexchar(fusion_result[159:128]>>(16-4*(idx-20)));
 end
 if(fusion_enabled&&row==4)begin
  if(idx==0)ch="S";else if(idx>=1&&idx<=8)ch=hexchar(fusion_result[95:64]>>(32-4*idx));
  else if(idx>=10&&idx<=24)case((idx-10)%4)
   0:ch="Q";1:ch=hexchar(fusion_result[287:256]>>(8*((idx-10)/4)+4));
   2:ch=hexchar(fusion_result[287:256]>>(8*((idx-10)/4)));default:ch=32;
  endcase
 end
 bitidx=34-((local_y/2)*5)-(column/2);
end
// Split character selection from font decode; RGB/control use the same extra beat.
always @(posedge clk)begin
 ch_q<=ch;bitidx_q<=bitidx;
 active<=(x>=8&&x<((mode==5||mode==6)?428:356)&&((y>=4&&y<20)||(shape_enable&&y>=22&&y<38)||(fusion_enabled&&((y>=40&&y<56)||(y>=58&&y<74)||(y>=76&&y<92)))));
 ink_region_q<=column<10&&local_y<14&&bitidx<35;
end
assign ink=active&&ink_region_q&&bits[bitidx_q];
endmodule
