`timescale 1ns/1ps
module tb_roi_axi_scaler;
    reg clk=0,rst_n=0;
    always #5 clk=~clk;
    reg job_valid=0;
    wire job_ready;
    reg [31:0] base_addr=32'hfd0,stride_bytes=40,frame_id=32'h1234,config_id=7;
    reg [15:0] src_width=13,src_height=9,roi_x=3,roi_y=1,roi_w=7,roi_h=5;
    reg [15:0] dst_width=11,dst_height=8;
    wire pixel_valid,pixel_sof,pixel_eol,pixel_eof,done,error;
    reg pixel_ready=0;
    wire [15:0] pixel_data;
    wire [31:0] pixel_frame_id,pixel_config_id;
    wire [3:0] m_axi_arid;
    wire [31:0] m_axi_araddr;
    wire [7:0] m_axi_arlen;
    wire [2:0] m_axi_arsize;
    wire [1:0] m_axi_arburst;
    wire m_axi_arvalid,m_axi_rready;
    reg m_axi_arready=0,m_axi_rvalid=0,m_axi_rlast=0;
    reg [127:0] m_axi_rdata=0;
    reg [1:0] m_axi_rresp=0;
    reg pending=0,inject_error=0;
    reg [31:0] response_addr=0;
    integer response_left=0,cycle=0,k,received=0,commands=0,lines=0;
    integer dx,dy,sx,sy;
    reg [31:0] expected_address;
    reg stalled=0;
    reg [82:0] stalled_payload;
    roi_axi_scaler #(.MAX_LINE_PIXELS(32)) dut(.*);
    function automatic [15:0] pixel_at(input [31:0] a);
        pixel_at=(a>>1)^16'h5a3c;
    endfunction

    always @(negedge clk) begin
        cycle=cycle+1;
        m_axi_arready=!pending && !m_axi_rvalid && cycle%3!=1;
        pixel_ready=(cycle%5!=0);
    end
    always @(posedge clk) begin
        if (!rst_n) begin
            pending<=0;m_axi_rvalid<=0;stalled<=0;
        end else begin
            if (dut.rd_cmd_valid && dut.rd_cmd_ready) lines<=lines+1;
            if (m_axi_arvalid && m_axi_arready) begin
                if(pending || m_axi_rvalid) $fatal(1,"Overlapping AXI burst");
                if({1'b0,m_axi_araddr[11:0]}+(m_axi_arlen+1)*16>4096)
                    $fatal(1,"Cross-page burst");
                response_addr<=m_axi_araddr;response_left<=m_axi_arlen+1;
                pending<=1;commands<=commands+1;
            end
            if(m_axi_rvalid && m_axi_rready) begin
                m_axi_rvalid<=0;response_left<=response_left-1;response_addr<=response_addr+16;
                if(response_left==1) pending<=0;
            end
            if(pending && !m_axi_rvalid && cycle%4!=2) begin
                for(k=0;k<8;k=k+1) m_axi_rdata[k*16+:16]<=pixel_at(response_addr+2*k);
                m_axi_rvalid<=1;m_axi_rlast<=(response_left==1);
                m_axi_rresp<=inject_error ? 2'b10 : 2'b00;
            end
            if(stalled && (!pixel_valid ||
               {pixel_data,pixel_sof,pixel_eol,pixel_eof,pixel_frame_id,pixel_config_id}!==stalled_payload))
                $fatal(1,"Unstable pixel under backpressure");
            stalled<=pixel_valid && !pixel_ready;
            stalled_payload<={pixel_data,pixel_sof,pixel_eol,pixel_eof,pixel_frame_id,pixel_config_id};
            if(pixel_valid && pixel_ready) begin
                dx=received%11;dy=received/11;
                sx=3+(dx*7)/11;sy=1+(dy*5)/8;
                expected_address=32'hfd0+sy*40+sx*2;
                if(pixel_data!==pixel_at(expected_address))
                    $fatal(1,"Coordinate mismatch n=%0d data=%h expected=%h",received,pixel_data,pixel_at(expected_address));
                if(pixel_sof !== (received==0) || pixel_eol !== (dx==10) || pixel_eof !== (received==87))
                    $fatal(1,"Output flags mismatch");
                if(pixel_frame_id!==32'h1234 || pixel_config_id!==7) $fatal(1,"Metadata mismatch");
                received<=received+1;
            end
        end
    end
    task automatic run_job(input bad_bus);
        integer before_commands,before_lines,started;
        begin
            @(negedge clk);received=0;inject_error=bad_bus;
            before_commands=commands;before_lines=lines;started=cycle;
            job_valid=1;
            @(posedge clk);while(!job_ready) @(posedge clk);
            @(negedge clk);job_valid=0;
            while(!done) @(negedge clk);
            if(received!=88 || error!==bad_bus) $fatal(1,"Job result mismatch");
            if(lines-before_lines!=5) $fatal(1,"Repeated source rows fetched again");
            if(commands-before_commands!=6) $fatal(1,"Unexpected boundary split");
            $display("CASE integrated pixels=%0d source_lines=%0d bursts=%0d cycles=%0d error=%0d",received,lines-before_lines,commands-before_commands,cycle-started,error);
            @(negedge clk);
        end
    endtask
    initial begin
        repeat(4) @(negedge clk);rst_n=1;
        run_job(0);run_job(1);
        $display("PASS tb_roi_axi_scaler cases=2");$finish;
    end
    initial begin #2000000;$fatal(1,"Timeout");end
endmodule
