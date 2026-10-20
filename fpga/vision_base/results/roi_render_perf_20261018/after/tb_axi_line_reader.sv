`timescale 1ns/1ps
`default_nettype none

module tb_axi_line_reader #(parameter FIFO_BEATS=64, MAX_BURST_BEATS=64);
    reg clk=0, rst_n=0;
    always #5 clk=~clk;
    reg req_valid=0;
    wire req_ready;
    reg [31:0] req_addr=0;
    reg [15:0] req_pixels=0;
    wire pixel_valid, done, error;
    reg pixel_ready=0;
    wire [31:0] pixel_data;
    wire [1:0] pixel_keep;
    wire [3:0] arid;
    wire [31:0] araddr;
    wire [7:0] arlen;
    wire [2:0] arsize;
    wire [1:0] arburst;
    wire arvalid, rready;
    reg arready=0, rvalid=0, rlast=0;
    reg [127:0] rdata=0;
    reg [1:0] rresp=0;
    reg pending=0, inject_error=0, pause_output=0;
    integer response_left=0, cycle=0, commands=0, received=0, tests=0;
    integer expected_base=0, expected_pixels=0, expected_index=0;
    integer bad_cases=0, cycle_start=0;
    reg [31:0] response_addr=0;
    reg previous_stall=0;
    reg [31:0] previous_data=0;
    reg [1:0] previous_keep=0;
    reg ar_stalled=0;
    reg [31:0] previous_araddr=0;
    reg [7:0] previous_arlen=0;
    integer k;

    axi_line_reader #(.MAX_BURST_BEATS(MAX_BURST_BEATS), .FIFO_BEATS(FIFO_BEATS)) dut (
      .clk(clk), .rst_n(rst_n), .req_valid(req_valid), .req_ready(req_ready),
      .req_addr(req_addr), .req_pixels(req_pixels), .pixel_valid(pixel_valid),
      .pixel_ready(pixel_ready), .pixel_data(pixel_data), .pixel_keep(pixel_keep),
      .done(done), .error(error), .m_axi_arid(arid), .m_axi_araddr(araddr),
      .m_axi_arlen(arlen), .m_axi_arsize(arsize), .m_axi_arburst(arburst),
      .m_axi_arvalid(arvalid), .m_axi_arready(arready), .m_axi_rdata(rdata),
      .m_axi_rresp(rresp), .m_axi_rlast(rlast), .m_axi_rvalid(rvalid),
      .m_axi_rready(rready));

    function automatic [15:0] pixel_at(input integer a);
        pixel_at = ((a >> 1) ^ (a >> 5) ^ 16'h5a3c ^ (a * 13));
    endfunction

    // Behavioral AXI memory.  It permits one burst in flight, checks INCR
    // geometry and holds R payload stable until RREADY.
    always @(posedge clk) begin
        if (!rst_n) begin
            pending <= 0;
            rvalid <= 0;
            previous_stall <= 0;
        end else begin
            if (previous_stall && (!pixel_valid
                || pixel_data !== previous_data || pixel_keep !== previous_keep))
                $fatal(1,"Pixel changed while stalled");
            previous_stall <= pixel_valid && !pixel_ready;
            if (ar_stalled && (araddr !== previous_araddr || arlen !== previous_arlen))
                $fatal(1,"AR payload changed while ARREADY=0");
            if (rvalid && !rready)
                $fatal(1,"Accepted burst stalled behind pixel unpacking");
            ar_stalled <= arvalid && !arready;
            previous_araddr <= araddr;
            previous_arlen <= arlen;
            previous_data <= pixel_data;
            previous_keep <= pixel_keep;

            if (arvalid && arready) begin
                if (pending || rvalid) $fatal(1,"More than one burst in flight");
                if (araddr[3:0] != 0 || arsize != 4 || arburst != 1 || arid != 0)
                    $fatal(1,"Invalid AXI command");
                if (({1'b0,araddr[11:0]} + (({1'b0,arlen}+1)*16)) > 4096)
                    $fatal(1,"Burst crossed 4 KiB");
                if (arlen >= MAX_BURST_BEATS) $fatal(1,"Burst cap exceeded");
                pending <= 1;
                response_left <= arlen+1;
                response_addr <= araddr;
                commands <= commands+1;
            end
            if (rvalid && rready) begin
                rvalid <= 0;
                response_left <= response_left-1;
                response_addr <= response_addr+16;
                if (response_left == 1) pending <= 0;
            end
            if (pending && !rvalid && (cycle % 5 != 1)) begin
                for (k=0;k<8;k=k+1)
                    rdata[k*16 +: 16] <= pixel_at(response_addr+2*k);
                rvalid <= 1;
                rlast <= (response_left == 1);
                rresp <= inject_error ? 2'b10 : 2'b00;
            end

            if (pixel_valid && pixel_ready) begin
                if (expected_index + ((pixel_keep == 2'b11) ? 2 : 1)
                    > expected_pixels)
                    $fatal(1,"Too many output pixels");
                if (pixel_keep == 2'b11) begin
                    if (pixel_data[15:0] !== pixel_at(expected_base+2*expected_index)
                        || pixel_data[31:16] !== pixel_at(expected_base+2*(expected_index+1)))
                        $fatal(1,"Pair mismatch index=%0d data=%h",expected_index,pixel_data);
                    expected_index <= expected_index+2;
                end else if (pixel_keep == 2'b01) begin
                    if (pixel_data[15:0] !== pixel_at(expected_base+2*expected_index)
                        || pixel_data[31:16] !== 0)
                        $fatal(1,"Tail mismatch index=%0d data=%h",expected_index,pixel_data);
                    expected_index <= expected_index+1;
                end else begin
                    $fatal(1,"Invalid keep=%b",pixel_keep);
                end
                received <= received + ((pixel_keep == 2'b11) ? 2 : 1);
            end
        end
    end

    always @(negedge clk) begin
        cycle = cycle+1;
        arready = !pending && !rvalid && (cycle%3 != 0);
        pixel_ready = !pause_output && (cycle%5 != 2) && (cycle%7 != 3);
    end

    task automatic run_line(input [31:0] a, input [15:0] n,
                            input bad, input bus_error);
        integer old_commands;
        begin
            @(negedge clk);
            expected_base=a; expected_pixels=n; expected_index=0; received=0;
            old_commands=commands; inject_error=bus_error; cycle_start=cycle;
            req_addr=a; req_pixels=n; req_valid=1;
            @(posedge clk);
            while (!req_ready) @(posedge clk);
            @(negedge clk); req_valid=0;
            while (!done) @(negedge clk);
            if (bad || bus_error) begin
                if (!error) $fatal(1,"Error flag missing");
                if (bad && commands != old_commands)
                    $fatal(1,"Invalid request reached AXI");
                if (bad && received != 0)
                    $fatal(1,"Invalid request emitted pixels");
                bad_cases=bad_cases+1;
            end else begin
                if (error) $fatal(1,"Unexpected reader error");
                if (received != n || expected_index != n)
                    $fatal(1,"Pixel count mismatch got=%0d expected=%0d",received,n);
            end
            $display("PASS case axi_line addr=%h pixels=%0d bursts=%0d cycles=%0d keep_tail=%0d error=%0d",
                     a,n,commands-old_commands,cycle-cycle_start,
                     (n%2),error);
            tests=tests+1;
            inject_error=0;
            @(negedge clk);
        end
    endtask

    initial begin
        repeat(4) @(negedge clk);
        rst_n=1;
        // Aligned, offset, 4-KiB split, large request, and max-end address.
        run_line(32'h1000,8,0,0);
        run_line(32'h1206,21,0,0);
        run_line(32'h0ffe,33,0,0);
        run_line(32'h1ff2,600,0,0);
        run_line(32'h4000,1280,0,0);
        run_line(32'hffff_fffe,1,0,0);
        run_line(32'h2200,12,0,1);
        run_line(32'h1001,8,1,0);
        run_line(32'h1000,0,1,0);
        run_line(32'hffff_fffe,2,1,0);
        // A paused pixel sink must not pin the shared bus inside an accepted R burst.
        pause_output=1;
        fork
            run_line(32'h8000,MAX_BURST_BEATS*24,0,0);
            begin
                wait(pending);
                repeat(200) @(negedge clk);
                if(pending || rvalid) $fatal(1,"Pixel sink stall retained shared AXI burst");
                pause_output=0;
            end
        join
        $display("PASS tb_axi_line_reader cases=%0d invalid=%0d",tests,bad_cases);
        $finish;
    end
    initial begin #2000000; $fatal(1,"Timeout"); end
endmodule

`default_nettype wire
