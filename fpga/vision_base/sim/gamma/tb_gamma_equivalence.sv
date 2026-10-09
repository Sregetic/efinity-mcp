`timescale 1ns/1ps
module tb_gamma_equivalence;
    parameter integer DATA_WIDTH = 8;
    parameter CURVE = "./rtl/gamma_conrrection/display_gamma_2p2.mem";
    localparam integer MASK = (1 << DATA_WIDTH) - 1;
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst_n = 0, de = 0, hs = 0, vs = 0;
    reg [DATA_WIDTH-1:0] r = 0, g = 0, b = 0;
    wire [DATA_WIDTH-1:0] nr, ng, nb, lr, lg, lb;
    wire nd, nh, nv, ld, lh, lv;
    reg [9:0] table10 [0:1023];
    integer checked = 0, legacy_checked = 0;
    integer i, j, ready_count = 0;
    reg compare_legacy = 0;
    reg [3:0] tone_seen = 0;
    reg [31:0] rng = 32'h71c2da95;
    reg [DATA_WIDTH-1:0] er, eg, eb;

    gamma_correction #(.DATA_WIDTH(DATA_WIDTH), .GAMMA_CURVE(CURVE)) dut (
        .i_pclk(clk), .i_rstn(rst_n), .i_valid(de), .i_hs(hs), .i_vs(vs),
        .i_red(r), .i_green(g), .i_blue(b),
        .o_red(nr), .o_green(ng), .o_blue(nb), .o_valid(nd), .o_hs(nh), .o_vs(nv)
    );
    gamma_correction_legacy_reference #(.DATA_WIDTH(DATA_WIDTH), .GAMMA_CURVE(CURVE)) ref_old (
        .i_pclk(clk), .i_rstn(rst_n), .i_valid(de), .i_hs(hs), .i_vs(vs),
        .i_red(r), .i_green(g), .i_blue(b),
        .o_red(lr), .o_green(lg), .o_blue(lb), .o_valid(ld), .o_hs(lh), .o_vs(lv)
    );

    function automatic [DATA_WIDTH-1:0] expected(input [DATA_WIDTH-1:0] value);
        integer address;
        begin
            if (DATA_WIDTH == 10) begin
                address = value;
                expected = table10[address];
            end else begin
                address = (value << 2) | (value >> 6);
                expected = table10[address] >> 2;
            end
        end
    endfunction

    task automatic tick(input bit reset_value, input bit valid_value,
                        input bit hs_value, input bit vs_value,
                        input integer rv, gv, bv);
        begin
            @(negedge clk);
            rst_n = reset_value; de = valid_value; hs = hs_value; vs = vs_value;
            r = rv; g = gv; b = bv;
            er = (reset_value && valid_value) ? expected(r) : 0;
            eg = (reset_value && valid_value) ? expected(g) : 0;
            eb = (reset_value && valid_value) ? expected(b) : 0;
            @(posedge clk); #1;
            checked = checked + 1;
            if ({nr,ng,nb,nd,nh,nv} !==
                {er,eg,eb,(reset_value && valid_value),
                 (reset_value && hs_value),(reset_value && vs_value)})
                $fatal(1, "golden mismatch width=%0d cycle=%0d rgb=%0d,%0d,%0d got=%h expected=%h",
                    DATA_WIDTH, checked, r,g,b, {nr,ng,nb,nd,nh,nv},
                    {er,eg,eb,(reset_value && valid_value),(reset_value && hs_value),(reset_value && vs_value)});
            if (compare_legacy) begin
                legacy_checked = legacy_checked + 1;
                if ({nr,ng,nb,nd,nh,nv} !== {lr,lg,lb,ld,lh,lv})
                    $fatal(1, "legacy mismatch width=%0d cycle=%0d", DATA_WIDTH, checked);
            end
        end
    endtask

    task automatic warm_reference;
        begin
            compare_legacy = 0;
            // Original continuously copied ROM needs to fill. The NEW DUT is
            // still checked against the independent table on EVERY warm-up tick.
            for (j=0; j<2056; j=j+1)
                tick(1,1,j[0],j[1],j, j*37+19, MASK-j);
            compare_legacy = 1;
        end
    endtask

    // Exercise the unchanged top-level three-stage legacy delay and tone mux
    // with the actual shared chroma path, for the board's 8-bit configuration.
    generate if (DATA_WIDTH == 8) begin: tone_integration
        wire cd, ch, cv, highlight;
        wire [23:0] chroma_rgb, linear_rgb, plain_rgb;
        reg [23:0] n1=0,n2=0,n3=0,l1=0,l2=0,l3=0;
        reg [1:0] tone=3, pending=3;
        reg vq=0;
        wire [23:0] new_tone = tone==0 ? linear_rgb :
            (tone==1 ? n3 : (tone==2 ? plain_rgb : chroma_rgb));
        wire [23:0] old_tone = tone==0 ? linear_rgb :
            (tone==1 ? l3 : (tone==2 ? plain_rgb : chroma_rgb));
        rgb_chroma_tone common_path (
            .clk(clk),.rst_n(rst_n),.de(de),.hs(hs),.vs(vs),.r(r),.g(g),.b(b),
            .ode(cd),.ohs(ch),.ovs(cv),.rgb(chroma_rgb),.linear_rgb(linear_rgb),
            .gain_r(16'd256),.gain_g(16'd256),.gain_b(16'd256),
            .plain_rgb(plain_rgb),.highlight_active(highlight),.freeze_tone(1'b0),.shadow_boost(1'b1)
        );
        always @(posedge clk) begin
            n1 <= {nr,ng,nb}; n2 <= n1; n3 <= n2;
            l1 <= {lr,lg,lb}; l2 <= l1; l3 <= l2;
            vq <= cv;
            if (cv && !vq) begin tone <= pending; pending <= pending+1'b1; end
            if (!rst_n) begin tone <= 3; pending <= 3; end
        end
        always @(negedge clk) begin
            if (!compare_legacy || !rst_n) ready_count = 0;
            else ready_count = ready_count + 1;
            if (ready_count > 8) begin
                tone_seen[tone] = 1'b1;
                if (new_tone !== old_tone)
                    $fatal(1,"tone mux/delay mismatch mode=%0d",tone);
            end
        end
    end endgenerate

    initial begin
        $readmemh(CURVE,table10);
        for (i=0;i<1024;i=i+1)
            if ((^table10[i]) === 1'bx) $fatal(1,"curve missing/incomplete at %0d",i);
        // Reset black, HS/VS reset, and first pixel after reset are independently checked.
        tick(0,1,1,1,MASK,0,MASK/2);
        tick(0,0,1,1,0,MASK,1);
        tick(1,1,1,0,MASK,MASK/2,0);
        warm_reference();
        // Exhaustive channel domain, distinct simultaneous addresses and permutations.
        for (i=0;i<=MASK;i=i+1) begin
            tick(1,1,1,0,i,(i*37+19)&MASK,MASK-i);
            tick(1,1,1,0,MASK-i,i,(i*73+7)&MASK);
            tick(1,1,1,0,(i*53+3)&MASK,MASK-i,i);
        end
        // Independent values, DE bubbles, sync changes and repeated frame starts.
        for (i=0;i<20000;i=i+1) begin
            rng = rng ^ (rng << 13); rng = rng ^ (rng >> 17); rng = rng ^ (rng << 5);
            tick(1,(i%13)!=0,(i%101)<91,(i%503)==0,
                 rng & MASK,(rng>>10)&MASK,(rng>>20)&MASK);
        end
        // Midstream reset: legacy refill is explicitly outside the equivalence
        // window; new reset/startup remains fully checked by the independent oracle.
        compare_legacy=0;
        tick(0,1,1,1,1,MASK,0);
        tick(1,1,1,1,0,1,MASK);
        warm_reference();
        for(i=0;i<=MASK;i=i+1) tick(1,1,1,0,i,MASK-i,(i*3)&MASK);
        for(i=0;i<40;i=i+1) tick(1,0,i[0],i[1],MASK,1,0);
        compare_legacy=0;
        repeat(4) tick(0,1,1,1,MASK,MASK,MASK);
        if (DATA_WIDTH == 8 && tone_seen !== 4'b1111)
            $fatal(1,"not all four tone modes were exercised: %b",tone_seen);
        $display("PASS gamma width=%0d checked=%0d legacy_checked=%0d curve=%s",
                 DATA_WIDTH,checked,legacy_checked,CURVE);
        $finish;
    end
    initial begin #10000000; $fatal(1,"gamma regression timeout"); end
endmodule
