`timescale 1ns/1ps
`default_nettype none

module tb_roi_axi_scaler;
    reg clk=0, rst_n=0;
    always #5 clk=~clk;
    reg job_valid=0;
    wire job_ready;
    reg [31:0] base_addr=32'hfd0, stride_bytes=40, frame_id=32'h1234, config_id=7;
    reg [15:0] src_width=13, src_height=9, roi_x=3, roi_y=1, roi_w=7, roi_h=5;
    reg [15:0] dst_width=11, dst_height=8;
    wire pixel_valid, pixel_sof, pixel_eol, pixel_eof, done, error;
    reg pixel_ready=0;
    wire [31:0] pixel_data;
    wire [1:0] pixel_keep;
    wire [31:0] pixel_frame_id, pixel_config_id;
    wire [3:0] m_axi_arid;
    wire [31:0] m_axi_araddr;
    wire [7:0] m_axi_arlen;
    wire [2:0] m_axi_arsize;
    wire [1:0] m_axi_arburst;
    wire m_axi_arvalid, m_axi_rready;
    reg m_axi_arready=0, m_axi_rvalid=0, m_axi_rlast=0;
    reg [127:0] m_axi_rdata=0;
    reg [1:0] m_axi_rresp=0;
    reg pending=0, inject_error=0;
    reg [31:0] response_addr=0;
    integer response_left=0, cycle=0, k, received=0, commands=0, bursts=0;
    integer dx,dy,sx,sy, expected_addr, expected_base, expected_stride;
    integer expected_dst_w, expected_dst_h, expected_roi_x, expected_roi_y;
    integer expected_roi_w, expected_roi_h, expected_frame, expected_config;
    integer before_bursts, before_commands, before_lines, start_cycle;
    integer lines, expected_line, errors;
    reg stalled=0;
    reg [100:0] stalled_payload;

    roi_axi_scaler #(.MAX_LINE_PIXELS(32), .MAX_BURST_BEATS(16), .FIFO_BEATS(16)) dut (
      .clk(clk), .rst_n(rst_n), .job_valid(job_valid), .job_ready(job_ready),
      .base_addr(base_addr), .stride_bytes(stride_bytes), .frame_id(frame_id),
      .config_id(config_id), .src_width(src_width), .src_height(src_height),
      .roi_x(roi_x), .roi_y(roi_y), .roi_w(roi_w), .roi_h(roi_h),
      .dst_width(dst_width), .dst_height(dst_height), .pixel_valid(pixel_valid),
      .pixel_ready(pixel_ready), .pixel_data(pixel_data), .pixel_keep(pixel_keep),
      .pixel_sof(pixel_sof), .pixel_eol(pixel_eol), .pixel_eof(pixel_eof),
      .pixel_frame_id(pixel_frame_id), .pixel_config_id(pixel_config_id),
      .done(done), .error(error), .m_axi_arid(m_axi_arid), .m_axi_araddr(m_axi_araddr),
      .m_axi_arlen(m_axi_arlen), .m_axi_arsize(m_axi_arsize), .m_axi_arburst(m_axi_arburst),
      .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
      .m_axi_rdata(m_axi_rdata), .m_axi_rresp(m_axi_rresp), .m_axi_rlast(m_axi_rlast),
      .m_axi_rvalid(m_axi_rvalid), .m_axi_rready(m_axi_rready));

    function automatic [15:0] pixel_at(input integer a);
        pixel_at = ((a >> 1) ^ (a >> 5) ^ 16'h5a3c ^ (a * 13));
    endfunction

    always @(negedge clk) begin
        cycle=cycle+1;
        m_axi_arready=!pending && !m_axi_rvalid && cycle%3!=1;
        pixel_ready=(cycle%7!=0) && (cycle%11!=0);
    end

    // A line load must never target the bank being displayed.
    always @(posedge clk) begin
        if (rst_n && dut.scaler.state == 3 && dut.scaler.load_active_r
            && dut.scaler.load_target_bank_r == dut.scaler.cur_bank_r)
            $fatal(1,"Line load overlaps current output bank");
    end

    // One AXI burst in flight.  Address, burst cap, 4-KiB split and stable R
    // payload are checked at the actual interface boundary.
    always @(posedge clk) begin
        if (!rst_n) begin
            pending<=0; m_axi_rvalid<=0; stalled<=0;
        end else begin
            if (stalled && (!pixel_valid
                || {pixel_data,pixel_keep,pixel_sof,pixel_eol,pixel_eof,pixel_frame_id,pixel_config_id}
                   !== stalled_payload))
                begin $display("STALL old=%h current=%h t=%0d",stalled_payload,pixel_data,cycle); $fatal(1,"Unstable output under backpressure"); end
            stalled <= pixel_valid && !pixel_ready;
            stalled_payload <= {pixel_data,pixel_keep,pixel_sof,pixel_eol,pixel_eof,pixel_frame_id,pixel_config_id};

            if (m_axi_arvalid && m_axi_arready) begin
                if (pending || m_axi_rvalid) $fatal(1,"Overlapping AXI burst");
                if (m_axi_araddr[3:0]!=0 || m_axi_arsize!=4 || m_axi_arburst!=1 || m_axi_arid!=0)
                    $fatal(1,"Invalid AXI geometry");
                if (({1'b0,m_axi_araddr[11:0]} + (({1'b0,m_axi_arlen}+1)*16)) > 4096)
                    $fatal(1,"Cross-page AXI burst");
                if (m_axi_arlen > 15) $fatal(1,"Burst cap");
                pending<=1; response_left<=m_axi_arlen+1; response_addr<=m_axi_araddr; bursts<=bursts+1;
            end
            if (m_axi_rvalid && m_axi_rready) begin
                m_axi_rvalid<=0; response_left<=response_left-1; response_addr<=response_addr+16;
                if (response_left==1) pending<=0;
            end
            if (pending && !m_axi_rvalid && cycle%5!=2) begin
                for(k=0;k<8;k=k+1) m_axi_rdata[k*16 +: 16] <= pixel_at(response_addr+2*k);
                m_axi_rvalid<=1; m_axi_rlast<=response_left==1; m_axi_rresp<=inject_error ? 2'b10 : 2'b00;
            end

            if (pixel_valid && pixel_ready) begin
                dx=received % expected_dst_w; dy=received / expected_dst_w;
                sx=expected_roi_x + (dx*expected_roi_w)/expected_dst_w;
                sy=expected_roi_y + (dy*expected_roi_h)/expected_dst_h;
                expected_addr=expected_base + sy*expected_stride + sx*2;
                if (pixel_keep==2'b11) begin
                    if (pixel_data[15:0]!==pixel_at(expected_addr)
                        || pixel_data[31:16]!==pixel_at(expected_base + sy*expected_stride
                                                        + (expected_roi_x + ((dx+1)*expected_roi_w)/expected_dst_w)*2))
                        $fatal(1,"Pair mismatch n=%0d got=%h expected_addr=%h",received,pixel_data,expected_addr);
                    if (dx+2>expected_dst_w) $fatal(1,"Pair beyond line");
                end else if (pixel_keep==2'b01) begin
                    if (pixel_data[15:0]!==pixel_at(expected_addr) || pixel_data[31:16]!==0)
                        $fatal(1,"Tail mismatch n=%0d got=%h",received,pixel_data);
                    if (dx+1!=expected_dst_w) $fatal(1,"Early tail");
                end else $fatal(1,"Invalid keep=%b",pixel_keep);
                if (pixel_sof !== (dx==0 && dy==0)
                    || pixel_eol !== (dx+((pixel_keep==2'b11)?2:1)==expected_dst_w)
                    || pixel_eof !== (dx+((pixel_keep==2'b11)?2:1)==expected_dst_w && dy==expected_dst_h-1))
                    $fatal(1,"Output flags mismatch n=%0d",received);
                if (pixel_frame_id!==expected_frame || pixel_config_id!==expected_config)
                    $fatal(1,"Output metadata mismatch");
                received<=received+((pixel_keep==2'b11)?2:1);
            end
        end
    end

    task automatic run_job(input bit bus_error);
        integer before_received;
        begin
            // Restore the canonical job after the previous mutation test.
            base_addr=32'hfd0; stride_bytes=40; frame_id=32'h1234; config_id=7;
            src_width=13; src_height=9; roi_x=3; roi_y=1; roi_w=7; roi_h=5;
            dst_width=11; dst_height=8;
            inject_error=bus_error; received=0; before_bursts=bursts; start_cycle=cycle;
            before_commands=commands; before_lines=lines; expected_line=0;
            expected_base=base_addr; expected_stride=stride_bytes;
            expected_dst_w=dst_width; expected_dst_h=dst_height;
            expected_roi_x=roi_x; expected_roi_y=roi_y; expected_roi_w=roi_w; expected_roi_h=roi_h;
            expected_frame=frame_id; expected_config=config_id;
            job_valid=1;
            while(!job_ready) @(posedge clk);
            @(posedge clk); @(negedge clk);
            // Active parameters and IDs are locked at the job handshake.
            base_addr=32'h00f0_0002; stride_bytes=202; frame_id=32'hdead_beef;
            config_id=32'hcafe_f00d; src_width=99; src_height=97;
            roi_x=7; roi_y=8; roi_w=5; roi_h=4; dst_width=3; dst_height=2;
            job_valid=0;
            while(!done) @(negedge clk);
            if (!bus_error && error) $fatal(1,"Unexpected integrated error");
            if (bus_error && !error) $fatal(1,"Bus error not propagated");
            if (!bus_error && received != expected_dst_w*expected_dst_h)
                $fatal(1,"Pixel count %0d",received);
            $display("PASS integrated error=%0d pixels=%0d bursts=%0d cycles=%0d",bus_error,received,bursts-before_bursts,cycle-start_cycle);
            inject_error=0;
            @(negedge clk);
        end
    endtask

    initial begin
        repeat(4) @(negedge clk); rst_n=1;
        run_job(0); run_job(1);
        $display("PASS tb_roi_axi_scaler cases=2"); $finish;
    end
    initial begin #3000000; $fatal(1,"Timeout tb_roi_axi_scaler"); end
endmodule

`default_nettype wire

