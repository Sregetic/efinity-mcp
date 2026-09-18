`timescale 1ns/1ps
// 1920x1080p60 at 148.5 MHz. Positive sync, 2200x1125 total.
// Pattern has eight color bars, one-pixel white border, animated square.
module video_test_pattern_720 (
    input wire clk,rst_n,
    output reg [7:0] red,green,blue,
    output reg hs,vs,de,
    output reg [31:0] frame_count,
    output reg frame_pulse
);
    reg [11:0] x,y;
    reg [7:0] bar;
    always @* begin
        if(x<160)bar=8'b111;
        else if(x<320)bar=8'b110;
        else if(x<480)bar=8'b011;
        else if(x<640)bar=8'b010;
        else if(x<800)bar=8'b101;
        else if(x<960)bar=8'b100;
        else if(x<1120)bar=8'b001;
        else bar=0;
    end
    always @(posedge clk) begin
        if(!rst_n) begin
            x<=0;y<=0;red<=0;green<=0;blue<=0;hs<=0;vs<=0;de<=0;
            frame_count<=0;frame_pulse<=0;
        end else begin
            if(x==1649) begin x<=0;if(y==749)y<=0;else y<=y+1'b1;end
            else x<=x+1'b1;
            frame_pulse<=x==0 && y==720;
            if(x==0 && y==720)frame_count<=frame_count+1'b1;
            de<=x<1280 && y<720;
            hs<=x>=1390 && x<1430;
            vs<=y>=725 && y<730;
            red<=0;green<=0;blue<=0;
            if(x<1280 && y<720) begin
                red<={8{bar[2]}};green<={8{bar[1]}};blue<={8{bar[0]}};
                if(x==0 || x==1279 || y==0 || y==719) begin
                    red<=255;green<=255;blue<=255;
                end else if(y>=512 && y<576 && x[11:6]=={2'b0,frame_count[3:0]}) begin
                    red<=8'h40;green<=8'h40;blue<=8'h40;
                end
            end
        end
    end
endmodule
