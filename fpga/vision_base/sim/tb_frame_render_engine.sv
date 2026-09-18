`timescale 1ns/1ps
module tb_frame_render_engine;
    reg clk=0;always #5 clk=~clk;
    reg rst_n=0;
    reg cap_req_valid=0,cap_done_valid=0,cap_done_ok=1;
    wire cap_req_ready,cap_done_ready;wire [1:0] cap_req_bank;
    reg [1:0] cap_done_bank=0;reg [31:0] cap_req_config_id=1;
    reg analysis_acquire_valid=0,analysis_release=0;
    wire analysis_acquire_ready,analysis_hold_valid;wire [1:0] analysis_hold_bank;
    wire [31:0] analysis_hold_frame_id,analysis_hold_config_id;
    reg job_valid=0,freeze_source=0;wire job_ready;
    reg [31:0] job_config_id=100;
    reg [15:0] src_width=32,src_height=7,roi_x=3,roi_y=2,roi_w=13,roi_h=3,dst_width=16,dst_height=6;
    reg [31:0] src_stride_bytes=80,dst_stride_bytes=48;
    reg vblank=0;wire display_valid,done,error,busy,pending;
    wire [31:0] display_base,display_frame_id,display_config_id,last_cycles,deadline_misses;
    wire [15:0] display_width,display_height;
    wire [31:0] display_stride_bytes;
    wire [3:0] m_axi_arid,m_axi_awid;
    wire [31:0] m_axi_araddr,m_axi_awaddr;
    wire [7:0] m_axi_arlen,m_axi_awlen;
    wire [2:0] m_axi_arsize,m_axi_awsize;
    wire [1:0] m_axi_arburst,m_axi_awburst;
    wire m_axi_arvalid,m_axi_awvalid,m_axi_rready,m_axi_bready;
    wire [127:0] m_axi_wdata;wire [15:0] m_axi_wstrb;wire m_axi_wlast,m_axi_wvalid;
    reg [127:0] m_axi_rdata=0;reg [1:0] m_axi_rresp=0,m_axi_bresp=0;
    reg m_axi_rlast=0,m_axi_rvalid=0,m_axi_bvalid=0;
    integer cycle=0;always @(posedge clk)cycle<=cycle+1;
    reg rd_active=0,wr_active=0;integer rd_addr=0,rd_left=0,wr_addr=0,wr_left=0,bdelay=0;
    wire m_axi_arready=!rd_active && !m_axi_rvalid && cycle%5!=0;
    wire m_axi_awready=!wr_active && !m_axi_bvalid && bdelay==0 && cycle%7!=0;
    wire m_axi_wready=wr_active && cycle%7!=0;
    reg inject_read=0,inject_write=0;
    integer writes=0,reads=0,bresponses=0;
    integer k,wx,wy,sx,sy,expected_addr;
    frame_render_engine dut(.*);
    function automatic [15:0] source_pixel(input integer address);
        source_pixel=((address>>1) ^ (address>>12) ^ 16'h359a)&16'hffff;
    endfunction
    integer trace_addr=0,trace_pixels=0,trace_x=0,trace_y=0,trace_expected;
    always @(posedge clk) if(rst_n && $test$plusargs("TRACE")) begin
        if(dut.run_valid && dut.scale_ready && dut.write_ready)begin trace_x=0;trace_y=0;end
        if(dut.pv && dut.pr)begin
            trace_expected=(cap_done_bank<<22)+(roi_y+(trace_y*roi_h)/dst_height)*src_stride_bytes+(roi_x+(trace_x*roi_w)/dst_width)*2;
            if(dut.pd[15:0]!==source_pixel(trace_expected))begin
                $display("TRACE bank=%d row=%d mem0[6]=%h mem1[6]=%h pending=%d holdaddr=%d",dut.scaler.scaler.cur_bank_r,dut.scaler.scaler.src_y_r,dut.scaler.scaler.bank0.mem[6],dut.scaler.scaler.bank1.mem[6],dut.scaler.scaler.rd_pending_r,dut.scaler.scaler.ram_addr_hold0_r);
                $display("LOAD active=%d target=%d row=%d count=%d we=%d",dut.scaler.scaler.load_active_r,dut.scaler.scaler.load_target_bank_r,dut.scaler.scaler.load_row_r,dut.scaler.scaler.load_count_r,dut.scaler.scaler.load_we0); $fatal(1,"scaler output x=%d y=%d got=%h exp=%h",trace_x,trace_y,dut.pd[15:0],source_pixel(trace_expected));
            end
            if(dut.peol)begin trace_x=0;trace_y=trace_y+1;end else trace_x=trace_x+2;
        end
        if(dut.scaler.rd_cmd_valid && dut.scaler.rd_cmd_ready)begin
            trace_addr=dut.scaler.rd_addr;trace_pixels=0;
        end
        if(dut.scaler.rd_data_valid && dut.scaler.rd_data_ready)begin
            if(dut.scaler.rd_data[15:0]!==source_pixel(trace_addr+trace_pixels*2))
                $fatal(1,"reader pixel at addr=%h index=%d actual=%h expected=%h",trace_addr,trace_pixels,dut.scaler.rd_data[15:0],source_pixel(trace_addr+trace_pixels*2));
            if(dut.scaler.rd_keep==3 && dut.scaler.rd_data[31:16]!==source_pixel(trace_addr+(trace_pixels+1)*2))
                $fatal(1,"reader high pixel at addr=%h index=%d",trace_addr,trace_pixels+1);
            trace_pixels=trace_pixels+(dut.scaler.rd_keep==3 ? 2:1);
        end
    end
    always @(posedge clk)begin
        if(rst_n)begin
            if(m_axi_arvalid && m_axi_arready)begin
                if(m_axi_arsize!=4 || m_axi_arburst!=1 || m_axi_araddr[3:0]!=0 ||
                   m_axi_araddr[11:0]+(m_axi_arlen+1)*16>4096)$fatal(1,"AR protocol");
                rd_active<=1;rd_addr<=m_axi_araddr;rd_left<=m_axi_arlen+1;reads<=reads+1;
            end
            if(m_axi_rvalid && m_axi_rready)begin
                m_axi_rvalid<=0;rd_addr<=rd_addr+16;rd_left<=rd_left-1;
                if(rd_left==1)rd_active<=0;
            end
            if(rd_active && (!m_axi_rvalid || m_axi_rready) && !(m_axi_rvalid && rd_left==1) && cycle%8!=0)begin
                for(k=0;k<8;k=k+1)m_axi_rdata[k*16+:16]<=source_pixel(rd_addr+(m_axi_rvalid ? 16 : 0)+k*2);
                m_axi_rvalid<=1;m_axi_rlast<=rd_left==(m_axi_rvalid ? 2 : 1);
                m_axi_rresp<=inject_read ? 2'b10:0;
            end
            if(m_axi_awvalid && m_axi_awready)begin
                if(m_axi_awsize!=4 || m_axi_awburst!=1 || m_axi_awaddr[3:0]!=0 ||
                   m_axi_awaddr[11:0]+(m_axi_awlen+1)*16>4096)$fatal(1,"AW protocol");
                wr_active<=1;wr_addr<=m_axi_awaddr;wr_left<=m_axi_awlen+1;
            end
            if(m_axi_wvalid && m_axi_wready)begin
                if(m_axi_wlast!=(wr_left==1) || m_axi_wstrb!=16'hffff)$fatal(1,"W protocol");
                wy=(wr_addr & 32'h003fffff)/dst_stride_bytes;
                wx=((wr_addr & 32'h003fffff)%dst_stride_bytes)/2;
                if(wy>=dst_height || wx+7>=dst_width)$fatal(1,"write outside result pixels");
                for(k=0;k<8;k=k+1)begin
                    sx=roi_x+((wx+k)*roi_w)/dst_width;sy=roi_y+(wy*roi_h)/dst_height;
                    expected_addr=(cap_done_bank<<22)+sy*src_stride_bytes+sx*2;
                    if(m_axi_wdata[k*16+:16]!==source_pixel(expected_addr))
                        $fatal(1,"pixel mismatch x=%0d y=%0d got=%h expected=%h",wx+k,wy,m_axi_wdata[k*16+:16],source_pixel(expected_addr));
                end
                writes<=writes+8;wr_addr<=wr_addr+16;wr_left<=wr_left-1;
                if(wr_left==1)begin wr_active<=0;bdelay<=9;end
            end
            if(bdelay>0)begin bdelay<=bdelay-1;if(bdelay==1)begin m_axi_bvalid<=1;m_axi_bresp<=inject_write ? 2:0;end end
            if(m_axi_bvalid && m_axi_bready)begin m_axi_bvalid<=0;bresponses<=bresponses+1;end
        end
    end
    task tick;begin @(posedge clk);#1;end endtask
    task render(input integer test_id,input bit rerr,input bit werr);
        integer before_w,start_cycle;
        begin
            before_w=writes;inject_read=rerr;inject_write=werr;job_config_id=test_id;
            @(negedge clk);job_valid=1;
            if(!job_ready)$fatal(1,"job not ready");tick();
            @(negedge clk);job_valid=0;start_cycle=cycle;
            while(!done)begin
                tick();
                if(cycle-start_cycle==1000 && $test$plusargs("DEBUG")) begin
                    $display("DEBUG ctrl=%d src_hold=%d pool=%b scaler=%d rd_active=%d rd_left=%d pv=%d pr=%d write=%d in_left=%d writes=%d",dut.control.state,dut.control.source_hold_valid,dut.control.pool.ready_q,dut.scaler.scaler.state,rd_active,rd_left,dut.pv,dut.pr,dut.writer.state,dut.writer.input_beats_remaining,writes);
                    $display("BDBG delay=%d valid=%d ready=%d outleft=%d wractive=%d wrleft=%d",bdelay,m_axi_bvalid,m_axi_bready,dut.writer.out_beats_remaining,wr_active,wr_left);
                    $finish;
                end
                if(cycle-start_cycle>2000000)$fatal(1,"render timeout");
            end
            if(error!=(rerr || werr) || writes-before_w!=dst_width*dst_height || bdelay!=0 || m_axi_bvalid)$fatal(1,"completion or final B");
            if(pending!=( !(rerr || werr)))$fatal(1,"pending mismatch");
            $display("ENGINE case=%0d pixels=%0d cycles=%0d reads=%0d writes=%0d error=%0d",test_id,writes-before_w,last_cycles,reads,bresponses,error);
            if(dst_width==1920 && (last_cycles>1666667 || deadline_misses!=0))$fatal(1,"1080p60 modeled deadline");
            repeat(4)tick();
            if(!(rerr || werr))begin
                if(display_config_id==test_id)$fatal(1,"early display");
                @(negedge clk);vblank=1;tick();@(negedge clk);vblank=0;
                if(!display_valid || display_frame_id!=1 || display_config_id!=test_id)$fatal(1,"publication");
                if(display_width!=dst_width || display_height!=dst_height || display_stride_bytes!=dst_stride_bytes)$fatal(1,"descriptor geometry");
            end
        end
    endtask
    integer full=0;
    initial begin
        repeat(4)tick();@(negedge clk);rst_n=1;cap_req_valid=1;
        #1;cap_done_bank=cap_req_bank;tick();@(negedge clk);cap_req_valid=0;cap_done_valid=1;
        tick();@(negedge clk);cap_done_valid=0;
        render(100,0,0);render(101,1,0);render(102,0,1);
        if($value$plusargs("FULL=%d",full) && full!=0)begin
            src_width=1280;src_height=720;roi_x=0;roi_y=0;roi_w=1280;roi_h=720;
            dst_width=1920;dst_height=1080;src_stride_bytes=2560;dst_stride_bytes=3840;
            render(190,0,0);
            src_width=1920;src_height=1080;roi_w=1920;roi_h=1080;src_stride_bytes=3840;
            render(191,0,0);
            roi_x=480;roi_y=270;roi_w=960;roi_h=540;
            render(192,0,0);
        end
        $display("PASS tb_frame_render_engine");$finish;
    end
endmodule
