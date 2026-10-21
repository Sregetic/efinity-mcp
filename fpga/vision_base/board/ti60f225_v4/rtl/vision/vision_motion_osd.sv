// Read-only motion HUD. Direction codes and activity come from the actual core.
// Scores are not probabilities. Frame-held inputs are supplied by vision_display.
module vision_motion_osd(
 input[11:0]x,y,input[31:0]status,observation,input[15:0]active_sites,input[2:0]show_direction,input held,
 output reg active,ink,output reg[23:0]color);
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
8'd76:glyph=35'b10000100001000010000100001000011111;
8'd77:glyph=35'b10001110111010110101100011000110001;
8'd78:glyph=35'b10001110011010110011100011000110001;
8'd79:glyph=35'b01110100011000110001100011000101110;
8'd80:glyph=35'b11110100011000111110100001000010000;
8'd82:glyph=35'b11110100011000111110101001001010001;
8'd83:glyph=35'b01111100001000001110000010000111110;
8'd84:glyph=35'b11111001000010000100001000010000100;
8'd85:glyph=35'b10001100011000110001100011000101110;
8'd86:glyph=35'b10001100011000110001100010101000100;
8'd87:glyph=35'b10001100011000110101101011101110001;
8'd89:glyph=35'b10001100010101000100001000010000100;
8'd90:glyph=35'b11111000010001000100010001000011111;
8'd75:glyph=35'b10001100101010011000101001001010001;
 default:glyph=0;endcase end
endfunction
function automatic[7:0]at20(input[159:0]text,input[4:0]index);
 begin at20=8'd32;if(index<20)at20=text[159-(index*8)-:8];end
endfunction
function automatic[7:0]hexchar(input[3:0]v);
 begin hexchar=v<10?8'd48+v:8'd55+v;end
endfunction
reg[159:0]line;
reg[7:0]ch;reg[34:0]bits;
reg[11:0]bcd;integer k,bit_index;
reg[11:0]rx,ry,ax,ay;reg[4:0]column;reg[2:0]text_row;
reg[2:0]gx,gy;reg text_ink,arrow_ink;
reg ready,bad;reg[2:0]direction;
always @*begin
 ready=status[0]&&status[1];bad=status[6]||active_sites>16'd144;
 direction=show_direction;
 color=bad?24'hff5050:!ready?24'hffb050:direction==1?24'hd0d0d0:(direction==0||direction>5)?24'hffb050:24'h40ffd0;
 active=x>=24&&x<888&&y>=24&&y<212;
 rx=x-12'd32;ry=y-12'd32;column=rx[9:5];text_row=ry[7:5];gx=rx[4:2];gy=ry[4:2];
 bcd=0;
 for(k=7;k>=0;k=k-1)begin
  if(bcd[3:0]>=5)bcd[3:0]=bcd[3:0]+3;
  if(bcd[7:4]>=5)bcd[7:4]=bcd[7:4]+3;
  if(bcd[11:8]>=5)bcd[11:8]=bcd[11:8]+3;
  bcd={bcd[10:0],active_sites[k]};
 end
 line="                    ";
 case(text_row)
  0:line="FLY LOCAL OBSERVE   ";
  1:begin
    if(bad)line="SHOW ERROR          ";
    else if(!ready)line="SHOW WAIT           ";
    else case(direction)
     1:line="SHOW STILL          ";2:line="SHOW LEFT           ";3:line="SHOW RIGHT          ";
     4:line="SHOW UP             ";5:line="SHOW DOWN           ";default:line="SHOW UNKNOWN        ";
    endcase
    if(ready&&!bad&&direction>=2&&direction<=5)line[71:40]=held?"HOLD":"SUM ";
   end
  2:begin
    if(bad)line="RAW ERROR           ";else if(!ready)line="RAW WAIT            ";
    else case(status[5:3])
     1:line="RAW STILL           ";2:line="RAW LEFT            ";3:line="RAW RIGHT           ";
     4:line="RAW UP              ";5:line="RAW DOWN            ";default:line="RAW UNKNOWN         ";
    endcase
   end
  3:line=status[2]?"ACT 000 ROI YES     ":"ACT 000 ROI NO      ";
  4:case(status[9:8])
    0:line="SKIP FRAME 00000000 ";1:line="ROI  FRAME 00000000 ";default:line="FULL FRAME 00000000 ";
   endcase
 endcase
 ch=at20(line,column);
 if(text_row==3)case(column)
  4:ch=8'd48+{4'd0,bcd[11:8]};5:ch=8'd48+{4'd0,bcd[7:4]};6:ch=8'd48+{4'd0,bcd[3:0]};
 endcase
 if(text_row==4&&column>=11&&column<19)ch=hexchar((observation>>((18-column)*4))&15);
 bits=glyph(ch);bit_index=34-(gy*5)-gx;
 text_ink=0;
 if(x>=32&&x<672&&y>=32&&y<192&&gx<5&&gy<7&&bit_index>=0&&bit_index<35)text_ink=bits[bit_index];
 ax=x>=800?x-12'd800:12'd800-x;ay=y>=96?y-12'd96:12'd96-y;
 arrow_ink=0;
 if(ready&&!bad)case(direction)
  1:arrow_ink=x>=772&&x<=828&&y>=93&&y<=99;
  2:arrow_ink=(x>=748&&x<=852&&y>=93&&y<=99)||(x>=748&&x<=776&&ay<=x-748);
  3:arrow_ink=(x>=748&&x<=852&&y>=93&&y<=99)||(x>=824&&x<=852&&ay<=852-x);
  4:arrow_ink=(y>=44&&y<=148&&x>=797&&x<=803)||(y>=44&&y<=72&&ax<=y-44);
  5:arrow_ink=(y>=44&&y<=148&&x>=797&&x<=803)||(y>=120&&y<=148&&ax<=148-y);
  default:arrow_ink=0;
 endcase
 if(bad&&ax<=32&&ay<=32)arrow_ink=(ax>=ay?ax-ay:ay-ax)<=2;
 ink=active&&(text_ink||arrow_ink);
end
endmodule
