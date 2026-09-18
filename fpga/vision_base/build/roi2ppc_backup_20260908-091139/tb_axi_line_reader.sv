`timescale 1ns/1ps
module tb_axi_line_reader;
    reg clk=0, rst_n=0;
    always #5 clk=~clk;
    reg req_valid=0;
    wire req_ready;
    reg [31:0] req_addr=0;
    reg [15:0] req_pixels=0;
    wire pixel_valid,done,error;
    reg pixel_ready=0;
    wire [15:0] pixel_data;
    wire [3:0] arid;
    wire [31:0] araddr;
    wire [7:0] arlen;
    wire [2:0] arsize;
    wire [1:0] arburst;
    wire arvalid,rready;
    reg arready=0,rvalid=0,rlast=0;
    reg [127:0] rdata=0;
    reg [1:0] rresp=0;
    reg pending=0, inject_error=0;
    integer response_left=0,cycle=0,commands=0,received=0,tests=0;
    reg [31:0] response_addr=0, expected_addr=0;
    reg previous_stall=0;
    reg [15:0] previous_data=0;
    integer k;

    axi_line_reader dut(.*,
      .m_axi_arid(arid),.m_axi_araddr(araddr),.m_axi_arlen(arlen),
      .m_axi_arsize(arsize),.m_axi_arburst(arburst),.m_axi_arvalid(arvalid),
      .m_axi_arready(arready),.m_axi_rdata(rdata),.m_axi_rresp(rresp),
      .m_axi_rlast(rlast),.m_axi_rvalid(rvalid),.m_axi_rready(rready));
    function automatic [15:0] pixel_at(input [31:0] a);
        pixel_at = (a >> 1) ^ 16'h5a3c;
    endfunction

    // Behavioral AXI memory. Burst rules and stable R payload are checked here.
    always @(posedge clk) begin
        if (!rst_n) begin
            pending <= 0;
            rvalid <= 0;
            previous_stall <= 0;
        end else begin
            if (previous_stall && (!pixel_valid || pixel_data !== previous_data))
                $fatal(1,"Pixel changed while stalled");
            previous_stall <= pixel_valid && !pixel_ready;
            previous_data <= pixel_data;
            if (arvalid && arready) begin
                if (pending || rvalid) $fatal(1,"More than one burst in flight");
                if (araddr[3:0] != 0 || arsize != 4 || arburst != 1 || arid != 0)
                    $fatal(1,"Invalid AXI address command");
                if (({1'b0,araddr[11:0]} + (({1'b0,arlen}+1)*16)) > 4096)
                    $fatal(1,"Burst crossed 4 KiB");
                if (arlen > 15) $fatal(1,"Burst cap exceeded");
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
            if (pending && !rvalid && (cycle % 4 != 1)) begin
                for (k=0;k<8;k=k+1)
                    rdata[k*16 +: 16] <= pixel_at(response_addr+2*k);
                rvalid <= 1;
                rlast <= (response_left == 1);
                rresp <= inject_error ? 2'b10 : 2'b00;
            end
            if (pixel_valid && pixel_ready) begin
                if (pixel_data !== pixel_at(expected_addr + 2*received))
                    $fatal(1,"Pixel mismatch index=%0d",received);
                received <= received+1;
            end
        end
    end
    always @(negedge clk) begin
        cycle = cycle+1;
        arready = !pending && !rvalid && (cycle%3 != 0);
        pixel_ready = (cycle%5 != 2) && (cycle%7 != 3);
    end

    task automatic run_line(input [31:0] a,input [15:0] n,input bad,input bus_error);
        integer old_commands;
        begin
            @(negedge clk);
            expected_addr=a;received=0;old_commands=commands;inject_error=bus_error;
            req_addr=a;req_pixels=n;req_valid=1;
            @(posedge clk);
            while (!req_ready) @(posedge clk);
            @(negedge clk);req_valid=0;
            while (!done) @(negedge clk);
            if (error !== (bad || bus_error)) $fatal(1,"Error flag mismatch");
            if (received != (bad ? 0 : n)) $fatal(1,"Pixel count mismatch %0d",received);
            if (bad && commands != old_commands) $fatal(1,"Invalid request reached AXI");
            $display("CASE axi_line addr=%h pixels=%0d bursts=%0d error=%0d",a,n,commands-old_commands,error);
            tests=tests+1;
            @(negedge clk);
        end
    endtask
    initial begin
        repeat(4) @(negedge clk);
        rst_n=1;
        run_line(32'h1000,8,0,0);
        run_line(32'h1206,21,0,0);
        run_line(32'h0ffe,33,0,0);
        run_line(32'h1ff2,600,0,0);
        run_line(32'hffff_fffe,1,0,0);
        run_line(32'h2200,12,0,1);
        run_line(32'h1001,8,1,0);
        run_line(32'h1000,0,1,0);
        run_line(32'hffff_fffe,2,1,0);
        $display("PASS tb_axi_line_reader cases=%0d",tests);
        $finish;
    end
    initial begin #2000000; $fatal(1,"Timeout"); end
endmodule
