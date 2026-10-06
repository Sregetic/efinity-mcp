`timescale 1ns/1ps
// Synthesizable AXI service fixture, NOT a DDR controller or image source.
// Keeps the RGB565 engine physically placed/routed under the real board clock.
// Address-derived data and write checksum prevent pixel datapath pruning.
module frame_engine_timing_probe (
    input wire clk,rst_n,
    input wire [15:0] control_a,control_b,control_c,
    output reg [31:0] checksum,
    output wire active,
    output reg failed
);
    // Debug configuration is stable while a job runs. VIO changes take effect
    // on later jobs. These synchronizers are not a coherent bus transport.
    reg [15:0] a_meta,b_meta,c_meta,a,b,c;
    always @(posedge clk)begin
        a_meta<=control_a;b_meta<=control_b;c_meta<=control_c;
        a<=a_meta;b<=b_meta;c<=c_meta;
    end
    reg [1:0] state;
    reg [1:0] captured_bank;
    reg [31:0] epoch;
    wire cap_ready,cap_done_ready,job_ready,done,error,display_valid,pending;
    wire [1:0] cap_bank;
    wire [31:0] display_base,display_frame_id,display_config_id,last_cycles,deadline_misses;
    wire [31:0] araddr,awaddr;wire [7:0] arlen,awlen;
    wire arvalid,arready,rready,awvalid,awready,wlast,wvalid,wready,bready;
    reg rvalid,rlast,bvalid;
    reg [127:0] rdata;
    wire [127:0] wdata;wire [15:0] wstrb;
    reg read_active,write_active;
    reg [31:0] read_addr;
    reg [8:0] read_left,write_left;
    reg [3:0] b_delay;
    assign arready=!read_active && !rvalid;
    assign awready=!write_active && !bvalid && b_delay==0;
    assign wready=write_active;
    integer i;
    always @(posedge clk)begin
        if(!rst_n)begin
            state<=0;captured_bank<=0;epoch<=0;failed<=0;checksum<=0;
            rvalid<=0;rlast<=0;rdata<=0;read_active<=0;read_addr<=0;read_left<=0;
            write_active<=0;write_left<=0;b_delay<=0;bvalid<=0;
        end else begin
            case(state)
                0:if(cap_ready)begin captured_bank<=cap_bank;state<=1;end
                1:if(cap_done_ready)state<=2;
                2:if(job_ready)state<=3;
                3:if(done)begin state<=0;epoch<=epoch+1'b1;failed<=failed|error;end
            endcase
            if(arvalid && arready)begin read_active<=1;read_addr<=araddr;read_left<=arlen+1'b1;end
            if(rvalid && rready)begin
                rvalid<=0;read_addr<=read_addr+16;read_left<=read_left-1'b1;
                if(read_left==1)read_active<=0;
            end
            if(read_active && !rvalid)begin
                for(i=0;i<8;i=i+1)rdata[i*16+:16]<=read_addr[16:1]+i;
                rvalid<=1;rlast<=read_left==1;
            end
            if(awvalid && awready)begin write_active<=1;write_left<=awlen+1'b1;end
            if(wvalid && wready)begin
                checksum<=checksum ^ wdata[31:0] ^ wdata[63:32] ^ wdata[95:64] ^ wdata[127:96];
                write_left<=write_left-1'b1;
                if(wlast)begin write_active<=0;b_delay<=3;end
            end
            if(b_delay!=0)begin b_delay<=b_delay-1'b1;if(b_delay==1)bvalid<=1;end
            if(bvalid && bready)bvalid<=0;
        end
    end
    frame_render_engine engine (
        .clk(clk),.rst_n(rst_n),.cap_req_valid(state==0),.cap_req_ready(cap_ready),
        .cap_req_config_id(epoch),.cap_req_bank(cap_bank),.cap_done_valid(state==1),
        .cap_done_ready(cap_done_ready),.cap_done_bank(captured_bank),.cap_done_ok(1'b1),
        .analysis_acquire_valid(1'b0),.analysis_acquire_ready(),.analysis_release(1'b0),
        .analysis_hold_valid(),.analysis_hold_bank(),.analysis_hold_frame_id(),.analysis_hold_config_id(),
        .job_valid(state==2),.job_ready(job_ready),.freeze_source(1'b0),.release_source(1'b0),.job_config_id(epoch),
        .src_width(16'd1024+{8'b0,a[7:0]}),.src_height(16'd512+{8'b0,b[7:0]}),
        .roi_x({9'b0,c[6:0]}),.roi_y(16'd0),
        .roi_w(16'd1024+{8'b0,a[7:0]}-{9'b0,c[6:0]}),.roi_h(16'd512+{8'b0,b[7:0]}),
        .dst_width(16'd1920),.dst_height(16'd1080),.src_stride_bytes(32'd4096),.dst_stride_bytes(32'd3840),
        .vblank(1'b1),.display_valid(display_valid),.display_base(display_base),
        .display_frame_id(display_frame_id),.display_config_id(display_config_id),
        .done(done),.error(error),.busy(active),.pending(pending),.last_cycles(last_cycles),.deadline_misses(deadline_misses),
        .m_axi_arid(),.m_axi_araddr(araddr),.m_axi_arlen(arlen),.m_axi_arsize(),.m_axi_arburst(),
        .m_axi_arvalid(arvalid),.m_axi_arready(arready),.m_axi_rdata(rdata),.m_axi_rresp(2'b0),
        .m_axi_rlast(rlast),.m_axi_rvalid(rvalid),.m_axi_rready(rready),
        .m_axi_awid(),.m_axi_awaddr(awaddr),.m_axi_awlen(awlen),.m_axi_awsize(),.m_axi_awburst(),
        .m_axi_awvalid(awvalid),.m_axi_awready(awready),.m_axi_wdata(wdata),.m_axi_wstrb(wstrb),
        .m_axi_wlast(wlast),.m_axi_wvalid(wvalid),.m_axi_wready(wready),
        .m_axi_bresp(2'b0),.m_axi_bvalid(bvalid),.m_axi_bready(bready)
    );
endmodule
