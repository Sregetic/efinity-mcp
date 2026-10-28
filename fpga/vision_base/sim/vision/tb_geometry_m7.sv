`timescale 1ns/1ps
module tb;
reg clk=0,cpu=0,rst=0;always #5 clk=~clk;always #7 cpu=~cpu;
reg cpu_run=1;reg de=0,vs=0,nde=0,nvs=0;integer ix=0,iy=0,rx=0,ry=0;
always @(posedge clk)begin de<=nde;vs<=nvs;rx<=ix;ry<=iy;end
reg enabled=1,frozen=0,valid=1,changed=0,capture=0,ready=1;reg[31:0]frame=123,view_cfg=2,context_id=1,completed=0;
reg[31:0]errors=0;
wire hold_plane,raw_read,published;
reg[31:0]capture_frame=0,result_frame=0,result_config=0,result_context=0;
wire primary_we,meta_we;wire[1:0]meta_index;wire[31:0]meta_data;wire[37:0]primary_data;
reg[37:0]primary_box=0;reg seen_published=0;
always @(posedge clk)begin
 if(capture)capture_frame<=frame;
 if(primary_we)primary_box<=primary_data;
 if(meta_we)case(meta_index)0:result_frame<=meta_data;1:result_config<=meta_data;2:result_context<=meta_data;endcase
 if(published)seen_published<=1;
end
reg[7:0]paddr=0;reg psel=0,penable=0,pwrite=0;reg[31:0]pwdata=0;wire[31:0]prdata;wire pready;
wire current,mark;wire[2:0]count;wire[23:0]color;
vision_geometry_m7 dut(.clk(clk),.rst_n(rst),.de(de),.vs(vs),.x(12'(rx)),.y(12'(ry)),.enabled(enabled),.frozen(frozen),.source_valid(valid),
 .invalidated(changed),.capture_start(capture),.canny_ready(ready),.capture_frame(capture_frame),.result_frame(result_frame),.view_frame(frame),.view_config(view_cfg),.view_context(context_id),.canny_completed(completed),.source_errors(errors),
 .bitmap_hold(hold_plane),.raw_bitmap_enable(raw_read),
 .cpu_clk(cpu),.cpu_rst_n(rst&&cpu_run),.paddr(paddr),.psel(psel),.penable(penable),.pwrite(pwrite),.pwdata(pwdata),.prdata(prdata),.pready(pready),
 .current(current),.count(count),.primary_we(primary_we),.primary_data(primary_data),.published(published),.meta_we(meta_we),.meta_index(meta_index),.meta_data(meta_data),.mark(mark),.color(color));
task bus(input wr,input[7:0]a,input[31:0]v,output[31:0]q);begin
 @(negedge cpu);psel=1;penable=0;pwrite=wr;paddr=a;pwdata=v;
 @(negedge cpu);penable=1;@(posedge cpu);while(!pready)@(posedge cpu);
 q=prdata;@(negedge cpu);psel=0;penable=0;
end endtask
reg[31:0]s,q;integer i,f,checks=0;reg[37:0]boxes[0:3];integer visible=4;
task write_reg(input[7:0]a,input[31:0]v);reg[31:0]z;begin bus(1,a,v,z);end endtask
task read_status;begin bus(0,4,0,s);end endtask
task boundary;begin @(negedge clk);nvs=1;repeat(6)@(negedge clk);nvs=0;repeat(40)@(negedge clk);end endtask
task tagged_frame(input[31:0]n);begin
 @(negedge clk);frame=n;capture=1;@(negedge clk);capture=0;
 repeat(6)@(negedge clk);completed=completed+1;repeat(6)@(negedge clk);
end endtask
task snapshot;reg[31:0]old_token,new_token;begin
 bus(0,8,0,old_token);write_reg(4,1);new_token=old_token;
 while(new_token==old_token)bus(0,8,0,new_token);read_status;
end endtask
task put_box(input integer n,input[37:0]b);begin write_reg(8'h40+n*8,{13'd0,b[18:0]});write_reg(8'h44+n*8,{13'd0,b[37:19]});end endtask
integer x,y,n,x0,y0,x1,y1;reg expected,label,badge;reg[23:0]expected_color;
reg checking=0;integer hits=0;integer ppm;
always @(posedge clk)begin #1;
 if(checking&&de)begin
  expected=0;label=0;expected_color=0;badge=0;
  for(integer k=3;k>=0;k=k-1)if(k<visible)begin
   x0=boxes[k][35:27]*4+2;y0=boxes[k][26:18]*4+2;x1=boxes[k][17:9]*4+5;y1=boxes[k][8:0]*4+5;
   if((rx>=x0&&rx<=x1&&(ry==y0||ry==y1))||(ry>=y0&&ry<=y1&&(rx==x0||rx==x1)))begin
    expected=1;
    expected_color=boxes[k][37:36]==1?24'h20ff40:boxes[k][37:36]==2?24'h3090ff:24'hffe020;
   end
  end
  if(mark!==(expected||badge))$fatal(1,"mark mismatch x%0d y%0d actual%b expected%b",rx,ry,mark,expected||badge);
  if(expected&&!label&&!badge&&color!==expected_color)$fatal(1,"color mismatch %0d %0d",rx,ry);
  if(mark)hits++;checks++;
  if(ppm)$fwrite(ppm,"%c%c%c",mark?color[23:16]:8'h11,mark?color[15:8]:8'h22,mark?color[7:0]:8'h33);
 end
end
initial begin
 repeat(8)@(negedge clk);rst=1;boundary;
 tagged_frame(123);frame=124;snapshot;
 bus(0,8'h18,0,q);if(!s[0]||!hold_plane||!raw_read||q!=123)$fatal(1,"snapshot retagged to the current RGB frame");
 write_reg(4,0);repeat(8)@(negedge clk);if(hold_plane)$fatal(1,"plane not released");
 boxes[0]={2'd2,9'd1,9'd1,9'd60,9'd70};boxes[1]={2'd1,9'd100,9'd80,9'd150,9'd140};
 boxes[2]={2'd3,9'd200,9'd100,9'd240,9'd160};boxes[3]={2'd2,9'd1,9'd230,9'd478,9'd268};
 for(i=0;i<4;i=i+1)put_box(i,boxes[i]);
 put_box(4,123);put_box(5,2);put_box(6,1);put_box(7,4|8|(1<<4)|(2<<7)|(1<<10));write_reg(8'h24,0);
 if(count!=0)$fatal(1,"published before VS");repeat(8)@(negedge clk);boundary;
 if(count!=4||primary_box!==boxes[0]||!current||result_frame!=123||result_config!=2||result_context!=1||!seen_published)$fatal(1,"atomic tagged publication failed");
 // frame_ok is low in VBlank; completed status must remain valid independently.
 cpu_run=0;repeat(12)@(negedge cpu);cpu_run=1;repeat(12)@(negedge cpu);boundary;
 if(count!=4||result_frame!=123||dut.publish_request!=dut.publish_ack)$fatal(1,"CPU reset spuriously republished a RAM bank");
 valid=0;repeat(4)@(negedge clk);if(count!=4||current)$fatal(1,"VBlank destroyed completed status");valid=1;

 ppm=$fopen("results/geometry_m7_20261028/m7_overlay_v3.ppm","wb");$fwrite(ppm,"P6\n1920 1080\n255\n");
 checking=1;
 for(y=0;y<1080;y=y+1)begin
  for(x=0;x<1920;x=x+1)begin @(negedge clk);nde=1;ix=x;iy=y;end
  @(negedge clk);nde=0;ix=0;iy=y+1;repeat(40)@(negedge clk);
 end
 checking=0;$fclose(ppm);ppm=0;
 if(checks!=2073600)$fatal(1,"render coverage %0d",checks);
 frozen=1;frame=124;repeat(3)@(negedge clk);if(current)$fatal(1,"wrong frozen frame drew boxes");
 frame=123;repeat(3)@(negedge clk);if(!current)$fatal(1,"matching history source did not recover its result");frozen=0;
 changed=1;repeat(3)@(negedge clk);changed=0;context_id=2;
 if(current||mark)$fatal(1,"old processing context remained visible");
 frozen=1;tagged_frame(199);frame=200;snapshot;
 if(s[0]||hold_plane)$fatal(1,"wrong frozen source accepted or blocked Canny");write_reg(4,0);repeat(8)@(negedge clk);
 tagged_frame(200);snapshot;bus(0,8'h18,0,q);if(!s[0]||q!=200)$fatal(1,"matching frozen source rejected");
 write_reg(4,0);frozen=0;repeat(8)@(negedge clk);capture=1;frame=201;@(negedge clk);capture=0;errors=1;
 repeat(6)@(negedge clk);completed=completed+1;repeat(6)@(negedge clk);snapshot;
 if(s[0]||hold_plane)$fatal(1,"corrupt captured scan was accepted");write_reg(4,0);repeat(8)@(negedge clk);
 tagged_frame(202);snapshot;if(!s[0])$fatal(1,"clean capture after scan failure rejected");
 enabled=0;repeat(20)@(negedge clk);read_status;
 if(s[4]||s[0]||hold_plane||raw_read||current)$fatal(1,"mode exit did not cancel a blocked read");
 write_reg(8'h2c,144);if(dut.edge_threshold!=96)$fatal(1,"threshold changed outside VS");
 repeat(8)@(negedge clk);boundary;if(dut.edge_threshold!=144)$fatal(1,"threshold not applied at VS");
 write_reg(8'h2c,160);
 fork
  begin write_reg(8'h2c,176);end
  begin repeat(8)@(negedge cpu);if(pready)$fatal(1,"pending edge update did not backpressure");boundary;repeat(8)@(negedge clk);boundary;end
 join
 if(dut.edge_threshold!=176)$fatal(1,"consecutive edge updates lost a value");
 $display("PASS M7 async snapshot/shared-reader enable/atomic publish/2073600 pixels/frozen tags/context/cancel; hits%0d",hits);$finish;
end
initial begin #100000000;$fatal(1,"watchdog");end
endmodule
