`timescale 1ns/1ps
module tb_video_test_pattern;
    reg clk=0;always #5 clk=~clk;
    reg rst_n=0;wire [7:0] red,green,blue;wire hs,vs,de,frame_pulse;
    wire [31:0] frame_count;
    video_test_pattern dut(.*);
    integer x,y,active=0,hsc=0,vsc=0,pulses=0;
    initial begin
        repeat(3)@(negedge clk);rst_n=1;
        for(y=0;y<1125;y=y+1)for(x=0;x<2200;x=x+1)begin
            @(posedge clk);#1;
            if(de !== (x<1920 && y<1080) || hs !== (x>=2008 && x<2052) || vs !== (y>=1084 && y<1089))$fatal(1,"raster x=%d y=%d",x,y);
            if(de)active=active+1;if(hs)hsc=hsc+1;if(vs)vsc=vsc+1;if(frame_pulse)pulses=pulses+1;
            if(de && (x==0 || x==1919 || y==0 || y==1079) && {red,green,blue}!==24'hffffff)$fatal(1,"border");
            if(!de && {red,green,blue}!==0)$fatal(1,"blank RGB");
        end
        if(active!=2073600 || hsc!=49500 || vsc!=11000 || pulses!=1 || frame_count!=1)$fatal(1,"frame accounting");
        $display("PASS tb_video_test_pattern total=2475000 active=%0d positive_sync=44x5",active);$finish;
    end
endmodule
