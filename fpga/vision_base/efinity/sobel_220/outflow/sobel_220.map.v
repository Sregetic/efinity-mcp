
//
// Verific Verilog Description of module sobel_timing_top
//

module sobel_timing_top (CLK_25M, clk, fb, pll_rstn, result) /* verific EFX_ATTRIBUTE_NETLIST__EFINITY_VERSION=2026.1.132.3.9 */ ;
    input CLK_25M /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(2)
    input clk /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(2)
    input fb /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(2)
    output pll_rstn /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(2)
    output result /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(2)
    
    wire [71:0]stimulus;
    wire [1:0]direction;
    wire [10:0]mag;
    wire edge_pixel;
    wire [10:0]threshold;
    wire n9;
    wire n10;
    wire n8;
    
    wire n680, n681;
    wire [17:0]\dut/ax106_3 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(13)
    wire [10:0]\dut/n238 ;
    
    wire \dut/add_26/n10 , \threshold[0] ;
    wire [9:0]\dut/n202 ;
    
    wire n679;
    wire [10:0]\dut/n225 ;
    
    wire \dut/sub_25/add_2/n16 , \dut/add_26/n18 ;
    wire [9:0]\dut/n136 ;
    
    wire \dut/add_17/n2 ;
    wire [7:0]\dut/n148 ;
    
    wire \dut/add_18/n2 ;
    wire [9:0]\dut/n158 ;
    
    wire \dut/add_19/n2 ;
    wire [7:0]\dut/n170 ;
    
    wire \dut/add_20/n2 ;
    wire [9:0]\dut/n180 ;
    
    wire \dut/add_21/n2 ;
    wire [7:0]\dut/n192 ;
    
    wire \dut/add_22/n2 , \dut/add_23/n2 , \dut/add_26/n2 ;
    wire [10:0]\dut/n213 ;
    
    wire \dut/sub_24/add_2/n2 ;
    wire [17:0]\dut/ay106_3 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(13)
    wire [9:0]\dut/right1 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(8)
    
    wire \dut/add_23/n18 , \dut/add_18/n8 , \dut/add_23/n16 ;
    wire [9:0]\dut/top1 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(8)
    wire [9:0]\dut/bottom1 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(8)
    wire [9:0]\dut/left1 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(8)
    wire [10:0]\dut/ax2 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    wire [10:0]\dut/ay2 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    wire [10:0]\dut/t2 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(16)
    wire [10:0]\dut/mag3 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(11)
    wire [10:0]\dut/t3 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(16)
    
    wire \dut/signs3 , \dut/add_23/n14 , \dut/add_23/n12 , \dut/add_23/n10 , 
        \dut/add_23/n8 ;
    wire [7:0]\dut/n126 ;
    
    wire \dut/add_16/n2 , \dut/add_23/n6 , \dut/add_16/n4 , \dut/add_26/n14 , 
        \dut/sub_24/add_2/n4 , \dut/sub_24/add_2/n8 , \dut/sub_24/add_2/n12 , 
        \dut/sub_24/add_2/n16 , \dut/sub_24/add_2/n20 , \dut/sub_25/add_2/n4 , 
        \dut/sub_25/add_2/n8 , \dut/sub_25/add_2/n12 , \dut/sub_25/add_2/n20 , 
        \dut/add_26/n16 , \dut/sub_25/add_2/n14 , \dut/add_16/n6 , \dut/add_16/n8 , 
        \dut/add_26/n12 , \dut/add_26/n20 , \dut/sub_24/add_2/n6 , \dut/sub_24/add_2/n10 , 
        \dut/sub_24/add_2/n14 , \dut/sub_24/add_2/n18 , \dut/sub_25/add_2/n6 , 
        \dut/sub_25/add_2/n10 , \dut/sub_25/add_2/n18 , \dut/dff_56/i20_pre , 
        \dut/dff_56/i30_pre , \dut/dff_56/i40_pre , \dut/dff_56/i50_pre , 
        \dut/dff_56/i60_pre , \dut/dff_56/i6_pre , \dut/dff_56/i7_pre , 
        \dut/dff_56/i8_pre , \dut/dff_56/i9_pre , \dut/dff_56/i1_pre , 
        \dut/dff_56/i11_pre , \dut/dff_56/i12_pre , \dut/dff_56/i13_pre , 
        \dut/dff_56/i14_pre , \dut/dff_56/i15_pre , \dut/dff_56/i16_pre , 
        \dut/dff_56/i17_pre , \dut/dff_56/i18_pre , \dut/dff_56/i19_pre , 
        \dut/dff_56/i2_pre , \dut/dff_56/i21_pre , \dut/dff_56/i22_pre , 
        \dut/dff_56/i23_pre , \dut/dff_56/i24_pre , \dut/dff_56/i25_pre , 
        \dut/dff_56/i26_pre , \dut/dff_56/i27_pre , \dut/dff_56/i28_pre , 
        \dut/dff_56/i29_pre , \dut/dff_56/i3_pre , \dut/dff_56/i31_pre , 
        \dut/dff_56/i32_pre , \dut/dff_56/i33_pre , \dut/dff_56/i34_pre , 
        \dut/dff_56/i35_pre , \dut/dff_56/i36_pre , \dut/dff_56/i37_pre , 
        \dut/dff_56/i38_pre , \dut/dff_56/i39_pre , \dut/dff_56/i4_pre , 
        \dut/dff_56/i41_pre , \dut/dff_56/i42_pre , \dut/dff_56/i43_pre , 
        \dut/dff_56/i44_pre , \dut/dff_56/i45_pre , \dut/dff_56/i46_pre , 
        \dut/dff_56/i47_pre , \dut/dff_56/i48_pre , \dut/dff_56/i49_pre , 
        \dut/dff_56/i5_pre , \dut/dff_56/i51_pre , \dut/dff_56/i52_pre , 
        \dut/dff_56/i53_pre , \dut/dff_56/i54_pre , \dut/dff_56/i55_pre , 
        \dut/dff_56/i56_pre , \dut/dff_56/i57_pre , \dut/dff_56/i58_pre , 
        \dut/dff_56/i59_pre , \dut/add_23/n4 , \dut/n191 , \dut/add_22/n14 , 
        \dut/add_22/n12 , \dut/add_22/n10 , \dut/add_22/n8 ;
    wire [18:0]\dut/ax256_3 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(12)
    
    wire \dut/add_22/n6 , \dut/add_22/n4 , \dut/add_21/n18 , \dut/add_21/n16 , 
        \dut/add_21/n14 ;
    wire [18:0]\dut/ay256_3 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(12)
    
    wire \dut/dff_56/i10_pre , \dut/add_21/n12 , \dut/add_21/n10 , \dut/add_21/n8 , 
        \dut/add_21/n6 , \dut/add_21/n4 , \dut/n169 , \dut/add_20/n14 , 
        \dut/add_20/n12 , \dut/add_20/n10 , \dut/add_20/n8 , \dut/add_20/n6 , 
        \dut/add_20/n4 , \dut/add_19/n18 , \dut/add_18/n6 , \dut/add_18/n4 ;
    wire [10:0]\dut/t1 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(16)
    
    wire \dut/add_17/n18 , \dut/add_17/n16 ;
    wire [10:0]\dut/gx2 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(9)
    wire [10:0]\dut/gy2 ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(9)
    
    wire \dut/add_17/n14 , \dut/add_17/n12 , \dut/add_17/n10 , \dut/add_17/n8 , 
        \dut/add_17/n6 , \dut/add_17/n4 , \dut/n125 , \dut/add_16/n14 , 
        \dut/add_16/n12 , \dut/add_16/n10 , \dut/add_26/n8 , \dut/sub_25/add_2/n2 , 
        \dut/add_26/n6 , \dut/add_19/n16 , \dut/add_26/n4 , \stimulus[2] , 
        \stimulus[3] , \stimulus[4] , \stimulus[5] , \stimulus[7] , 
        \stimulus[9] , \stimulus[11] , \stimulus[12] , \stimulus[13] , 
        \stimulus[14] , \stimulus[15] , \stimulus[17] , \stimulus[18] , 
        \stimulus[19] , \stimulus[20] , \stimulus[22] , \stimulus[23] , 
        \stimulus[26] , \stimulus[27] , \stimulus[28] , \stimulus[29] , 
        \stimulus[31] , \stimulus[33] , \stimulus[35] , \stimulus[36] , 
        \stimulus[39] , \stimulus[43] , \stimulus[44] , \stimulus[45] , 
        \stimulus[46] , \stimulus[49] , \stimulus[50] , \stimulus[52] , 
        \stimulus[54] , \stimulus[58] , \stimulus[60] , \stimulus[61] , 
        \stimulus[65] , \stimulus[68] , \threshold[2] , \threshold[4] , 
        \threshold[5] , \threshold[8] , \dut/add_19/n14 , \dut/add_19/n12 , 
        \dut/add_19/n10 , \dut/add_19/n8 , \dut/add_19/n6 , \dut/add_19/n4 , 
        \dut/n147 , \dut/add_18/n14 , \dut/add_18/n12 , \dut/add_18/n10 , 
        n678, \dut/n1319 , \dut/n250 , \dut/n287 ;
    wire [1:0]\dut/n293 ;
    
    wire \dut/n288 , n601, n602, n603, n604, n605, n606, n607, 
        n608, n609, n610, n611, n612, n613, n614, n615, n616, 
        n617, n618, n619, n620, n621, n622, n623, n624, n625, 
        n626, n627, n628, n629, n630, n631, n632, n633, n634, 
        n635, n636, n637, n638, n639, n640, n641, n642, n643, 
        n644, n645, n646, n647, n648, n649, n650, n651, n652, 
        n653, n654, n655, n656, n657, n658, n659, n660, n661, 
        n662, n663, n664, n665, n666, n667, n668, n669, n670, 
        n671, n672, n673, n674, n675, n676, n677, n682, n683;
    
    assign pll_rstn = 1'b1 /* verific EFX_ATTRIBUTE_CELL_NAME=VCC */ ;
    EFX_ADD \dut/add_20/i8__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), .CI(n680), 
            .O(\dut/n169 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_20/i8__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \dut/add_20/i8__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_16/i8__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), .CI(n681), 
            .O(\dut/n125 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_16/i8__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \dut/add_16/i8__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_FF \threshold[0]~FF  (.D(n9), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\threshold[0] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[0]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[0]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[0]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[0]~FF .D_POLARITY = 1'b0;
    defparam \threshold[0]~FF .SR_SYNC = 1'b1;
    defparam \threshold[0]~FF .SR_VALUE = 1'b0;
    defparam \threshold[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \result~FF  (.D(n10), .CE(1'b1), .CLK(clk), .SR(1'b0), .Q(result)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \result~FF .CLK_POLARITY = 1'b1;
    defparam \result~FF .CE_POLARITY = 1'b1;
    defparam \result~FF .SR_POLARITY = 1'b1;
    defparam \result~FF .D_POLARITY = 1'b1;
    defparam \result~FF .SR_SYNC = 1'b1;
    defparam \result~FF .SR_VALUE = 1'b0;
    defparam \result~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[0]~FF  (.D(n8), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(stimulus[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[0]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[0]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[0]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[0]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[0]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[0]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \direction[0]~FF  (.D(\dut/n1319 ), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(direction[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \direction[0]~FF .CLK_POLARITY = 1'b1;
    defparam \direction[0]~FF .CE_POLARITY = 1'b1;
    defparam \direction[0]~FF .SR_POLARITY = 1'b1;
    defparam \direction[0]~FF .D_POLARITY = 1'b0;
    defparam \direction[0]~FF .SR_SYNC = 1'b1;
    defparam \direction[0]~FF .SR_VALUE = 1'b0;
    defparam \direction[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/right1[0]~FF  (.D(\dut/n158 [0]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/right1 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/right1[0]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/right1[0]~FF .CE_POLARITY = 1'b1;
    defparam \dut/right1[0]~FF .SR_POLARITY = 1'b1;
    defparam \dut/right1[0]~FF .D_POLARITY = 1'b1;
    defparam \dut/right1[0]~FF .SR_SYNC = 1'b1;
    defparam \dut/right1[0]~FF .SR_VALUE = 1'b0;
    defparam \dut/right1[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/top1[0]~FF  (.D(\dut/n180 [0]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/top1 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/top1[0]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/top1[0]~FF .CE_POLARITY = 1'b1;
    defparam \dut/top1[0]~FF .SR_POLARITY = 1'b1;
    defparam \dut/top1[0]~FF .D_POLARITY = 1'b1;
    defparam \dut/top1[0]~FF .SR_SYNC = 1'b1;
    defparam \dut/top1[0]~FF .SR_VALUE = 1'b0;
    defparam \dut/top1[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/bottom1[0]~FF  (.D(\dut/n202 [0]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/bottom1 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/bottom1[0]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/bottom1[0]~FF .CE_POLARITY = 1'b1;
    defparam \dut/bottom1[0]~FF .SR_POLARITY = 1'b1;
    defparam \dut/bottom1[0]~FF .D_POLARITY = 1'b1;
    defparam \dut/bottom1[0]~FF .SR_SYNC = 1'b1;
    defparam \dut/bottom1[0]~FF .SR_VALUE = 1'b0;
    defparam \dut/bottom1[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/left1[0]~FF  (.D(\dut/n136 [0]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/left1 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/left1[0]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/left1[0]~FF .CE_POLARITY = 1'b1;
    defparam \dut/left1[0]~FF .SR_POLARITY = 1'b1;
    defparam \dut/left1[0]~FF .D_POLARITY = 1'b1;
    defparam \dut/left1[0]~FF .SR_SYNC = 1'b1;
    defparam \dut/left1[0]~FF .SR_VALUE = 1'b0;
    defparam \dut/left1[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax2[0]~FF  (.D(\dut/n213 [0]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/ax2 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax2[0]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax2[0]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax2[0]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax2[0]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax2[0]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax2[0]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax2[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay2[0]~FF  (.D(\dut/n225 [0]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/ay2 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay2[0]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay2[0]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay2[0]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay2[0]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay2[0]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay2[0]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay2[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t2[0]~FF  (.D(threshold[1]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t2 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t2[0]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t2[0]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t2[0]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t2[0]~FF .D_POLARITY = 1'b1;
    defparam \dut/t2[0]~FF .SR_SYNC = 1'b1;
    defparam \dut/t2[0]~FF .SR_VALUE = 1'b0;
    defparam \dut/t2[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[0]~FF  (.D(\dut/n238 [0]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[0]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[0]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[0]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[0]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[0]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[0]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t3[0]~FF  (.D(\dut/t2 [0]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t3 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t3[0]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t3[0]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t3[0]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t3[0]~FF .D_POLARITY = 1'b1;
    defparam \dut/t3[0]~FF .SR_SYNC = 1'b1;
    defparam \dut/t3[0]~FF .SR_VALUE = 1'b0;
    defparam \dut/t3[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/signs3~FF  (.D(\dut/n250 ), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/signs3 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/signs3~FF .CLK_POLARITY = 1'b1;
    defparam \dut/signs3~FF .CE_POLARITY = 1'b1;
    defparam \dut/signs3~FF .SR_POLARITY = 1'b1;
    defparam \dut/signs3~FF .D_POLARITY = 1'b1;
    defparam \dut/signs3~FF .SR_SYNC = 1'b1;
    defparam \dut/signs3~FF .SR_VALUE = 1'b0;
    defparam \dut/signs3~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[0]~FF  (.D(\dut/mag3 [0]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[0]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[0]~FF .CE_POLARITY = 1'b1;
    defparam \mag[0]~FF .SR_POLARITY = 1'b1;
    defparam \mag[0]~FF .D_POLARITY = 1'b1;
    defparam \mag[0]~FF .SR_SYNC = 1'b1;
    defparam \mag[0]~FF .SR_VALUE = 1'b0;
    defparam \mag[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \edge_pixel~FF  (.D(\dut/n287 ), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(edge_pixel)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \edge_pixel~FF .CLK_POLARITY = 1'b1;
    defparam \edge_pixel~FF .CE_POLARITY = 1'b1;
    defparam \edge_pixel~FF .SR_POLARITY = 1'b1;
    defparam \edge_pixel~FF .D_POLARITY = 1'b1;
    defparam \edge_pixel~FF .SR_SYNC = 1'b1;
    defparam \edge_pixel~FF .SR_VALUE = 1'b0;
    defparam \edge_pixel~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[8]~FF  (.D(\dut/ax2 [0]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[8]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[8]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[8]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[8]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[8]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[8]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[9]~FF  (.D(\dut/ax2 [1]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[9]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[9]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[9]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[9]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[9]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[9]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[10]~FF  (.D(\dut/ax2 [2]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[10]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[10]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[10]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[10]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[10]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[10]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[11]~FF  (.D(\dut/ax2 [3]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[11]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[11]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[11]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[11]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[11]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[11]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[12]~FF  (.D(\dut/ax2 [4]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[12]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[12]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[12]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[12]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[12]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[12]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[13]~FF  (.D(\dut/ax2 [5]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[13]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[13]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[13]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[13]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[13]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[13]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[14]~FF  (.D(\dut/ax2 [6]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[14]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[14]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[14]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[14]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[14]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[14]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[15]~FF  (.D(\dut/ax2 [7]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[15]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[15]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[15]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[15]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[15]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[15]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[16]~FF  (.D(\dut/ax2 [8]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[16]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[16]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[16]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[16]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[16]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[16]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[17]~FF  (.D(\dut/ax2 [9]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[17]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[17]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[17]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[17]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[17]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[17]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ax256_3[18]~FF  (.D(\dut/ax2 [10]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ax256_3 [18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ax256_3[18]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ax256_3[18]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ax256_3[18]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ax256_3[18]~FF .D_POLARITY = 1'b1;
    defparam \dut/ax256_3[18]~FF .SR_SYNC = 1'b1;
    defparam \dut/ax256_3[18]~FF .SR_VALUE = 1'b0;
    defparam \dut/ax256_3[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[8]~FF  (.D(\dut/ay2 [0]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[8]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[8]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[8]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[8]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[8]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[8]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[9]~FF  (.D(\dut/ay2 [1]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[9]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[9]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[9]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[9]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[9]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[9]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[10]~FF  (.D(\dut/ay2 [2]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[10]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[10]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[10]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[10]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[10]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[10]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[11]~FF  (.D(\dut/ay2 [3]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[11]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[11]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[11]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[11]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[11]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[11]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[12]~FF  (.D(\dut/ay2 [4]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[12]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[12]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[12]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[12]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[12]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[12]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[13]~FF  (.D(\dut/ay2 [5]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[13]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[13]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[13]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[13]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[13]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[13]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[14]~FF  (.D(\dut/ay2 [6]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[14]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[14]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[14]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[14]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[14]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[14]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[15]~FF  (.D(\dut/ay2 [7]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[15]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[15]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[15]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[15]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[15]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[15]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[16]~FF  (.D(\dut/ay2 [8]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[16]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[16]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[16]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[16]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[16]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[16]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[17]~FF  (.D(\dut/ay2 [9]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[17]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[17]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[17]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[17]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[17]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[17]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/ay256_3[18]~FF  (.D(\dut/ay2 [10]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/ay256_3 [18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/ay256_3[18]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/ay256_3[18]~FF .CE_POLARITY = 1'b1;
    defparam \dut/ay256_3[18]~FF .SR_POLARITY = 1'b1;
    defparam \dut/ay256_3[18]~FF .D_POLARITY = 1'b1;
    defparam \dut/ay256_3[18]~FF .SR_SYNC = 1'b1;
    defparam \dut/ay256_3[18]~FF .SR_VALUE = 1'b0;
    defparam \dut/ay256_3[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t1[3]~FF  (.D(threshold[3]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t1 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t1[3]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t1[3]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t1[3]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t1[3]~FF .D_POLARITY = 1'b1;
    defparam \dut/t1[3]~FF .SR_SYNC = 1'b1;
    defparam \dut/t1[3]~FF .SR_VALUE = 1'b0;
    defparam \dut/t1[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t1[4]~FF  (.D(\threshold[4] ), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t1 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t1[4]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t1[4]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t1[4]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t1[4]~FF .D_POLARITY = 1'b0;
    defparam \dut/t1[4]~FF .SR_SYNC = 1'b1;
    defparam \dut/t1[4]~FF .SR_VALUE = 1'b0;
    defparam \dut/t1[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t1[7]~FF  (.D(threshold[7]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t1 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t1[7]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t1[7]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t1[7]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t1[7]~FF .D_POLARITY = 1'b1;
    defparam \dut/t1[7]~FF .SR_SYNC = 1'b1;
    defparam \dut/t1[7]~FF .SR_VALUE = 1'b0;
    defparam \dut/t1[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t1[10]~FF  (.D(threshold[10]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t1 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t1[10]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t1[10]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t1[10]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t1[10]~FF .D_POLARITY = 1'b1;
    defparam \dut/t1[10]~FF .SR_SYNC = 1'b1;
    defparam \dut/t1[10]~FF .SR_VALUE = 1'b0;
    defparam \dut/t1[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gx2[1]~FF  (.D(\dut/n213 [1]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gx2 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gx2[1]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gx2[1]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gx2[1]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gx2[1]~FF .D_POLARITY = 1'b1;
    defparam \dut/gx2[1]~FF .SR_SYNC = 1'b1;
    defparam \dut/gx2[1]~FF .SR_VALUE = 1'b0;
    defparam \dut/gx2[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gx2[2]~FF  (.D(\dut/n213 [2]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gx2 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gx2[2]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gx2[2]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gx2[2]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gx2[2]~FF .D_POLARITY = 1'b1;
    defparam \dut/gx2[2]~FF .SR_SYNC = 1'b1;
    defparam \dut/gx2[2]~FF .SR_VALUE = 1'b0;
    defparam \dut/gx2[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gx2[3]~FF  (.D(\dut/n213 [3]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gx2 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gx2[3]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gx2[3]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gx2[3]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gx2[3]~FF .D_POLARITY = 1'b1;
    defparam \dut/gx2[3]~FF .SR_SYNC = 1'b1;
    defparam \dut/gx2[3]~FF .SR_VALUE = 1'b0;
    defparam \dut/gx2[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gx2[4]~FF  (.D(\dut/n213 [4]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gx2 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gx2[4]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gx2[4]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gx2[4]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gx2[4]~FF .D_POLARITY = 1'b1;
    defparam \dut/gx2[4]~FF .SR_SYNC = 1'b1;
    defparam \dut/gx2[4]~FF .SR_VALUE = 1'b0;
    defparam \dut/gx2[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gx2[5]~FF  (.D(\dut/n213 [5]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gx2 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gx2[5]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gx2[5]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gx2[5]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gx2[5]~FF .D_POLARITY = 1'b1;
    defparam \dut/gx2[5]~FF .SR_SYNC = 1'b1;
    defparam \dut/gx2[5]~FF .SR_VALUE = 1'b0;
    defparam \dut/gx2[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gx2[6]~FF  (.D(\dut/n213 [6]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gx2 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gx2[6]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gx2[6]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gx2[6]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gx2[6]~FF .D_POLARITY = 1'b1;
    defparam \dut/gx2[6]~FF .SR_SYNC = 1'b1;
    defparam \dut/gx2[6]~FF .SR_VALUE = 1'b0;
    defparam \dut/gx2[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gx2[7]~FF  (.D(\dut/n213 [7]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gx2 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gx2[7]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gx2[7]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gx2[7]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gx2[7]~FF .D_POLARITY = 1'b1;
    defparam \dut/gx2[7]~FF .SR_SYNC = 1'b1;
    defparam \dut/gx2[7]~FF .SR_VALUE = 1'b0;
    defparam \dut/gx2[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gx2[8]~FF  (.D(\dut/n213 [8]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gx2 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gx2[8]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gx2[8]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gx2[8]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gx2[8]~FF .D_POLARITY = 1'b1;
    defparam \dut/gx2[8]~FF .SR_SYNC = 1'b1;
    defparam \dut/gx2[8]~FF .SR_VALUE = 1'b0;
    defparam \dut/gx2[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gx2[9]~FF  (.D(\dut/n213 [9]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gx2 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gx2[9]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gx2[9]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gx2[9]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gx2[9]~FF .D_POLARITY = 1'b1;
    defparam \dut/gx2[9]~FF .SR_SYNC = 1'b1;
    defparam \dut/gx2[9]~FF .SR_VALUE = 1'b0;
    defparam \dut/gx2[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gx2[10]~FF  (.D(\dut/n213 [10]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/gx2 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gx2[10]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gx2[10]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gx2[10]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gx2[10]~FF .D_POLARITY = 1'b1;
    defparam \dut/gx2[10]~FF .SR_SYNC = 1'b1;
    defparam \dut/gx2[10]~FF .SR_VALUE = 1'b0;
    defparam \dut/gx2[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gy2[1]~FF  (.D(\dut/n225 [1]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gy2 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gy2[1]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gy2[1]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gy2[1]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gy2[1]~FF .D_POLARITY = 1'b1;
    defparam \dut/gy2[1]~FF .SR_SYNC = 1'b1;
    defparam \dut/gy2[1]~FF .SR_VALUE = 1'b0;
    defparam \dut/gy2[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gy2[2]~FF  (.D(\dut/n225 [2]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gy2 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gy2[2]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gy2[2]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gy2[2]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gy2[2]~FF .D_POLARITY = 1'b1;
    defparam \dut/gy2[2]~FF .SR_SYNC = 1'b1;
    defparam \dut/gy2[2]~FF .SR_VALUE = 1'b0;
    defparam \dut/gy2[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gy2[3]~FF  (.D(\dut/n225 [3]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gy2 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gy2[3]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gy2[3]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gy2[3]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gy2[3]~FF .D_POLARITY = 1'b1;
    defparam \dut/gy2[3]~FF .SR_SYNC = 1'b1;
    defparam \dut/gy2[3]~FF .SR_VALUE = 1'b0;
    defparam \dut/gy2[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gy2[4]~FF  (.D(\dut/n225 [4]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gy2 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gy2[4]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gy2[4]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gy2[4]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gy2[4]~FF .D_POLARITY = 1'b1;
    defparam \dut/gy2[4]~FF .SR_SYNC = 1'b1;
    defparam \dut/gy2[4]~FF .SR_VALUE = 1'b0;
    defparam \dut/gy2[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gy2[5]~FF  (.D(\dut/n225 [5]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gy2 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gy2[5]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gy2[5]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gy2[5]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gy2[5]~FF .D_POLARITY = 1'b1;
    defparam \dut/gy2[5]~FF .SR_SYNC = 1'b1;
    defparam \dut/gy2[5]~FF .SR_VALUE = 1'b0;
    defparam \dut/gy2[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gy2[6]~FF  (.D(\dut/n225 [6]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gy2 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gy2[6]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gy2[6]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gy2[6]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gy2[6]~FF .D_POLARITY = 1'b1;
    defparam \dut/gy2[6]~FF .SR_SYNC = 1'b1;
    defparam \dut/gy2[6]~FF .SR_VALUE = 1'b0;
    defparam \dut/gy2[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gy2[7]~FF  (.D(\dut/n225 [7]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gy2 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gy2[7]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gy2[7]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gy2[7]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gy2[7]~FF .D_POLARITY = 1'b1;
    defparam \dut/gy2[7]~FF .SR_SYNC = 1'b1;
    defparam \dut/gy2[7]~FF .SR_VALUE = 1'b0;
    defparam \dut/gy2[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gy2[8]~FF  (.D(\dut/n225 [8]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gy2 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gy2[8]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gy2[8]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gy2[8]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gy2[8]~FF .D_POLARITY = 1'b1;
    defparam \dut/gy2[8]~FF .SR_SYNC = 1'b1;
    defparam \dut/gy2[8]~FF .SR_VALUE = 1'b0;
    defparam \dut/gy2[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gy2[9]~FF  (.D(\dut/n225 [9]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/gy2 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gy2[9]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gy2[9]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gy2[9]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gy2[9]~FF .D_POLARITY = 1'b1;
    defparam \dut/gy2[9]~FF .SR_SYNC = 1'b1;
    defparam \dut/gy2[9]~FF .SR_VALUE = 1'b0;
    defparam \dut/gy2[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/gy2[10]~FF  (.D(\dut/n225 [10]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/gy2 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/gy2[10]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/gy2[10]~FF .CE_POLARITY = 1'b1;
    defparam \dut/gy2[10]~FF .SR_POLARITY = 1'b1;
    defparam \dut/gy2[10]~FF .D_POLARITY = 1'b1;
    defparam \dut/gy2[10]~FF .SR_SYNC = 1'b1;
    defparam \dut/gy2[10]~FF .SR_VALUE = 1'b0;
    defparam \dut/gy2[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t2[3]~FF  (.D(\dut/t1 [3]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t2 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t2[3]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t2[3]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t2[3]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t2[3]~FF .D_POLARITY = 1'b1;
    defparam \dut/t2[3]~FF .SR_SYNC = 1'b1;
    defparam \dut/t2[3]~FF .SR_VALUE = 1'b0;
    defparam \dut/t2[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t2[4]~FF  (.D(\dut/t1 [4]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t2 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t2[4]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t2[4]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t2[4]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t2[4]~FF .D_POLARITY = 1'b1;
    defparam \dut/t2[4]~FF .SR_SYNC = 1'b1;
    defparam \dut/t2[4]~FF .SR_VALUE = 1'b0;
    defparam \dut/t2[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t2[7]~FF  (.D(\dut/t1 [7]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t2 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t2[7]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t2[7]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t2[7]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t2[7]~FF .D_POLARITY = 1'b1;
    defparam \dut/t2[7]~FF .SR_SYNC = 1'b1;
    defparam \dut/t2[7]~FF .SR_VALUE = 1'b0;
    defparam \dut/t2[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t2[10]~FF  (.D(\dut/t1 [10]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t2 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t2[10]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t2[10]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t2[10]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t2[10]~FF .D_POLARITY = 1'b1;
    defparam \dut/t2[10]~FF .SR_SYNC = 1'b1;
    defparam \dut/t2[10]~FF .SR_VALUE = 1'b0;
    defparam \dut/t2[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[1]~FF  (.D(\dut/n238 [1]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[1]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[1]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[1]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[1]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[1]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[1]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[2]~FF  (.D(\dut/n238 [2]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[2]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[2]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[2]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[2]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[2]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[2]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[3]~FF  (.D(\dut/n238 [3]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[3]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[3]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[3]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[3]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[3]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[3]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[4]~FF  (.D(\dut/n238 [4]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[4]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[4]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[4]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[4]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[4]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[4]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[5]~FF  (.D(\dut/n238 [5]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[5]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[5]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[5]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[5]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[5]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[5]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[6]~FF  (.D(\dut/n238 [6]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[6]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[6]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[6]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[6]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[6]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[6]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[7]~FF  (.D(\dut/n238 [7]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[7]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[7]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[7]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[7]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[7]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[7]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[8]~FF  (.D(\dut/n238 [8]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[8]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[8]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[8]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[8]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[8]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[8]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[9]~FF  (.D(\dut/n238 [9]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[9]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[9]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[9]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[9]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[9]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[9]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/mag3[10]~FF  (.D(\dut/n238 [10]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/mag3 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/mag3[10]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/mag3[10]~FF .CE_POLARITY = 1'b1;
    defparam \dut/mag3[10]~FF .SR_POLARITY = 1'b1;
    defparam \dut/mag3[10]~FF .D_POLARITY = 1'b1;
    defparam \dut/mag3[10]~FF .SR_SYNC = 1'b1;
    defparam \dut/mag3[10]~FF .SR_VALUE = 1'b0;
    defparam \dut/mag3[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t3[1]~FF  (.D(\dut/t3 [0]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t3 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t3[1]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t3[1]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t3[1]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t3[1]~FF .D_POLARITY = 1'b1;
    defparam \dut/t3[1]~FF .SR_SYNC = 1'b1;
    defparam \dut/t3[1]~FF .SR_VALUE = 1'b0;
    defparam \dut/t3[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t3[3]~FF  (.D(\dut/t2 [3]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t3 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t3[3]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t3[3]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t3[3]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t3[3]~FF .D_POLARITY = 1'b1;
    defparam \dut/t3[3]~FF .SR_SYNC = 1'b1;
    defparam \dut/t3[3]~FF .SR_VALUE = 1'b0;
    defparam \dut/t3[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t3[4]~FF  (.D(\dut/t2 [4]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t3 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t3[4]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t3[4]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t3[4]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t3[4]~FF .D_POLARITY = 1'b1;
    defparam \dut/t3[4]~FF .SR_SYNC = 1'b1;
    defparam \dut/t3[4]~FF .SR_VALUE = 1'b0;
    defparam \dut/t3[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t3[7]~FF  (.D(\dut/t2 [7]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t3 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t3[7]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t3[7]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t3[7]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t3[7]~FF .D_POLARITY = 1'b1;
    defparam \dut/t3[7]~FF .SR_SYNC = 1'b1;
    defparam \dut/t3[7]~FF .SR_VALUE = 1'b0;
    defparam \dut/t3[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/t3[10]~FF  (.D(\dut/t2 [10]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\dut/t3 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/t3[10]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/t3[10]~FF .CE_POLARITY = 1'b1;
    defparam \dut/t3[10]~FF .SR_POLARITY = 1'b1;
    defparam \dut/t3[10]~FF .D_POLARITY = 1'b1;
    defparam \dut/t3[10]~FF .SR_SYNC = 1'b1;
    defparam \dut/t3[10]~FF .SR_VALUE = 1'b0;
    defparam \dut/t3[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[1]~FF  (.D(\dut/mag3 [1]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[1]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[1]~FF .CE_POLARITY = 1'b1;
    defparam \mag[1]~FF .SR_POLARITY = 1'b1;
    defparam \mag[1]~FF .D_POLARITY = 1'b1;
    defparam \mag[1]~FF .SR_SYNC = 1'b1;
    defparam \mag[1]~FF .SR_VALUE = 1'b0;
    defparam \mag[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[2]~FF  (.D(\dut/mag3 [2]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[2]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[2]~FF .CE_POLARITY = 1'b1;
    defparam \mag[2]~FF .SR_POLARITY = 1'b1;
    defparam \mag[2]~FF .D_POLARITY = 1'b1;
    defparam \mag[2]~FF .SR_SYNC = 1'b1;
    defparam \mag[2]~FF .SR_VALUE = 1'b0;
    defparam \mag[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[3]~FF  (.D(\dut/mag3 [3]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[3]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[3]~FF .CE_POLARITY = 1'b1;
    defparam \mag[3]~FF .SR_POLARITY = 1'b1;
    defparam \mag[3]~FF .D_POLARITY = 1'b1;
    defparam \mag[3]~FF .SR_SYNC = 1'b1;
    defparam \mag[3]~FF .SR_VALUE = 1'b0;
    defparam \mag[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[4]~FF  (.D(\dut/mag3 [4]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[4]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[4]~FF .CE_POLARITY = 1'b1;
    defparam \mag[4]~FF .SR_POLARITY = 1'b1;
    defparam \mag[4]~FF .D_POLARITY = 1'b1;
    defparam \mag[4]~FF .SR_SYNC = 1'b1;
    defparam \mag[4]~FF .SR_VALUE = 1'b0;
    defparam \mag[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[5]~FF  (.D(\dut/mag3 [5]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[5]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[5]~FF .CE_POLARITY = 1'b1;
    defparam \mag[5]~FF .SR_POLARITY = 1'b1;
    defparam \mag[5]~FF .D_POLARITY = 1'b1;
    defparam \mag[5]~FF .SR_SYNC = 1'b1;
    defparam \mag[5]~FF .SR_VALUE = 1'b0;
    defparam \mag[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[6]~FF  (.D(\dut/mag3 [6]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[6]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[6]~FF .CE_POLARITY = 1'b1;
    defparam \mag[6]~FF .SR_POLARITY = 1'b1;
    defparam \mag[6]~FF .D_POLARITY = 1'b1;
    defparam \mag[6]~FF .SR_SYNC = 1'b1;
    defparam \mag[6]~FF .SR_VALUE = 1'b0;
    defparam \mag[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[7]~FF  (.D(\dut/mag3 [7]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[7]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[7]~FF .CE_POLARITY = 1'b1;
    defparam \mag[7]~FF .SR_POLARITY = 1'b1;
    defparam \mag[7]~FF .D_POLARITY = 1'b1;
    defparam \mag[7]~FF .SR_SYNC = 1'b1;
    defparam \mag[7]~FF .SR_VALUE = 1'b0;
    defparam \mag[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[8]~FF  (.D(\dut/mag3 [8]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[8]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[8]~FF .CE_POLARITY = 1'b1;
    defparam \mag[8]~FF .SR_POLARITY = 1'b1;
    defparam \mag[8]~FF .D_POLARITY = 1'b1;
    defparam \mag[8]~FF .SR_SYNC = 1'b1;
    defparam \mag[8]~FF .SR_VALUE = 1'b0;
    defparam \mag[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[9]~FF  (.D(\dut/mag3 [9]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[9]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[9]~FF .CE_POLARITY = 1'b1;
    defparam \mag[9]~FF .SR_POLARITY = 1'b1;
    defparam \mag[9]~FF .D_POLARITY = 1'b1;
    defparam \mag[9]~FF .SR_SYNC = 1'b1;
    defparam \mag[9]~FF .SR_VALUE = 1'b0;
    defparam \mag[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \mag[10]~FF  (.D(\dut/mag3 [10]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(mag[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \mag[10]~FF .CLK_POLARITY = 1'b1;
    defparam \mag[10]~FF .CE_POLARITY = 1'b1;
    defparam \mag[10]~FF .SR_POLARITY = 1'b1;
    defparam \mag[10]~FF .D_POLARITY = 1'b1;
    defparam \mag[10]~FF .SR_SYNC = 1'b1;
    defparam \mag[10]~FF .SR_VALUE = 1'b0;
    defparam \mag[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/right1[1]~FF  (.D(\dut/n158 [1]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/right1 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/right1[1]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/right1[1]~FF .CE_POLARITY = 1'b1;
    defparam \dut/right1[1]~FF .SR_POLARITY = 1'b1;
    defparam \dut/right1[1]~FF .D_POLARITY = 1'b1;
    defparam \dut/right1[1]~FF .SR_SYNC = 1'b1;
    defparam \dut/right1[1]~FF .SR_VALUE = 1'b0;
    defparam \dut/right1[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/right1[2]~FF  (.D(\dut/n158 [2]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/right1 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/right1[2]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/right1[2]~FF .CE_POLARITY = 1'b1;
    defparam \dut/right1[2]~FF .SR_POLARITY = 1'b1;
    defparam \dut/right1[2]~FF .D_POLARITY = 1'b1;
    defparam \dut/right1[2]~FF .SR_SYNC = 1'b1;
    defparam \dut/right1[2]~FF .SR_VALUE = 1'b0;
    defparam \dut/right1[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/right1[3]~FF  (.D(\dut/n158 [3]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/right1 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/right1[3]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/right1[3]~FF .CE_POLARITY = 1'b1;
    defparam \dut/right1[3]~FF .SR_POLARITY = 1'b1;
    defparam \dut/right1[3]~FF .D_POLARITY = 1'b1;
    defparam \dut/right1[3]~FF .SR_SYNC = 1'b1;
    defparam \dut/right1[3]~FF .SR_VALUE = 1'b0;
    defparam \dut/right1[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/right1[4]~FF  (.D(\dut/n158 [4]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/right1 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/right1[4]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/right1[4]~FF .CE_POLARITY = 1'b1;
    defparam \dut/right1[4]~FF .SR_POLARITY = 1'b1;
    defparam \dut/right1[4]~FF .D_POLARITY = 1'b1;
    defparam \dut/right1[4]~FF .SR_SYNC = 1'b1;
    defparam \dut/right1[4]~FF .SR_VALUE = 1'b0;
    defparam \dut/right1[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/right1[5]~FF  (.D(\dut/n158 [5]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/right1 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/right1[5]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/right1[5]~FF .CE_POLARITY = 1'b1;
    defparam \dut/right1[5]~FF .SR_POLARITY = 1'b1;
    defparam \dut/right1[5]~FF .D_POLARITY = 1'b1;
    defparam \dut/right1[5]~FF .SR_SYNC = 1'b1;
    defparam \dut/right1[5]~FF .SR_VALUE = 1'b0;
    defparam \dut/right1[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/right1[6]~FF  (.D(\dut/n158 [6]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/right1 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/right1[6]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/right1[6]~FF .CE_POLARITY = 1'b1;
    defparam \dut/right1[6]~FF .SR_POLARITY = 1'b1;
    defparam \dut/right1[6]~FF .D_POLARITY = 1'b1;
    defparam \dut/right1[6]~FF .SR_SYNC = 1'b1;
    defparam \dut/right1[6]~FF .SR_VALUE = 1'b0;
    defparam \dut/right1[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/right1[7]~FF  (.D(\dut/n158 [7]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/right1 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/right1[7]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/right1[7]~FF .CE_POLARITY = 1'b1;
    defparam \dut/right1[7]~FF .SR_POLARITY = 1'b1;
    defparam \dut/right1[7]~FF .D_POLARITY = 1'b1;
    defparam \dut/right1[7]~FF .SR_SYNC = 1'b1;
    defparam \dut/right1[7]~FF .SR_VALUE = 1'b0;
    defparam \dut/right1[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/right1[8]~FF  (.D(\dut/n158 [8]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/right1 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/right1[8]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/right1[8]~FF .CE_POLARITY = 1'b1;
    defparam \dut/right1[8]~FF .SR_POLARITY = 1'b1;
    defparam \dut/right1[8]~FF .D_POLARITY = 1'b1;
    defparam \dut/right1[8]~FF .SR_SYNC = 1'b1;
    defparam \dut/right1[8]~FF .SR_VALUE = 1'b0;
    defparam \dut/right1[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/right1[9]~FF  (.D(\dut/n158 [9]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/right1 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/right1[9]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/right1[9]~FF .CE_POLARITY = 1'b1;
    defparam \dut/right1[9]~FF .SR_POLARITY = 1'b1;
    defparam \dut/right1[9]~FF .D_POLARITY = 1'b1;
    defparam \dut/right1[9]~FF .SR_SYNC = 1'b1;
    defparam \dut/right1[9]~FF .SR_VALUE = 1'b0;
    defparam \dut/right1[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/top1[1]~FF  (.D(\dut/n180 [1]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/top1 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/top1[1]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/top1[1]~FF .CE_POLARITY = 1'b1;
    defparam \dut/top1[1]~FF .SR_POLARITY = 1'b1;
    defparam \dut/top1[1]~FF .D_POLARITY = 1'b1;
    defparam \dut/top1[1]~FF .SR_SYNC = 1'b1;
    defparam \dut/top1[1]~FF .SR_VALUE = 1'b0;
    defparam \dut/top1[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/top1[2]~FF  (.D(\dut/n180 [2]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/top1 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/top1[2]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/top1[2]~FF .CE_POLARITY = 1'b1;
    defparam \dut/top1[2]~FF .SR_POLARITY = 1'b1;
    defparam \dut/top1[2]~FF .D_POLARITY = 1'b1;
    defparam \dut/top1[2]~FF .SR_SYNC = 1'b1;
    defparam \dut/top1[2]~FF .SR_VALUE = 1'b0;
    defparam \dut/top1[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/top1[3]~FF  (.D(\dut/n180 [3]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/top1 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/top1[3]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/top1[3]~FF .CE_POLARITY = 1'b1;
    defparam \dut/top1[3]~FF .SR_POLARITY = 1'b1;
    defparam \dut/top1[3]~FF .D_POLARITY = 1'b1;
    defparam \dut/top1[3]~FF .SR_SYNC = 1'b1;
    defparam \dut/top1[3]~FF .SR_VALUE = 1'b0;
    defparam \dut/top1[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/top1[4]~FF  (.D(\dut/n180 [4]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/top1 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/top1[4]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/top1[4]~FF .CE_POLARITY = 1'b1;
    defparam \dut/top1[4]~FF .SR_POLARITY = 1'b1;
    defparam \dut/top1[4]~FF .D_POLARITY = 1'b1;
    defparam \dut/top1[4]~FF .SR_SYNC = 1'b1;
    defparam \dut/top1[4]~FF .SR_VALUE = 1'b0;
    defparam \dut/top1[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/top1[5]~FF  (.D(\dut/n180 [5]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/top1 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/top1[5]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/top1[5]~FF .CE_POLARITY = 1'b1;
    defparam \dut/top1[5]~FF .SR_POLARITY = 1'b1;
    defparam \dut/top1[5]~FF .D_POLARITY = 1'b1;
    defparam \dut/top1[5]~FF .SR_SYNC = 1'b1;
    defparam \dut/top1[5]~FF .SR_VALUE = 1'b0;
    defparam \dut/top1[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/top1[6]~FF  (.D(\dut/n180 [6]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/top1 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/top1[6]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/top1[6]~FF .CE_POLARITY = 1'b1;
    defparam \dut/top1[6]~FF .SR_POLARITY = 1'b1;
    defparam \dut/top1[6]~FF .D_POLARITY = 1'b1;
    defparam \dut/top1[6]~FF .SR_SYNC = 1'b1;
    defparam \dut/top1[6]~FF .SR_VALUE = 1'b0;
    defparam \dut/top1[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/top1[7]~FF  (.D(\dut/n180 [7]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/top1 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/top1[7]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/top1[7]~FF .CE_POLARITY = 1'b1;
    defparam \dut/top1[7]~FF .SR_POLARITY = 1'b1;
    defparam \dut/top1[7]~FF .D_POLARITY = 1'b1;
    defparam \dut/top1[7]~FF .SR_SYNC = 1'b1;
    defparam \dut/top1[7]~FF .SR_VALUE = 1'b0;
    defparam \dut/top1[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/top1[8]~FF  (.D(\dut/n180 [8]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/top1 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/top1[8]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/top1[8]~FF .CE_POLARITY = 1'b1;
    defparam \dut/top1[8]~FF .SR_POLARITY = 1'b1;
    defparam \dut/top1[8]~FF .D_POLARITY = 1'b1;
    defparam \dut/top1[8]~FF .SR_SYNC = 1'b1;
    defparam \dut/top1[8]~FF .SR_VALUE = 1'b0;
    defparam \dut/top1[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/top1[9]~FF  (.D(\dut/n180 [9]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/top1 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/top1[9]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/top1[9]~FF .CE_POLARITY = 1'b1;
    defparam \dut/top1[9]~FF .SR_POLARITY = 1'b1;
    defparam \dut/top1[9]~FF .D_POLARITY = 1'b1;
    defparam \dut/top1[9]~FF .SR_SYNC = 1'b1;
    defparam \dut/top1[9]~FF .SR_VALUE = 1'b0;
    defparam \dut/top1[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/bottom1[1]~FF  (.D(\dut/n202 [1]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/bottom1 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/bottom1[1]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/bottom1[1]~FF .CE_POLARITY = 1'b1;
    defparam \dut/bottom1[1]~FF .SR_POLARITY = 1'b1;
    defparam \dut/bottom1[1]~FF .D_POLARITY = 1'b1;
    defparam \dut/bottom1[1]~FF .SR_SYNC = 1'b1;
    defparam \dut/bottom1[1]~FF .SR_VALUE = 1'b0;
    defparam \dut/bottom1[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/bottom1[2]~FF  (.D(\dut/n202 [2]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/bottom1 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/bottom1[2]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/bottom1[2]~FF .CE_POLARITY = 1'b1;
    defparam \dut/bottom1[2]~FF .SR_POLARITY = 1'b1;
    defparam \dut/bottom1[2]~FF .D_POLARITY = 1'b1;
    defparam \dut/bottom1[2]~FF .SR_SYNC = 1'b1;
    defparam \dut/bottom1[2]~FF .SR_VALUE = 1'b0;
    defparam \dut/bottom1[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/bottom1[3]~FF  (.D(\dut/n202 [3]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/bottom1 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/bottom1[3]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/bottom1[3]~FF .CE_POLARITY = 1'b1;
    defparam \dut/bottom1[3]~FF .SR_POLARITY = 1'b1;
    defparam \dut/bottom1[3]~FF .D_POLARITY = 1'b1;
    defparam \dut/bottom1[3]~FF .SR_SYNC = 1'b1;
    defparam \dut/bottom1[3]~FF .SR_VALUE = 1'b0;
    defparam \dut/bottom1[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/bottom1[4]~FF  (.D(\dut/n202 [4]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/bottom1 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/bottom1[4]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/bottom1[4]~FF .CE_POLARITY = 1'b1;
    defparam \dut/bottom1[4]~FF .SR_POLARITY = 1'b1;
    defparam \dut/bottom1[4]~FF .D_POLARITY = 1'b1;
    defparam \dut/bottom1[4]~FF .SR_SYNC = 1'b1;
    defparam \dut/bottom1[4]~FF .SR_VALUE = 1'b0;
    defparam \dut/bottom1[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/bottom1[5]~FF  (.D(\dut/n202 [5]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/bottom1 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/bottom1[5]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/bottom1[5]~FF .CE_POLARITY = 1'b1;
    defparam \dut/bottom1[5]~FF .SR_POLARITY = 1'b1;
    defparam \dut/bottom1[5]~FF .D_POLARITY = 1'b1;
    defparam \dut/bottom1[5]~FF .SR_SYNC = 1'b1;
    defparam \dut/bottom1[5]~FF .SR_VALUE = 1'b0;
    defparam \dut/bottom1[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/bottom1[6]~FF  (.D(\dut/n202 [6]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/bottom1 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/bottom1[6]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/bottom1[6]~FF .CE_POLARITY = 1'b1;
    defparam \dut/bottom1[6]~FF .SR_POLARITY = 1'b1;
    defparam \dut/bottom1[6]~FF .D_POLARITY = 1'b1;
    defparam \dut/bottom1[6]~FF .SR_SYNC = 1'b1;
    defparam \dut/bottom1[6]~FF .SR_VALUE = 1'b0;
    defparam \dut/bottom1[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/bottom1[7]~FF  (.D(\dut/n202 [7]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/bottom1 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/bottom1[7]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/bottom1[7]~FF .CE_POLARITY = 1'b1;
    defparam \dut/bottom1[7]~FF .SR_POLARITY = 1'b1;
    defparam \dut/bottom1[7]~FF .D_POLARITY = 1'b1;
    defparam \dut/bottom1[7]~FF .SR_SYNC = 1'b1;
    defparam \dut/bottom1[7]~FF .SR_VALUE = 1'b0;
    defparam \dut/bottom1[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/bottom1[8]~FF  (.D(\dut/n202 [8]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/bottom1 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/bottom1[8]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/bottom1[8]~FF .CE_POLARITY = 1'b1;
    defparam \dut/bottom1[8]~FF .SR_POLARITY = 1'b1;
    defparam \dut/bottom1[8]~FF .D_POLARITY = 1'b1;
    defparam \dut/bottom1[8]~FF .SR_SYNC = 1'b1;
    defparam \dut/bottom1[8]~FF .SR_VALUE = 1'b0;
    defparam \dut/bottom1[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/bottom1[9]~FF  (.D(\dut/n202 [9]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/bottom1 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/bottom1[9]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/bottom1[9]~FF .CE_POLARITY = 1'b1;
    defparam \dut/bottom1[9]~FF .SR_POLARITY = 1'b1;
    defparam \dut/bottom1[9]~FF .D_POLARITY = 1'b1;
    defparam \dut/bottom1[9]~FF .SR_SYNC = 1'b1;
    defparam \dut/bottom1[9]~FF .SR_VALUE = 1'b0;
    defparam \dut/bottom1[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/left1[1]~FF  (.D(\dut/n136 [1]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/left1 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/left1[1]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/left1[1]~FF .CE_POLARITY = 1'b1;
    defparam \dut/left1[1]~FF .SR_POLARITY = 1'b1;
    defparam \dut/left1[1]~FF .D_POLARITY = 1'b1;
    defparam \dut/left1[1]~FF .SR_SYNC = 1'b1;
    defparam \dut/left1[1]~FF .SR_VALUE = 1'b0;
    defparam \dut/left1[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/left1[2]~FF  (.D(\dut/n136 [2]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/left1 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/left1[2]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/left1[2]~FF .CE_POLARITY = 1'b1;
    defparam \dut/left1[2]~FF .SR_POLARITY = 1'b1;
    defparam \dut/left1[2]~FF .D_POLARITY = 1'b1;
    defparam \dut/left1[2]~FF .SR_SYNC = 1'b1;
    defparam \dut/left1[2]~FF .SR_VALUE = 1'b0;
    defparam \dut/left1[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/left1[3]~FF  (.D(\dut/n136 [3]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/left1 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/left1[3]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/left1[3]~FF .CE_POLARITY = 1'b1;
    defparam \dut/left1[3]~FF .SR_POLARITY = 1'b1;
    defparam \dut/left1[3]~FF .D_POLARITY = 1'b1;
    defparam \dut/left1[3]~FF .SR_SYNC = 1'b1;
    defparam \dut/left1[3]~FF .SR_VALUE = 1'b0;
    defparam \dut/left1[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/left1[4]~FF  (.D(\dut/n136 [4]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/left1 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/left1[4]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/left1[4]~FF .CE_POLARITY = 1'b1;
    defparam \dut/left1[4]~FF .SR_POLARITY = 1'b1;
    defparam \dut/left1[4]~FF .D_POLARITY = 1'b1;
    defparam \dut/left1[4]~FF .SR_SYNC = 1'b1;
    defparam \dut/left1[4]~FF .SR_VALUE = 1'b0;
    defparam \dut/left1[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/left1[5]~FF  (.D(\dut/n136 [5]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/left1 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/left1[5]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/left1[5]~FF .CE_POLARITY = 1'b1;
    defparam \dut/left1[5]~FF .SR_POLARITY = 1'b1;
    defparam \dut/left1[5]~FF .D_POLARITY = 1'b1;
    defparam \dut/left1[5]~FF .SR_SYNC = 1'b1;
    defparam \dut/left1[5]~FF .SR_VALUE = 1'b0;
    defparam \dut/left1[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/left1[6]~FF  (.D(\dut/n136 [6]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/left1 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/left1[6]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/left1[6]~FF .CE_POLARITY = 1'b1;
    defparam \dut/left1[6]~FF .SR_POLARITY = 1'b1;
    defparam \dut/left1[6]~FF .D_POLARITY = 1'b1;
    defparam \dut/left1[6]~FF .SR_SYNC = 1'b1;
    defparam \dut/left1[6]~FF .SR_VALUE = 1'b0;
    defparam \dut/left1[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/left1[7]~FF  (.D(\dut/n136 [7]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/left1 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/left1[7]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/left1[7]~FF .CE_POLARITY = 1'b1;
    defparam \dut/left1[7]~FF .SR_POLARITY = 1'b1;
    defparam \dut/left1[7]~FF .D_POLARITY = 1'b1;
    defparam \dut/left1[7]~FF .SR_SYNC = 1'b1;
    defparam \dut/left1[7]~FF .SR_VALUE = 1'b0;
    defparam \dut/left1[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/left1[8]~FF  (.D(\dut/n136 [8]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/left1 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/left1[8]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/left1[8]~FF .CE_POLARITY = 1'b1;
    defparam \dut/left1[8]~FF .SR_POLARITY = 1'b1;
    defparam \dut/left1[8]~FF .D_POLARITY = 1'b1;
    defparam \dut/left1[8]~FF .SR_SYNC = 1'b1;
    defparam \dut/left1[8]~FF .SR_VALUE = 1'b0;
    defparam \dut/left1[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \dut/left1[9]~FF  (.D(\dut/n136 [9]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\dut/left1 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \dut/left1[9]~FF .CLK_POLARITY = 1'b1;
    defparam \dut/left1[9]~FF .CE_POLARITY = 1'b1;
    defparam \dut/left1[9]~FF .SR_POLARITY = 1'b1;
    defparam \dut/left1[9]~FF .D_POLARITY = 1'b1;
    defparam \dut/left1[9]~FF .SR_SYNC = 1'b1;
    defparam \dut/left1[9]~FF .SR_VALUE = 1'b0;
    defparam \dut/left1[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \direction[1]~FF  (.D(\dut/n293 [1]), .CE(1'b1), .CLK(clk), 
           .SR(\dut/n288 ), .Q(direction[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(35)
    defparam \direction[1]~FF .CLK_POLARITY = 1'b1;
    defparam \direction[1]~FF .CE_POLARITY = 1'b1;
    defparam \direction[1]~FF .SR_POLARITY = 1'b1;
    defparam \direction[1]~FF .D_POLARITY = 1'b1;
    defparam \direction[1]~FF .SR_SYNC = 1'b1;
    defparam \direction[1]~FF .SR_VALUE = 1'b0;
    defparam \direction[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[1]~FF  (.D(stimulus[0]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(stimulus[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[1]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[1]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[1]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[1]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[1]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[1]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[2]~FF  (.D(stimulus[1]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\stimulus[2] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[2]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[2]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[2]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[2]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[2]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[2]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[3]~FF  (.D(\stimulus[2] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[3] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[3]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[3]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[3]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[3]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[3]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[3]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[4]~FF  (.D(\stimulus[3] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[4] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[4]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[4]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[4]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[4]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[4]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[4]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[5]~FF  (.D(\stimulus[4] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[5] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[5]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[5]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[5]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[5]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[5]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[5]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[6]~FF  (.D(\stimulus[5] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[6]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[6]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[6]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[6]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[6]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[6]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[7]~FF  (.D(stimulus[6]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\stimulus[7] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[7]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[7]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[7]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[7]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[7]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[7]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[8]~FF  (.D(\stimulus[7] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[8]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[8]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[8]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[8]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[8]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[8]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[9]~FF  (.D(stimulus[8]), .CE(1'b1), .CLK(clk), .SR(1'b0), 
           .Q(\stimulus[9] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[9]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[9]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[9]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[9]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[9]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[9]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[10]~FF  (.D(\stimulus[9] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[10]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[10]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[10]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[10]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[10]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[10]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[11]~FF  (.D(stimulus[10]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[11] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[11]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[11]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[11]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[11]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[11]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[11]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[12]~FF  (.D(\stimulus[11] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[12] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[12]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[12]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[12]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[12]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[12]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[12]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[13]~FF  (.D(\stimulus[12] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[13] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[13]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[13]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[13]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[13]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[13]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[13]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[14]~FF  (.D(\stimulus[13] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[14] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[14]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[14]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[14]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[14]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[14]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[14]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[15]~FF  (.D(\stimulus[14] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[15] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[15]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[15]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[15]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[15]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[15]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[15]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[16]~FF  (.D(\stimulus[15] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[16]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[16]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[16]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[16]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[16]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[16]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[17]~FF  (.D(stimulus[16]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[17] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[17]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[17]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[17]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[17]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[17]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[17]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[18]~FF  (.D(\stimulus[17] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[18] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[18]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[18]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[18]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[18]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[18]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[18]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[19]~FF  (.D(\stimulus[18] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[19] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[19]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[19]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[19]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[19]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[19]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[19]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[19]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[20]~FF  (.D(\stimulus[19] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[20] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[20]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[20]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[20]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[20]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[20]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[20]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[20]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[21]~FF  (.D(\stimulus[20] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[21])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[21]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[21]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[21]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[21]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[21]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[21]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[21]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[22]~FF  (.D(stimulus[21]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[22] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[22]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[22]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[22]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[22]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[22]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[22]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[22]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[23]~FF  (.D(\stimulus[22] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[23] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[23]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[23]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[23]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[23]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[23]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[23]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[23]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[24]~FF  (.D(\stimulus[23] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[24])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[24]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[24]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[24]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[24]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[24]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[24]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[24]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[25]~FF  (.D(stimulus[24]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[25])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[25]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[25]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[25]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[25]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[25]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[25]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[25]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[26]~FF  (.D(stimulus[25]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[26] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[26]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[26]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[26]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[26]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[26]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[26]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[26]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[27]~FF  (.D(\stimulus[26] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[27] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[27]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[27]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[27]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[27]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[27]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[27]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[27]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[28]~FF  (.D(\stimulus[27] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[28] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[28]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[28]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[28]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[28]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[28]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[28]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[28]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[29]~FF  (.D(\stimulus[28] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[29] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[29]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[29]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[29]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[29]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[29]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[29]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[29]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[30]~FF  (.D(\stimulus[29] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[30])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[30]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[30]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[30]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[30]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[30]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[30]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[30]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[31]~FF  (.D(stimulus[30]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[31] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[31]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[31]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[31]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[31]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[31]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[31]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[31]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[32]~FF  (.D(\stimulus[31] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[32])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[32]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[32]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[32]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[32]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[32]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[32]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[32]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[33]~FF  (.D(stimulus[32]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[33] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[33]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[33]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[33]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[33]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[33]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[33]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[33]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[34]~FF  (.D(\stimulus[33] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[34])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[34]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[34]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[34]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[34]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[34]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[34]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[34]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[35]~FF  (.D(stimulus[34]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[35] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[35]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[35]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[35]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[35]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[35]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[35]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[35]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[36]~FF  (.D(\stimulus[35] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[36] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[36]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[36]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[36]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[36]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[36]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[36]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[36]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[37]~FF  (.D(\stimulus[36] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[37])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[37]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[37]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[37]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[37]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[37]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[37]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[37]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[38]~FF  (.D(stimulus[37]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[38])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[38]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[38]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[38]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[38]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[38]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[38]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[38]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[39]~FF  (.D(stimulus[38]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[39] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[39]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[39]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[39]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[39]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[39]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[39]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[39]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[40]~FF  (.D(\stimulus[39] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[40])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[40]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[40]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[40]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[40]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[40]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[40]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[40]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[41]~FF  (.D(stimulus[40]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[41])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[41]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[41]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[41]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[41]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[41]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[41]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[41]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[42]~FF  (.D(stimulus[41]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[42])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[42]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[42]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[42]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[42]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[42]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[42]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[42]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[43]~FF  (.D(stimulus[42]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[43] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[43]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[43]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[43]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[43]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[43]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[43]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[43]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[44]~FF  (.D(\stimulus[43] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[44] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[44]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[44]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[44]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[44]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[44]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[44]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[44]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[45]~FF  (.D(\stimulus[44] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[45] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[45]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[45]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[45]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[45]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[45]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[45]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[45]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[46]~FF  (.D(\stimulus[45] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[46] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[46]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[46]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[46]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[46]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[46]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[46]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[46]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[47]~FF  (.D(\stimulus[46] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[47])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[47]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[47]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[47]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[47]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[47]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[47]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[47]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[48]~FF  (.D(stimulus[47]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[48])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[48]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[48]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[48]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[48]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[48]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[48]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[48]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[49]~FF  (.D(stimulus[48]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[49] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[49]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[49]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[49]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[49]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[49]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[49]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[49]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[50]~FF  (.D(\stimulus[49] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[50] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[50]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[50]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[50]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[50]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[50]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[50]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[50]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[51]~FF  (.D(\stimulus[50] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[51])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[51]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[51]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[51]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[51]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[51]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[51]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[51]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[52]~FF  (.D(stimulus[51]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[52] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[52]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[52]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[52]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[52]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[52]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[52]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[52]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[53]~FF  (.D(\stimulus[52] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[53])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[53]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[53]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[53]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[53]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[53]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[53]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[53]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[54]~FF  (.D(stimulus[53]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[54] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[54]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[54]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[54]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[54]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[54]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[54]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[54]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[55]~FF  (.D(\stimulus[54] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[55])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[55]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[55]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[55]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[55]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[55]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[55]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[55]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[56]~FF  (.D(stimulus[55]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[56])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[56]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[56]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[56]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[56]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[56]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[56]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[56]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[57]~FF  (.D(stimulus[56]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[57])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[57]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[57]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[57]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[57]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[57]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[57]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[57]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[58]~FF  (.D(stimulus[57]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[58] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[58]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[58]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[58]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[58]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[58]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[58]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[58]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[59]~FF  (.D(\stimulus[58] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[59])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[59]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[59]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[59]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[59]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[59]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[59]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[59]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[60]~FF  (.D(stimulus[59]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[60] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[60]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[60]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[60]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[60]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[60]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[60]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[60]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[61]~FF  (.D(\stimulus[60] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[61] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[61]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[61]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[61]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[61]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[61]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[61]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[61]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[62]~FF  (.D(\stimulus[61] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[62])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[62]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[62]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[62]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[62]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[62]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[62]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[62]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[63]~FF  (.D(stimulus[62]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[63])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[63]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[63]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[63]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[63]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[63]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[63]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[63]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[64]~FF  (.D(stimulus[63]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[64])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[64]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[64]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[64]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[64]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[64]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[64]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[64]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[65]~FF  (.D(stimulus[64]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[65] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[65]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[65]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[65]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[65]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[65]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[65]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[65]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[66]~FF  (.D(\stimulus[65] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[66])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[66]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[66]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[66]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[66]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[66]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[66]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[66]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[67]~FF  (.D(stimulus[66]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[67])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[67]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[67]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[67]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[67]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[67]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[67]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[67]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[68]~FF  (.D(stimulus[67]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\stimulus[68] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[68]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[68]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[68]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[68]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[68]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[68]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[68]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[69]~FF  (.D(\stimulus[68] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[69])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[69]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[69]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[69]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[69]~FF .D_POLARITY = 1'b0;
    defparam \stimulus[69]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[69]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[69]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[70]~FF  (.D(stimulus[69]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[70])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[70]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[70]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[70]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[70]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[70]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[70]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[70]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \stimulus[71]~FF  (.D(stimulus[70]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(stimulus[71])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \stimulus[71]~FF .CLK_POLARITY = 1'b1;
    defparam \stimulus[71]~FF .CE_POLARITY = 1'b1;
    defparam \stimulus[71]~FF .SR_POLARITY = 1'b1;
    defparam \stimulus[71]~FF .D_POLARITY = 1'b1;
    defparam \stimulus[71]~FF .SR_SYNC = 1'b1;
    defparam \stimulus[71]~FF .SR_VALUE = 1'b0;
    defparam \stimulus[71]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \threshold[1]~FF  (.D(\threshold[0] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(threshold[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[1]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[1]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[1]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[1]~FF .D_POLARITY = 1'b0;
    defparam \threshold[1]~FF .SR_SYNC = 1'b1;
    defparam \threshold[1]~FF .SR_VALUE = 1'b0;
    defparam \threshold[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \threshold[2]~FF  (.D(threshold[1]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\threshold[2] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[2]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[2]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[2]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[2]~FF .D_POLARITY = 1'b0;
    defparam \threshold[2]~FF .SR_SYNC = 1'b1;
    defparam \threshold[2]~FF .SR_VALUE = 1'b0;
    defparam \threshold[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \threshold[3]~FF  (.D(\threshold[2] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(threshold[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[3]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[3]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[3]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[3]~FF .D_POLARITY = 1'b0;
    defparam \threshold[3]~FF .SR_SYNC = 1'b1;
    defparam \threshold[3]~FF .SR_VALUE = 1'b0;
    defparam \threshold[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \threshold[4]~FF  (.D(threshold[3]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\threshold[4] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[4]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[4]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[4]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[4]~FF .D_POLARITY = 1'b0;
    defparam \threshold[4]~FF .SR_SYNC = 1'b1;
    defparam \threshold[4]~FF .SR_VALUE = 1'b0;
    defparam \threshold[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \threshold[5]~FF  (.D(\threshold[4] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\threshold[5] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[5]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[5]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[5]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[5]~FF .D_POLARITY = 1'b1;
    defparam \threshold[5]~FF .SR_SYNC = 1'b1;
    defparam \threshold[5]~FF .SR_VALUE = 1'b0;
    defparam \threshold[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \threshold[6]~FF  (.D(\threshold[5] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(threshold[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[6]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[6]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[6]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[6]~FF .D_POLARITY = 1'b0;
    defparam \threshold[6]~FF .SR_SYNC = 1'b1;
    defparam \threshold[6]~FF .SR_VALUE = 1'b0;
    defparam \threshold[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \threshold[7]~FF  (.D(threshold[6]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(threshold[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[7]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[7]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[7]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[7]~FF .D_POLARITY = 1'b1;
    defparam \threshold[7]~FF .SR_SYNC = 1'b1;
    defparam \threshold[7]~FF .SR_VALUE = 1'b0;
    defparam \threshold[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \threshold[8]~FF  (.D(threshold[7]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(\threshold[8] )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[8]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[8]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[8]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[8]~FF .D_POLARITY = 1'b0;
    defparam \threshold[8]~FF .SR_SYNC = 1'b1;
    defparam \threshold[8]~FF .SR_VALUE = 1'b0;
    defparam \threshold[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \threshold[9]~FF  (.D(\threshold[8] ), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(threshold[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[9]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[9]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[9]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[9]~FF .D_POLARITY = 1'b0;
    defparam \threshold[9]~FF .SR_SYNC = 1'b1;
    defparam \threshold[9]~FF .SR_VALUE = 1'b0;
    defparam \threshold[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \threshold[10]~FF  (.D(threshold[9]), .CE(1'b1), .CLK(clk), 
           .SR(1'b0), .Q(threshold[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam \threshold[10]~FF .CLK_POLARITY = 1'b1;
    defparam \threshold[10]~FF .CE_POLARITY = 1'b1;
    defparam \threshold[10]~FF .SR_POLARITY = 1'b1;
    defparam \threshold[10]~FF .D_POLARITY = 1'b1;
    defparam \threshold[10]~FF .SR_SYNC = 1'b1;
    defparam \threshold[10]~FF .SR_VALUE = 1'b0;
    defparam \threshold[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_ADD \dut/add_26/i5  (.I0(\dut/ax2 [4]), .I1(\dut/ay2 [4]), .CI(\dut/add_26/n8 ), 
            .O(\dut/n238 [4]), .CO(\dut/add_26/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i5 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_23/i10  (.I0(\dut/n191 ), .I1(1'b0), .CI(\dut/add_23/n18 ), 
            .O(\dut/n202 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_23/i10 .I0_POLARITY = 1'b1;
    defparam \dut/add_23/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/sub_25/add_2/i8  (.I0(\dut/bottom1 [7]), .I1(\dut/top1 [7]), 
            .CI(\dut/sub_25/add_2/n14 ), .O(\dut/n225 [7]), .CO(\dut/sub_25/add_2/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i8 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_26/i9  (.I0(\dut/ax2 [8]), .I1(\dut/ay2 [8]), .CI(\dut/add_26/n16 ), 
            .O(\dut/n238 [8]), .CO(\dut/add_26/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i9 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_17/i1  (.I0(stimulus[64]), .I1(stimulus[16]), .CI(1'b0), 
            .O(\dut/n136 [0]), .CO(\dut/add_17/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_17/i1 .I0_POLARITY = 1'b1;
    defparam \dut/add_17/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_18/i1  (.I0(\stimulus[49] ), .I1(stimulus[24]), .CI(1'b0), 
            .O(\dut/n148 [0]), .CO(\dut/add_18/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_18/i1 .I0_POLARITY = 1'b0;
    defparam \dut/add_18/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_19/i1  (.I0(stimulus[48]), .I1(stimulus[0]), .CI(1'b0), 
            .O(\dut/n158 [0]), .CO(\dut/add_19/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_19/i1 .I0_POLARITY = 1'b1;
    defparam \dut/add_19/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_20/i1  (.I0(\stimulus[65] ), .I1(stimulus[56]), .CI(1'b0), 
            .O(\dut/n170 [0]), .CO(\dut/add_20/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_20/i1 .I0_POLARITY = 1'b0;
    defparam \dut/add_20/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_21/i1  (.I0(stimulus[64]), .I1(stimulus[48]), .CI(1'b0), 
            .O(\dut/n180 [0]), .CO(\dut/add_21/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_21/i1 .I0_POLARITY = 1'b1;
    defparam \dut/add_21/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_22/i1  (.I0(\stimulus[17] ), .I1(stimulus[8]), .CI(1'b0), 
            .O(\dut/n192 [0]), .CO(\dut/add_22/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_22/i1 .I0_POLARITY = 1'b0;
    defparam \dut/add_22/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_23/i1  (.I0(stimulus[16]), .I1(stimulus[0]), .CI(1'b0), 
            .O(\dut/n202 [0]), .CO(\dut/add_23/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_23/i1 .I0_POLARITY = 1'b1;
    defparam \dut/add_23/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_26/i1  (.I0(\dut/ax2 [0]), .I1(\dut/ay2 [0]), .CI(1'b0), 
            .O(\dut/n238 [0]), .CO(\dut/add_26/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i1 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/sub_24/add_2/i1  (.I0(\dut/right1 [0]), .I1(\dut/left1 [0]), 
            .CI(n678), .O(\dut/n213 [0]), .CO(\dut/sub_24/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_23/i9  (.I0(\dut/n192 [7]), .I1(1'b0), .CI(\dut/add_23/n16 ), 
            .O(\dut/n202 [8]), .CO(\dut/add_23/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_23/i9 .I0_POLARITY = 1'b1;
    defparam \dut/add_23/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_18/i4  (.I0(\stimulus[52] ), .I1(\stimulus[27] ), .CI(\dut/add_18/n6 ), 
            .O(\dut/n148 [3]), .CO(\dut/add_18/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_18/i4 .I0_POLARITY = 1'b0;
    defparam \dut/add_18/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_23/i8  (.I0(\dut/n192 [6]), .I1(\stimulus[7] ), .CI(\dut/add_23/n14 ), 
            .O(\dut/n202 [7]), .CO(\dut/add_23/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_23/i8 .I0_POLARITY = 1'b1;
    defparam \dut/add_23/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_23/i7  (.I0(\dut/n192 [5]), .I1(stimulus[6]), .CI(\dut/add_23/n12 ), 
            .O(\dut/n202 [6]), .CO(\dut/add_23/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_23/i7 .I0_POLARITY = 1'b1;
    defparam \dut/add_23/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_23/i6  (.I0(\dut/n192 [4]), .I1(\stimulus[5] ), .CI(\dut/add_23/n10 ), 
            .O(\dut/n202 [5]), .CO(\dut/add_23/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_23/i6 .I0_POLARITY = 1'b1;
    defparam \dut/add_23/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_23/i5  (.I0(\dut/n192 [3]), .I1(\stimulus[4] ), .CI(\dut/add_23/n8 ), 
            .O(\dut/n202 [4]), .CO(\dut/add_23/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_23/i5 .I0_POLARITY = 1'b1;
    defparam \dut/add_23/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_23/i4  (.I0(\dut/n192 [2]), .I1(\stimulus[3] ), .CI(\dut/add_23/n6 ), 
            .O(\dut/n202 [3]), .CO(\dut/add_23/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_23/i4 .I0_POLARITY = 1'b1;
    defparam \dut/add_23/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_16/i1  (.I0(\stimulus[65] ), .I1(stimulus[40]), .CI(1'b0), 
            .O(\dut/n126 [0]), .CO(\dut/add_16/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_16/i1 .I0_POLARITY = 1'b0;
    defparam \dut/add_16/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_23/i3  (.I0(\dut/n192 [1]), .I1(\stimulus[2] ), .CI(\dut/add_23/n4 ), 
            .O(\dut/n202 [2]), .CO(\dut/add_23/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_23/i3 .I0_POLARITY = 1'b1;
    defparam \dut/add_23/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_16/i2  (.I0(stimulus[66]), .I1(stimulus[41]), .CI(\dut/add_16/n2 ), 
            .O(\dut/n126 [1]), .CO(\dut/add_16/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_16/i2 .I0_POLARITY = 1'b1;
    defparam \dut/add_16/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_26/i7  (.I0(\dut/ax2 [6]), .I1(\dut/ay2 [6]), .CI(\dut/add_26/n12 ), 
            .O(\dut/n238 [6]), .CO(\dut/add_26/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i7 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_26/i11  (.I0(\dut/ax2 [10]), .I1(\dut/ay2 [10]), .CI(\dut/add_26/n20 ), 
            .O(\dut/n238 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i11 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/sub_24/add_2/i2  (.I0(\dut/right1 [1]), .I1(\dut/left1 [1]), 
            .CI(\dut/sub_24/add_2/n2 ), .O(\dut/n213 [1]), .CO(\dut/sub_24/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_24/add_2/i4  (.I0(\dut/right1 [3]), .I1(\dut/left1 [3]), 
            .CI(\dut/sub_24/add_2/n6 ), .O(\dut/n213 [3]), .CO(\dut/sub_24/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_24/add_2/i6  (.I0(\dut/right1 [5]), .I1(\dut/left1 [5]), 
            .CI(\dut/sub_24/add_2/n10 ), .O(\dut/n213 [5]), .CO(\dut/sub_24/add_2/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_24/add_2/i8  (.I0(\dut/right1 [7]), .I1(\dut/left1 [7]), 
            .CI(\dut/sub_24/add_2/n14 ), .O(\dut/n213 [7]), .CO(\dut/sub_24/add_2/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i8 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_24/add_2/i10  (.I0(\dut/right1 [9]), .I1(\dut/left1 [9]), 
            .CI(\dut/sub_24/add_2/n18 ), .O(\dut/n213 [9]), .CO(\dut/sub_24/add_2/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i10 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i10 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_25/add_2/i2  (.I0(\dut/bottom1 [1]), .I1(\dut/top1 [1]), 
            .CI(\dut/sub_25/add_2/n2 ), .O(\dut/n225 [1]), .CO(\dut/sub_25/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_25/add_2/i4  (.I0(\dut/bottom1 [3]), .I1(\dut/top1 [3]), 
            .CI(\dut/sub_25/add_2/n6 ), .O(\dut/n225 [3]), .CO(\dut/sub_25/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_25/add_2/i6  (.I0(\dut/bottom1 [5]), .I1(\dut/top1 [5]), 
            .CI(\dut/sub_25/add_2/n10 ), .O(\dut/n225 [5]), .CO(\dut/sub_25/add_2/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i6 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_25/add_2/i10  (.I0(\dut/bottom1 [9]), .I1(\dut/top1 [9]), 
            .CI(\dut/sub_25/add_2/n18 ), .O(\dut/n225 [9]), .CO(\dut/sub_25/add_2/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i10 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i10 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_26/i8  (.I0(\dut/ax2 [7]), .I1(\dut/ay2 [7]), .CI(\dut/add_26/n14 ), 
            .O(\dut/n238 [7]), .CO(\dut/add_26/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i8 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/sub_25/add_2/i7  (.I0(\dut/bottom1 [6]), .I1(\dut/top1 [6]), 
            .CI(\dut/sub_25/add_2/n12 ), .O(\dut/n225 [6]), .CO(\dut/sub_25/add_2/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i7 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i7 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_16/i3  (.I0(stimulus[67]), .I1(stimulus[42]), .CI(\dut/add_16/n4 ), 
            .O(\dut/n126 [2]), .CO(\dut/add_16/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_16/i3 .I0_POLARITY = 1'b1;
    defparam \dut/add_16/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_16/i4  (.I0(\stimulus[68] ), .I1(\stimulus[43] ), .CI(\dut/add_16/n6 ), 
            .O(\dut/n126 [3]), .CO(\dut/add_16/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_16/i4 .I0_POLARITY = 1'b0;
    defparam \dut/add_16/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_26/i6  (.I0(\dut/ax2 [5]), .I1(\dut/ay2 [5]), .CI(\dut/add_26/n10 ), 
            .O(\dut/n238 [5]), .CO(\dut/add_26/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i6 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_26/i10  (.I0(\dut/ax2 [9]), .I1(\dut/ay2 [9]), .CI(\dut/add_26/n18 ), 
            .O(\dut/n238 [9]), .CO(\dut/add_26/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i10 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/sub_24/add_2/i3  (.I0(\dut/right1 [2]), .I1(\dut/left1 [2]), 
            .CI(\dut/sub_24/add_2/n4 ), .O(\dut/n213 [2]), .CO(\dut/sub_24/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_24/add_2/i5  (.I0(\dut/right1 [4]), .I1(\dut/left1 [4]), 
            .CI(\dut/sub_24/add_2/n8 ), .O(\dut/n213 [4]), .CO(\dut/sub_24/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_24/add_2/i7  (.I0(\dut/right1 [6]), .I1(\dut/left1 [6]), 
            .CI(\dut/sub_24/add_2/n12 ), .O(\dut/n213 [6]), .CO(\dut/sub_24/add_2/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i7 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i7 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_24/add_2/i9  (.I0(\dut/right1 [8]), .I1(\dut/left1 [8]), 
            .CI(\dut/sub_24/add_2/n16 ), .O(\dut/n213 [8]), .CO(\dut/sub_24/add_2/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i9 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i9 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_24/add_2/i11  (.I0(1'b0), .I1(1'b1), .CI(\dut/sub_24/add_2/n20 ), 
            .O(\dut/n213 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i11 .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/sub_25/add_2/i3  (.I0(\dut/bottom1 [2]), .I1(\dut/top1 [2]), 
            .CI(\dut/sub_25/add_2/n4 ), .O(\dut/n225 [2]), .CO(\dut/sub_25/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_25/add_2/i5  (.I0(\dut/bottom1 [4]), .I1(\dut/top1 [4]), 
            .CI(\dut/sub_25/add_2/n8 ), .O(\dut/n225 [4]), .CO(\dut/sub_25/add_2/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_25/add_2/i9  (.I0(\dut/bottom1 [8]), .I1(\dut/top1 [8]), 
            .CI(\dut/sub_25/add_2/n16 ), .O(\dut/n225 [8]), .CO(\dut/sub_25/add_2/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i9 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i9 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/sub_25/add_2/i11  (.I0(1'b0), .I1(1'b1), .CI(\dut/sub_25/add_2/n20 ), 
            .O(\dut/n225 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i11 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_23/i2  (.I0(\dut/n192 [0]), .I1(stimulus[1]), .CI(\dut/add_23/n2 ), 
            .O(\dut/n202 [1]), .CO(\dut/add_23/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_23/i2 .I0_POLARITY = 1'b1;
    defparam \dut/add_23/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_22/i8  (.I0(1'b0), .I1(\stimulus[15] ), .CI(\dut/add_22/n14 ), 
            .O(\dut/n192 [7]), .CO(n679)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_22/i8 .I0_POLARITY = 1'b1;
    defparam \dut/add_22/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_22/i7  (.I0(\stimulus[23] ), .I1(\stimulus[14] ), .CI(\dut/add_22/n12 ), 
            .O(\dut/n192 [6]), .CO(\dut/add_22/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_22/i7 .I0_POLARITY = 1'b0;
    defparam \dut/add_22/i7 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_22/i6  (.I0(\stimulus[22] ), .I1(\stimulus[13] ), .CI(\dut/add_22/n10 ), 
            .O(\dut/n192 [5]), .CO(\dut/add_22/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_22/i6 .I0_POLARITY = 1'b0;
    defparam \dut/add_22/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_22/i5  (.I0(stimulus[21]), .I1(\stimulus[12] ), .CI(\dut/add_22/n8 ), 
            .O(\dut/n192 [4]), .CO(\dut/add_22/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_22/i5 .I0_POLARITY = 1'b1;
    defparam \dut/add_22/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_22/i4  (.I0(\stimulus[20] ), .I1(\stimulus[11] ), .CI(\dut/add_22/n6 ), 
            .O(\dut/n192 [3]), .CO(\dut/add_22/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_22/i4 .I0_POLARITY = 1'b0;
    defparam \dut/add_22/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_22/i3  (.I0(\stimulus[19] ), .I1(stimulus[10]), .CI(\dut/add_22/n4 ), 
            .O(\dut/n192 [2]), .CO(\dut/add_22/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_22/i3 .I0_POLARITY = 1'b0;
    defparam \dut/add_22/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_22/i2  (.I0(\stimulus[18] ), .I1(\stimulus[9] ), .CI(\dut/add_22/n2 ), 
            .O(\dut/n192 [1]), .CO(\dut/add_22/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_22/i2 .I0_POLARITY = 1'b0;
    defparam \dut/add_22/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_21/i10  (.I0(\dut/n169 ), .I1(1'b0), .CI(\dut/add_21/n18 ), 
            .O(\dut/n180 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_21/i10 .I0_POLARITY = 1'b1;
    defparam \dut/add_21/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_21/i9  (.I0(\dut/n170 [7]), .I1(1'b0), .CI(\dut/add_21/n16 ), 
            .O(\dut/n180 [8]), .CO(\dut/add_21/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_21/i9 .I0_POLARITY = 1'b1;
    defparam \dut/add_21/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_21/i8  (.I0(\dut/n170 [6]), .I1(stimulus[55]), .CI(\dut/add_21/n14 ), 
            .O(\dut/n180 [7]), .CO(\dut/add_21/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_21/i8 .I0_POLARITY = 1'b1;
    defparam \dut/add_21/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_21/i7  (.I0(\dut/n170 [5]), .I1(\stimulus[54] ), .CI(\dut/add_21/n12 ), 
            .O(\dut/n180 [6]), .CO(\dut/add_21/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_21/i7 .I0_POLARITY = 1'b1;
    defparam \dut/add_21/i7 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_21/i6  (.I0(\dut/n170 [4]), .I1(stimulus[53]), .CI(\dut/add_21/n10 ), 
            .O(\dut/n180 [5]), .CO(\dut/add_21/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_21/i6 .I0_POLARITY = 1'b1;
    defparam \dut/add_21/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_21/i5  (.I0(\dut/n170 [3]), .I1(\stimulus[52] ), .CI(\dut/add_21/n8 ), 
            .O(\dut/n180 [4]), .CO(\dut/add_21/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_21/i5 .I0_POLARITY = 1'b1;
    defparam \dut/add_21/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_21/i4  (.I0(\dut/n170 [2]), .I1(stimulus[51]), .CI(\dut/add_21/n6 ), 
            .O(\dut/n180 [3]), .CO(\dut/add_21/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_21/i4 .I0_POLARITY = 1'b1;
    defparam \dut/add_21/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_21/i3  (.I0(\dut/n170 [1]), .I1(\stimulus[50] ), .CI(\dut/add_21/n4 ), 
            .O(\dut/n180 [2]), .CO(\dut/add_21/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_21/i3 .I0_POLARITY = 1'b1;
    defparam \dut/add_21/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_21/i2  (.I0(\dut/n170 [0]), .I1(\stimulus[49] ), .CI(\dut/add_21/n2 ), 
            .O(\dut/n180 [1]), .CO(\dut/add_21/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_21/i2 .I0_POLARITY = 1'b1;
    defparam \dut/add_21/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_20/i8  (.I0(1'b0), .I1(stimulus[63]), .CI(\dut/add_20/n14 ), 
            .O(\dut/n170 [7]), .CO(n680)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_20/i8 .I0_POLARITY = 1'b1;
    defparam \dut/add_20/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_20/i7  (.I0(stimulus[71]), .I1(stimulus[62]), .CI(\dut/add_20/n12 ), 
            .O(\dut/n170 [6]), .CO(\dut/add_20/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_20/i7 .I0_POLARITY = 1'b1;
    defparam \dut/add_20/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_20/i6  (.I0(stimulus[70]), .I1(\stimulus[61] ), .CI(\dut/add_20/n10 ), 
            .O(\dut/n170 [5]), .CO(\dut/add_20/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_20/i6 .I0_POLARITY = 1'b1;
    defparam \dut/add_20/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_20/i5  (.I0(stimulus[69]), .I1(\stimulus[60] ), .CI(\dut/add_20/n8 ), 
            .O(\dut/n170 [4]), .CO(\dut/add_20/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_20/i5 .I0_POLARITY = 1'b1;
    defparam \dut/add_20/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_20/i4  (.I0(\stimulus[68] ), .I1(stimulus[59]), .CI(\dut/add_20/n6 ), 
            .O(\dut/n170 [3]), .CO(\dut/add_20/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_20/i4 .I0_POLARITY = 1'b0;
    defparam \dut/add_20/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_20/i3  (.I0(stimulus[67]), .I1(\stimulus[58] ), .CI(\dut/add_20/n4 ), 
            .O(\dut/n170 [2]), .CO(\dut/add_20/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_20/i3 .I0_POLARITY = 1'b1;
    defparam \dut/add_20/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_20/i2  (.I0(stimulus[66]), .I1(stimulus[57]), .CI(\dut/add_20/n2 ), 
            .O(\dut/n170 [1]), .CO(\dut/add_20/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(20)
    defparam \dut/add_20/i2 .I0_POLARITY = 1'b1;
    defparam \dut/add_20/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_19/i10  (.I0(\dut/n147 ), .I1(1'b0), .CI(\dut/add_19/n18 ), 
            .O(\dut/n158 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_19/i10 .I0_POLARITY = 1'b1;
    defparam \dut/add_19/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_19/i9  (.I0(\dut/n148 [7]), .I1(1'b0), .CI(\dut/add_19/n16 ), 
            .O(\dut/n158 [8]), .CO(\dut/add_19/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_19/i9 .I0_POLARITY = 1'b1;
    defparam \dut/add_19/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_18/i3  (.I0(stimulus[51]), .I1(\stimulus[26] ), .CI(\dut/add_18/n4 ), 
            .O(\dut/n148 [2]), .CO(\dut/add_18/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_18/i3 .I0_POLARITY = 1'b1;
    defparam \dut/add_18/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_18/i2  (.I0(\stimulus[50] ), .I1(stimulus[25]), .CI(\dut/add_18/n2 ), 
            .O(\dut/n148 [1]), .CO(\dut/add_18/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_18/i2 .I0_POLARITY = 1'b0;
    defparam \dut/add_18/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_17/i10  (.I0(\dut/n125 ), .I1(1'b0), .CI(\dut/add_17/n18 ), 
            .O(\dut/n136 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_17/i10 .I0_POLARITY = 1'b1;
    defparam \dut/add_17/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_17/i9  (.I0(\dut/n126 [7]), .I1(1'b0), .CI(\dut/add_17/n16 ), 
            .O(\dut/n136 [8]), .CO(\dut/add_17/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_17/i9 .I0_POLARITY = 1'b1;
    defparam \dut/add_17/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_17/i8  (.I0(\dut/n126 [6]), .I1(\stimulus[23] ), .CI(\dut/add_17/n14 ), 
            .O(\dut/n136 [7]), .CO(\dut/add_17/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_17/i8 .I0_POLARITY = 1'b1;
    defparam \dut/add_17/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_17/i7  (.I0(\dut/n126 [5]), .I1(\stimulus[22] ), .CI(\dut/add_17/n12 ), 
            .O(\dut/n136 [6]), .CO(\dut/add_17/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_17/i7 .I0_POLARITY = 1'b1;
    defparam \dut/add_17/i7 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_17/i6  (.I0(\dut/n126 [4]), .I1(stimulus[21]), .CI(\dut/add_17/n10 ), 
            .O(\dut/n136 [5]), .CO(\dut/add_17/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_17/i6 .I0_POLARITY = 1'b1;
    defparam \dut/add_17/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_17/i5  (.I0(\dut/n126 [3]), .I1(\stimulus[20] ), .CI(\dut/add_17/n8 ), 
            .O(\dut/n136 [4]), .CO(\dut/add_17/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_17/i5 .I0_POLARITY = 1'b1;
    defparam \dut/add_17/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_17/i4  (.I0(\dut/n126 [2]), .I1(\stimulus[19] ), .CI(\dut/add_17/n6 ), 
            .O(\dut/n136 [3]), .CO(\dut/add_17/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_17/i4 .I0_POLARITY = 1'b1;
    defparam \dut/add_17/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_17/i3  (.I0(\dut/n126 [1]), .I1(\stimulus[18] ), .CI(\dut/add_17/n4 ), 
            .O(\dut/n136 [2]), .CO(\dut/add_17/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_17/i3 .I0_POLARITY = 1'b1;
    defparam \dut/add_17/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_17/i2  (.I0(\dut/n126 [0]), .I1(\stimulus[17] ), .CI(\dut/add_17/n2 ), 
            .O(\dut/n136 [1]), .CO(\dut/add_17/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_17/i2 .I0_POLARITY = 1'b1;
    defparam \dut/add_17/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_16/i8  (.I0(1'b0), .I1(stimulus[47]), .CI(\dut/add_16/n14 ), 
            .O(\dut/n126 [7]), .CO(n681)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_16/i8 .I0_POLARITY = 1'b1;
    defparam \dut/add_16/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_16/i7  (.I0(stimulus[71]), .I1(\stimulus[46] ), .CI(\dut/add_16/n12 ), 
            .O(\dut/n126 [6]), .CO(\dut/add_16/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_16/i7 .I0_POLARITY = 1'b1;
    defparam \dut/add_16/i7 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_16/i6  (.I0(stimulus[70]), .I1(\stimulus[45] ), .CI(\dut/add_16/n10 ), 
            .O(\dut/n126 [5]), .CO(\dut/add_16/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_16/i6 .I0_POLARITY = 1'b1;
    defparam \dut/add_16/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_16/i5  (.I0(stimulus[69]), .I1(\stimulus[44] ), .CI(\dut/add_16/n8 ), 
            .O(\dut/n126 [4]), .CO(\dut/add_16/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(18)
    defparam \dut/add_16/i5 .I0_POLARITY = 1'b1;
    defparam \dut/add_16/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_26/i4  (.I0(\dut/ax2 [3]), .I1(\dut/ay2 [3]), .CI(\dut/add_26/n6 ), 
            .O(\dut/n238 [3]), .CO(\dut/add_26/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i4 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/sub_25/add_2/i1  (.I0(\dut/bottom1 [0]), .I1(\dut/top1 [0]), 
            .CI(n682), .O(\dut/n225 [0]), .CO(\dut/sub_25/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_26/i3  (.I0(\dut/ax2 [2]), .I1(\dut/ay2 [2]), .CI(\dut/add_26/n4 ), 
            .O(\dut/n238 [2]), .CO(\dut/add_26/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i3 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_19/i8  (.I0(\dut/n148 [6]), .I1(\stimulus[7] ), .CI(\dut/add_19/n14 ), 
            .O(\dut/n158 [7]), .CO(\dut/add_19/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_19/i8 .I0_POLARITY = 1'b1;
    defparam \dut/add_19/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_26/i2  (.I0(\dut/ax2 [1]), .I1(\dut/ay2 [1]), .CI(\dut/add_26/n2 ), 
            .O(\dut/n238 [1]), .CO(\dut/add_26/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam \dut/add_26/i2 .I0_POLARITY = 1'b1;
    defparam \dut/add_26/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_19/i7  (.I0(\dut/n148 [5]), .I1(stimulus[6]), .CI(\dut/add_19/n12 ), 
            .O(\dut/n158 [6]), .CO(\dut/add_19/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_19/i7 .I0_POLARITY = 1'b1;
    defparam \dut/add_19/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_19/i6  (.I0(\dut/n148 [4]), .I1(\stimulus[5] ), .CI(\dut/add_19/n10 ), 
            .O(\dut/n158 [5]), .CO(\dut/add_19/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_19/i6 .I0_POLARITY = 1'b1;
    defparam \dut/add_19/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_19/i5  (.I0(\dut/n148 [3]), .I1(\stimulus[4] ), .CI(\dut/add_19/n8 ), 
            .O(\dut/n158 [4]), .CO(\dut/add_19/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_19/i5 .I0_POLARITY = 1'b1;
    defparam \dut/add_19/i5 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_19/i4  (.I0(\dut/n148 [2]), .I1(\stimulus[3] ), .CI(\dut/add_19/n6 ), 
            .O(\dut/n158 [3]), .CO(\dut/add_19/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_19/i4 .I0_POLARITY = 1'b1;
    defparam \dut/add_19/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_19/i3  (.I0(\dut/n148 [1]), .I1(\stimulus[2] ), .CI(\dut/add_19/n4 ), 
            .O(\dut/n158 [2]), .CO(\dut/add_19/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_19/i3 .I0_POLARITY = 1'b1;
    defparam \dut/add_19/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_19/i2  (.I0(\dut/n148 [0]), .I1(stimulus[1]), .CI(\dut/add_19/n2 ), 
            .O(\dut/n158 [1]), .CO(\dut/add_19/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_19/i2 .I0_POLARITY = 1'b1;
    defparam \dut/add_19/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_18/i8  (.I0(1'b0), .I1(\stimulus[31] ), .CI(\dut/add_18/n14 ), 
            .O(\dut/n148 [7]), .CO(n683)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_18/i8 .I0_POLARITY = 1'b1;
    defparam \dut/add_18/i8 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_18/i7  (.I0(stimulus[55]), .I1(stimulus[30]), .CI(\dut/add_18/n12 ), 
            .O(\dut/n148 [6]), .CO(\dut/add_18/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_18/i7 .I0_POLARITY = 1'b1;
    defparam \dut/add_18/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_18/i6  (.I0(\stimulus[54] ), .I1(\stimulus[29] ), .CI(\dut/add_18/n10 ), 
            .O(\dut/n148 [5]), .CO(\dut/add_18/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b0, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_18/i6 .I0_POLARITY = 1'b0;
    defparam \dut/add_18/i6 .I1_POLARITY = 1'b0;
    EFX_ADD \dut/add_18/i5  (.I0(stimulus[53]), .I1(\stimulus[28] ), .CI(\dut/add_18/n8 ), 
            .O(\dut/n148 [4]), .CO(\dut/add_18/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_18/i5 .I0_POLARITY = 1'b1;
    defparam \dut/add_18/i5 .I1_POLARITY = 1'b0;
    EFX_DSP48 \dut/mult_28  (.A({8'b00000000, \dut/ax2 }), .B({18'b000000000000110101}), 
            .C({18'b000000000000000000}), .CASCIN({48'b000000000000000000000000000000000000000000000000}), 
            .OP({2'b00}), .SHIFT_ENA(1'b0), .CLK(clk), .CE(1'b0), .RST(1'b0), 
            .O({Open_0, Open_1, Open_2, Open_3, Open_4, Open_5, 
            Open_6, Open_7, Open_8, Open_9, Open_10, Open_11, Open_12, 
            Open_13, Open_14, Open_15, Open_16, Open_17, Open_18, 
            Open_19, Open_20, Open_21, Open_22, Open_23, Open_24, 
            Open_25, Open_26, Open_27, Open_28, Open_29, Open_30, 
            \dut/ax106_3 [17:1]})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_DSP48, SIGNED=0, W_SEL="P", MODE="NORMAL", ROUNDING="RNE", A_REG=1'b0, B_REG=1'b0, C_REG=1'b0, P_REG=1'b1, OP_REG=1'b0, W_REG=1'b0, O_REG=1'b0, SHIFTER=1'b0, RST_SYNC=1'b1, P_EXT="ALIGN_RIGHT", C_EXT="ALIGN_RIGHT", M_SEL="P", N_SEL="C", CASCOUT_SEL="W", CLK_POLARITY=1'b1, CE_POLARITY=1'b1, RST_POLARITY=1'b1, SHIFT_ENA_POLARITY=1'b1, A_REG_USE_CE=1'b1, B_REG_USE_CE=1'b1, C_REG_USE_CE=1'b1, OP_REG_USE_CE=1'b1, P_REG_USE_CE=1'b0, W_REG_USE_CE=1'b1, O_REG_USE_CE=1'b1, A_REG_USE_RST=1'b1, B_REG_USE_RST=1'b1, C_REG_USE_RST=1'b1, OP_REG_USE_RST=1'b1, P_REG_USE_RST=1'b0, W_REG_USE_RST=1'b1, O_REG_USE_RST=1'b1 */ ;
    defparam \dut/mult_28 .MODE = "NORMAL";
    defparam \dut/mult_28 .CLK_POLARITY = 1'b1;
    defparam \dut/mult_28 .CE_POLARITY = 1'b1;
    defparam \dut/mult_28 .RST_POLARITY = 1'b1;
    defparam \dut/mult_28 .SHIFT_ENA_POLARITY = 1'b1;
    defparam \dut/mult_28 .A_REG = 1'b0;
    defparam \dut/mult_28 .B_REG = 1'b0;
    defparam \dut/mult_28 .C_REG = 1'b0;
    defparam \dut/mult_28 .P_REG = 1'b1;
    defparam \dut/mult_28 .OP_REG = 1'b0;
    defparam \dut/mult_28 .W_REG = 1'b0;
    defparam \dut/mult_28 .O_REG = 1'b0;
    defparam \dut/mult_28 .A_REG_USE_CE = 1'b1;
    defparam \dut/mult_28 .B_REG_USE_CE = 1'b1;
    defparam \dut/mult_28 .C_REG_USE_CE = 1'b1;
    defparam \dut/mult_28 .P_REG_USE_CE = 1'b0;
    defparam \dut/mult_28 .OP_REG_USE_CE = 1'b1;
    defparam \dut/mult_28 .W_REG_USE_CE = 1'b1;
    defparam \dut/mult_28 .O_REG_USE_CE = 1'b1;
    defparam \dut/mult_28 .A_REG_USE_RST = 1'b1;
    defparam \dut/mult_28 .B_REG_USE_RST = 1'b1;
    defparam \dut/mult_28 .C_REG_USE_RST = 1'b1;
    defparam \dut/mult_28 .P_REG_USE_RST = 1'b0;
    defparam \dut/mult_28 .OP_REG_USE_RST = 1'b1;
    defparam \dut/mult_28 .W_REG_USE_RST = 1'b1;
    defparam \dut/mult_28 .O_REG_USE_RST = 1'b1;
    defparam \dut/mult_28 .RST_SYNC = 1'b1;
    defparam \dut/mult_28 .SIGNED = 0;
    defparam \dut/mult_28 .SHIFTER = 1'b0;
    defparam \dut/mult_28 .P_EXT = "ALIGN_RIGHT";
    defparam \dut/mult_28 .C_EXT = "ALIGN_RIGHT";
    defparam \dut/mult_28 .M_SEL = "P";
    defparam \dut/mult_28 .N_SEL = "C";
    defparam \dut/mult_28 .W_SEL = "P";
    defparam \dut/mult_28 .CASCOUT_SEL = "W";
    defparam \dut/mult_28 .ROUNDING = "RNE";
    EFX_DSP48 \dut/mult_29  (.A({8'b00000000, \dut/ay2 }), .B({18'b000000000000110101}), 
            .C({18'b000000000000000000}), .CASCIN({48'b000000000000000000000000000000000000000000000000}), 
            .OP({2'b00}), .SHIFT_ENA(1'b0), .CLK(clk), .CE(1'b0), .RST(1'b0), 
            .O({Open_31, Open_32, Open_33, Open_34, Open_35, Open_36, 
            Open_37, Open_38, Open_39, Open_40, Open_41, Open_42, 
            Open_43, Open_44, Open_45, Open_46, Open_47, Open_48, 
            Open_49, Open_50, Open_51, Open_52, Open_53, Open_54, 
            Open_55, Open_56, Open_57, Open_58, Open_59, Open_60, 
            Open_61, \dut/ay106_3 [17:1]})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_DSP48, SIGNED=0, W_SEL="P", MODE="NORMAL", ROUNDING="RNE", A_REG=1'b0, B_REG=1'b0, C_REG=1'b0, P_REG=1'b1, OP_REG=1'b0, W_REG=1'b0, O_REG=1'b0, SHIFTER=1'b0, RST_SYNC=1'b1, P_EXT="ALIGN_RIGHT", C_EXT="ALIGN_RIGHT", M_SEL="P", N_SEL="C", CASCOUT_SEL="W", CLK_POLARITY=1'b1, CE_POLARITY=1'b1, RST_POLARITY=1'b1, SHIFT_ENA_POLARITY=1'b1, A_REG_USE_CE=1'b1, B_REG_USE_CE=1'b1, C_REG_USE_CE=1'b1, OP_REG_USE_CE=1'b1, P_REG_USE_CE=1'b0, W_REG_USE_CE=1'b1, O_REG_USE_CE=1'b1, A_REG_USE_RST=1'b1, B_REG_USE_RST=1'b1, C_REG_USE_RST=1'b1, OP_REG_USE_RST=1'b1, P_REG_USE_RST=1'b0, W_REG_USE_RST=1'b1, O_REG_USE_RST=1'b1 */ ;
    defparam \dut/mult_29 .MODE = "NORMAL";
    defparam \dut/mult_29 .CLK_POLARITY = 1'b1;
    defparam \dut/mult_29 .CE_POLARITY = 1'b1;
    defparam \dut/mult_29 .RST_POLARITY = 1'b1;
    defparam \dut/mult_29 .SHIFT_ENA_POLARITY = 1'b1;
    defparam \dut/mult_29 .A_REG = 1'b0;
    defparam \dut/mult_29 .B_REG = 1'b0;
    defparam \dut/mult_29 .C_REG = 1'b0;
    defparam \dut/mult_29 .P_REG = 1'b1;
    defparam \dut/mult_29 .OP_REG = 1'b0;
    defparam \dut/mult_29 .W_REG = 1'b0;
    defparam \dut/mult_29 .O_REG = 1'b0;
    defparam \dut/mult_29 .A_REG_USE_CE = 1'b1;
    defparam \dut/mult_29 .B_REG_USE_CE = 1'b1;
    defparam \dut/mult_29 .C_REG_USE_CE = 1'b1;
    defparam \dut/mult_29 .P_REG_USE_CE = 1'b0;
    defparam \dut/mult_29 .OP_REG_USE_CE = 1'b1;
    defparam \dut/mult_29 .W_REG_USE_CE = 1'b1;
    defparam \dut/mult_29 .O_REG_USE_CE = 1'b1;
    defparam \dut/mult_29 .A_REG_USE_RST = 1'b1;
    defparam \dut/mult_29 .B_REG_USE_RST = 1'b1;
    defparam \dut/mult_29 .C_REG_USE_RST = 1'b1;
    defparam \dut/mult_29 .P_REG_USE_RST = 1'b0;
    defparam \dut/mult_29 .OP_REG_USE_RST = 1'b1;
    defparam \dut/mult_29 .W_REG_USE_RST = 1'b1;
    defparam \dut/mult_29 .O_REG_USE_RST = 1'b1;
    defparam \dut/mult_29 .RST_SYNC = 1'b1;
    defparam \dut/mult_29 .SIGNED = 0;
    defparam \dut/mult_29 .SHIFTER = 1'b0;
    defparam \dut/mult_29 .P_EXT = "ALIGN_RIGHT";
    defparam \dut/mult_29 .C_EXT = "ALIGN_RIGHT";
    defparam \dut/mult_29 .M_SEL = "P";
    defparam \dut/mult_29 .N_SEL = "C";
    defparam \dut/mult_29 .W_SEL = "P";
    defparam \dut/mult_29 .CASCOUT_SEL = "W";
    defparam \dut/mult_29 .ROUNDING = "RNE";
    EFX_SRL8 \dut/dff_56/i20_2  (.D(stimulus[19]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i20_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i20_2 .INIT = 8'h0;
    defparam \dut/dff_56/i20_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i20_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i30_2  (.D(stimulus[29]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i30_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i30_2 .INIT = 8'h0;
    defparam \dut/dff_56/i30_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i30_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i40_2  (.D(stimulus[39]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i40_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i40_2 .INIT = 8'h0;
    defparam \dut/dff_56/i40_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i40_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i50_2  (.D(stimulus[49]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i50_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i50_2 .INIT = 8'h0;
    defparam \dut/dff_56/i50_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i50_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i60_2  (.D(stimulus[59]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i60_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i60_2 .INIT = 8'h0;
    defparam \dut/dff_56/i60_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i60_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i6_2  (.D(stimulus[5]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i6_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i6_2 .INIT = 8'h0;
    defparam \dut/dff_56/i6_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i6_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i7_2  (.D(stimulus[6]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i7_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i7_2 .INIT = 8'h0;
    defparam \dut/dff_56/i7_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i7_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i8_2  (.D(stimulus[7]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i8_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i8_2 .INIT = 8'h0;
    defparam \dut/dff_56/i8_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i8_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i9_2  (.D(stimulus[8]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i9_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i9_2 .INIT = 8'h0;
    defparam \dut/dff_56/i9_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i9_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i1_2  (.D(stimulus[0]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i1_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i1_2 .INIT = 8'h0;
    defparam \dut/dff_56/i1_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i1_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i11_2  (.D(stimulus[10]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i11_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i11_2 .INIT = 8'h0;
    defparam \dut/dff_56/i11_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i11_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i12_2  (.D(stimulus[11]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i12_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i12_2 .INIT = 8'h0;
    defparam \dut/dff_56/i12_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i12_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i13_2  (.D(stimulus[12]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i13_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i13_2 .INIT = 8'h0;
    defparam \dut/dff_56/i13_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i13_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i14_2  (.D(stimulus[13]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i14_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i14_2 .INIT = 8'h0;
    defparam \dut/dff_56/i14_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i14_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i15_2  (.D(stimulus[14]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i15_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i15_2 .INIT = 8'h0;
    defparam \dut/dff_56/i15_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i15_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i16_2  (.D(stimulus[15]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i16_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i16_2 .INIT = 8'h0;
    defparam \dut/dff_56/i16_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i16_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i17_2  (.D(stimulus[16]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i17_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i17_2 .INIT = 8'h0;
    defparam \dut/dff_56/i17_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i17_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i18_2  (.D(stimulus[17]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i18_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i18_2 .INIT = 8'h0;
    defparam \dut/dff_56/i18_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i18_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i19_2  (.D(stimulus[18]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i19_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i19_2 .INIT = 8'h0;
    defparam \dut/dff_56/i19_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i19_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i2_2  (.D(stimulus[1]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i2_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i2_2 .INIT = 8'h0;
    defparam \dut/dff_56/i2_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i2_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i21_2  (.D(stimulus[20]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i21_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i21_2 .INIT = 8'h0;
    defparam \dut/dff_56/i21_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i21_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i22_2  (.D(stimulus[21]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i22_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i22_2 .INIT = 8'h0;
    defparam \dut/dff_56/i22_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i22_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i23_2  (.D(stimulus[22]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i23_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i23_2 .INIT = 8'h0;
    defparam \dut/dff_56/i23_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i23_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i24_2  (.D(stimulus[23]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i24_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i24_2 .INIT = 8'h0;
    defparam \dut/dff_56/i24_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i24_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i25_2  (.D(stimulus[24]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i25_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i25_2 .INIT = 8'h0;
    defparam \dut/dff_56/i25_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i25_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i26_2  (.D(stimulus[25]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i26_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i26_2 .INIT = 8'h0;
    defparam \dut/dff_56/i26_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i26_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i27_2  (.D(stimulus[26]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i27_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i27_2 .INIT = 8'h0;
    defparam \dut/dff_56/i27_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i27_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i28_2  (.D(stimulus[27]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i28_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i28_2 .INIT = 8'h0;
    defparam \dut/dff_56/i28_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i28_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i29_2  (.D(stimulus[28]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i29_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i29_2 .INIT = 8'h0;
    defparam \dut/dff_56/i29_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i29_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i3_2  (.D(stimulus[2]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i3_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i3_2 .INIT = 8'h0;
    defparam \dut/dff_56/i3_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i3_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i31_2  (.D(stimulus[30]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i31_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i31_2 .INIT = 8'h0;
    defparam \dut/dff_56/i31_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i31_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i32_2  (.D(stimulus[31]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i32_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i32_2 .INIT = 8'h0;
    defparam \dut/dff_56/i32_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i32_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i33_2  (.D(stimulus[32]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i33_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i33_2 .INIT = 8'h0;
    defparam \dut/dff_56/i33_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i33_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i34_2  (.D(stimulus[33]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i34_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i34_2 .INIT = 8'h0;
    defparam \dut/dff_56/i34_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i34_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i35_2  (.D(stimulus[34]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i35_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i35_2 .INIT = 8'h0;
    defparam \dut/dff_56/i35_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i35_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i36_2  (.D(stimulus[35]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i36_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i36_2 .INIT = 8'h0;
    defparam \dut/dff_56/i36_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i36_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i37_2  (.D(stimulus[36]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i37_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i37_2 .INIT = 8'h0;
    defparam \dut/dff_56/i37_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i37_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i38_2  (.D(stimulus[37]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i38_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i38_2 .INIT = 8'h0;
    defparam \dut/dff_56/i38_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i38_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i39_2  (.D(stimulus[38]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i39_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i39_2 .INIT = 8'h0;
    defparam \dut/dff_56/i39_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i39_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i4_2  (.D(stimulus[3]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i4_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i4_2 .INIT = 8'h0;
    defparam \dut/dff_56/i4_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i4_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i41_2  (.D(stimulus[40]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i41_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i41_2 .INIT = 8'h0;
    defparam \dut/dff_56/i41_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i41_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i42_2  (.D(stimulus[41]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i42_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i42_2 .INIT = 8'h0;
    defparam \dut/dff_56/i42_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i42_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i43_2  (.D(stimulus[42]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i43_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i43_2 .INIT = 8'h0;
    defparam \dut/dff_56/i43_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i43_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i44_2  (.D(stimulus[43]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i44_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i44_2 .INIT = 8'h0;
    defparam \dut/dff_56/i44_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i44_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i45_2  (.D(stimulus[44]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i45_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i45_2 .INIT = 8'h0;
    defparam \dut/dff_56/i45_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i45_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i46_2  (.D(stimulus[45]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i46_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i46_2 .INIT = 8'h0;
    defparam \dut/dff_56/i46_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i46_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i47_2  (.D(stimulus[46]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i47_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i47_2 .INIT = 8'h0;
    defparam \dut/dff_56/i47_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i47_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i48_2  (.D(stimulus[47]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i48_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i48_2 .INIT = 8'h0;
    defparam \dut/dff_56/i48_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i48_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i49_2  (.D(stimulus[48]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i49_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i49_2 .INIT = 8'h0;
    defparam \dut/dff_56/i49_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i49_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i5_2  (.D(stimulus[4]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i5_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i5_2 .INIT = 8'h0;
    defparam \dut/dff_56/i5_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i5_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i51_2  (.D(stimulus[50]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i51_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i51_2 .INIT = 8'h0;
    defparam \dut/dff_56/i51_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i51_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i52_2  (.D(stimulus[51]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i52_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i52_2 .INIT = 8'h0;
    defparam \dut/dff_56/i52_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i52_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i53_2  (.D(stimulus[52]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i53_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i53_2 .INIT = 8'h0;
    defparam \dut/dff_56/i53_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i53_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i54_2  (.D(stimulus[53]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i54_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i54_2 .INIT = 8'h0;
    defparam \dut/dff_56/i54_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i54_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i55_2  (.D(stimulus[54]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i55_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i55_2 .INIT = 8'h0;
    defparam \dut/dff_56/i55_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i55_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i56_2  (.D(stimulus[55]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i56_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i56_2 .INIT = 8'h0;
    defparam \dut/dff_56/i56_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i56_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i57_2  (.D(stimulus[56]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i57_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i57_2 .INIT = 8'h0;
    defparam \dut/dff_56/i57_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i57_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i58_2  (.D(stimulus[57]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i58_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i58_2 .INIT = 8'h0;
    defparam \dut/dff_56/i58_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i58_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i59_2  (.D(stimulus[58]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i59_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i59_2 .INIT = 8'h0;
    defparam \dut/dff_56/i59_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i59_2 .CE_POLARITY = 1'b1;
    EFX_SRL8 \dut/dff_56/i10_2  (.D(stimulus[9]), .CLK(clk), .CE(1'b1), 
            .Q(\dut/dff_56/i10_pre ), .A({3'b100})) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_SRL8, INIT=8'h0, CLK_POLARITY=1'b1, CE_POLARITY=1'b1 */ ;
    defparam \dut/dff_56/i10_2 .INIT = 8'h0;
    defparam \dut/dff_56/i10_2 .CLK_POLARITY = 1'b1;
    defparam \dut/dff_56/i10_2 .CE_POLARITY = 1'b1;
    EFX_LUT4 LUT__1442 (.I0(n601), .I1(\dut/gx2 [10]), .I2(\dut/gx2 [2]), 
            .O(\dut/ax2 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb4b4 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1442.LUTMASK = 16'hb4b4;
    EFX_LUT4 LUT__1443 (.I0(\dut/gx2 [2]), .I1(n601), .I2(\dut/gx2 [10]), 
            .I3(\dut/gx2 [3]), .O(\dut/ax2 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4fb0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1443.LUTMASK = 16'h4fb0;
    EFX_LUT4 LUT__1444 (.I0(\dut/gx2 [2]), .I1(\dut/gx2 [3]), .I2(n601), 
            .O(n602)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__1444.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__1445 (.I0(n602), .I1(\dut/gx2 [10]), .I2(\dut/gx2 [4]), 
            .O(\dut/ax2 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb4b4 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1445.LUTMASK = 16'hb4b4;
    EFX_LUT4 LUT__1446 (.I0(\dut/gx2 [4]), .I1(n602), .I2(\dut/gx2 [10]), 
            .I3(\dut/gx2 [5]), .O(\dut/ax2 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4fb0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1446.LUTMASK = 16'h4fb0;
    EFX_LUT4 LUT__1447 (.I0(\dut/gx2 [4]), .I1(\dut/gx2 [5]), .I2(n602), 
            .O(n603)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__1447.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__1448 (.I0(n603), .I1(\dut/gx2 [10]), .I2(\dut/gx2 [6]), 
            .O(\dut/ax2 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb4b4 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1448.LUTMASK = 16'hb4b4;
    EFX_LUT4 LUT__1449 (.I0(\dut/gx2 [6]), .I1(n603), .I2(\dut/gx2 [10]), 
            .I3(\dut/gx2 [7]), .O(\dut/ax2 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4fb0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1449.LUTMASK = 16'h4fb0;
    EFX_LUT4 LUT__1450 (.I0(\dut/gx2 [6]), .I1(\dut/gx2 [7]), .I2(n603), 
            .O(n604)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__1450.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__1451 (.I0(n604), .I1(\dut/gx2 [10]), .I2(\dut/gx2 [8]), 
            .O(\dut/ax2 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb4b4 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1451.LUTMASK = 16'hb4b4;
    EFX_LUT4 LUT__1452 (.I0(\dut/gx2 [8]), .I1(n604), .I2(\dut/gx2 [10]), 
            .I3(\dut/gx2 [9]), .O(\dut/ax2 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4fb0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1452.LUTMASK = 16'h4fb0;
    EFX_LUT4 LUT__1453 (.I0(\dut/gx2 [8]), .I1(\dut/gx2 [9]), .I2(\dut/gx2 [10]), 
            .I3(n604), .O(\dut/ax2 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1453.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__1454 (.I0(\dut/ay2 [0]), .I1(\dut/gy2 [1]), .O(n605)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;
    defparam LUT__1454.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__1455 (.I0(\dut/gy2 [2]), .I1(\dut/gy2 [3]), .I2(n605), 
            .O(n606)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__1455.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__1456 (.I0(n606), .I1(\dut/gy2 [10]), .I2(\dut/gy2 [4]), 
            .O(\dut/ay2 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb4b4 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1456.LUTMASK = 16'hb4b4;
    EFX_LUT4 LUT__1457 (.I0(\threshold[8] ), .I1(threshold[10]), .O(n9)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(9)
    defparam LUT__1457.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__1458 (.I0(\dut/dff_56/i59_pre ), .I1(\dut/dff_56/i10_pre ), 
            .I2(mag[1]), .I3(mag[9]), .O(n607)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1458.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1459 (.I0(mag[4]), .I1(mag[6]), .I2(mag[7]), .I3(mag[8]), 
            .O(n608)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1459.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1460 (.I0(mag[0]), .I1(\dut/dff_56/i36_pre ), .I2(\dut/dff_56/i38_pre ), 
            .I3(\dut/dff_56/i58_pre ), .O(n609)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1460.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1461 (.I0(\dut/dff_56/i39_pre ), .I1(\dut/dff_56/i43_pre ), 
            .I2(\dut/dff_56/i46_pre ), .I3(\dut/dff_56/i57_pre ), .O(n610)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1461.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1462 (.I0(n607), .I1(n608), .I2(n609), .I3(n610), 
            .O(n611)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1462.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1463 (.I0(\dut/dff_56/i7_pre ), .I1(\dut/dff_56/i8_pre ), 
            .I2(\dut/dff_56/i9_pre ), .I3(\dut/dff_56/i12_pre ), .O(n612)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1463.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1464 (.I0(edge_pixel), .I1(\dut/dff_56/i1_pre ), .I2(\dut/dff_56/i11_pre ), 
            .I3(mag[2]), .O(n613)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1464.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1465 (.I0(\dut/dff_56/i20_pre ), .I1(\dut/dff_56/i6_pre ), 
            .I2(\dut/dff_56/i25_pre ), .I3(\dut/dff_56/i26_pre ), .O(n614)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1465.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1466 (.I0(\dut/dff_56/i30_pre ), .I1(\dut/dff_56/i40_pre ), 
            .I2(\dut/dff_56/i50_pre ), .I3(\dut/dff_56/i60_pre ), .O(n615)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1466.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1467 (.I0(n612), .I1(n613), .I2(n614), .I3(n615), 
            .O(n616)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1467.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1468 (.I0(\dut/dff_56/i16_pre ), .I1(\dut/dff_56/i19_pre ), 
            .I2(\dut/dff_56/i47_pre ), .I3(\dut/dff_56/i48_pre ), .O(n617)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1468.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1469 (.I0(\dut/dff_56/i14_pre ), .I1(\dut/dff_56/i15_pre ), 
            .I2(n617), .O(n618)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9696 */ ;
    defparam LUT__1469.LUTMASK = 16'h9696;
    EFX_LUT4 LUT__1470 (.I0(\dut/dff_56/i13_pre ), .I1(\dut/dff_56/i17_pre ), 
            .I2(\dut/dff_56/i18_pre ), .I3(\dut/dff_56/i2_pre ), .O(n619)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1470.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1471 (.I0(\dut/dff_56/i21_pre ), .I1(\dut/dff_56/i22_pre ), 
            .I2(\dut/dff_56/i23_pre ), .I3(\dut/dff_56/i24_pre ), .O(n620)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1471.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1472 (.I0(n616), .I1(n618), .I2(n619), .I3(n620), 
            .O(n621)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1472.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1473 (.I0(direction[0]), .I1(\dut/dff_56/i27_pre ), .I2(mag[10]), 
            .I3(direction[1]), .O(n622)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1473.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1474 (.I0(\dut/dff_56/i28_pre ), .I1(\dut/dff_56/i29_pre ), 
            .I2(\dut/dff_56/i3_pre ), .I3(\dut/dff_56/i33_pre ), .O(n623)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1474.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1475 (.I0(\dut/dff_56/i52_pre ), .I1(\dut/dff_56/i53_pre ), 
            .I2(\dut/dff_56/i54_pre ), .I3(\dut/dff_56/i55_pre ), .O(n624)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1475.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1476 (.I0(\dut/dff_56/i51_pre ), .I1(\dut/dff_56/i56_pre ), 
            .I2(mag[3]), .I3(mag[5]), .O(n625)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1476.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1477 (.I0(n622), .I1(n623), .I2(n624), .I3(n625), 
            .O(n626)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1477.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1478 (.I0(\dut/dff_56/i31_pre ), .I1(\dut/dff_56/i32_pre ), 
            .I2(\dut/dff_56/i34_pre ), .I3(\dut/dff_56/i5_pre ), .O(n627)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1478.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1479 (.I0(\dut/dff_56/i42_pre ), .I1(\dut/dff_56/i44_pre ), 
            .I2(\dut/dff_56/i45_pre ), .I3(\dut/dff_56/i49_pre ), .O(n628)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1479.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1480 (.I0(\dut/dff_56/i35_pre ), .I1(\dut/dff_56/i37_pre ), 
            .I2(\dut/dff_56/i4_pre ), .I3(\dut/dff_56/i41_pre ), .O(n629)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1480.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1481 (.I0(n626), .I1(n627), .I2(n628), .I3(n629), 
            .O(n630)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9669 */ ;
    defparam LUT__1481.LUTMASK = 16'h9669;
    EFX_LUT4 LUT__1482 (.I0(n611), .I1(n621), .I2(n630), .O(n10)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6969 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(10)
    defparam LUT__1482.LUTMASK = 16'h6969;
    EFX_LUT4 LUT__1483 (.I0(\stimulus[18] ), .I1(stimulus[24]), .I2(\stimulus[65] ), 
            .I3(stimulus[71]), .O(n8)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6996 */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(8)
    defparam LUT__1483.LUTMASK = 16'h6996;
    EFX_LUT4 LUT__1484 (.I0(\dut/gy2 [4]), .I1(\dut/gy2 [5]), .I2(n606), 
            .O(n631)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__1484.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__1485 (.I0(\dut/gy2 [6]), .I1(\dut/gy2 [7]), .I2(n631), 
            .O(n632)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__1485.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__1486 (.I0(n632), .I1(\dut/gy2 [10]), .I2(\dut/gy2 [8]), 
            .O(\dut/ay2 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb4b4 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1486.LUTMASK = 16'hb4b4;
    EFX_LUT4 LUT__1487 (.I0(\dut/ax106_3 [1]), .I1(\dut/ax106_3 [2]), .I2(\dut/ax106_3 [3]), 
            .O(n633)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;
    defparam LUT__1487.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__1488 (.I0(\dut/ax106_3 [4]), .I1(\dut/ax106_3 [5]), .I2(\dut/ax106_3 [6]), 
            .I3(\dut/ax106_3 [7]), .O(n634)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__1488.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__1489 (.I0(\dut/ax106_3 [8]), .I1(\dut/ay256_3 [8]), .O(n635)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__1489.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__1490 (.I0(\dut/ay256_3 [9]), .I1(\dut/ax106_3 [9]), .I2(\dut/ay256_3 [8]), 
            .I3(\dut/ax106_3 [8]), .O(n636)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1490.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1491 (.I0(n634), .I1(n633), .I2(n635), .I3(n636), 
            .O(n637)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hf800 */ ;
    defparam LUT__1491.LUTMASK = 16'hf800;
    EFX_LUT4 LUT__1492 (.I0(\dut/ax106_3 [10]), .I1(\dut/ay256_3 [10]), 
            .I2(\dut/ax106_3 [9]), .I3(\dut/ay256_3 [9]), .O(n638)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1492.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1493 (.I0(\dut/ay256_3 [11]), .I1(\dut/ax106_3 [11]), 
            .I2(\dut/ay256_3 [10]), .I3(\dut/ax106_3 [10]), .O(n639)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1493.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1494 (.I0(\dut/ax106_3 [12]), .I1(\dut/ay256_3 [12]), 
            .I2(\dut/ax106_3 [11]), .I3(\dut/ay256_3 [11]), .O(n640)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1494.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1495 (.I0(n637), .I1(n638), .I2(n639), .I3(n640), 
            .O(n641)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4f00 */ ;
    defparam LUT__1495.LUTMASK = 16'h4f00;
    EFX_LUT4 LUT__1496 (.I0(\dut/ay256_3 [13]), .I1(\dut/ax106_3 [13]), 
            .I2(\dut/ay256_3 [12]), .I3(\dut/ax106_3 [12]), .O(n642)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1496.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1497 (.I0(\dut/ax106_3 [14]), .I1(\dut/ay256_3 [14]), 
            .I2(\dut/ax106_3 [13]), .I3(\dut/ay256_3 [13]), .O(n643)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1497.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1498 (.I0(\dut/ay256_3 [15]), .I1(\dut/ax106_3 [15]), 
            .I2(\dut/ay256_3 [14]), .I3(\dut/ax106_3 [14]), .O(n644)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1498.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1499 (.I0(n641), .I1(n642), .I2(n643), .I3(n644), 
            .O(n645)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4f00 */ ;
    defparam LUT__1499.LUTMASK = 16'h4f00;
    EFX_LUT4 LUT__1500 (.I0(\dut/ax106_3 [16]), .I1(\dut/ay256_3 [16]), 
            .I2(\dut/ax106_3 [15]), .I3(\dut/ay256_3 [15]), .O(n646)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1500.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1501 (.I0(\dut/ay256_3 [17]), .I1(\dut/ax106_3 [17]), 
            .I2(\dut/ay256_3 [16]), .I3(\dut/ax106_3 [16]), .O(n647)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1501.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1502 (.I0(\dut/ay256_3 [17]), .I1(\dut/ax106_3 [17]), 
            .I2(\dut/ay256_3 [18]), .O(n648)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0d0d */ ;
    defparam LUT__1502.LUTMASK = 16'h0d0d;
    EFX_LUT4 LUT__1503 (.I0(n645), .I1(n646), .I2(n647), .I3(n648), 
            .O(\dut/n288 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4f00 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(32)
    defparam LUT__1503.LUTMASK = 16'h4f00;
    EFX_LUT4 LUT__1504 (.I0(\dut/ay106_3 [1]), .I1(\dut/ay106_3 [2]), .I2(\dut/ay106_3 [3]), 
            .O(n649)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;
    defparam LUT__1504.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__1505 (.I0(\dut/ay106_3 [4]), .I1(\dut/ay106_3 [5]), .I2(\dut/ay106_3 [6]), 
            .I3(\dut/ay106_3 [7]), .O(n650)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__1505.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__1506 (.I0(\dut/ay106_3 [8]), .I1(\dut/ax256_3 [8]), .O(n651)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__1506.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__1507 (.I0(\dut/ax256_3 [9]), .I1(\dut/ay106_3 [9]), .I2(\dut/ax256_3 [8]), 
            .I3(\dut/ay106_3 [8]), .O(n652)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1507.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1508 (.I0(n650), .I1(n649), .I2(n651), .I3(n652), 
            .O(n653)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hf800 */ ;
    defparam LUT__1508.LUTMASK = 16'hf800;
    EFX_LUT4 LUT__1509 (.I0(\dut/ay106_3 [10]), .I1(\dut/ax256_3 [10]), 
            .I2(\dut/ay106_3 [9]), .I3(\dut/ax256_3 [9]), .O(n654)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1509.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1510 (.I0(\dut/ax256_3 [11]), .I1(\dut/ay106_3 [11]), 
            .I2(\dut/ax256_3 [10]), .I3(\dut/ay106_3 [10]), .O(n655)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1510.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1511 (.I0(\dut/ay106_3 [12]), .I1(\dut/ax256_3 [12]), 
            .I2(\dut/ay106_3 [11]), .I3(\dut/ax256_3 [11]), .O(n656)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1511.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1512 (.I0(n653), .I1(n654), .I2(n655), .I3(n656), 
            .O(n657)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4f00 */ ;
    defparam LUT__1512.LUTMASK = 16'h4f00;
    EFX_LUT4 LUT__1513 (.I0(\dut/ax256_3 [13]), .I1(\dut/ay106_3 [13]), 
            .I2(\dut/ax256_3 [12]), .I3(\dut/ay106_3 [12]), .O(n658)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1513.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1514 (.I0(\dut/ay106_3 [14]), .I1(\dut/ax256_3 [14]), 
            .I2(\dut/ay106_3 [13]), .I3(\dut/ax256_3 [13]), .O(n659)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1514.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1515 (.I0(\dut/ax256_3 [15]), .I1(\dut/ay106_3 [15]), 
            .I2(\dut/ax256_3 [14]), .I3(\dut/ay106_3 [14]), .O(n660)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1515.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1516 (.I0(n657), .I1(n658), .I2(n659), .I3(n660), 
            .O(n661)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4f00 */ ;
    defparam LUT__1516.LUTMASK = 16'h4f00;
    EFX_LUT4 LUT__1517 (.I0(\dut/ay106_3 [16]), .I1(\dut/ax256_3 [16]), 
            .I2(\dut/ay106_3 [15]), .I3(\dut/ax256_3 [15]), .O(n662)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1517.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1518 (.I0(\dut/ax256_3 [17]), .I1(\dut/ay106_3 [17]), 
            .I2(\dut/ax256_3 [16]), .I3(\dut/ay106_3 [16]), .O(n663)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1518.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1519 (.I0(\dut/ax256_3 [17]), .I1(\dut/ay106_3 [17]), 
            .I2(\dut/ax256_3 [18]), .O(n664)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0d0d */ ;
    defparam LUT__1519.LUTMASK = 16'h0d0d;
    EFX_LUT4 LUT__1520 (.I0(n661), .I1(n662), .I2(n663), .I3(n664), 
            .O(n665)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4f00 */ ;
    defparam LUT__1520.LUTMASK = 16'h4f00;
    EFX_LUT4 LUT__1521 (.I0(\dut/n288 ), .I1(n665), .O(\dut/n1319 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(12)
    defparam LUT__1521.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__1522 (.I0(\dut/ay2 [0]), .I1(\dut/gy2 [10]), .I2(\dut/gy2 [1]), 
            .O(\dut/ay2 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7878 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1522.LUTMASK = 16'h7878;
    EFX_LUT4 LUT__1523 (.I0(n605), .I1(\dut/gy2 [10]), .I2(\dut/gy2 [2]), 
            .O(\dut/ay2 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb4b4 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1523.LUTMASK = 16'hb4b4;
    EFX_LUT4 LUT__1524 (.I0(\dut/gy2 [2]), .I1(n605), .I2(\dut/gy2 [10]), 
            .I3(\dut/gy2 [3]), .O(\dut/ay2 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4fb0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1524.LUTMASK = 16'h4fb0;
    EFX_LUT4 LUT__1525 (.I0(\dut/gy2 [4]), .I1(n606), .I2(\dut/gy2 [10]), 
            .I3(\dut/gy2 [5]), .O(\dut/ay2 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4fb0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1525.LUTMASK = 16'h4fb0;
    EFX_LUT4 LUT__1526 (.I0(n631), .I1(\dut/gy2 [10]), .I2(\dut/gy2 [6]), 
            .O(\dut/ay2 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb4b4 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1526.LUTMASK = 16'hb4b4;
    EFX_LUT4 LUT__1527 (.I0(\dut/gy2 [6]), .I1(n631), .I2(\dut/gy2 [10]), 
            .I3(\dut/gy2 [7]), .O(\dut/ay2 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4fb0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1527.LUTMASK = 16'h4fb0;
    EFX_LUT4 LUT__1528 (.I0(\dut/gy2 [8]), .I1(n632), .I2(\dut/gy2 [10]), 
            .I3(\dut/gy2 [9]), .O(\dut/ay2 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4fb0 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1528.LUTMASK = 16'h4fb0;
    EFX_LUT4 LUT__1529 (.I0(\dut/gy2 [8]), .I1(\dut/gy2 [9]), .I2(\dut/gy2 [10]), 
            .I3(n632), .O(\dut/ay2 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1529.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__1530 (.I0(\dut/gx2 [10]), .I1(\dut/gy2 [10]), .O(\dut/n250 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(26)
    defparam LUT__1530.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__1531 (.I0(\dut/t3 [3]), .I1(\dut/mag3 [3]), .O(n666)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__1531.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__1532 (.I0(\dut/mag3 [1]), .I1(\dut/mag3 [0]), .I2(\dut/t3 [1]), 
            .I3(\dut/t3 [0]), .O(n667)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8eaf */ ;
    defparam LUT__1532.LUTMASK = 16'h8eaf;
    EFX_LUT4 LUT__1533 (.I0(\dut/mag3 [3]), .I1(\dut/t3 [3]), .O(n668)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__1533.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__1534 (.I0(\dut/t2 [3]), .I1(\dut/mag3 [2]), .I2(n667), 
            .I3(n668), .O(n669)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h00d4 */ ;
    defparam LUT__1534.LUTMASK = 16'h00d4;
    EFX_LUT4 LUT__1535 (.I0(\dut/mag3 [4]), .I1(n666), .I2(n669), .I3(\dut/t3 [4]), 
            .O(n670)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'ha8fe */ ;
    defparam LUT__1535.LUTMASK = 16'ha8fe;
    EFX_LUT4 LUT__1536 (.I0(\dut/t3 [7]), .I1(\dut/mag3 [7]), .I2(\dut/t2 [7]), 
            .I3(\dut/mag3 [6]), .O(n671)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1536.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1537 (.I0(\dut/t1 [7]), .I1(\dut/mag3 [5]), .I2(n670), 
            .I3(n671), .O(n672)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h2b00 */ ;
    defparam LUT__1537.LUTMASK = 16'h2b00;
    EFX_LUT4 LUT__1538 (.I0(\dut/mag3 [7]), .I1(\dut/t3 [7]), .I2(\dut/mag3 [9]), 
            .I3(\dut/t2 [10]), .O(n673)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0bb */ ;
    defparam LUT__1538.LUTMASK = 16'hb0bb;
    EFX_LUT4 LUT__1539 (.I0(\dut/mag3 [8]), .I1(\dut/t1 [10]), .I2(n673), 
            .O(n674)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb0b0 */ ;
    defparam LUT__1539.LUTMASK = 16'hb0b0;
    EFX_LUT4 LUT__1540 (.I0(\dut/mag3 [6]), .I1(n671), .I2(\dut/t2 [7]), 
            .I3(n674), .O(n675)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hbf00 */ ;
    defparam LUT__1540.LUTMASK = 16'hbf00;
    EFX_LUT4 LUT__1541 (.I0(\dut/t2 [10]), .I1(\dut/t1 [10]), .I2(\dut/mag3 [9]), 
            .I3(\dut/mag3 [8]), .O(n676)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8eaf */ ;
    defparam LUT__1541.LUTMASK = 16'h8eaf;
    EFX_LUT4 LUT__1542 (.I0(n675), .I1(n672), .I2(n676), .O(n677)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hd0d0 */ ;
    defparam LUT__1542.LUTMASK = 16'hd0d0;
    EFX_LUT4 LUT__1543 (.I0(\dut/mag3 [10]), .I1(\dut/t3 [10]), .I2(n677), 
            .O(\dut/n287 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h2b2b */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(30)
    defparam LUT__1543.LUTMASK = 16'h2b2b;
    EFX_LUT4 LUT__1544 (.I0(\dut/signs3 ), .I1(n665), .O(\dut/n293 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(34)
    defparam LUT__1544.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__1549 (.I0(\stimulus[49] ), .O(stimulus[49])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1549.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1551 (.I0(\stimulus[17] ), .O(stimulus[17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1551.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1553 (.I0(\stimulus[52] ), .O(stimulus[52])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1553.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1554 (.I0(\stimulus[27] ), .O(stimulus[27])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1554.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1555 (.I0(\stimulus[7] ), .O(stimulus[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1555.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1556 (.I0(\stimulus[5] ), .O(stimulus[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1556.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1557 (.I0(\stimulus[4] ), .O(stimulus[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1557.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1558 (.I0(\stimulus[3] ), .O(stimulus[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1558.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1559 (.I0(\stimulus[2] ), .O(stimulus[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1559.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1571 (.I0(\stimulus[43] ), .O(stimulus[43])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1571.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1579 (.I0(\stimulus[19] ), .O(stimulus[19])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1579.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1580 (.I0(\stimulus[29] ), .O(stimulus[29])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1580.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1581 (.I0(\stimulus[39] ), .O(stimulus[39])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1581.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1582 (.I0(\stimulus[11] ), .O(stimulus[11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1582.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1583 (.I0(\stimulus[12] ), .O(stimulus[12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1583.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1584 (.I0(\stimulus[13] ), .O(stimulus[13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1584.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1585 (.I0(\stimulus[14] ), .O(stimulus[14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1585.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1586 (.I0(\stimulus[15] ), .O(stimulus[15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1586.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1587 (.I0(\stimulus[18] ), .O(stimulus[18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1587.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1588 (.I0(\stimulus[20] ), .O(stimulus[20])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1588.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1589 (.I0(\stimulus[22] ), .O(stimulus[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1589.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1590 (.I0(\stimulus[23] ), .O(stimulus[23])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1590.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1591 (.I0(\stimulus[26] ), .O(stimulus[26])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1591.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1592 (.I0(\stimulus[28] ), .O(stimulus[28])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1592.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1593 (.I0(\stimulus[31] ), .O(stimulus[31])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1593.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1594 (.I0(\stimulus[33] ), .O(stimulus[33])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1594.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1595 (.I0(\stimulus[35] ), .O(stimulus[35])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1595.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1596 (.I0(\stimulus[36] ), .O(stimulus[36])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1596.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1597 (.I0(\stimulus[44] ), .O(stimulus[44])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1597.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1598 (.I0(\stimulus[45] ), .O(stimulus[45])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1598.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1599 (.I0(\stimulus[46] ), .O(stimulus[46])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1599.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1600 (.I0(\stimulus[50] ), .O(stimulus[50])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1600.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1601 (.I0(\stimulus[54] ), .O(stimulus[54])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1601.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1602 (.I0(\stimulus[58] ), .O(stimulus[58])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1602.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1603 (.I0(\stimulus[9] ), .O(stimulus[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\efinity\sobel_220\sobel_timing_top.sv(11)
    defparam LUT__1603.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__1440 (.I0(\dut/ax2 [0]), .I1(\dut/gx2 [10]), .I2(\dut/gx2 [1]), 
            .O(\dut/ax2 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7878 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(10)
    defparam LUT__1440.LUTMASK = 16'h7878;
    EFX_LUT4 LUT__1441 (.I0(\dut/ax2 [0]), .I1(\dut/gx2 [1]), .O(n601)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;
    defparam LUT__1441.LUTMASK = 16'h1111;
    EFX_ADD \dut/add_22/i8__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), .CI(n679), 
            .O(\dut/n191 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(21)
    defparam \dut/add_22/i8__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \dut/add_22/i8__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \dut/sub_24/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), .CI(1'b0), 
            .CO(n678)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(23)
    defparam \dut/sub_24/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \dut/sub_24/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \dut/sub_25/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), .CI(1'b0), 
            .CO(n682)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(24)
    defparam \dut/sub_25/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \dut/sub_25/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \dut/add_18/i8__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), .CI(n683), 
            .O(\dut/n147 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\ti60f225_v4\rtl\vision\vision_sobel.sv(19)
    defparam \dut/add_18/i8__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \dut/add_18/i8__AUX_ADD_CO .I1_POLARITY = 1'b1;
    
endmodule

//
// Verific Verilog Description of module EFX_ADD_d17d2e62_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_d17d2e62_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_d17d2e62_1
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_ADD_d17d2e62_1
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_ADD_d17d2e62_2
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_ADD_d17d2e62_3
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_DSP48_d17d2e62_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_SRL8_d17d2e62_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_1
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_2
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_3
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_4
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_5
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_6
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_7
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_8
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_9
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_10
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_11
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_12
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_13
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_14
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_15
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_16
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_17
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_18
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_19
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_20
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_21
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_22
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_23
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_24
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_25
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_26
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_27
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_d17d2e62_28
// module not written out since it is a black box. 
//

