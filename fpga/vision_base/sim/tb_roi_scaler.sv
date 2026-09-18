`timescale 1ns/1ps
`default_nettype none

module tb_roi_scaler;
    localparam integer MAX_LINE_PIXELS = 2560;
    logic clk=0, rst_n=0;
    always #5 clk=~clk;

    logic job_valid=0, job_ready;
    logic [31:0] base_addr=0, stride_bytes=0, frame_id=0, config_id=0;
    logic [15:0] src_width=0, src_height=0, roi_x=0, roi_y=0, roi_w=0, roi_h=0;
    logic [15:0] dst_width=0, dst_height=0;
    logic pixel_valid, pixel_ready=1;
    logic [31:0] pixel_data;
    logic [1:0] pixel_keep;
    logic pixel_sof, pixel_eol, pixel_eof;
    logic [31:0] pixel_frame_id, pixel_config_id;
    logic done, error;
    logic rd_cmd_valid, rd_cmd_ready;
    logic [31:0] rd_addr;
    logic [15:0] rd_pixels;
    logic rd_data_valid, rd_data_ready;
    logic [31:0] rd_data;
    logic [1:0] rd_keep;
    logic rd_error=0;

    roi_scaler #(.MAX_LINE_PIXELS(MAX_LINE_PIXELS)) dut (.*);

    integer case_no, base_i, src_w_i, src_h_i, stride_i, roi_x_i, roi_y_i;
    integer roi_w_i, roi_h_i, dst_w_i, dst_h_i, frame_i, config_i;
    integer expected_x, expected_y, accepted_pixels, pixel_errors, flag_errors, id_errors;
    integer command_count, command_errors, command_row_last, cycle, start_cycle, finish_cycle;
    integer issue_count, capture_count, output_accept_count;
    integer ready_phase, mem_state, mem_wait, mem_index, mem_beats, mem_row, mem_x0;
    integer mem_gap, command_delta, command_row, command_x;
    integer stall_seen, stall_errors, command_hold_seen, command_hold_errors;
    logic [31:0] stall_data;
    logic [1:0] stall_keep;
    logic stall_sof, stall_eol, stall_eof;
    logic [31:0] stall_frame, stall_config;
    logic [31:0] command_hold_addr;
    logic [15:0] command_hold_pixels;

    localparam MEM_IDLE=0, MEM_WAIT=1, MEM_SEND=2;
    function automatic [15:0] source_pattern(input integer sx, input integer sy);
        integer v;
        begin
            v = ((sx * 16'h0137) ^ (sy * 16'h028d)
                 ^ ((sx + 3 * sy) << 5) ^ (sx * sy));
            source_pattern = v[15:0];
        end
    endfunction
    function automatic integer src_x_for(input integer ox);
        src_x_for = roi_x_i + ((ox * roi_w_i) / dst_w_i);
    endfunction
    function automatic integer src_y_for(input integer oy);
        src_y_for = roi_y_i + ((oy * roi_h_i) / dst_h_i);
    endfunction

    // Backpressure includes real multi-cycle holds.  The checker below proves
    // every stream field is stable during a hold.
    always @(negedge clk) begin
        ready_phase = ready_phase + 1;
        pixel_ready <= ((ready_phase % 11) != 0) && ((ready_phase % 17) != 0);
    end

    assign rd_cmd_ready = (mem_state == MEM_IDLE) && ((cycle % 5) != 0);

    // 2PPC source-line responder with bounded command latency and response
    // gaps.  It deliberately accepts a keep01 tail for odd ROI widths.
    always @(posedge clk) begin
        if (!rst_n) begin
            mem_state <= MEM_IDLE; mem_wait <= 0; mem_gap <= 0;
            mem_index <= 0; mem_beats <= 0; mem_row <= 0; mem_x0 <= 0;
            rd_data_valid <= 0; rd_data <= 0; rd_keep <= 0;
            command_count <= 0; command_errors <= 0; command_row_last <= -1;
        end else begin
            rd_error <= 0;
            if (mem_state == MEM_IDLE) begin
                rd_data_valid <= 0;
                if (rd_cmd_valid && rd_cmd_ready) begin
                    command_delta = rd_addr - base_i;
                    if (stride_i <= 0 || command_delta < 0
                        || (command_delta % stride_i) != (roi_x_i * 2)
                        || (command_delta % 2) != 0
                        || rd_pixels != roi_w_i) begin
                        command_errors = command_errors + 1;
                        $display("ERROR command case=%0d addr=%08h pixels=%0d",case_no,rd_addr,rd_pixels);
                        command_row = -1; command_x = -1;
                    end else begin
                        command_row = command_delta / stride_i;
                        command_x = (command_delta % stride_i) / 2;
                        if (command_row < roi_y_i
                            || command_row >= roi_y_i + roi_h_i
                            || command_x != roi_x_i)
                            command_errors = command_errors + 1;
                        if (command_row_last > command_row)
                            command_errors = command_errors + 1;
                        command_row_last = command_row;
                    end
                    mem_row <= command_row; mem_x0 <= command_x;
                    mem_index <= 0; mem_beats <= (rd_pixels+1)/2;
                    mem_wait <= 1 + (command_count % 3);
                    mem_gap <= 0; mem_state <= MEM_WAIT;
                    command_count = command_count + 1;
                end
            end else if (mem_state == MEM_WAIT) begin
                rd_data_valid <= 0;
                if (mem_wait == 0) begin
                    rd_data[15:0] <= source_pattern(mem_x0 + 2*mem_index, mem_row);
                    if (2*mem_index + 1 < roi_w_i)
                        rd_data[31:16] <= source_pattern(mem_x0 + 2*mem_index + 1, mem_row);
                    else rd_data[31:16] <= 0;
                    rd_keep <= (2*mem_index + 1 < roi_w_i) ? 2'b11 : 2'b01;
                    rd_data_valid <= 1;
                    mem_state <= MEM_SEND;
                end else mem_wait <= mem_wait - 1;
            end else begin
                if (rd_data_valid && rd_data_ready) begin
                    if (mem_index == mem_beats-1) begin
                        rd_data_valid <= 0; mem_state <= MEM_IDLE; mem_index <= 0;
                    end else begin
                        mem_index <= mem_index + 1;
                        mem_gap <= 1 + ((mem_index + mem_row) % 3 == 0);
                        rd_data_valid <= 0;
                    end
                end else if (!rd_data_valid) begin
                    if (mem_gap == 0) begin
                        rd_data[15:0] <= source_pattern(mem_x0 + 2*mem_index, mem_row);
                        if (2*mem_index + 1 < roi_w_i)
                            rd_data[31:16] <= source_pattern(mem_x0 + 2*mem_index + 1, mem_row);
                        else rd_data[31:16] <= 0;
                        rd_keep <= (2*mem_index + 1 < roi_w_i) ? 2'b11 : 2'b01;
                        rd_data_valid <= 1;
                    end else mem_gap <= mem_gap - 1;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin cycle <= 0; issue_count <= 0; capture_count <= 0; output_accept_count <= 0; end
        else begin
            cycle <= cycle + 1;
            if (dut.read_issue_c) issue_count <= issue_count + 1;
            if (dut.capture_pending_c) capture_count <= capture_count + 1;
            if (pixel_valid && pixel_ready) output_accept_count <= output_accept_count + 1;
        end
    end

    always @(posedge clk) begin
        if (rst_n && pixel_valid && pixel_ready) begin
            if (pixel_keep == 2'b11) begin
                if (pixel_data[15:0] !== source_pattern(src_x_for(expected_x),src_y_for(expected_y))
                    || pixel_data[31:16] !== source_pattern(src_x_for(expected_x+1),src_y_for(expected_y))) begin
                    pixel_errors = pixel_errors + 1;
                    if (pixel_errors < 4) $display("ERROR pixel case=%0d xy=(%0d,%0d) got=%h exp=%h dutx=%0d dxty=%0d addr0=%0d addr1=%0d r0=%h r1=%h",case_no,expected_x,expected_y,pixel_data,source_pattern(src_x_for(expected_x),src_y_for(expected_y)),dut.x_src_r,dut.dst_x_r,dut.ram_raddr0,dut.ram_raddr1,dut.ram_rd0,dut.ram_rd1);
                end
                expected_x = expected_x + 2; accepted_pixels = accepted_pixels + 2;
            end else if (pixel_keep == 2'b01) begin
                if (pixel_data[15:0] !== source_pattern(src_x_for(expected_x),src_y_for(expected_y))
                    || pixel_data[31:16] !== 0) begin
                    pixel_errors = pixel_errors + 1;
                    if (pixel_errors < 4) $display("ERROR tail case=%0d xy=(%0d,%0d) got=%h",case_no,expected_x,expected_y,pixel_data);
                end
                expected_x = expected_x + 1; accepted_pixels = accepted_pixels + 1;
            end else begin
                pixel_errors = pixel_errors + 1;
            end
            if (pixel_sof !== (expected_y == 0 && (expected_x - ((pixel_keep==2'b11)?2:1)) == 0)) flag_errors=flag_errors+1;
            if (pixel_eol !== (expected_x >= dst_w_i)) flag_errors=flag_errors+1;
            if (pixel_eof !== (expected_x >= dst_w_i && expected_y == dst_h_i-1)) flag_errors=flag_errors+1;
            if (pixel_frame_id !== frame_i || pixel_config_id !== config_i) id_errors=id_errors+1;
            if (expected_x >= dst_w_i) begin expected_x=0; expected_y=expected_y+1; end
        end
    end

    always @(posedge clk) begin
        if (rst_n && dut.state == 3 && dut.load_active_r
            && dut.load_target_bank_r == dut.cur_bank_r)
            $fatal(1,"Line load overlaps current output bank");
        if (!rst_n) begin
            stall_seen<=0; command_hold_seen<=0;
        end else begin
            if (pixel_valid && !pixel_ready) begin
                if (stall_seen && (pixel_data!==stall_data || pixel_keep!==stall_keep
                    || pixel_sof!==stall_sof || pixel_eol!==stall_eol || pixel_eof!==stall_eof
                    || pixel_frame_id!==stall_frame || pixel_config_id!==stall_config)) begin
                    stall_errors=stall_errors+1;
                end
                if (!stall_seen) begin
                    stall_data<=pixel_data; stall_keep<=pixel_keep; stall_sof<=pixel_sof;
                    stall_eol<=pixel_eol; stall_eof<=pixel_eof; stall_frame<=pixel_frame_id; stall_config<=pixel_config_id;
                end
                stall_seen<=1;
            end else stall_seen<=0;
            if (rd_cmd_valid && !rd_cmd_ready) begin
                if (command_hold_seen && (rd_addr!==command_hold_addr || rd_pixels!==command_hold_pixels))
                    command_hold_errors=command_hold_errors+1;
                if (!command_hold_seen) begin command_hold_addr<=rd_addr; command_hold_pixels<=rd_pixels; end
                command_hold_seen<=1;
            end else command_hold_seen<=0;
        end
    end

    task automatic set_job(input integer b,sw,sh,st,rx,ry,rw,rh,dw,dh,fr,cf);
        begin
            base_addr=b; src_width=sw; src_height=sh; stride_bytes=st;
            roi_x=rx; roi_y=ry; roi_w=rw; roi_h=rh; dst_width=dw; dst_height=dh;
            frame_id=fr; config_id=cf;
        end
    endtask

    task automatic run_case(input integer no,b,sw,sh,st,rx,ry,rw,rh,dw,dh);
        begin
            case_no=no; base_i=b; src_w_i=sw; src_h_i=sh; stride_i=st;
            roi_x_i=rx; roi_y_i=ry; roi_w_i=rw; roi_h_i=rh; dst_w_i=dw; dst_h_i=dh;
            frame_i=32'h1000+no; config_i=32'h2000+no;
            expected_x=0; expected_y=0; accepted_pixels=0; pixel_errors=0; flag_errors=0; id_errors=0;
            command_count=0; command_errors=0; command_row_last=-1; stall_errors=0; command_hold_errors=0;
            start_cycle=cycle; issue_count=0; capture_count=0; output_accept_count=0;
            set_job(b,sw,sh,st,rx,ry,rw,rh,dw,dh,frame_i,config_i);
            job_valid=1;
            while (!job_ready) @(posedge clk);
            @(posedge clk); @(negedge clk);
            // Change every live job field after the handshake.  The locked
            // configuration/IDs must remain the values captured above.
            set_job(32'h00f0_0002,99,97,202,7,8,5,4,3,2,32'hdead_beef,32'hcafe_f00d);
            job_valid=0;
            while (!done) @(posedge clk);
            finish_cycle=cycle;
            if (accepted_pixels != dw*dh || expected_y != dh || expected_x != 0)
                $fatal(1,"Case %0d count=%0d endpoint=(%0d,%0d) expected=%0d",no,accepted_pixels,expected_x,expected_y,dw*dh);
            if (pixel_errors || flag_errors || id_errors || command_errors || stall_errors || command_hold_errors || error)
                $fatal(1,"Case %0d errors pixels=%0d flags=%0d ids=%0d cmds=%0d stalls=%0d holds=%0d error=%0d",no,pixel_errors,flag_errors,id_errors,command_errors,stall_errors,command_hold_errors,error);
            $display("PASS case=%0d pixels=%0d source_lines=%0d cycles=%0d beats=%0d issues=%0d captures=%0d accepts=%0d",no,accepted_pixels,command_count,finish_cycle-start_cycle,(dw+1)/2*dh,issue_count,capture_count,output_accept_count);
            @(negedge clk);
        end
    endtask


    task automatic run_invalid(input integer no,b,sw,sh,st,rx,ry,rw,rh,dw,dh);
        begin
            case_no=no; base_i=b; src_w_i=sw; src_h_i=sh; stride_i=st;
            roi_x_i=rx; roi_y_i=ry; roi_w_i=rw; roi_h_i=rh; dst_w_i=dw; dst_h_i=dh;
            command_count=0; command_errors=0; accepted_pixels=0;
            set_job(b,sw,sh,st,rx,ry,rw,rh,dw,dh,32'h3000+no,32'h4000+no);
            job_valid=1;
            while (!job_ready) @(posedge clk);
            @(posedge clk); @(negedge clk);
            set_job(32'h00f0_0002,99,97,202,7,8,5,4,3,2,32'hdead_beef,32'hcafe_f00d);
            job_valid=0;
            while (!done) @(posedge clk);
            if (!error || command_count != 0 || accepted_pixels != 0)
                $fatal(1,"Invalid case %0d visited memory or emitted output",no);
            $display("PASS invalid case=%0d no_memory_read=1",no);
            @(negedge clk);
        end
    endtask

    initial begin
        repeat(4) @(negedge clk); rst_n=1; ready_phase=0; cycle=0;
        run_case(1,32'h0001_0000,4,3,12,0,0,2,2,4,4);
        run_case(2,32'h0002_0000,8,6,20,1,1,6,4,3,2);
        run_case(3,32'h0003_0000,7,5,18,1,1,5,3,4,2);
        run_case(4,32'h0004_0000,9,6,24,2,2,4,3,7,5);
        run_invalid(5,32'h0005_0001,8,4,16,0,0,2,2,2,2);
        run_invalid(6,32'h0006_0000,8,4,17,0,0,2,2,2,2);
        run_invalid(7,32'h0007_0000,8,4,16,7,0,2,2,2,2);
        run_invalid(8,32'h0008_0000,3000,2,6000,0,0,2561,1,2,2);
        if ($test$plusargs("FULL")) begin
            run_case(90,32'h0100_0000,1920,1080,3840,0,0,1920,1080,1920,1080);
            run_case(91,32'h0200_0000,1280,720,2560,0,0,1280,720,1920,1080);
            run_case(92,32'h0300_0000,1920,1080,3840,480,270,960,540,1920,1080);
        end else $display("INFO FULL skipped; use +FULL=1 for 1080p cases");
        $display("PASS tb_roi_scaler"); $finish;
    end
    initial begin
        if ($test$plusargs("FULL")) #200_000_000; else #10_000_000;
        $fatal(1,"Timeout tb_roi_scaler");
    end
endmodule

`default_nettype wire




