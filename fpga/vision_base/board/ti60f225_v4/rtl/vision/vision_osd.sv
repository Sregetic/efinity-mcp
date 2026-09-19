module vision_osd(input[11:0]x,y,input[2:0]mode,input[10:0]threshold,input median_en,input[1:0]memory_mode,input[2:0]history_index,input canny_ready,input[1:0]shape_class,input shape_valid,input shape_enable,output active,output ink);
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
reg[7:0]ch;integer idx;reg[34:0]bits;integer bitidx;reg second_line;
always @*begin
 second_line=(y>=22);idx=(x-8)/12;ch=32;
 if(!second_line)case(idx)
 0:ch="M";1:ch=hexchar({1'b0,mode});
 3:ch="T";4:ch=hexchar({1'b0,threshold[10:8]});5:ch=hexchar(threshold[7:4]);6:ch=hexchar(threshold[3:0]);
 8:ch="M";9:ch="E";10:ch="D";11:ch=median_en?"1":"0";
 13:ch="F";14:ch=hexchar({2'b0,memory_mode});16:ch="I";17:ch=hexchar({1'b0,history_index});
 19:ch="C";20:ch=canny_ready?"1":"0";
 default:ch=32;
 endcase
 else if(mode==7&&shape_enable)begin
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
 bits=glyph(ch);bitidx=34-(((second_line?y-22:y-4)/2)*5)-(((x-8)%12)/2);
end
assign active=(x>=8&&x<272&&((y>=4&&y<20)||(mode==7&&shape_enable&&y>=22&&y<38)));
assign ink=active&&((x-8)%12)<10&&(((second_line?y-22:y-4)/2)<7)&&bitidx>=0&&bitidx<35&&bits[bitidx];
endmodule
