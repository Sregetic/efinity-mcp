`timescale 1ns/1ps
module tb;
reg clk=0,cpu=0,rst=0;always #5 clk=~clk;always #7 cpu=~cpu;
reg de=0,vs=0,capture=0,valid=1;reg[11:0]x=0,y=0;
reg[31:0]frame=123,completed=0;wire[31:0]result_frame,result_config,result_context;
reg[7:0]paddr=0;reg psel=0,penable=0,pwrite=0;reg[31:0]pwdata=0;wire[31:0]prdata;wire pready,done,ode;
wire[7:0]r,g,b;wire[63:0]status;wire hold_plane,raw_read;
vision_display #(.EXTERNAL_GEOMETRY(1),.FUSION(1)) dut(.clk(clk),.rst_n(rst),.de(1'b0),.hs(1'b0),.vs(1'b0),.r(8'd0),.g(8'd0),.b(8'd0),
 .mode(3'd0),.threshold(11'd96),.median_en(1'b1),.memory_mode(2'd0),.history_index(3'd0),.canny_pixel(1'b0),.canny_ready(1'b1),.canny_coverage(8'd0),
 .geometry_enable(1'b1),.geometry_selection_bank(1'b0),.geometry_selection(3'd0),.shape_enable(1'b1),.shape_status(status),.canny_effective_threshold(11'd96),.canny_requested_threshold(11'd96),
 .analysis_enabled(1'b0),.analysis_context_changed(1'b0),.frame_id(frame),.render_config_id(32'd2),.analysis_context(32'd1),.analysis_result(352'd0),
 .analysis_match(1'b0),.analysis_identity_match(1'b0),.analysis_age(16'd0),.ui_state(24'd0),.motion_enable(1'b0),
 .geometry_done(done),.geometry_frame(result_frame),.geometry_config(result_config),.geometry_context(result_context),.ode(ode),.orr(r),.ogg(g),.obb(b),
 .geometry_rst_n(rst),.geometry_source_valid(valid),.geometry_changed(1'b0),.canny_capture_start(capture),.canny_completed(completed),.geometry_source_errors(32'd0),
 .geometry_cpu_clk(cpu),.geometry_cpu_rst_n(rst),.geometry_paddr(paddr),.geometry_psel(psel),.geometry_penable(penable),.geometry_pwrite(pwrite),.geometry_pwdata(pwdata),
 .geometry_prdata(prdata),.geometry_pready(pready),.geometry_bitmap_hold(hold_plane),.geometry_raw_read(raw_read));
reg[31:0]expected_frame=123;reg[1:0]expected_class=2;integer visible=4;
reg seen_done=0;always @(posedge clk)if(done)begin
 if(!status[62]||status[61:60]!=expected_class||result_frame!=expected_frame||result_config!=2||result_context!=1)$fatal(1,"I3 geometry publication incoherent");seen_done<=1;end
task bus(input wr,input[7:0]a,input[31:0]v,output[31:0]q);begin
 @(negedge cpu);psel=1;penable=0;pwrite=wr;paddr=a;pwdata=v;
 @(negedge cpu);penable=1;@(posedge cpu);while(!pready)@(posedge cpu);
 q=prdata;@(negedge cpu);psel=0;penable=0;
end endtask

reg[31:0]q,old_token;reg[37:0]boxes[0:3];integer i,xx,yy,checks=0,ppm;
task wr(input[7:0]a,input[31:0]v);reg[31:0]z;begin bus(1,a,v,z);end endtask
task record(input integer n,input[37:0]v);begin wr(8'h40+n*8,v[18:0]);wr(8'h44+n*8,v[37:19]);end endtask
task character(input integer col,input[7:0]wanted);begin
 @(negedge clk);de=1;x=8+12*col;y=22;repeat(3)@(negedge clk);
 if(dut.osd0.ch_q!==wanted)$fatal(1,"M7 HUD col%0d got %c expected %c",col,dut.osd0.ch_q,wanted);
end endtask
reg checking=0,expected_de=0,skip=0;reg[23:0]wanted=0;integer x0,y0,x1,y1;reg[23:0]next_color;
always @(posedge clk)begin #1;
 if(checking&&expected_de)begin
  if(!ode||(!skip&&{r,g,b}!==wanted))$fatal(1,"integrated pixel mismatch wanted%h got%h",wanted,{r,g,b});checks++;
  $fwrite(ppm,"%c%c%c",r,g,b);
 end
 expected_de=de;skip=x>=8&&x<356&&y>=4&&y<38;next_color=24'h112233;
 for(integer n=3;n>=0;n--)if(n<visible)begin
  x0=boxes[n][35:27]*4+2;y0=boxes[n][26:18]*4+2;x1=boxes[n][17:9]*4+5;y1=boxes[n][8:0]*4+5;
  if((x>=x0&&x<=x1&&(y==y0||y==y1))||(y>=y0&&y<=y1&&(x==x0||x==x1)))
   next_color=boxes[n][37:36]==1?24'h20ff40:boxes[n][37:36]==2?24'h3090ff:24'hffe020;
 end
 wanted=next_color;
end
initial begin
 force dut.fd=de;force dut.fv=vs;force dut.x=x;force dut.y=y;force dut.border=0;force dut.fr=8'h11;force dut.fg=8'h22;force dut.fb=8'h33;
 repeat(8)@(negedge clk);rst=1;capture=1;@(negedge clk);capture=0;repeat(8)@(negedge clk);completed=1;
 repeat(8)@(negedge clk);frame=124;bus(0,8,0,old_token);wr(4,1);q=old_token;while(q==old_token)bus(0,8,0,q);
 boxes[0]={2'd2,9'd1,9'd1,9'd60,9'd70};boxes[1]={2'd1,9'd100,9'd80,9'd150,9'd140};
 boxes[2]={2'd3,9'd200,9'd100,9'd240,9'd160};boxes[3]={2'd2,9'd1,9'd230,9'd478,9'd268};
 for(i=0;i<4;i++)record(i,boxes[i]);record(4,123);record(5,2);record(6,1);record(7,4|8|(1<<4)|(2<<7)|(1<<10));wr(4,0);wr(8'h24,0);
 valid=0;repeat(8)@(negedge clk);vs=1;repeat(8)@(negedge clk);vs=0;repeat(40)@(negedge clk);
 if(!seen_done||!status[62]||status[47:0]!={12'd6,12'd6,12'd245,12'd285})$fatal(1,"VBlank result/primary missing");valid=1;
 character(14,"N");character(15,"4");character(16,"+");character(18,"C");character(19,"1");character(21,"R");character(22,"2");character(24,"F");character(25,"1");

 // Geometry frame125 updates first; the slower face remains from frame123.
 @(negedge clk);de=0;capture=1;frame=125;@(negedge clk);capture=0;
 repeat(8)@(negedge clk);completed=2;repeat(8)@(negedge clk);
 bus(0,8,0,old_token);wr(4,1);q=old_token;while(q==old_token)bus(0,8,0,q);wr(4,0);
 boxes[0]={2'd2,9'd300,9'd170,9'd380,9'd230};boxes[1]={2'd1,9'd350,9'd30,9'd390,9'd70};boxes[2]=0;boxes[3]=0;visible=2;
 for(i=0;i<4;i++)record(i,boxes[i]);record(4,125);record(5,2);record(6,1);record(7,2|(1<<4)|(1<<7));
 expected_frame=125;expected_class=2;wr(8'h24,0);repeat(8)@(negedge clk);vs=1;repeat(8)@(negedge clk);vs=0;repeat(40)@(negedge clk);
 if(result_frame!=125||dut.geo_count!=2)$fatal(1,"geometry waited for face or published wrong source");
 boxes[2]=boxes[1];boxes[1]=boxes[0];boxes[0]={2'd3,9'd70,9'd80,9'd180,9'd220};visible=3;
 for(i=0;i<4;i++)record(i,boxes[i]);record(4,123);record(7,3|(1<<4)|(1<<7)|(1<<10));
 expected_frame=123;expected_class=3;wr(8'h24,0);repeat(8)@(negedge clk);vs=1;repeat(8)@(negedge clk);vs=0;repeat(40)@(negedge clk);
 if(result_frame!=123||dut.geo_count!=3)$fatal(1,"mixed publication lost the primary face source");
 character(15,"3");character(19,"1");character(22,"1");character(25,"1");
 @(negedge clk);de=0;repeat(10)@(negedge clk);
 ppm=$fopen("results/geometry_edge_split_20261028/m7_split_display.ppm","wb");$fwrite(ppm,"P6\n1920 1080\n255\n");checking=1;
 for(yy=0;yy<1080;yy++)begin
  for(xx=0;xx<1920;xx++)begin @(negedge clk);de=1;x=xx;y=yy;end
  @(negedge clk);de=0;x=0;y=yy+1;repeat(40)@(negedge clk);
 end
 checking=0;$fclose(ppm);if(checks!=2073600)$fatal(1,"coverage %0d",checks);
 $display("PASS M7 split publications: newer geometry + older face, coherent I3 primary source, VS atomic counts and 2073600 RGB pixels");$finish;
end
initial begin #100000000;$fatal(1,"watchdog");end
endmodule
