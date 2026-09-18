
//
// Verific Verilog Description of module hdmi_bringup
//

module hdmi_bringup (CLK_27M, jtag_inst1_CAPTURE, jtag_inst1_DRCK, jtag_inst1_RESET, 
            jtag_inst1_RUNTEST, jtag_inst1_SEL, jtag_inst1_SHIFT, jtag_inst1_TCK, 
            jtag_inst1_TDI, jtag_inst1_TMS, jtag_inst1_UPDATE, jtag_inst1_TDO, 
            CLK_25M, hdmi_tx_slow_clk, hdmi_tx_locked, tmds_data0_o, 
            tmds_data1_o, tmds_data2_o, tmds_clk_o, tmds_data0_TX_OE, 
            tmds_data1_TX_OE, tmds_data2_TX_OE, tmds_clk_TX_OE, tmds_data0_TX_RST, 
            tmds_data1_TX_RST, tmds_data2_TX_RST, tmds_clk_TX_RST, led0, 
            led1) /* verific EFX_ATTRIBUTE_NETLIST__EFINITY_VERSION=2026.1.132.3.9 */ ;
    input CLK_27M /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(2)
    input jtag_inst1_CAPTURE /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    input jtag_inst1_DRCK /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    input jtag_inst1_RESET /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    input jtag_inst1_RUNTEST /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    input jtag_inst1_SEL /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    input jtag_inst1_SHIFT /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    input jtag_inst1_TCK /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    input jtag_inst1_TDI /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    input jtag_inst1_TMS /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    input jtag_inst1_UPDATE /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    output jtag_inst1_TDO /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(4)
    input CLK_25M /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(5)
    input hdmi_tx_slow_clk /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(5)
    input hdmi_tx_locked /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_INPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(5)
    output [9:0]tmds_data0_o /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    output [9:0]tmds_data1_o /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    output [9:0]tmds_data2_o /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    output [9:0]tmds_clk_o /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    output tmds_data0_TX_OE /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(7)
    output tmds_data1_TX_OE /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(7)
    output tmds_data2_TX_OE /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(7)
    output tmds_clk_TX_OE /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(7)
    output tmds_data0_TX_RST /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(8)
    output tmds_data1_TX_RST /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(8)
    output tmds_data2_TX_RST /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(8)
    output tmds_clk_TX_RST /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(8)
    output led0 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(9)
    output led1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(9)
    
    wire [9:0]d0;
    wire [9:0]d1;
    wire [9:0]d2;
    wire [31:0]frames;
    wire [7:0]r;
    wire [7:0]g;
    wire [7:0]b;
    wire hs;
    wire vs;
    wire de;
    wire [25:0]n6;
    wire [25:0]n226_25;
    wire [25:0]n226_24;
    wire [25:0]n226_23;
    wire [25:0]n226_22;
    wire [25:0]n226_21;
    wire [25:0]n226_20;
    wire [25:0]n226_19;
    wire [25:0]n226_18;
    wire [25:0]n226_17;
    wire [25:0]n226_16;
    wire [25:0]n226_15;
    wire [25:0]n226_14;
    wire [25:0]n226_13;
    wire [25:0]n226_12;
    wire [25:0]n226_11;
    wire [25:0]n226_7;
    wire [25:0]n226_6;
    wire [25:0]n226_4;
    wire [25:0]n226_3;
    wire [2:0]reset_pipe;
    wire [31:0]n420_2;
    wire [7:0]n281_2;
    wire [7:0]n300_2;
    wire [6:0]n319_2;
    wire [31:0]n420_3;
    wire [31:0]n420_4;
    wire [31:0]n420_5;
    wire [31:0]n420_6;
    wire [31:0]n420_7;
    wire [31:0]n420_8;
    wire [31:0]n420_9;
    wire [31:0]n420_10;
    wire [31:0]n420_11;
    wire [31:0]n420_12;
    wire [31:0]n420_13;
    wire [31:0]n420_14;
    wire [31:0]n420_15;
    wire [31:0]n420_16;
    wire [31:0]n420_17;
    wire [31:0]n420_18;
    wire [31:0]n420_19;
    wire [31:0]n420_20;
    wire [31:0]n420_21;
    wire [31:0]n420_22;
    wire [31:0]n420_23;
    wire [31:0]n420_24;
    wire [31:0]n420_25;
    wire [7:0]n281;
    wire [6:0]n319_3;
    wire [6:0]n319_5;
    wire [6:0]n319_6;
    wire [6:0]n319_7;
    
    wire n1135, n1136, n1137, n1138;
    wire [25:0]n226_2;
    
    wire \add_53/n2 ;
    wire [25:0]reference_ticks;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(11)
    
    wire \add_51/n4 , \add_51/n2 ;
    wire [7:0]gray25;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(27)
    wire [7:0]gray27;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(27)
    wire [6:0]grayframes;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(28)
    wire [23:0]status_sync;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(32)
    wire [25:0]ref27_ticks;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(25)
    wire [23:0]status_meta;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(32)
    wire [8:0]\encoder/encb/q_m_reg ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(133)
    wire [7:0]\encoder/encb/din_q ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(63)
    wire [4:0]\encoder/encb/cnt ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(118)
    wire [31:0]\pattern/n119 ;
    
    wire \pattern/add_110/n10 , \encoder/encb/de_q , \pattern/add_110/n8 , 
        \pattern/add_110/n6 , \encoder/encb/de_reg , \encoder/encb/c0_q , 
        \encoder/encb/c0_reg , \encoder/encb/c1_q , \encoder/encb/c1_reg ;
    wire [4:0]\encoder/encb/n232 ;
    
    wire \encoder/encb/add_83/n2 , \pattern/add_110/n4 ;
    wire [4:0]\encoder/encb/n273 ;
    
    wire \encoder/encb/add_89/n2 ;
    wire [4:0]\encoder/encb/n292 ;
    
    wire \encoder/encb/add_93/n2 ;
    wire [4:0]\encoder/encb/n225 ;
    
    wire \encoder/encb/sub_82/add_2/n2 ;
    wire [4:0]\encoder/encb/n285 ;
    
    wire \encoder/encb/sub_92/add_2/n2 ;
    wire [4:0]\encoder/encr/n273 ;
    
    wire \encoder/encr/add_89/n4 ;
    wire [3:0]\encoder/encb/n1q_m ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(107)
    wire [3:0]\encoder/encb/n0q_m ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(107)
    wire [3:0]\encoder/encb/n1d ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(62)
    wire [11:0]\pattern/n46 ;
    
    wire \pattern/add_112/n20 , \pattern/add_112/n18 ;
    wire [4:0]\encoder/encr/n232 ;
    
    wire \pattern/add_112/n16 , \pattern/add_112/n14 , \pattern/add_112/n12 , 
        \pattern/add_112/n10 , \pattern/add_112/n8 , \encoder/encr/add_83/n8 , 
        \pattern/add_112/n6 , \encoder/encr/add_83/n6 , \encoder/encr/add_83/n4 ;
    wire [4:0]\encoder/encr/n219 ;
    
    wire \encoder/encr/add_81/n8 , \encoder/encr/add_81/n6 , \pattern/add_112/n4 , 
        \encoder/encr/add_81/n4 , \encoder/encr/add_81/n2 ;
    wire [8:0]\encoder/encr/q_m_reg ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(133)
    wire [4:0]\encoder/encg/n285 ;
    wire [7:0]\encoder/encr/din_q ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(63)
    
    wire \encoder/encg/sub_92/add_2/n8 ;
    wire [4:0]\encoder/encr/cnt ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(118)
    
    wire \encoder/encg/sub_92/add_2/n6 , \encoder/encg/sub_92/add_2/n4 ;
    wire [4:0]\encoder/encg/n266 ;
    
    wire \encoder/encg/sub_88/add_2/n8 , \encoder/encr/add_89/n2 , \encoder/encg/sub_88/add_2/n6 ;
    wire [4:0]\encoder/encr/n292 ;
    
    wire \encoder/encr/add_93/n2 ;
    wire [4:0]\encoder/encr/n238 ;
    
    wire \encoder/encr/sub_84/add_2/n2 ;
    wire [4:0]\encoder/encr/n285 ;
    
    wire \encoder/encr/sub_92/add_2/n2 ;
    wire [4:0]\encoder/encg/n273 ;
    
    wire \encoder/encg/add_89/n4 ;
    wire [3:0]\encoder/encr/n1q_m ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(107)
    wire [3:0]\encoder/encr/n0q_m ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(107)
    wire [3:0]\encoder/encr/n1d ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(62)
    
    wire \encoder/encg/sub_88/add_2/n4 ;
    wire [4:0]\encoder/encg/n238 ;
    wire [4:0]\encoder/encg/n232 ;
    
    wire \encoder/encg/sub_84/add_2/n8 , \encoder/encg/sub_84/add_2/n6 , 
        \encoder/encg/sub_84/add_2/n4 ;
    wire [4:0]\encoder/encg/n225 ;
    
    wire \encoder/encg/add_83/n8 , \encoder/encg/sub_82/add_2/n8 , \encoder/encg/add_83/n6 , 
        \encoder/encg/add_83/n4 ;
    wire [4:0]\encoder/encg/n219 ;
    
    wire \encoder/encg/add_81/n8 , \encoder/encg/add_81/n6 , \encoder/encg/sub_82/add_2/n6 , 
        \encoder/encg/add_81/n4 , \encoder/encg/add_81/n2 ;
    wire [8:0]\encoder/encg/q_m_reg ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(133)
    
    wire \encoder/encg/sub_82/add_2/n4 ;
    wire [4:0]\encoder/encg/n292 ;
    
    wire \encoder/encg/add_93/n8 ;
    wire [7:0]\encoder/encg/din_q ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(63)
    
    wire \encoder/encg/add_93/n6 ;
    wire [4:0]\encoder/encg/cnt ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(118)
    
    wire \encoder/encg/add_93/n4 , \encoder/encg/add_89/n8 , \encoder/encg/add_89/n6 , 
        \encoder/encg/add_89/n2 , \encoder/encg/add_93/n2 , \encoder/encg/sub_84/add_2/n2 , 
        \encoder/encg/sub_92/add_2/n2 ;
    wire [11:0]\pattern/n73 ;
    wire [3:0]\encoder/encg/n1q_m ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(107)
    wire [3:0]\encoder/encg/n0q_m ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(107)
    wire [3:0]\encoder/encg/n1d ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(62)
    
    wire \encoder/encr/sub_92/add_2/n8 , \encoder/encr/sub_92/add_2/n6 , 
        \encoder/encr/sub_92/add_2/n4 , \pattern/add_114/n20 , \pattern/add_114/n18 ;
    wire [4:0]\encoder/encr/n266 ;
    
    wire \encoder/encr/sub_88/add_2/n8 , \encoder/encr/sub_88/add_2/n6 , 
        \pattern/add_114/n16 , \encoder/encr/sub_88/add_2/n4 , \pattern/add_114/n14 , 
        \pattern/add_114/n12 , \pattern/add_114/n10 , \pattern/add_114/n8 , 
        \pattern/add_114/n6 , \pattern/add_114/n4 , \pattern/add_114/n2 , 
        \pattern/add_112/n2 , \encoder/encr/sub_84/add_2/n8 , \encoder/encr/sub_84/add_2/n6 , 
        \pattern/add_110/n2 ;
    wire [11:0]\pattern/y ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(11)
    wire [11:0]\pattern/x ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(11)
    
    wire \encoder/encr/sub_84/add_2/n4 ;
    wire [4:0]\encoder/encr/n225 ;
    
    wire \encoder/encr/sub_82/add_2/n8 , \encoder/encr/sub_82/add_2/n6 , 
        \encoder/encr/sub_82/add_2/n4 , \encoder/encr/add_93/n8 , \encoder/encr/add_93/n6 , 
        \encoder/encr/add_93/n4 , \encoder/encr/add_89/n8 , \encoder/encr/add_89/n6 , 
        \encoder/encb/sub_92/add_2/n8 , \encoder/encb/sub_92/add_2/n6 , 
        \encoder/encb/sub_92/add_2/n4 ;
    wire [4:0]\encoder/encb/n266 ;
    
    wire \encoder/encb/sub_88/add_2/n8 , \encoder/encb/sub_88/add_2/n6 , 
        \encoder/encb/sub_88/add_2/n4 ;
    wire [4:0]\encoder/encb/n238 ;
    
    wire \encoder/encb/sub_84/add_2/n8 , \encoder/encb/sub_84/add_2/n6 , 
        \encoder/encb/sub_84/add_2/n4 , \encoder/encb/sub_82/add_2/n8 , 
        \encoder/encb/sub_82/add_2/n6 , \encoder/encb/sub_82/add_2/n4 , 
        \encoder/encb/add_93/n8 , \encoder/encb/add_93/n6 , \encoder/encb/add_93/n4 , 
        \encoder/encb/add_89/n8 , \encoder/encb/add_89/n6 , \encoder/encb/add_89/n4 , 
        \encoder/encb/add_83/n8 , \encoder/encb/add_83/n6 , \encoder/encb/add_83/n4 ;
    wire [4:0]\encoder/encb/n219 ;
    
    wire \encoder/encb/add_81/n8 , \encoder/encb/add_81/n6 , \encoder/encb/add_81/n4 , 
        \add_51/n46 , \add_51/n44 , \add_51/n42 , \add_51/n40 , \add_51/n38 , 
        \add_51/n36 , \add_51/n34 , \add_51/n32 , \add_51/n30 , \add_51/n28 , 
        \add_51/n26 , \add_51/n24 , \add_51/n22 , \add_51/n20 , \add_51/n18 , 
        \add_51/n16 , \add_51/n14 , \add_51/n12 , \add_51/n10 , \add_51/n8 , 
        \add_51/n6 , \add_53/n46 , \add_53/n44 , \add_53/n42 , \add_53/n40 , 
        \add_53/n38 , \add_53/n36 , \add_53/n34 , \add_53/n32 , \add_53/n30 , 
        \add_53/n28 , \add_53/n26 , \add_53/n24 , \add_53/n22 , \add_53/n20 ;
    wire [25:0]n226_10;
    
    wire \add_53/n18 ;
    wire [25:0]n226_9;
    
    wire \add_53/n16 ;
    wire [25:0]n226_8;
    
    wire \add_53/n14 , \add_53/n12 , \add_53/n10 ;
    wire [25:0]n226_5;
    
    wire \add_53/n8 , \add_53/n6 , \add_53/n4 ;
    wire [31:0]debug_shift;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(37)
    
    wire n1134, n1133, n1132, n1131, n1130, n1129, ceg_net2, n1128;
    wire [9:0]\encoder/encb/n339 ;
    
    wire n1127;
    wire [8:0]\encoder/encb/q_m ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(92)
    
    wire n1126, n1125, n1124, n1123, n1122;
    wire [4:0]\encoder/encb/n350 ;
    
    wire \encoder/encb/n505 , \encoder/encb/n510 , \encoder/encb/n515 , 
        n1121, \encoder/encb/n601 , \encoder/encb/n606 , \encoder/encb/n464 , 
        n1120, \encoder/encb/n474 ;
    wire [9:0]\encoder/encr/n339 ;
    wire [8:0]\encoder/encr/q_m ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(92)
    
    wire n1119, n1118, n1117, n1116, n1115;
    wire [4:0]\encoder/encr/n350 ;
    
    wire \encoder/encr/n505 , \encoder/encr/n510 , \encoder/encr/n515 , 
        n1114, \encoder/encr/n601 , \encoder/encr/n606 , \encoder/encr/n464 , 
        n1113, \encoder/encr/n474 ;
    wire [9:0]\encoder/encg/n339 ;
    wire [8:0]\encoder/encg/q_m ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(92)
    
    wire n1112, n1111, \encoder/encg/n626 , n1110, n1109, \encoder/encg/n621 , 
        n1108, \encoder/encg/n616 ;
    wire [4:0]\encoder/encg/n350 ;
    
    wire \encoder/encg/n694 , \encoder/encg/n505 , \encoder/encg/n510 , 
        \encoder/encg/n515 , n1107, \encoder/encg/n601 , \encoder/encg/n606 , 
        \encoder/encg/n464 , n1106, \encoder/encg/n474 , \pattern/n114 ;
    wire [7:0]\pattern/n236 ;
    
    wire \pattern/n567 ;
    wire [11:0]\pattern/n59 ;
    
    wire \pattern/equal_24/n23 , \pattern/n561 ;
    wire [7:0]\pattern/n245 ;
    wire [7:0]\pattern/n254 ;
    
    wire \pattern/n190 , \pattern/n193 , \pattern/n187 , \encoder/encr/n626 , 
        \encoder/encr/n621 , \encoder/encr/n616 , \encoder/encr/n694 , 
        \encoder/encb/n626 , \encoder/encb/n621 , \encoder/encb/n616 , 
        \encoder/encb/n694 , n1105, n1104, n1103;
    wire [7:0]n300;
    wire [6:0]n319_4;
    
    wire n996, n997, n998, n999, n1000, n1002, n1003, n1004, 
        n1006, n1007, n1008, n1009, n1010, n1011, n1012, n1013, 
        n1014, n1015, n1016, n1017, n1018, n1019, n1021, n1022, 
        n1023, n1025, n1026, n1027, n1028, n1029, n1030, n1031, 
        n1032, n1033, n1034, n1035, n1036, n1037, n1038, n1040, 
        n1041, n1042, n1044, n1045, n1046, n1047, n1048, n1049, 
        n1050, n1051, n1052, n1053, n1054, n1055, n1056, n1057, 
        n1058, n1059, n1060, n1061, n1062, n1063, n1064, n1065, 
        n1066, n1067, n1068, n1069, n1070, n1071, n1072, n1073, 
        n1074, n1075, n1076, n1077, n1078, n1079, n1080, n1081, 
        n1082, n1083, n1084, n1085, n1086, n1087, n1088, n1089, 
        n1090, n1091, n1092, n1093, n1094, n1095, n1096, n1097, 
        n1098, n1099, n1100, n1101, n1102;
    
    assign tmds_data0_o[3] = tmds_data0_o[5] /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_data0_o[2] = tmds_data0_o[4] /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_data0_o[1] = tmds_data0_o[5] /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_data1_o[3] = tmds_data1_o[5] /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_data1_o[2] = tmds_data1_o[4] /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_data1_o[1] = tmds_data1_o[5] /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_data2_o[3] = tmds_data2_o[5] /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_data2_o[2] = tmds_data2_o[4] /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_data2_o[1] = tmds_data2_o[5] /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_clk_o[8] = 1'b0 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_clk_o[7] = 1'b0 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_clk_o[6] = 1'b0 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_clk_o[5] = 1'b0 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_clk_o[3] = 1'b1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_clk_o[2] = 1'b1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_clk_o[1] = 1'b1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_clk_o[0] = 1'b1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(6)
    assign tmds_data0_TX_OE = 1'b1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(7)
    assign tmds_data1_TX_OE = 1'b1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(7)
    assign tmds_data2_TX_OE = 1'b1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(7)
    assign tmds_clk_TX_OE = 1'b1 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(7)
    assign tmds_data0_TX_RST = 1'b0 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(8)
    assign tmds_data1_TX_RST = 1'b0 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(8)
    assign tmds_data2_TX_RST = 1'b0 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(8)
    assign tmds_clk_TX_RST = 1'b0 /* verific EFX_ATTRIBUTE_PORT__IS_PRIMARY_OUTPUT=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(8)
    assign tmds_clk_o[4] = 1'b1 /* verific EFX_ATTRIBUTE_CELL_NAME=VCC */ ;
    assign tmds_clk_o[9] = 1'b0 /* verific EFX_ATTRIBUTE_CELL_NAME=GND */ ;
    EFX_ADD \encoder/encg/sub_92/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1135)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/sub_92/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_92/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_92/add_2/i1__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1136), .O(\encoder/encg/sub_92/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/sub_92/add_2/i1__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_92/add_2/i1__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_88/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encg/sub_92/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1137)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/sub_88/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_88/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_92/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encg/sub_92/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1138)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/sub_92/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_92/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_FF \reference_ticks[0]~FF  (.D(reference_ticks[0]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[0]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[0]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[0]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[0]~FF .D_POLARITY = 1'b0;
    defparam \reference_ticks[0]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[0]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \jtag_inst1_TDO~FF  (.D(n420_2[0]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(jtag_inst1_TDO)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \jtag_inst1_TDO~FF .CLK_POLARITY = 1'b1;
    defparam \jtag_inst1_TDO~FF .CE_POLARITY = 1'b0;
    defparam \jtag_inst1_TDO~FF .SR_POLARITY = 1'b1;
    defparam \jtag_inst1_TDO~FF .D_POLARITY = 1'b1;
    defparam \jtag_inst1_TDO~FF .SR_SYNC = 1'b1;
    defparam \jtag_inst1_TDO~FF .SR_VALUE = 1'b0;
    defparam \jtag_inst1_TDO~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray25[0]~FF  (.D(n281_2[0]), .CE(1'b1), .CLK(CLK_25M), .SR(1'b0), 
           .Q(gray25[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam \gray25[0]~FF .CLK_POLARITY = 1'b1;
    defparam \gray25[0]~FF .CE_POLARITY = 1'b1;
    defparam \gray25[0]~FF .SR_POLARITY = 1'b1;
    defparam \gray25[0]~FF .D_POLARITY = 1'b1;
    defparam \gray25[0]~FF .SR_SYNC = 1'b1;
    defparam \gray25[0]~FF .SR_VALUE = 1'b0;
    defparam \gray25[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray27[0]~FF  (.D(n300_2[0]), .CE(1'b1), .CLK(CLK_27M), .SR(1'b0), 
           .Q(gray27[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam \gray27[0]~FF .CLK_POLARITY = 1'b1;
    defparam \gray27[0]~FF .CE_POLARITY = 1'b1;
    defparam \gray27[0]~FF .SR_POLARITY = 1'b1;
    defparam \gray27[0]~FF .D_POLARITY = 1'b1;
    defparam \gray27[0]~FF .SR_SYNC = 1'b1;
    defparam \gray27[0]~FF .SR_VALUE = 1'b0;
    defparam \gray27[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \grayframes[0]~FF  (.D(n319_2[0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(grayframes[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam \grayframes[0]~FF .CLK_POLARITY = 1'b1;
    defparam \grayframes[0]~FF .CE_POLARITY = 1'b1;
    defparam \grayframes[0]~FF .SR_POLARITY = 1'b1;
    defparam \grayframes[0]~FF .D_POLARITY = 1'b1;
    defparam \grayframes[0]~FF .SR_SYNC = 1'b1;
    defparam \grayframes[0]~FF .SR_VALUE = 1'b0;
    defparam \grayframes[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d0[7]~FF  (.D(\encoder/encb/n339 [7]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d0[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d0[7]~FF .CLK_POLARITY = 1'b1;
    defparam \d0[7]~FF .CE_POLARITY = 1'b1;
    defparam \d0[7]~FF .SR_POLARITY = 1'b0;
    defparam \d0[7]~FF .D_POLARITY = 1'b1;
    defparam \d0[7]~FF .SR_SYNC = 1'b0;
    defparam \d0[7]~FF .SR_VALUE = 1'b0;
    defparam \d0[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reset_pipe[0]~FF  (.D(1'b1), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(hdmi_tx_locked), .Q(reset_pipe[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(16)
    defparam \reset_pipe[0]~FF .CLK_POLARITY = 1'b1;
    defparam \reset_pipe[0]~FF .CE_POLARITY = 1'b1;
    defparam \reset_pipe[0]~FF .SR_POLARITY = 1'b0;
    defparam \reset_pipe[0]~FF .D_POLARITY = 1'b1;
    defparam \reset_pipe[0]~FF .SR_SYNC = 1'b0;
    defparam \reset_pipe[0]~FF .SR_VALUE = 1'b0;
    defparam \reset_pipe[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d0[6]~FF  (.D(\encoder/encb/n339 [6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d0[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d0[6]~FF .CLK_POLARITY = 1'b1;
    defparam \d0[6]~FF .CE_POLARITY = 1'b1;
    defparam \d0[6]~FF .SR_POLARITY = 1'b0;
    defparam \d0[6]~FF .D_POLARITY = 1'b1;
    defparam \d0[6]~FF .SR_SYNC = 1'b0;
    defparam \d0[6]~FF .SR_VALUE = 1'b0;
    defparam \d0[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[0]~FF  (.D(status_meta[0]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[0]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[0]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[0]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[0]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[0]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[0]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d0[5]~FF  (.D(\encoder/encb/n339 [5]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d0[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d0[5]~FF .CLK_POLARITY = 1'b1;
    defparam \d0[5]~FF .CE_POLARITY = 1'b1;
    defparam \d0[5]~FF .SR_POLARITY = 1'b0;
    defparam \d0[5]~FF .D_POLARITY = 1'b1;
    defparam \d0[5]~FF .SR_SYNC = 1'b0;
    defparam \d0[5]~FF .SR_VALUE = 1'b0;
    defparam \d0[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[0]~FF  (.D(ref27_ticks[0]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[0]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[0]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[0]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[0]~FF .D_POLARITY = 1'b0;
    defparam \ref27_ticks[0]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[0]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[0]~FF  (.D(grayframes[0]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[0]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[0]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[0]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[0]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[0]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[0]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/q_m_reg[5]~FF  (.D(\encoder/encb/q_m [5]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/q_m_reg [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/q_m_reg[5]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[5]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[5]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[5]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[5]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/q_m_reg[5]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/q_m_reg[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/q_m_reg[4]~FF  (.D(\encoder/encb/din_q [0]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/q_m_reg [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/q_m_reg[4]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[4]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[4]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[4]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[4]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/q_m_reg[4]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/q_m_reg[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/q_m_reg[8]~FF  (.D(\encoder/encb/q_m [5]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/q_m_reg [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/q_m_reg[8]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[8]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[8]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[8]~FF .D_POLARITY = 1'b0;
    defparam \encoder/encb/q_m_reg[8]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/q_m_reg[8]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/q_m_reg[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/q_m_reg[7]~FF  (.D(\encoder/encb/q_m [7]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/q_m_reg [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/q_m_reg[7]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[7]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[7]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[7]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[7]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/q_m_reg[7]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/q_m_reg[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/din_q[6]~FF  (.D(b[6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(\encoder/encb/din_q [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encb/din_q[6]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/din_q[6]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/din_q[6]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/din_q[6]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/din_q[6]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/din_q[6]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/din_q[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d0[9]~FF  (.D(\encoder/encb/n339 [9]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d0[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d0[9]~FF .CLK_POLARITY = 1'b1;
    defparam \d0[9]~FF .CE_POLARITY = 1'b1;
    defparam \d0[9]~FF .SR_POLARITY = 1'b0;
    defparam \d0[9]~FF .D_POLARITY = 1'b1;
    defparam \d0[9]~FF .SR_SYNC = 1'b0;
    defparam \d0[9]~FF .SR_VALUE = 1'b0;
    defparam \d0[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/q_m_reg[6]~FF  (.D(\encoder/encb/din_q [6]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/q_m_reg [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/q_m_reg[6]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[6]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[6]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[6]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/q_m_reg[6]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/q_m_reg[6]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/q_m_reg[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d0[8]~FF  (.D(\encoder/encb/n339 [8]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d0[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d0[8]~FF .CLK_POLARITY = 1'b1;
    defparam \d0[8]~FF .CE_POLARITY = 1'b1;
    defparam \d0[8]~FF .SR_POLARITY = 1'b0;
    defparam \d0[8]~FF .D_POLARITY = 1'b1;
    defparam \d0[8]~FF .SR_SYNC = 1'b0;
    defparam \d0[8]~FF .SR_VALUE = 1'b0;
    defparam \d0[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/cnt[0]~FF  (.D(\encoder/encb/n350 [0]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encb/cnt [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encb/cnt[0]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[0]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[0]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encb/cnt[0]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[0]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encb/cnt[0]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/cnt[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d0[4]~FF  (.D(\encoder/encb/n339 [4]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d0[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d0[4]~FF .CLK_POLARITY = 1'b1;
    defparam \d0[4]~FF .CE_POLARITY = 1'b1;
    defparam \d0[4]~FF .SR_POLARITY = 1'b0;
    defparam \d0[4]~FF .D_POLARITY = 1'b1;
    defparam \d0[4]~FF .SR_SYNC = 1'b0;
    defparam \d0[4]~FF .SR_VALUE = 1'b0;
    defparam \d0[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/de_q~FF  (.D(de), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(\encoder/encb/de_q )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/de_q~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/de_q~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/de_q~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/de_q~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/de_q~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/de_q~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/de_q~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/de_reg~FF  (.D(\encoder/encb/de_q ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/de_reg )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/de_reg~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/de_reg~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/de_reg~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/de_reg~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/de_reg~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/de_reg~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/de_reg~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/c0_q~FF  (.D(hs), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(\encoder/encb/c0_q )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/c0_q~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/c0_q~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/c0_q~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/c0_q~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/c0_q~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/c0_q~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/c0_q~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/c0_reg~FF  (.D(\encoder/encb/c0_q ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/c0_reg )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/c0_reg~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/c0_reg~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/c0_reg~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/c0_reg~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/c0_reg~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/c0_reg~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/c0_reg~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/c1_q~FF  (.D(vs), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(\encoder/encb/c1_q )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/c1_q~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/c1_q~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/c1_q~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/c1_q~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/c1_q~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/c1_q~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/c1_q~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/c1_reg~FF  (.D(\encoder/encb/c1_q ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/c1_reg )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encb/c1_reg~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/c1_reg~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/c1_reg~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/c1_reg~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/c1_reg~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/c1_reg~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/c1_reg~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/din_q[0]~FF  (.D(b[0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(\encoder/encb/din_q [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encb/din_q[0]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/din_q[0]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/din_q[0]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/din_q[0]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/din_q[0]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/din_q[0]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/din_q[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d0[0]~FF  (.D(\encoder/encb/n339 [0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d0[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d0[0]~FF .CLK_POLARITY = 1'b1;
    defparam \d0[0]~FF .CE_POLARITY = 1'b1;
    defparam \d0[0]~FF .SR_POLARITY = 1'b0;
    defparam \d0[0]~FF .D_POLARITY = 1'b1;
    defparam \d0[0]~FF .SR_SYNC = 1'b0;
    defparam \d0[0]~FF .SR_VALUE = 1'b0;
    defparam \d0[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/cnt[1]~FF  (.D(\encoder/encb/n350 [1]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encb/cnt [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encb/cnt[1]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[1]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[1]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encb/cnt[1]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[1]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encb/cnt[1]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/cnt[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/cnt[2]~FF  (.D(\encoder/encb/n350 [2]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encb/cnt [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encb/cnt[2]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[2]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[2]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encb/cnt[2]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[2]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encb/cnt[2]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/cnt[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/cnt[3]~FF  (.D(\encoder/encb/n350 [3]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encb/cnt [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encb/cnt[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[3]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encb/cnt[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[3]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encb/cnt[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/cnt[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/cnt[4]~FF  (.D(\encoder/encb/n350 [4]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encb/cnt [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encb/cnt[4]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[4]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[4]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encb/cnt[4]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/cnt[4]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encb/cnt[4]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/cnt[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/n1q_m[1]~FF  (.D(\encoder/encb/n505 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/n1q_m [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encb/n1q_m[1]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[1]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[1]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[1]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[1]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/n1q_m[1]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/n1q_m[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/n1q_m[2]~FF  (.D(\encoder/encb/n510 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/n1q_m [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encb/n1q_m[2]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[2]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[2]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[2]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[2]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/n1q_m[2]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/n1q_m[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/n1q_m[3]~FF  (.D(\encoder/encb/n515 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/n1q_m [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encb/n1q_m[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[3]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/n1q_m[3]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/n1q_m[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/n1q_m[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/n0q_m[2]~FF  (.D(\encoder/encb/n601 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/n0q_m [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encb/n0q_m[2]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/n0q_m[2]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/n0q_m[2]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/n0q_m[2]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/n0q_m[2]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/n0q_m[2]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/n0q_m[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/n0q_m[3]~FF  (.D(\encoder/encb/n606 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/n0q_m [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encb/n0q_m[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/n0q_m[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/n0q_m[3]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/n0q_m[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/n0q_m[3]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/n0q_m[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/n0q_m[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/n1d[1]~FF  (.D(\encoder/encb/n464 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/n1d [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encb/n1d[1]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/n1d[1]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/n1d[1]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/n1d[1]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/n1d[1]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/n1d[1]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/n1d[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encb/n1d[3]~FF  (.D(\encoder/encb/n474 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encb/n1d [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encb/n1d[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encb/n1d[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encb/n1d[3]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encb/n1d[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encb/n1d[3]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encb/n1d[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encb/n1d[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d1[7]~FF  (.D(\encoder/encr/n339 [7]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d1[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d1[7]~FF .CLK_POLARITY = 1'b1;
    defparam \d1[7]~FF .CE_POLARITY = 1'b1;
    defparam \d1[7]~FF .SR_POLARITY = 1'b0;
    defparam \d1[7]~FF .D_POLARITY = 1'b1;
    defparam \d1[7]~FF .SR_SYNC = 1'b0;
    defparam \d1[7]~FF .SR_VALUE = 1'b0;
    defparam \d1[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d1[6]~FF  (.D(\encoder/encr/n339 [6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d1[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d1[6]~FF .CLK_POLARITY = 1'b1;
    defparam \d1[6]~FF .CE_POLARITY = 1'b1;
    defparam \d1[6]~FF .SR_POLARITY = 1'b0;
    defparam \d1[6]~FF .D_POLARITY = 1'b1;
    defparam \d1[6]~FF .SR_SYNC = 1'b0;
    defparam \d1[6]~FF .SR_VALUE = 1'b0;
    defparam \d1[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d1[5]~FF  (.D(\encoder/encr/n339 [5]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d1[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d1[5]~FF .CLK_POLARITY = 1'b1;
    defparam \d1[5]~FF .CE_POLARITY = 1'b1;
    defparam \d1[5]~FF .SR_POLARITY = 1'b0;
    defparam \d1[5]~FF .D_POLARITY = 1'b1;
    defparam \d1[5]~FF .SR_SYNC = 1'b0;
    defparam \d1[5]~FF .SR_VALUE = 1'b0;
    defparam \d1[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/q_m_reg[5]~FF  (.D(\encoder/encr/q_m [5]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/q_m_reg [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encr/q_m_reg[5]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[5]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[5]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[5]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[5]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/q_m_reg[5]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/q_m_reg[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/q_m_reg[4]~FF  (.D(\encoder/encr/din_q [0]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/q_m_reg [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encr/q_m_reg[4]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[4]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[4]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[4]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[4]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/q_m_reg[4]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/q_m_reg[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/q_m_reg[8]~FF  (.D(\encoder/encr/q_m [5]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/q_m_reg [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encr/q_m_reg[8]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[8]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[8]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[8]~FF .D_POLARITY = 1'b0;
    defparam \encoder/encr/q_m_reg[8]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/q_m_reg[8]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/q_m_reg[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/q_m_reg[7]~FF  (.D(\encoder/encr/q_m [7]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/q_m_reg [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encr/q_m_reg[7]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[7]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[7]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[7]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[7]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/q_m_reg[7]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/q_m_reg[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/din_q[6]~FF  (.D(g[6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(\encoder/encr/din_q [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encr/din_q[6]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/din_q[6]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/din_q[6]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/din_q[6]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/din_q[6]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/din_q[6]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/din_q[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d1[9]~FF  (.D(\encoder/encr/n339 [9]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d1[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d1[9]~FF .CLK_POLARITY = 1'b1;
    defparam \d1[9]~FF .CE_POLARITY = 1'b1;
    defparam \d1[9]~FF .SR_POLARITY = 1'b0;
    defparam \d1[9]~FF .D_POLARITY = 1'b1;
    defparam \d1[9]~FF .SR_SYNC = 1'b0;
    defparam \d1[9]~FF .SR_VALUE = 1'b0;
    defparam \d1[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/q_m_reg[6]~FF  (.D(\encoder/encr/din_q [6]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/q_m_reg [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encr/q_m_reg[6]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[6]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[6]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[6]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/q_m_reg[6]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/q_m_reg[6]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/q_m_reg[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d1[8]~FF  (.D(\encoder/encr/n339 [8]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d1[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d1[8]~FF .CLK_POLARITY = 1'b1;
    defparam \d1[8]~FF .CE_POLARITY = 1'b1;
    defparam \d1[8]~FF .SR_POLARITY = 1'b0;
    defparam \d1[8]~FF .D_POLARITY = 1'b1;
    defparam \d1[8]~FF .SR_SYNC = 1'b0;
    defparam \d1[8]~FF .SR_VALUE = 1'b0;
    defparam \d1[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/cnt[0]~FF  (.D(\encoder/encr/n350 [0]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encr/cnt [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encr/cnt[0]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[0]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[0]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encr/cnt[0]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[0]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encr/cnt[0]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/cnt[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d1[4]~FF  (.D(\encoder/encr/n339 [4]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d1[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d1[4]~FF .CLK_POLARITY = 1'b1;
    defparam \d1[4]~FF .CE_POLARITY = 1'b1;
    defparam \d1[4]~FF .SR_POLARITY = 1'b0;
    defparam \d1[4]~FF .D_POLARITY = 1'b1;
    defparam \d1[4]~FF .SR_SYNC = 1'b0;
    defparam \d1[4]~FF .SR_VALUE = 1'b0;
    defparam \d1[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/din_q[0]~FF  (.D(g[0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(\encoder/encr/din_q [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encr/din_q[0]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/din_q[0]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/din_q[0]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/din_q[0]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/din_q[0]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/din_q[0]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/din_q[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d1[0]~FF  (.D(\encoder/encr/n339 [0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d1[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d1[0]~FF .CLK_POLARITY = 1'b1;
    defparam \d1[0]~FF .CE_POLARITY = 1'b1;
    defparam \d1[0]~FF .SR_POLARITY = 1'b0;
    defparam \d1[0]~FF .D_POLARITY = 1'b1;
    defparam \d1[0]~FF .SR_SYNC = 1'b0;
    defparam \d1[0]~FF .SR_VALUE = 1'b0;
    defparam \d1[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/cnt[1]~FF  (.D(\encoder/encr/n350 [1]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encr/cnt [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encr/cnt[1]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[1]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[1]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encr/cnt[1]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[1]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encr/cnt[1]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/cnt[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/cnt[2]~FF  (.D(\encoder/encr/n350 [2]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encr/cnt [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encr/cnt[2]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[2]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[2]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encr/cnt[2]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[2]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encr/cnt[2]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/cnt[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/cnt[3]~FF  (.D(\encoder/encr/n350 [3]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encr/cnt [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encr/cnt[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[3]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encr/cnt[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[3]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encr/cnt[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/cnt[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/cnt[4]~FF  (.D(\encoder/encr/n350 [4]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encr/cnt [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encr/cnt[4]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[4]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[4]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encr/cnt[4]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/cnt[4]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encr/cnt[4]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/cnt[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/n1q_m[1]~FF  (.D(\encoder/encr/n505 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/n1q_m [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encr/n1q_m[1]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[1]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[1]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[1]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[1]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/n1q_m[1]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/n1q_m[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/n1q_m[2]~FF  (.D(\encoder/encr/n510 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/n1q_m [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encr/n1q_m[2]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[2]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[2]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[2]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[2]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/n1q_m[2]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/n1q_m[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/n1q_m[3]~FF  (.D(\encoder/encr/n515 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/n1q_m [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encr/n1q_m[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[3]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/n1q_m[3]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/n1q_m[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/n1q_m[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/n0q_m[2]~FF  (.D(\encoder/encr/n601 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/n0q_m [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encr/n0q_m[2]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/n0q_m[2]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/n0q_m[2]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/n0q_m[2]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/n0q_m[2]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/n0q_m[2]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/n0q_m[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/n0q_m[3]~FF  (.D(\encoder/encr/n606 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/n0q_m [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encr/n0q_m[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/n0q_m[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/n0q_m[3]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/n0q_m[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/n0q_m[3]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/n0q_m[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/n0q_m[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/n1d[1]~FF  (.D(\encoder/encr/n464 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/n1d [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encr/n1d[1]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/n1d[1]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/n1d[1]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/n1d[1]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/n1d[1]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/n1d[1]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/n1d[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encr/n1d[3]~FF  (.D(\encoder/encr/n474 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encr/n1d [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encr/n1d[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encr/n1d[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encr/n1d[3]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encr/n1d[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encr/n1d[3]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encr/n1d[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encr/n1d[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d2[7]~FF  (.D(\encoder/encg/n339 [7]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d2[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d2[7]~FF .CLK_POLARITY = 1'b1;
    defparam \d2[7]~FF .CE_POLARITY = 1'b1;
    defparam \d2[7]~FF .SR_POLARITY = 1'b0;
    defparam \d2[7]~FF .D_POLARITY = 1'b1;
    defparam \d2[7]~FF .SR_SYNC = 1'b0;
    defparam \d2[7]~FF .SR_VALUE = 1'b0;
    defparam \d2[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d2[6]~FF  (.D(\encoder/encg/n339 [6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d2[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d2[6]~FF .CLK_POLARITY = 1'b1;
    defparam \d2[6]~FF .CE_POLARITY = 1'b1;
    defparam \d2[6]~FF .SR_POLARITY = 1'b0;
    defparam \d2[6]~FF .D_POLARITY = 1'b1;
    defparam \d2[6]~FF .SR_SYNC = 1'b0;
    defparam \d2[6]~FF .SR_VALUE = 1'b0;
    defparam \d2[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d2[5]~FF  (.D(\encoder/encg/n339 [5]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d2[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d2[5]~FF .CLK_POLARITY = 1'b1;
    defparam \d2[5]~FF .CE_POLARITY = 1'b1;
    defparam \d2[5]~FF .SR_POLARITY = 1'b0;
    defparam \d2[5]~FF .D_POLARITY = 1'b1;
    defparam \d2[5]~FF .SR_SYNC = 1'b0;
    defparam \d2[5]~FF .SR_VALUE = 1'b0;
    defparam \d2[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/q_m_reg[5]~FF  (.D(\encoder/encg/q_m [5]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/q_m_reg [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encg/q_m_reg[5]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[5]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[5]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[5]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[5]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/q_m_reg[5]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/q_m_reg[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/q_m_reg[4]~FF  (.D(\encoder/encg/din_q [0]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/q_m_reg [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encg/q_m_reg[4]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[4]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[4]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[4]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[4]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/q_m_reg[4]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/q_m_reg[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/q_m_reg[8]~FF  (.D(\encoder/encg/q_m [5]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/q_m_reg [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encg/q_m_reg[8]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[8]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[8]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[8]~FF .D_POLARITY = 1'b0;
    defparam \encoder/encg/q_m_reg[8]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/q_m_reg[8]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/q_m_reg[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/q_m_reg[7]~FF  (.D(\encoder/encg/q_m [7]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/q_m_reg [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encg/q_m_reg[7]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[7]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[7]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[7]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[7]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/q_m_reg[7]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/q_m_reg[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/din_q[6]~FF  (.D(r[6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(\encoder/encg/din_q [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encg/din_q[6]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/din_q[6]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/din_q[6]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/din_q[6]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/din_q[6]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/din_q[6]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/din_q[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d2[9]~FF  (.D(\encoder/encg/n339 [9]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d2[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d2[9]~FF .CLK_POLARITY = 1'b1;
    defparam \d2[9]~FF .CE_POLARITY = 1'b1;
    defparam \d2[9]~FF .SR_POLARITY = 1'b0;
    defparam \d2[9]~FF .D_POLARITY = 1'b1;
    defparam \d2[9]~FF .SR_SYNC = 1'b0;
    defparam \d2[9]~FF .SR_VALUE = 1'b0;
    defparam \d2[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/q_m_reg[6]~FF  (.D(\encoder/encg/din_q [6]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/q_m_reg [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(145)
    defparam \encoder/encg/q_m_reg[6]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[6]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[6]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[6]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/q_m_reg[6]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/q_m_reg[6]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/q_m_reg[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d2[8]~FF  (.D(\encoder/encg/n339 [8]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d2[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d2[8]~FF .CLK_POLARITY = 1'b1;
    defparam \d2[8]~FF .CE_POLARITY = 1'b1;
    defparam \d2[8]~FF .SR_POLARITY = 1'b0;
    defparam \d2[8]~FF .D_POLARITY = 1'b1;
    defparam \d2[8]~FF .SR_SYNC = 1'b0;
    defparam \d2[8]~FF .SR_VALUE = 1'b0;
    defparam \d2[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/cnt[0]~FF  (.D(\encoder/encg/n350 [0]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encg/cnt [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encg/cnt[0]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[0]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[0]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encg/cnt[0]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[0]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encg/cnt[0]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/cnt[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d2[4]~FF  (.D(\encoder/encg/n339 [4]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d2[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d2[4]~FF .CLK_POLARITY = 1'b1;
    defparam \d2[4]~FF .CE_POLARITY = 1'b1;
    defparam \d2[4]~FF .SR_POLARITY = 1'b0;
    defparam \d2[4]~FF .D_POLARITY = 1'b1;
    defparam \d2[4]~FF .SR_SYNC = 1'b0;
    defparam \d2[4]~FF .SR_VALUE = 1'b0;
    defparam \d2[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/din_q[0]~FF  (.D(r[0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(\encoder/encg/din_q [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encg/din_q[0]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/din_q[0]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/din_q[0]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/din_q[0]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/din_q[0]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/din_q[0]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/din_q[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \d2[0]~FF  (.D(\encoder/encg/n339 [0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(d2[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \d2[0]~FF .CLK_POLARITY = 1'b1;
    defparam \d2[0]~FF .CE_POLARITY = 1'b1;
    defparam \d2[0]~FF .SR_POLARITY = 1'b0;
    defparam \d2[0]~FF .D_POLARITY = 1'b1;
    defparam \d2[0]~FF .SR_SYNC = 1'b0;
    defparam \d2[0]~FF .SR_VALUE = 1'b0;
    defparam \d2[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/cnt[1]~FF  (.D(\encoder/encg/n350 [1]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encg/cnt [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encg/cnt[1]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[1]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[1]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encg/cnt[1]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[1]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encg/cnt[1]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/cnt[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/cnt[2]~FF  (.D(\encoder/encg/n350 [2]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encg/cnt [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encg/cnt[2]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[2]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[2]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encg/cnt[2]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[2]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encg/cnt[2]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/cnt[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/cnt[3]~FF  (.D(\encoder/encg/n350 [3]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encg/cnt [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encg/cnt[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[3]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encg/cnt[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[3]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encg/cnt[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/cnt[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/cnt[4]~FF  (.D(\encoder/encg/n350 [4]), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\encoder/encg/cnt [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(188)
    defparam \encoder/encg/cnt[4]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[4]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[4]~FF .SR_POLARITY = 1'b0;
    defparam \encoder/encg/cnt[4]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/cnt[4]~FF .SR_SYNC = 1'b0;
    defparam \encoder/encg/cnt[4]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/cnt[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/n1q_m[1]~FF  (.D(\encoder/encg/n505 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/n1q_m [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encg/n1q_m[1]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[1]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[1]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[1]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[1]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/n1q_m[1]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/n1q_m[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/n1q_m[2]~FF  (.D(\encoder/encg/n510 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/n1q_m [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encg/n1q_m[2]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[2]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[2]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[2]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[2]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/n1q_m[2]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/n1q_m[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/n1q_m[3]~FF  (.D(\encoder/encg/n515 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/n1q_m [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encg/n1q_m[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[3]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/n1q_m[3]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/n1q_m[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/n1q_m[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/n0q_m[2]~FF  (.D(\encoder/encg/n601 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/n0q_m [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encg/n0q_m[2]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/n0q_m[2]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/n0q_m[2]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/n0q_m[2]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/n0q_m[2]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/n0q_m[2]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/n0q_m[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/n0q_m[3]~FF  (.D(\encoder/encg/n606 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/n0q_m [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(111)
    defparam \encoder/encg/n0q_m[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/n0q_m[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/n0q_m[3]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/n0q_m[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/n0q_m[3]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/n0q_m[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/n0q_m[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/n1d[1]~FF  (.D(\encoder/encg/n464 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/n1d [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encg/n1d[1]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/n1d[1]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/n1d[1]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/n1d[1]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/n1d[1]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/n1d[1]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/n1d[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \encoder/encg/n1d[3]~FF  (.D(\encoder/encg/n474 ), .CE(1'b1), 
           .CLK(hdmi_tx_slow_clk), .SR(1'b0), .Q(\encoder/encg/n1d [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(69)
    defparam \encoder/encg/n1d[3]~FF .CLK_POLARITY = 1'b1;
    defparam \encoder/encg/n1d[3]~FF .CE_POLARITY = 1'b1;
    defparam \encoder/encg/n1d[3]~FF .SR_POLARITY = 1'b1;
    defparam \encoder/encg/n1d[3]~FF .D_POLARITY = 1'b1;
    defparam \encoder/encg/n1d[3]~FF .SR_SYNC = 1'b1;
    defparam \encoder/encg/n1d[3]~FF .SR_VALUE = 1'b0;
    defparam \encoder/encg/n1d[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \frames[6]~FF  (.D(\pattern/n119 [6]), .CE(\pattern/n114 ), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(frames[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \frames[6]~FF .CLK_POLARITY = 1'b1;
    defparam \frames[6]~FF .CE_POLARITY = 1'b1;
    defparam \frames[6]~FF .SR_POLARITY = 1'b0;
    defparam \frames[6]~FF .D_POLARITY = 1'b1;
    defparam \frames[6]~FF .SR_SYNC = 1'b1;
    defparam \frames[6]~FF .SR_VALUE = 1'b0;
    defparam \frames[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \led1~FF  (.D(\pattern/n119 [5]), .CE(\pattern/n114 ), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(led1)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \led1~FF .CLK_POLARITY = 1'b1;
    defparam \led1~FF .CE_POLARITY = 1'b1;
    defparam \led1~FF .SR_POLARITY = 1'b0;
    defparam \led1~FF .D_POLARITY = 1'b1;
    defparam \led1~FF .SR_SYNC = 1'b1;
    defparam \led1~FF .SR_VALUE = 1'b0;
    defparam \led1~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \frames[4]~FF  (.D(\pattern/n119 [4]), .CE(\pattern/n114 ), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(frames[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \frames[4]~FF .CLK_POLARITY = 1'b1;
    defparam \frames[4]~FF .CE_POLARITY = 1'b1;
    defparam \frames[4]~FF .SR_POLARITY = 1'b0;
    defparam \frames[4]~FF .D_POLARITY = 1'b1;
    defparam \frames[4]~FF .SR_SYNC = 1'b1;
    defparam \frames[4]~FF .SR_VALUE = 1'b0;
    defparam \frames[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \frames[3]~FF  (.D(\pattern/n119 [3]), .CE(\pattern/n114 ), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(frames[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \frames[3]~FF .CLK_POLARITY = 1'b1;
    defparam \frames[3]~FF .CE_POLARITY = 1'b1;
    defparam \frames[3]~FF .SR_POLARITY = 1'b0;
    defparam \frames[3]~FF .D_POLARITY = 1'b1;
    defparam \frames[3]~FF .SR_SYNC = 1'b1;
    defparam \frames[3]~FF .SR_VALUE = 1'b0;
    defparam \frames[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \frames[2]~FF  (.D(\pattern/n119 [2]), .CE(\pattern/n114 ), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(frames[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \frames[2]~FF .CLK_POLARITY = 1'b1;
    defparam \frames[2]~FF .CE_POLARITY = 1'b1;
    defparam \frames[2]~FF .SR_POLARITY = 1'b0;
    defparam \frames[2]~FF .D_POLARITY = 1'b1;
    defparam \frames[2]~FF .SR_SYNC = 1'b1;
    defparam \frames[2]~FF .SR_VALUE = 1'b0;
    defparam \frames[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \frames[1]~FF  (.D(\pattern/n119 [1]), .CE(\pattern/n114 ), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(frames[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \frames[1]~FF .CLK_POLARITY = 1'b1;
    defparam \frames[1]~FF .CE_POLARITY = 1'b1;
    defparam \frames[1]~FF .SR_POLARITY = 1'b0;
    defparam \frames[1]~FF .D_POLARITY = 1'b1;
    defparam \frames[1]~FF .SR_SYNC = 1'b1;
    defparam \frames[1]~FF .SR_VALUE = 1'b0;
    defparam \frames[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \r[0]~FF  (.D(\pattern/n236 [0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n567 ), .Q(r[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \r[0]~FF .CLK_POLARITY = 1'b1;
    defparam \r[0]~FF .CE_POLARITY = 1'b1;
    defparam \r[0]~FF .SR_POLARITY = 1'b0;
    defparam \r[0]~FF .D_POLARITY = 1'b1;
    defparam \r[0]~FF .SR_SYNC = 1'b1;
    defparam \r[0]~FF .SR_VALUE = 1'b0;
    defparam \r[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[0]~FF  (.D(\pattern/n59 [0]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[0]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[0]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[0]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[0]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[0]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[0]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[0]~FF  (.D(\pattern/x [0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[0]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[0]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[0]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[0]~FF .D_POLARITY = 1'b0;
    defparam \pattern/x[0]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[0]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \g[0]~FF  (.D(\pattern/n245 [0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n567 ), .Q(g[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \g[0]~FF .CLK_POLARITY = 1'b1;
    defparam \g[0]~FF .CE_POLARITY = 1'b1;
    defparam \g[0]~FF .SR_POLARITY = 1'b0;
    defparam \g[0]~FF .D_POLARITY = 1'b1;
    defparam \g[0]~FF .SR_SYNC = 1'b1;
    defparam \g[0]~FF .SR_VALUE = 1'b0;
    defparam \g[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \b[0]~FF  (.D(\pattern/n254 [0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n567 ), .Q(b[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \b[0]~FF .CLK_POLARITY = 1'b1;
    defparam \b[0]~FF .CE_POLARITY = 1'b1;
    defparam \b[0]~FF .SR_POLARITY = 1'b0;
    defparam \b[0]~FF .D_POLARITY = 1'b1;
    defparam \b[0]~FF .SR_SYNC = 1'b1;
    defparam \b[0]~FF .SR_VALUE = 1'b0;
    defparam \b[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \hs~FF  (.D(\pattern/n190 ), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(hs)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \hs~FF .CLK_POLARITY = 1'b1;
    defparam \hs~FF .CE_POLARITY = 1'b1;
    defparam \hs~FF .SR_POLARITY = 1'b0;
    defparam \hs~FF .D_POLARITY = 1'b1;
    defparam \hs~FF .SR_SYNC = 1'b1;
    defparam \hs~FF .SR_VALUE = 1'b0;
    defparam \hs~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \vs~FF  (.D(\pattern/n193 ), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(vs)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \vs~FF .CLK_POLARITY = 1'b1;
    defparam \vs~FF .CE_POLARITY = 1'b1;
    defparam \vs~FF .SR_POLARITY = 1'b0;
    defparam \vs~FF .D_POLARITY = 1'b1;
    defparam \vs~FF .SR_SYNC = 1'b1;
    defparam \vs~FF .SR_VALUE = 1'b0;
    defparam \vs~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \de~FF  (.D(\pattern/n187 ), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(de)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \de~FF .CLK_POLARITY = 1'b1;
    defparam \de~FF .CE_POLARITY = 1'b1;
    defparam \de~FF .SR_POLARITY = 1'b0;
    defparam \de~FF .D_POLARITY = 1'b1;
    defparam \de~FF .SR_SYNC = 1'b1;
    defparam \de~FF .SR_VALUE = 1'b0;
    defparam \de~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \frames[0]~FF  (.D(frames[0]), .CE(\pattern/n114 ), .CLK(hdmi_tx_slow_clk), 
           .SR(reset_pipe[2]), .Q(frames[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b0, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \frames[0]~FF .CLK_POLARITY = 1'b1;
    defparam \frames[0]~FF .CE_POLARITY = 1'b1;
    defparam \frames[0]~FF .SR_POLARITY = 1'b0;
    defparam \frames[0]~FF .D_POLARITY = 1'b0;
    defparam \frames[0]~FF .SR_SYNC = 1'b1;
    defparam \frames[0]~FF .SR_VALUE = 1'b0;
    defparam \frames[0]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[1]~FF  (.D(\pattern/n59 [1]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[1]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[1]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[1]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[1]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[1]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[1]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[2]~FF  (.D(\pattern/n59 [2]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[2]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[2]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[2]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[2]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[2]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[2]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[3]~FF  (.D(\pattern/n59 [3]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[3]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[3]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[3]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[3]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[3]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[3]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[4]~FF  (.D(\pattern/n59 [4]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[4]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[4]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[4]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[4]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[4]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[4]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[5]~FF  (.D(\pattern/n59 [5]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[5]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[5]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[5]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[5]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[5]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[5]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[6]~FF  (.D(\pattern/n59 [6]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[6]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[6]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[6]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[6]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[6]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[6]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[7]~FF  (.D(\pattern/n59 [7]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[7]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[7]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[7]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[7]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[7]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[7]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[8]~FF  (.D(\pattern/n59 [8]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[8]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[8]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[8]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[8]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[8]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[8]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[9]~FF  (.D(\pattern/n59 [9]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[9]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[9]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[9]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[9]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[9]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[9]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[10]~FF  (.D(\pattern/n59 [10]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[10]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[10]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[10]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[10]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[10]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[10]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/y[11]~FF  (.D(\pattern/n59 [11]), .CE(\pattern/equal_24/n23 ), 
           .CLK(hdmi_tx_slow_clk), .SR(reset_pipe[2]), .Q(\pattern/y [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/y[11]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/y[11]~FF .CE_POLARITY = 1'b0;
    defparam \pattern/y[11]~FF .SR_POLARITY = 1'b0;
    defparam \pattern/y[11]~FF .D_POLARITY = 1'b1;
    defparam \pattern/y[11]~FF .SR_SYNC = 1'b1;
    defparam \pattern/y[11]~FF .SR_VALUE = 1'b0;
    defparam \pattern/y[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[1]~FF  (.D(\pattern/n73 [1]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[1]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[1]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[1]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[1]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[1]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[1]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[2]~FF  (.D(\pattern/n73 [2]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[2]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[2]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[2]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[2]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[2]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[2]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[3]~FF  (.D(\pattern/n73 [3]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[3]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[3]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[3]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[3]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[3]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[3]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[4]~FF  (.D(\pattern/n73 [4]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[4]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[4]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[4]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[4]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[4]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[4]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[5]~FF  (.D(\pattern/n73 [5]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[5]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[5]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[5]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[5]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[5]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[5]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[6]~FF  (.D(\pattern/n73 [6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[6]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[6]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[6]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[6]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[6]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[6]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[7]~FF  (.D(\pattern/n73 [7]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[7]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[7]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[7]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[7]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[7]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[7]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[8]~FF  (.D(\pattern/n73 [8]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[8]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[8]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[8]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[8]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[8]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[8]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[9]~FF  (.D(\pattern/n73 [9]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[9]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[9]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[9]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[9]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[9]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[9]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[10]~FF  (.D(\pattern/n73 [10]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[10]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[10]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[10]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[10]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[10]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[10]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \pattern/x[11]~FF  (.D(\pattern/n73 [11]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n561 ), .Q(\pattern/x [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \pattern/x[11]~FF .CLK_POLARITY = 1'b1;
    defparam \pattern/x[11]~FF .CE_POLARITY = 1'b1;
    defparam \pattern/x[11]~FF .SR_POLARITY = 1'b1;
    defparam \pattern/x[11]~FF .D_POLARITY = 1'b1;
    defparam \pattern/x[11]~FF .SR_SYNC = 1'b1;
    defparam \pattern/x[11]~FF .SR_VALUE = 1'b0;
    defparam \pattern/x[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \r[6]~FF  (.D(\pattern/n236 [6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n567 ), .Q(r[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \r[6]~FF .CLK_POLARITY = 1'b1;
    defparam \r[6]~FF .CE_POLARITY = 1'b1;
    defparam \r[6]~FF .SR_POLARITY = 1'b0;
    defparam \r[6]~FF .D_POLARITY = 1'b1;
    defparam \r[6]~FF .SR_SYNC = 1'b1;
    defparam \r[6]~FF .SR_VALUE = 1'b0;
    defparam \r[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \g[6]~FF  (.D(\pattern/n245 [6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n567 ), .Q(g[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \g[6]~FF .CLK_POLARITY = 1'b1;
    defparam \g[6]~FF .CE_POLARITY = 1'b1;
    defparam \g[6]~FF .SR_POLARITY = 1'b0;
    defparam \g[6]~FF .D_POLARITY = 1'b1;
    defparam \g[6]~FF .SR_SYNC = 1'b1;
    defparam \g[6]~FF .SR_VALUE = 1'b0;
    defparam \g[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \b[6]~FF  (.D(\pattern/n254 [6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(\pattern/n567 ), .Q(b[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(45)
    defparam \b[6]~FF .CLK_POLARITY = 1'b1;
    defparam \b[6]~FF .CE_POLARITY = 1'b1;
    defparam \b[6]~FF .SR_POLARITY = 1'b0;
    defparam \b[6]~FF .D_POLARITY = 1'b1;
    defparam \b[6]~FF .SR_SYNC = 1'b1;
    defparam \b[6]~FF .SR_VALUE = 1'b0;
    defparam \b[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[1]~FF  (.D(n420_3[1]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[1]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[1]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[1]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[1]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[1]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[1]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[2]~FF  (.D(n420_4[2]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[2]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[2]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[2]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[2]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[2]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[2]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[3]~FF  (.D(n420_5[3]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[3]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[3]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[3]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[3]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[3]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[3]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[4]~FF  (.D(n420_6[4]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[4]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[4]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[4]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[4]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[4]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[4]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[5]~FF  (.D(n420_7[5]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[5]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[5]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[5]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[5]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[5]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[5]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[6]~FF  (.D(n420_8[6]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[6]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[6]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[6]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[6]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[6]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[6]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[7]~FF  (.D(n420_9[7]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[7]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[7]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[7]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[7]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[7]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[7]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[8]~FF  (.D(n420_10[8]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[8]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[8]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[8]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[8]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[8]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[8]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[9]~FF  (.D(n420_11[9]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[9]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[9]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[9]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[9]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[9]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[9]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[10]~FF  (.D(n420_12[10]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[10]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[10]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[10]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[10]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[10]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[10]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[11]~FF  (.D(n420_13[11]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[11]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[11]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[11]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[11]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[11]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[11]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[12]~FF  (.D(n420_14[12]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[12]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[12]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[12]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[12]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[12]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[12]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[13]~FF  (.D(n420_15[13]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[13]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[13]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[13]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[13]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[13]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[13]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[14]~FF  (.D(n420_16[14]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[14]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[14]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[14]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[14]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[14]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[14]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[15]~FF  (.D(n420_17[15]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[15]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[15]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[15]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[15]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[15]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[15]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[16]~FF  (.D(n420_18[16]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[16]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[16]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[16]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[16]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[16]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[16]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[17]~FF  (.D(n420_19[17]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[17]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[17]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[17]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[17]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[17]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[17]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[18]~FF  (.D(n420_20[18]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[18]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[18]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[18]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[18]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[18]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[18]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[19]~FF  (.D(n420_21[19]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[19])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[19]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[19]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[19]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[19]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[19]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[19]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[19]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[20]~FF  (.D(n420_22[20]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[20])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[20]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[20]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[20]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[20]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[20]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[20]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[20]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[21]~FF  (.D(n420_23[21]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[21])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[21]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[21]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[21]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[21]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[21]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[21]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[21]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[22]~FF  (.D(n420_24[22]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[22]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[22]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[22]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[22]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[22]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[22]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[22]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[23]~FF  (.D(n420_25[23]), .CE(ceg_net2), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(debug_shift[23])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b0, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[23]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[23]~FF .CE_POLARITY = 1'b0;
    defparam \debug_shift[23]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[23]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[23]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[23]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[23]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[24]~FF  (.D(debug_shift[25]), .CE(jtag_inst1_SHIFT), 
           .CLK(jtag_inst1_DRCK), .SR(jtag_inst1_CAPTURE), .Q(debug_shift[24])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[24]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[24]~FF .CE_POLARITY = 1'b1;
    defparam \debug_shift[24]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[24]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[24]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[24]~FF .SR_VALUE = 1'b1;
    defparam \debug_shift[24]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[25]~FF  (.D(debug_shift[26]), .CE(jtag_inst1_SHIFT), 
           .CLK(jtag_inst1_DRCK), .SR(jtag_inst1_CAPTURE), .Q(debug_shift[25])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[25]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[25]~FF .CE_POLARITY = 1'b1;
    defparam \debug_shift[25]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[25]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[25]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[25]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[25]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[26]~FF  (.D(debug_shift[27]), .CE(jtag_inst1_SHIFT), 
           .CLK(jtag_inst1_DRCK), .SR(jtag_inst1_CAPTURE), .Q(debug_shift[26])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[26]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[26]~FF .CE_POLARITY = 1'b1;
    defparam \debug_shift[26]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[26]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[26]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[26]~FF .SR_VALUE = 1'b1;
    defparam \debug_shift[26]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[27]~FF  (.D(debug_shift[28]), .CE(jtag_inst1_SHIFT), 
           .CLK(jtag_inst1_DRCK), .SR(jtag_inst1_CAPTURE), .Q(debug_shift[27])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[27]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[27]~FF .CE_POLARITY = 1'b1;
    defparam \debug_shift[27]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[27]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[27]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[27]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[27]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[28]~FF  (.D(debug_shift[29]), .CE(jtag_inst1_SHIFT), 
           .CLK(jtag_inst1_DRCK), .SR(jtag_inst1_CAPTURE), .Q(debug_shift[28])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[28]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[28]~FF .CE_POLARITY = 1'b1;
    defparam \debug_shift[28]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[28]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[28]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[28]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[28]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[29]~FF  (.D(debug_shift[30]), .CE(jtag_inst1_SHIFT), 
           .CLK(jtag_inst1_DRCK), .SR(jtag_inst1_CAPTURE), .Q(debug_shift[29])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[29]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[29]~FF .CE_POLARITY = 1'b1;
    defparam \debug_shift[29]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[29]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[29]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[29]~FF .SR_VALUE = 1'b1;
    defparam \debug_shift[29]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[30]~FF  (.D(debug_shift[31]), .CE(jtag_inst1_SHIFT), 
           .CLK(jtag_inst1_DRCK), .SR(jtag_inst1_CAPTURE), .Q(debug_shift[30])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[30]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[30]~FF .CE_POLARITY = 1'b1;
    defparam \debug_shift[30]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[30]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[30]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[30]~FF .SR_VALUE = 1'b0;
    defparam \debug_shift[30]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \debug_shift[31]~FF  (.D(jtag_inst1_TDI), .CE(jtag_inst1_SHIFT), 
           .CLK(jtag_inst1_DRCK), .SR(jtag_inst1_CAPTURE), .Q(debug_shift[31])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b1, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(41)
    defparam \debug_shift[31]~FF .CLK_POLARITY = 1'b1;
    defparam \debug_shift[31]~FF .CE_POLARITY = 1'b1;
    defparam \debug_shift[31]~FF .SR_POLARITY = 1'b1;
    defparam \debug_shift[31]~FF .D_POLARITY = 1'b1;
    defparam \debug_shift[31]~FF .SR_SYNC = 1'b1;
    defparam \debug_shift[31]~FF .SR_VALUE = 1'b1;
    defparam \debug_shift[31]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[1]~FF  (.D(n226_2[1]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[1]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[1]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[1]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[1]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[1]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[1]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[2]~FF  (.D(n226_3[2]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[2]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[2]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[2]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[2]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[2]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[2]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[3]~FF  (.D(n226_4[3]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[3]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[3]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[3]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[3]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[3]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[3]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[4]~FF  (.D(n226_5[4]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[4]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[4]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[4]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[4]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[4]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[4]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[5]~FF  (.D(n226_6[5]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[5]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[5]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[5]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[5]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[5]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[5]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[6]~FF  (.D(n226_7[6]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[6]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[6]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[6]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[6]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[6]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[6]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[7]~FF  (.D(n226_8[7]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[7]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[7]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[7]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[7]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[7]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[7]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[8]~FF  (.D(n226_9[8]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[8]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[8]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[8]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[8]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[8]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[8]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[9]~FF  (.D(n226_10[9]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[9]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[9]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[9]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[9]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[9]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[9]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[10]~FF  (.D(n226_11[10]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[10]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[10]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[10]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[10]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[10]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[10]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[11]~FF  (.D(n226_12[11]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[11]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[11]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[11]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[11]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[11]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[11]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[12]~FF  (.D(n226_13[12]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[12]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[12]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[12]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[12]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[12]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[12]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[13]~FF  (.D(n226_14[13]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[13]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[13]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[13]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[13]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[13]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[13]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[14]~FF  (.D(n226_15[14]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[14]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[14]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[14]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[14]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[14]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[14]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[15]~FF  (.D(n226_16[15]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[15]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[15]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[15]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[15]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[15]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[15]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[16]~FF  (.D(n226_17[16]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[16]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[16]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[16]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[16]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[16]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[16]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[17]~FF  (.D(n226_18[17]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[17]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[17]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[17]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[17]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[17]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[17]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[18]~FF  (.D(n226_19[18]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[18]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[18]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[18]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[18]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[18]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[18]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[19]~FF  (.D(n226_20[19]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[19])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[19]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[19]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[19]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[19]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[19]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[19]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[19]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[20]~FF  (.D(n226_21[20]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[20])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[20]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[20]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[20]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[20]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[20]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[20]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[20]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[21]~FF  (.D(n226_22[21]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[21])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[21]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[21]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[21]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[21]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[21]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[21]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[21]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[22]~FF  (.D(n226_23[22]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[22]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[22]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[22]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[22]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[22]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[22]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[22]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[23]~FF  (.D(n226_24[23]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[23])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[23]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[23]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[23]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[23]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[23]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[23]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[23]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \ref27_ticks[24]~FF  (.D(n226_25[24]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(ref27_ticks[24])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \ref27_ticks[24]~FF .CLK_POLARITY = 1'b1;
    defparam \ref27_ticks[24]~FF .CE_POLARITY = 1'b1;
    defparam \ref27_ticks[24]~FF .SR_POLARITY = 1'b1;
    defparam \ref27_ticks[24]~FF .D_POLARITY = 1'b1;
    defparam \ref27_ticks[24]~FF .SR_SYNC = 1'b1;
    defparam \ref27_ticks[24]~FF .SR_VALUE = 1'b0;
    defparam \ref27_ticks[24]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[1]~FF  (.D(n6[1]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[1]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[1]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[1]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[1]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[1]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[1]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[2]~FF  (.D(n6[2]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[2]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[2]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[2]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[2]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[2]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[2]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[3]~FF  (.D(n6[3]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[3]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[3]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[3]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[3]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[3]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[3]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[4]~FF  (.D(n6[4]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[4]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[4]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[4]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[4]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[4]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[4]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[5]~FF  (.D(n6[5]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[5]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[5]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[5]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[5]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[5]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[5]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[6]~FF  (.D(n6[6]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[6]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[6]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[6]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[6]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[6]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[6]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[7]~FF  (.D(n6[7]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[7]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[7]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[7]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[7]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[7]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[7]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[8]~FF  (.D(n6[8]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[8]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[8]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[8]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[8]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[8]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[8]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[9]~FF  (.D(n6[9]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[9]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[9]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[9]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[9]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[9]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[9]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[10]~FF  (.D(n6[10]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[10]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[10]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[10]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[10]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[10]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[10]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[11]~FF  (.D(n6[11]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[11]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[11]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[11]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[11]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[11]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[11]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[12]~FF  (.D(n6[12]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[12]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[12]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[12]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[12]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[12]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[12]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[13]~FF  (.D(n6[13]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[13]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[13]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[13]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[13]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[13]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[13]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[14]~FF  (.D(n6[14]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[14]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[14]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[14]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[14]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[14]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[14]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[15]~FF  (.D(n6[15]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[15]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[15]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[15]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[15]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[15]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[15]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[16]~FF  (.D(n6[16]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[16]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[16]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[16]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[16]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[16]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[16]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[17]~FF  (.D(n6[17]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[17]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[17]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[17]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[17]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[17]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[17]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[18]~FF  (.D(n6[18]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[18]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[18]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[18]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[18]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[18]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[18]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[19]~FF  (.D(n6[19]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[19])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[19]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[19]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[19]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[19]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[19]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[19]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[19]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[20]~FF  (.D(n6[20]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[20])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[20]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[20]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[20]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[20]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[20]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[20]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[20]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[21]~FF  (.D(n6[21]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[21])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[21]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[21]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[21]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[21]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[21]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[21]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[21]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[22]~FF  (.D(n6[22]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[22]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[22]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[22]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[22]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[22]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[22]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[22]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reference_ticks[23]~FF  (.D(n6[23]), .CE(1'b1), .CLK(CLK_25M), 
           .SR(1'b0), .Q(reference_ticks[23])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \reference_ticks[23]~FF .CLK_POLARITY = 1'b1;
    defparam \reference_ticks[23]~FF .CE_POLARITY = 1'b1;
    defparam \reference_ticks[23]~FF .SR_POLARITY = 1'b1;
    defparam \reference_ticks[23]~FF .D_POLARITY = 1'b1;
    defparam \reference_ticks[23]~FF .SR_SYNC = 1'b1;
    defparam \reference_ticks[23]~FF .SR_VALUE = 1'b0;
    defparam \reference_ticks[23]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \led0~FF  (.D(n6[24]), .CE(1'b1), .CLK(CLK_25M), .SR(1'b0), 
           .Q(led0)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \led0~FF .CLK_POLARITY = 1'b1;
    defparam \led0~FF .CE_POLARITY = 1'b1;
    defparam \led0~FF .SR_POLARITY = 1'b1;
    defparam \led0~FF .D_POLARITY = 1'b1;
    defparam \led0~FF .SR_SYNC = 1'b1;
    defparam \led0~FF .SR_VALUE = 1'b0;
    defparam \led0~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[1]~FF  (.D(grayframes[1]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[1]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[1]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[1]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[1]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[1]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[1]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[2]~FF  (.D(grayframes[2]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[2]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[2]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[2]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[2]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[2]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[2]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[3]~FF  (.D(grayframes[3]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[3]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[3]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[3]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[3]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[3]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[3]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[4]~FF  (.D(grayframes[4]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[4]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[4]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[4]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[4]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[4]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[4]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[5]~FF  (.D(grayframes[5]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[5]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[5]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[5]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[5]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[5]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[5]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[6]~FF  (.D(grayframes[6]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[6]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[6]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[6]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[6]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[6]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[6]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[7]~FF  (.D(hdmi_tx_locked), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[7]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[7]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[7]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[7]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[7]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[7]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[8]~FF  (.D(gray27[0]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[8]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[8]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[8]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[8]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[8]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[8]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[9]~FF  (.D(gray27[1]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[9]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[9]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[9]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[9]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[9]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[9]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[10]~FF  (.D(gray27[2]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[10]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[10]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[10]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[10]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[10]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[10]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[11]~FF  (.D(gray27[3]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[11]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[11]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[11]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[11]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[11]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[11]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[12]~FF  (.D(gray27[4]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[12]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[12]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[12]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[12]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[12]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[12]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[13]~FF  (.D(gray27[5]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[13]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[13]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[13]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[13]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[13]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[13]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[14]~FF  (.D(gray27[6]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[14]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[14]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[14]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[14]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[14]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[14]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[15]~FF  (.D(gray27[7]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[15]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[15]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[15]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[15]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[15]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[15]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[16]~FF  (.D(gray25[0]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[16]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[16]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[16]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[16]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[16]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[16]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[17]~FF  (.D(gray25[1]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[17]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[17]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[17]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[17]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[17]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[17]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[18]~FF  (.D(gray25[2]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[18]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[18]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[18]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[18]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[18]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[18]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[19]~FF  (.D(gray25[3]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[19])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[19]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[19]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[19]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[19]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[19]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[19]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[19]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[20]~FF  (.D(gray25[4]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[20])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[20]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[20]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[20]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[20]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[20]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[20]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[20]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[21]~FF  (.D(gray25[5]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[21])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[21]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[21]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[21]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[21]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[21]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[21]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[21]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[22]~FF  (.D(gray25[6]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[22]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[22]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[22]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[22]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[22]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[22]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[22]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_meta[23]~FF  (.D(gray25[7]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_meta[23])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_meta[23]~FF .CLK_POLARITY = 1'b1;
    defparam \status_meta[23]~FF .CE_POLARITY = 1'b1;
    defparam \status_meta[23]~FF .SR_POLARITY = 1'b1;
    defparam \status_meta[23]~FF .D_POLARITY = 1'b1;
    defparam \status_meta[23]~FF .SR_SYNC = 1'b1;
    defparam \status_meta[23]~FF .SR_VALUE = 1'b0;
    defparam \status_meta[23]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[1]~FF  (.D(status_meta[1]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[1]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[1]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[1]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[1]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[1]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[1]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[2]~FF  (.D(status_meta[2]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[2]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[2]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[2]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[2]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[2]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[2]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[3]~FF  (.D(status_meta[3]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[3]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[3]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[3]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[3]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[3]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[3]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[4]~FF  (.D(status_meta[4]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[4]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[4]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[4]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[4]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[4]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[4]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[5]~FF  (.D(status_meta[5]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[5]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[5]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[5]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[5]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[5]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[5]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[6]~FF  (.D(status_meta[6]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[6]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[6]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[6]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[6]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[6]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[6]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[7]~FF  (.D(status_meta[7]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[7]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[7]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[7]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[7]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[7]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[7]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[8]~FF  (.D(status_meta[8]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[8]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[8]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[8]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[8]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[8]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[8]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[8]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[9]~FF  (.D(status_meta[9]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[9]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[9]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[9]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[9]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[9]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[9]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[9]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[10]~FF  (.D(status_meta[10]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[10]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[10]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[10]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[10]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[10]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[10]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[10]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[11]~FF  (.D(status_meta[11]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[11]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[11]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[11]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[11]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[11]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[11]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[11]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[12]~FF  (.D(status_meta[12]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[12]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[12]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[12]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[12]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[12]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[12]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[12]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[13]~FF  (.D(status_meta[13]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[13]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[13]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[13]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[13]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[13]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[13]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[13]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[14]~FF  (.D(status_meta[14]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[14]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[14]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[14]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[14]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[14]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[14]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[14]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[15]~FF  (.D(status_meta[15]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[15]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[15]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[15]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[15]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[15]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[15]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[15]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[16]~FF  (.D(status_meta[16]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[16]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[16]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[16]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[16]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[16]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[16]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[16]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[17]~FF  (.D(status_meta[17]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[17]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[17]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[17]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[17]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[17]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[17]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[17]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[18]~FF  (.D(status_meta[18]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[18]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[18]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[18]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[18]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[18]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[18]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[18]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[19]~FF  (.D(status_meta[19]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[19])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[19]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[19]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[19]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[19]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[19]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[19]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[19]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[20]~FF  (.D(status_meta[20]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[20])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[20]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[20]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[20]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[20]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[20]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[20]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[20]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[21]~FF  (.D(status_meta[21]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[21])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[21]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[21]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[21]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[21]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[21]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[21]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[21]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[22]~FF  (.D(status_meta[22]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[22]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[22]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[22]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[22]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[22]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[22]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[22]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \status_sync[23]~FF  (.D(status_meta[23]), .CE(1'b1), .CLK(jtag_inst1_DRCK), 
           .SR(1'b0), .Q(status_sync[23])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(36)
    defparam \status_sync[23]~FF .CLK_POLARITY = 1'b1;
    defparam \status_sync[23]~FF .CE_POLARITY = 1'b1;
    defparam \status_sync[23]~FF .SR_POLARITY = 1'b1;
    defparam \status_sync[23]~FF .D_POLARITY = 1'b1;
    defparam \status_sync[23]~FF .SR_SYNC = 1'b1;
    defparam \status_sync[23]~FF .SR_VALUE = 1'b0;
    defparam \status_sync[23]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray25[1]~FF  (.D(n281[1]), .CE(1'b1), .CLK(CLK_25M), .SR(1'b0), 
           .Q(gray25[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam \gray25[1]~FF .CLK_POLARITY = 1'b1;
    defparam \gray25[1]~FF .CE_POLARITY = 1'b1;
    defparam \gray25[1]~FF .SR_POLARITY = 1'b1;
    defparam \gray25[1]~FF .D_POLARITY = 1'b1;
    defparam \gray25[1]~FF .SR_SYNC = 1'b1;
    defparam \gray25[1]~FF .SR_VALUE = 1'b0;
    defparam \gray25[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray25[2]~FF  (.D(n281[2]), .CE(1'b1), .CLK(CLK_25M), .SR(1'b0), 
           .Q(gray25[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam \gray25[2]~FF .CLK_POLARITY = 1'b1;
    defparam \gray25[2]~FF .CE_POLARITY = 1'b1;
    defparam \gray25[2]~FF .SR_POLARITY = 1'b1;
    defparam \gray25[2]~FF .D_POLARITY = 1'b1;
    defparam \gray25[2]~FF .SR_SYNC = 1'b1;
    defparam \gray25[2]~FF .SR_VALUE = 1'b0;
    defparam \gray25[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray25[3]~FF  (.D(n281[3]), .CE(1'b1), .CLK(CLK_25M), .SR(1'b0), 
           .Q(gray25[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam \gray25[3]~FF .CLK_POLARITY = 1'b1;
    defparam \gray25[3]~FF .CE_POLARITY = 1'b1;
    defparam \gray25[3]~FF .SR_POLARITY = 1'b1;
    defparam \gray25[3]~FF .D_POLARITY = 1'b1;
    defparam \gray25[3]~FF .SR_SYNC = 1'b1;
    defparam \gray25[3]~FF .SR_VALUE = 1'b0;
    defparam \gray25[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray25[4]~FF  (.D(n281[4]), .CE(1'b1), .CLK(CLK_25M), .SR(1'b0), 
           .Q(gray25[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam \gray25[4]~FF .CLK_POLARITY = 1'b1;
    defparam \gray25[4]~FF .CE_POLARITY = 1'b1;
    defparam \gray25[4]~FF .SR_POLARITY = 1'b1;
    defparam \gray25[4]~FF .D_POLARITY = 1'b1;
    defparam \gray25[4]~FF .SR_SYNC = 1'b1;
    defparam \gray25[4]~FF .SR_VALUE = 1'b0;
    defparam \gray25[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray25[5]~FF  (.D(n281[5]), .CE(1'b1), .CLK(CLK_25M), .SR(1'b0), 
           .Q(gray25[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam \gray25[5]~FF .CLK_POLARITY = 1'b1;
    defparam \gray25[5]~FF .CE_POLARITY = 1'b1;
    defparam \gray25[5]~FF .SR_POLARITY = 1'b1;
    defparam \gray25[5]~FF .D_POLARITY = 1'b1;
    defparam \gray25[5]~FF .SR_SYNC = 1'b1;
    defparam \gray25[5]~FF .SR_VALUE = 1'b0;
    defparam \gray25[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray25[6]~FF  (.D(n281[6]), .CE(1'b1), .CLK(CLK_25M), .SR(1'b0), 
           .Q(gray25[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam \gray25[6]~FF .CLK_POLARITY = 1'b1;
    defparam \gray25[6]~FF .CE_POLARITY = 1'b1;
    defparam \gray25[6]~FF .SR_POLARITY = 1'b1;
    defparam \gray25[6]~FF .D_POLARITY = 1'b1;
    defparam \gray25[6]~FF .SR_SYNC = 1'b1;
    defparam \gray25[6]~FF .SR_VALUE = 1'b0;
    defparam \gray25[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray25[7]~FF  (.D(led0), .CE(1'b1), .CLK(CLK_25M), .SR(1'b0), 
           .Q(gray25[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam \gray25[7]~FF .CLK_POLARITY = 1'b1;
    defparam \gray25[7]~FF .CE_POLARITY = 1'b1;
    defparam \gray25[7]~FF .SR_POLARITY = 1'b1;
    defparam \gray25[7]~FF .D_POLARITY = 1'b1;
    defparam \gray25[7]~FF .SR_SYNC = 1'b1;
    defparam \gray25[7]~FF .SR_VALUE = 1'b0;
    defparam \gray25[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray27[1]~FF  (.D(n300[1]), .CE(1'b1), .CLK(CLK_27M), .SR(1'b0), 
           .Q(gray27[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam \gray27[1]~FF .CLK_POLARITY = 1'b1;
    defparam \gray27[1]~FF .CE_POLARITY = 1'b1;
    defparam \gray27[1]~FF .SR_POLARITY = 1'b1;
    defparam \gray27[1]~FF .D_POLARITY = 1'b1;
    defparam \gray27[1]~FF .SR_SYNC = 1'b1;
    defparam \gray27[1]~FF .SR_VALUE = 1'b0;
    defparam \gray27[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray27[2]~FF  (.D(n300[2]), .CE(1'b1), .CLK(CLK_27M), .SR(1'b0), 
           .Q(gray27[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam \gray27[2]~FF .CLK_POLARITY = 1'b1;
    defparam \gray27[2]~FF .CE_POLARITY = 1'b1;
    defparam \gray27[2]~FF .SR_POLARITY = 1'b1;
    defparam \gray27[2]~FF .D_POLARITY = 1'b1;
    defparam \gray27[2]~FF .SR_SYNC = 1'b1;
    defparam \gray27[2]~FF .SR_VALUE = 1'b0;
    defparam \gray27[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray27[3]~FF  (.D(n300[3]), .CE(1'b1), .CLK(CLK_27M), .SR(1'b0), 
           .Q(gray27[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam \gray27[3]~FF .CLK_POLARITY = 1'b1;
    defparam \gray27[3]~FF .CE_POLARITY = 1'b1;
    defparam \gray27[3]~FF .SR_POLARITY = 1'b1;
    defparam \gray27[3]~FF .D_POLARITY = 1'b1;
    defparam \gray27[3]~FF .SR_SYNC = 1'b1;
    defparam \gray27[3]~FF .SR_VALUE = 1'b0;
    defparam \gray27[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray27[4]~FF  (.D(n300[4]), .CE(1'b1), .CLK(CLK_27M), .SR(1'b0), 
           .Q(gray27[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam \gray27[4]~FF .CLK_POLARITY = 1'b1;
    defparam \gray27[4]~FF .CE_POLARITY = 1'b1;
    defparam \gray27[4]~FF .SR_POLARITY = 1'b1;
    defparam \gray27[4]~FF .D_POLARITY = 1'b1;
    defparam \gray27[4]~FF .SR_SYNC = 1'b1;
    defparam \gray27[4]~FF .SR_VALUE = 1'b0;
    defparam \gray27[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray27[5]~FF  (.D(n300[5]), .CE(1'b1), .CLK(CLK_27M), .SR(1'b0), 
           .Q(gray27[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam \gray27[5]~FF .CLK_POLARITY = 1'b1;
    defparam \gray27[5]~FF .CE_POLARITY = 1'b1;
    defparam \gray27[5]~FF .SR_POLARITY = 1'b1;
    defparam \gray27[5]~FF .D_POLARITY = 1'b1;
    defparam \gray27[5]~FF .SR_SYNC = 1'b1;
    defparam \gray27[5]~FF .SR_VALUE = 1'b0;
    defparam \gray27[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray27[6]~FF  (.D(n300[6]), .CE(1'b1), .CLK(CLK_27M), .SR(1'b0), 
           .Q(gray27[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam \gray27[6]~FF .CLK_POLARITY = 1'b1;
    defparam \gray27[6]~FF .CE_POLARITY = 1'b1;
    defparam \gray27[6]~FF .SR_POLARITY = 1'b1;
    defparam \gray27[6]~FF .D_POLARITY = 1'b1;
    defparam \gray27[6]~FF .SR_SYNC = 1'b1;
    defparam \gray27[6]~FF .SR_VALUE = 1'b0;
    defparam \gray27[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \gray27[7]~FF  (.D(ref27_ticks[24]), .CE(1'b1), .CLK(CLK_27M), 
           .SR(1'b0), .Q(gray27[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam \gray27[7]~FF .CLK_POLARITY = 1'b1;
    defparam \gray27[7]~FF .CE_POLARITY = 1'b1;
    defparam \gray27[7]~FF .SR_POLARITY = 1'b1;
    defparam \gray27[7]~FF .D_POLARITY = 1'b1;
    defparam \gray27[7]~FF .SR_SYNC = 1'b1;
    defparam \gray27[7]~FF .SR_VALUE = 1'b0;
    defparam \gray27[7]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \grayframes[1]~FF  (.D(n319_3[1]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(grayframes[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam \grayframes[1]~FF .CLK_POLARITY = 1'b1;
    defparam \grayframes[1]~FF .CE_POLARITY = 1'b1;
    defparam \grayframes[1]~FF .SR_POLARITY = 1'b1;
    defparam \grayframes[1]~FF .D_POLARITY = 1'b1;
    defparam \grayframes[1]~FF .SR_SYNC = 1'b1;
    defparam \grayframes[1]~FF .SR_VALUE = 1'b0;
    defparam \grayframes[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \grayframes[2]~FF  (.D(n319_4[2]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(grayframes[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam \grayframes[2]~FF .CLK_POLARITY = 1'b1;
    defparam \grayframes[2]~FF .CE_POLARITY = 1'b1;
    defparam \grayframes[2]~FF .SR_POLARITY = 1'b1;
    defparam \grayframes[2]~FF .D_POLARITY = 1'b1;
    defparam \grayframes[2]~FF .SR_SYNC = 1'b1;
    defparam \grayframes[2]~FF .SR_VALUE = 1'b0;
    defparam \grayframes[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \grayframes[3]~FF  (.D(n319_5[3]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(grayframes[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam \grayframes[3]~FF .CLK_POLARITY = 1'b1;
    defparam \grayframes[3]~FF .CE_POLARITY = 1'b1;
    defparam \grayframes[3]~FF .SR_POLARITY = 1'b1;
    defparam \grayframes[3]~FF .D_POLARITY = 1'b1;
    defparam \grayframes[3]~FF .SR_SYNC = 1'b1;
    defparam \grayframes[3]~FF .SR_VALUE = 1'b0;
    defparam \grayframes[3]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \grayframes[4]~FF  (.D(n319_6[4]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(grayframes[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam \grayframes[4]~FF .CLK_POLARITY = 1'b1;
    defparam \grayframes[4]~FF .CE_POLARITY = 1'b1;
    defparam \grayframes[4]~FF .SR_POLARITY = 1'b1;
    defparam \grayframes[4]~FF .D_POLARITY = 1'b1;
    defparam \grayframes[4]~FF .SR_SYNC = 1'b1;
    defparam \grayframes[4]~FF .SR_VALUE = 1'b0;
    defparam \grayframes[4]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \grayframes[5]~FF  (.D(n319_7[5]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(grayframes[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam \grayframes[5]~FF .CLK_POLARITY = 1'b1;
    defparam \grayframes[5]~FF .CE_POLARITY = 1'b1;
    defparam \grayframes[5]~FF .SR_POLARITY = 1'b1;
    defparam \grayframes[5]~FF .D_POLARITY = 1'b1;
    defparam \grayframes[5]~FF .SR_SYNC = 1'b1;
    defparam \grayframes[5]~FF .SR_VALUE = 1'b0;
    defparam \grayframes[5]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \grayframes[6]~FF  (.D(frames[6]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(1'b0), .Q(grayframes[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b1, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam \grayframes[6]~FF .CLK_POLARITY = 1'b1;
    defparam \grayframes[6]~FF .CE_POLARITY = 1'b1;
    defparam \grayframes[6]~FF .SR_POLARITY = 1'b1;
    defparam \grayframes[6]~FF .D_POLARITY = 1'b1;
    defparam \grayframes[6]~FF .SR_SYNC = 1'b1;
    defparam \grayframes[6]~FF .SR_VALUE = 1'b0;
    defparam \grayframes[6]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reset_pipe[1]~FF  (.D(reset_pipe[0]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(hdmi_tx_locked), .Q(reset_pipe[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(16)
    defparam \reset_pipe[1]~FF .CLK_POLARITY = 1'b1;
    defparam \reset_pipe[1]~FF .CE_POLARITY = 1'b1;
    defparam \reset_pipe[1]~FF .SR_POLARITY = 1'b0;
    defparam \reset_pipe[1]~FF .D_POLARITY = 1'b1;
    defparam \reset_pipe[1]~FF .SR_SYNC = 1'b0;
    defparam \reset_pipe[1]~FF .SR_VALUE = 1'b0;
    defparam \reset_pipe[1]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_FF \reset_pipe[2]~FF  (.D(reset_pipe[1]), .CE(1'b1), .CLK(hdmi_tx_slow_clk), 
           .SR(hdmi_tx_locked), .Q(reset_pipe[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_FF, CLK_POLARITY=1'b1, D_POLARITY=1'b1, CE_POLARITY=1'b1, SR_SYNC=1'b0, SR_SYNC_PRIORITY=1'b1, SR_VALUE=1'b0, SR_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(16)
    defparam \reset_pipe[2]~FF .CLK_POLARITY = 1'b1;
    defparam \reset_pipe[2]~FF .CE_POLARITY = 1'b1;
    defparam \reset_pipe[2]~FF .SR_POLARITY = 1'b0;
    defparam \reset_pipe[2]~FF .D_POLARITY = 1'b1;
    defparam \reset_pipe[2]~FF .SR_SYNC = 1'b0;
    defparam \reset_pipe[2]~FF .SR_VALUE = 1'b0;
    defparam \reset_pipe[2]~FF .SR_SYNC_PRIORITY = 1'b1;
    EFX_ADD \add_53/i1  (.I0(ref27_ticks[1]), .I1(ref27_ticks[0]), .CI(1'b0), 
            .O(n226_2[1]), .CO(\add_53/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i1 .I0_POLARITY = 1'b1;
    defparam \add_53/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i2  (.I0(reference_ticks[2]), .I1(1'b0), .CI(\add_51/n2 ), 
            .O(n6[2]), .CO(\add_51/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i2 .I0_POLARITY = 1'b1;
    defparam \add_51/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i1  (.I0(reference_ticks[1]), .I1(reference_ticks[0]), 
            .CI(1'b0), .O(n6[1]), .CO(\add_51/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i1 .I0_POLARITY = 1'b1;
    defparam \add_51/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_110/i6  (.I0(frames[6]), .I1(1'b0), .CI(\pattern/add_110/n10 ), 
            .O(\pattern/n119 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(31)
    defparam \pattern/add_110/i6 .I0_POLARITY = 1'b1;
    defparam \pattern/add_110/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_110/i5  (.I0(led1), .I1(1'b0), .CI(\pattern/add_110/n8 ), 
            .O(\pattern/n119 [5]), .CO(\pattern/add_110/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(31)
    defparam \pattern/add_110/i5 .I0_POLARITY = 1'b1;
    defparam \pattern/add_110/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_110/i4  (.I0(frames[4]), .I1(1'b0), .CI(\pattern/add_110/n6 ), 
            .O(\pattern/n119 [4]), .CO(\pattern/add_110/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(31)
    defparam \pattern/add_110/i4 .I0_POLARITY = 1'b1;
    defparam \pattern/add_110/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_110/i3  (.I0(frames[3]), .I1(1'b0), .CI(\pattern/add_110/n4 ), 
            .O(\pattern/n119 [3]), .CO(\pattern/add_110/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(31)
    defparam \pattern/add_110/i3 .I0_POLARITY = 1'b1;
    defparam \pattern/add_110/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_83/i1  (.I0(\encoder/encb/cnt [0]), .I1(1'b0), 
            .CI(1'b0), .O(\encoder/encb/n232 [0]), .CO(n1103)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_83/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_83/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_110/i2  (.I0(frames[2]), .I1(1'b0), .CI(\pattern/add_110/n2 ), 
            .O(\pattern/n119 [2]), .CO(\pattern/add_110/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(31)
    defparam \pattern/add_110/i2 .I0_POLARITY = 1'b1;
    defparam \pattern/add_110/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_89/i1  (.I0(\encoder/encb/cnt [0]), .I1(\encoder/encb/n285 [0]), 
            .CI(n1106), .O(\encoder/encb/n273 [0]), .CO(\encoder/encb/add_89/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/add_89/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_89/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_93/i1  (.I0(\encoder/encb/cnt [0]), .I1(\encoder/encb/n285 [0]), 
            .CI(1'b0), .O(\encoder/encb/n292 [0]), .CO(\encoder/encb/add_93/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/add_93/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_93/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_82/add_2/i1  (.I0(\encoder/encb/n232 [0]), .I1(1'b0), 
            .CI(n1107), .O(\encoder/encb/n225 [0]), .CO(n1108)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_82/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_82/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_92/add_2/i1  (.I0(1'b0), .I1(1'b0), .CI(n1111), 
            .O(\encoder/encb/n285 [0]), .CO(n1112)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/sub_92/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_92/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/add_89/i2  (.I0(\encoder/encr/cnt [1]), .I1(\encoder/encr/n266 [1]), 
            .CI(\encoder/encr/add_89/n2 ), .O(\encoder/encr/n273 [1]), .CO(\encoder/encr/add_89/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/add_89/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_89/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i11  (.I0(\pattern/y [11]), .I1(1'b0), .CI(\pattern/add_112/n20 ), 
            .O(\pattern/n46 [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i11 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i10  (.I0(\pattern/y [10]), .I1(1'b0), .CI(\pattern/add_112/n18 ), 
            .O(\pattern/n46 [10]), .CO(\pattern/add_112/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i10 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i9  (.I0(\pattern/y [9]), .I1(1'b0), .CI(\pattern/add_112/n16 ), 
            .O(\pattern/n46 [9]), .CO(\pattern/add_112/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i9 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_83/i5  (.I0(\encoder/encr/cnt [4]), .I1(1'b0), 
            .CI(\encoder/encr/add_83/n8 ), .O(\encoder/encr/n232 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_83/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_83/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i8  (.I0(\pattern/y [8]), .I1(1'b0), .CI(\pattern/add_112/n14 ), 
            .O(\pattern/n46 [8]), .CO(\pattern/add_112/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i8 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i7  (.I0(\pattern/y [7]), .I1(1'b0), .CI(\pattern/add_112/n12 ), 
            .O(\pattern/n46 [7]), .CO(\pattern/add_112/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i7 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i6  (.I0(\pattern/y [6]), .I1(1'b0), .CI(\pattern/add_112/n10 ), 
            .O(\pattern/n46 [6]), .CO(\pattern/add_112/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i6 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i5  (.I0(\pattern/y [5]), .I1(1'b0), .CI(\pattern/add_112/n8 ), 
            .O(\pattern/n46 [5]), .CO(\pattern/add_112/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i5 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i4  (.I0(\pattern/y [4]), .I1(1'b0), .CI(\pattern/add_112/n6 ), 
            .O(\pattern/n46 [4]), .CO(\pattern/add_112/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i4 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_83/i4  (.I0(\encoder/encr/cnt [3]), .I1(\encoder/encr/n1q_m [3]), 
            .CI(\encoder/encr/add_83/n6 ), .O(\encoder/encr/n232 [3]), .CO(\encoder/encr/add_83/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_83/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_83/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i3  (.I0(\pattern/y [3]), .I1(1'b0), .CI(\pattern/add_112/n4 ), 
            .O(\pattern/n46 [3]), .CO(\pattern/add_112/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i3 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_83/i3  (.I0(\encoder/encr/cnt [2]), .I1(\encoder/encr/n1q_m [2]), 
            .CI(\encoder/encr/add_83/n4 ), .O(\encoder/encr/n232 [2]), .CO(\encoder/encr/add_83/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_83/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_83/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_83/i2  (.I0(\encoder/encr/cnt [1]), .I1(\encoder/encr/n1q_m [1]), 
            .CI(n1117), .O(\encoder/encr/n232 [1]), .CO(\encoder/encr/add_83/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_83/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_83/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_81/i5  (.I0(\encoder/encr/cnt [4]), .I1(1'b0), 
            .CI(\encoder/encr/add_81/n8 ), .O(\encoder/encr/n219 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_81/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_81/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_81/i4  (.I0(\encoder/encr/cnt [3]), .I1(\encoder/encr/n0q_m [3]), 
            .CI(\encoder/encr/add_81/n6 ), .O(\encoder/encr/n219 [3]), .CO(\encoder/encr/add_81/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_81/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_81/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_81/i3  (.I0(\encoder/encr/cnt [2]), .I1(\encoder/encr/n0q_m [2]), 
            .CI(\encoder/encr/add_81/n4 ), .O(\encoder/encr/n219 [2]), .CO(\encoder/encr/add_81/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_81/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_81/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i2  (.I0(\pattern/y [2]), .I1(1'b0), .CI(\pattern/add_112/n2 ), 
            .O(\pattern/n46 [2]), .CO(\pattern/add_112/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i2 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_81/i2  (.I0(\encoder/encr/cnt [1]), .I1(\encoder/encr/n1q_m [1]), 
            .CI(n1116), .O(\encoder/encr/n219 [1]), .CO(\encoder/encr/add_81/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_81/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_81/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_81/i1  (.I0(\encoder/encr/cnt [0]), .I1(1'b0), 
            .CI(1'b0), .O(\encoder/encr/n219 [0]), .CO(n1115)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_81/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_81/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_92/add_2/i5  (.I0(1'b0), .I1(1'b1), .CI(\encoder/encg/sub_92/add_2/n8 ), 
            .O(\encoder/encg/n285 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/sub_92/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_92/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_92/add_2/i4  (.I0(\encoder/encg/n1q_m [3]), 
            .I1(\encoder/encg/n0q_m [3]), .CI(\encoder/encg/sub_92/add_2/n6 ), 
            .O(\encoder/encg/n285 [3]), .CO(\encoder/encg/sub_92/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/sub_92/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_92/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/sub_92/add_2/i3  (.I0(\encoder/encg/n1q_m [2]), 
            .I1(\encoder/encg/n0q_m [2]), .CI(\encoder/encg/sub_92/add_2/n4 ), 
            .O(\encoder/encg/n285 [2]), .CO(\encoder/encg/sub_92/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/sub_92/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_92/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/sub_92/add_2/i2  (.I0(\encoder/encg/n1q_m [1]), 
            .I1(\encoder/encg/n1q_m [1]), .CI(n1138), .O(\encoder/encg/n285 [1]), 
            .CO(\encoder/encg/sub_92/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/sub_92/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_92/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/sub_88/add_2/i5  (.I0(1'b0), .I1(1'b1), .CI(\encoder/encg/sub_88/add_2/n8 ), 
            .O(\encoder/encg/n266 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/sub_88/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_88/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_88/add_2/i4  (.I0(\encoder/encg/n0q_m [3]), 
            .I1(\encoder/encg/n1q_m [3]), .CI(\encoder/encg/sub_88/add_2/n6 ), 
            .O(\encoder/encg/n266 [3]), .CO(\encoder/encg/sub_88/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/sub_88/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_88/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/add_89/i1  (.I0(\encoder/encr/cnt [0]), .I1(\encoder/encr/n285 [0]), 
            .CI(n1118), .O(\encoder/encr/n273 [0]), .CO(\encoder/encr/add_89/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/add_89/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_89/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_88/add_2/i3  (.I0(\encoder/encg/n0q_m [2]), 
            .I1(\encoder/encg/n1q_m [2]), .CI(\encoder/encg/sub_88/add_2/n4 ), 
            .O(\encoder/encg/n266 [2]), .CO(\encoder/encg/sub_88/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/sub_88/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_88/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/add_93/i1  (.I0(\encoder/encr/cnt [0]), .I1(\encoder/encr/n285 [0]), 
            .CI(1'b0), .O(\encoder/encr/n292 [0]), .CO(\encoder/encr/add_93/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/add_93/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_93/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_84/add_2/i1  (.I0(\encoder/encr/n219 [0]), .I1(1'b0), 
            .CI(n1119), .O(\encoder/encr/n238 [0]), .CO(n1120)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_84/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_84/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/sub_92/add_2/i1  (.I0(1'b0), .I1(1'b0), .CI(n1123), 
            .O(\encoder/encr/n285 [0]), .CO(n1124)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/sub_92/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_92/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/add_89/i2  (.I0(\encoder/encg/cnt [1]), .I1(\encoder/encg/n266 [1]), 
            .CI(\encoder/encg/add_89/n2 ), .O(\encoder/encg/n273 [1]), .CO(\encoder/encg/add_89/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/add_89/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_89/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_88/add_2/i2  (.I0(\encoder/encg/n1q_m [1]), 
            .I1(\encoder/encg/n1q_m [1]), .CI(n1137), .O(\encoder/encg/n266 [1]), 
            .CO(\encoder/encg/sub_88/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/sub_88/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_88/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/sub_84/add_2/i5  (.I0(\encoder/encg/n232 [4]), .I1(1'b1), 
            .CI(\encoder/encg/sub_84/add_2/n8 ), .O(\encoder/encg/n238 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_84/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_84/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_83/i5  (.I0(\encoder/encg/cnt [4]), .I1(1'b0), 
            .CI(\encoder/encg/add_83/n8 ), .O(\encoder/encg/n232 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_83/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_83/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_84/add_2/i4  (.I0(\encoder/encg/n232 [3]), .I1(\encoder/encg/n0q_m [3]), 
            .CI(\encoder/encg/sub_84/add_2/n6 ), .O(\encoder/encg/n238 [3]), 
            .CO(\encoder/encg/sub_84/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_84/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_84/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/sub_84/add_2/i3  (.I0(\encoder/encg/n232 [2]), .I1(\encoder/encg/n0q_m [2]), 
            .CI(\encoder/encg/sub_84/add_2/n4 ), .O(\encoder/encg/n238 [2]), 
            .CO(\encoder/encg/sub_84/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_84/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_84/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/sub_84/add_2/i2  (.I0(\encoder/encg/n232 [1]), .I1(\encoder/encg/n1q_m [1]), 
            .CI(n1134), .O(\encoder/encg/n238 [1]), .CO(\encoder/encg/sub_84/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_84/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_84/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/sub_82/add_2/i5  (.I0(\encoder/encg/n219 [4]), .I1(1'b1), 
            .CI(\encoder/encg/sub_82/add_2/n8 ), .O(\encoder/encg/n225 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_82/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_82/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_83/i4  (.I0(\encoder/encg/cnt [3]), .I1(\encoder/encg/n1q_m [3]), 
            .CI(\encoder/encg/add_83/n6 ), .O(\encoder/encg/n232 [3]), .CO(\encoder/encg/add_83/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_83/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_83/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_82/add_2/i4  (.I0(\encoder/encg/n219 [3]), .I1(\encoder/encg/n1q_m [3]), 
            .CI(\encoder/encg/sub_82/add_2/n6 ), .O(\encoder/encg/n225 [3]), 
            .CO(\encoder/encg/sub_82/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_82/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_82/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/add_83/i3  (.I0(\encoder/encg/cnt [2]), .I1(\encoder/encg/n1q_m [2]), 
            .CI(\encoder/encg/add_83/n4 ), .O(\encoder/encg/n232 [2]), .CO(\encoder/encg/add_83/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_83/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_83/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_83/i2  (.I0(\encoder/encg/cnt [1]), .I1(\encoder/encg/n1q_m [1]), 
            .CI(n1129), .O(\encoder/encg/n232 [1]), .CO(\encoder/encg/add_83/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_83/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_83/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_81/i5  (.I0(\encoder/encg/cnt [4]), .I1(1'b0), 
            .CI(\encoder/encg/add_81/n8 ), .O(\encoder/encg/n219 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_81/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_81/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_81/i4  (.I0(\encoder/encg/cnt [3]), .I1(\encoder/encg/n0q_m [3]), 
            .CI(\encoder/encg/add_81/n6 ), .O(\encoder/encg/n219 [3]), .CO(\encoder/encg/add_81/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_81/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_81/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_81/i3  (.I0(\encoder/encg/cnt [2]), .I1(\encoder/encg/n0q_m [2]), 
            .CI(\encoder/encg/add_81/n4 ), .O(\encoder/encg/n219 [2]), .CO(\encoder/encg/add_81/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_81/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_81/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_82/add_2/i3  (.I0(\encoder/encg/n219 [2]), .I1(\encoder/encg/n1q_m [2]), 
            .CI(\encoder/encg/sub_82/add_2/n4 ), .O(\encoder/encg/n225 [2]), 
            .CO(\encoder/encg/sub_82/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_82/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_82/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/add_81/i2  (.I0(\encoder/encg/cnt [1]), .I1(\encoder/encg/n1q_m [1]), 
            .CI(n1128), .O(\encoder/encg/n219 [1]), .CO(\encoder/encg/add_81/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_81/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_81/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_81/i1  (.I0(\encoder/encg/cnt [0]), .I1(1'b0), 
            .CI(1'b0), .O(\encoder/encg/n219 [0]), .CO(n1127)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_81/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_81/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_82/add_2/i2  (.I0(\encoder/encg/n219 [1]), .I1(\encoder/encg/n1q_m [1]), 
            .CI(n1133), .O(\encoder/encg/n225 [1]), .CO(\encoder/encg/sub_82/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_82/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_82/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/add_93/i5  (.I0(\encoder/encg/n626 ), .I1(\encoder/encg/n285 [4]), 
            .CI(\encoder/encg/add_93/n8 ), .O(\encoder/encg/n292 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/add_93/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_93/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_93/i4  (.I0(\encoder/encg/n621 ), .I1(\encoder/encg/n285 [3]), 
            .CI(\encoder/encg/add_93/n6 ), .O(\encoder/encg/n292 [3]), .CO(\encoder/encg/add_93/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/add_93/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_93/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_93/i3  (.I0(\encoder/encg/n616 ), .I1(\encoder/encg/n285 [2]), 
            .CI(\encoder/encg/add_93/n4 ), .O(\encoder/encg/n292 [2]), .CO(\encoder/encg/add_93/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/add_93/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_93/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_93/i2  (.I0(\encoder/encg/n694 ), .I1(\encoder/encg/n285 [1]), 
            .CI(\encoder/encg/add_93/n2 ), .O(\encoder/encg/n292 [1]), .CO(\encoder/encg/add_93/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/add_93/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_93/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_89/i5  (.I0(\encoder/encg/cnt [4]), .I1(\encoder/encg/n266 [4]), 
            .CI(\encoder/encg/add_89/n8 ), .O(\encoder/encg/n273 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/add_89/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_89/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_89/i4  (.I0(\encoder/encg/cnt [3]), .I1(\encoder/encg/n266 [3]), 
            .CI(\encoder/encg/add_89/n6 ), .O(\encoder/encg/n273 [3]), .CO(\encoder/encg/add_89/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/add_89/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_89/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_89/i3  (.I0(\encoder/encg/cnt [2]), .I1(\encoder/encg/n266 [2]), 
            .CI(\encoder/encg/add_89/n4 ), .O(\encoder/encg/n273 [2]), .CO(\encoder/encg/add_89/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/add_89/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_89/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_89/i1  (.I0(\encoder/encg/cnt [0]), .I1(\encoder/encg/n285 [0]), 
            .CI(n1130), .O(\encoder/encg/n273 [0]), .CO(\encoder/encg/add_89/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/add_89/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_89/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_92/add_2/i5  (.I0(1'b0), .I1(1'b1), .CI(\encoder/encr/sub_92/add_2/n8 ), 
            .O(\encoder/encr/n285 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/sub_92/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_92/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_93/i1  (.I0(\encoder/encg/cnt [0]), .I1(\encoder/encg/n285 [0]), 
            .CI(1'b0), .O(\encoder/encg/n292 [0]), .CO(\encoder/encg/add_93/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/add_93/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_93/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_84/add_2/i1  (.I0(\encoder/encg/n219 [0]), .I1(1'b0), 
            .CI(n1131), .O(\encoder/encg/n238 [0]), .CO(n1132)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_84/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_84/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encg/sub_92/add_2/i1  (.I0(1'b0), .I1(1'b0), .CI(n1135), 
            .O(\encoder/encg/n285 [0]), .CO(n1136)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encg/sub_92/add_2/i1 .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_92/add_2/i1 .I1_POLARITY = 1'b0;
    EFX_ADD \pattern/add_114/i11  (.I0(\pattern/x [11]), .I1(1'b0), .CI(\pattern/add_114/n20 ), 
            .O(\pattern/n73 [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i11 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_92/add_2/i4  (.I0(\encoder/encr/n1q_m [3]), 
            .I1(\encoder/encr/n0q_m [3]), .CI(\encoder/encr/sub_92/add_2/n6 ), 
            .O(\encoder/encr/n285 [3]), .CO(\encoder/encr/sub_92/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/sub_92/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_92/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/sub_92/add_2/i3  (.I0(\encoder/encr/n1q_m [2]), 
            .I1(\encoder/encr/n0q_m [2]), .CI(\encoder/encr/sub_92/add_2/n4 ), 
            .O(\encoder/encr/n285 [2]), .CO(\encoder/encr/sub_92/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/sub_92/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_92/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/sub_92/add_2/i2  (.I0(\encoder/encr/n1q_m [1]), 
            .I1(\encoder/encr/n1q_m [1]), .CI(n1125), .O(\encoder/encr/n285 [1]), 
            .CO(\encoder/encr/sub_92/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/sub_92/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_92/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \pattern/add_114/i10  (.I0(\pattern/x [10]), .I1(1'b0), .CI(\pattern/add_114/n18 ), 
            .O(\pattern/n73 [10]), .CO(\pattern/add_114/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i10 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_114/i9  (.I0(\pattern/x [9]), .I1(1'b0), .CI(\pattern/add_114/n16 ), 
            .O(\pattern/n73 [9]), .CO(\pattern/add_114/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i9 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_88/add_2/i5  (.I0(1'b0), .I1(1'b1), .CI(\encoder/encr/sub_88/add_2/n8 ), 
            .O(\encoder/encr/n266 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/sub_88/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_88/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_88/add_2/i4  (.I0(\encoder/encr/n0q_m [3]), 
            .I1(\encoder/encr/n1q_m [3]), .CI(\encoder/encr/sub_88/add_2/n6 ), 
            .O(\encoder/encr/n266 [3]), .CO(\encoder/encr/sub_88/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/sub_88/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_88/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/sub_88/add_2/i3  (.I0(\encoder/encr/n0q_m [2]), 
            .I1(\encoder/encr/n1q_m [2]), .CI(\encoder/encr/sub_88/add_2/n4 ), 
            .O(\encoder/encr/n266 [2]), .CO(\encoder/encr/sub_88/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/sub_88/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_88/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \pattern/add_114/i8  (.I0(\pattern/x [8]), .I1(1'b0), .CI(\pattern/add_114/n14 ), 
            .O(\pattern/n73 [8]), .CO(\pattern/add_114/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i8 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_88/add_2/i2  (.I0(\encoder/encr/n1q_m [1]), 
            .I1(\encoder/encr/n1q_m [1]), .CI(n1126), .O(\encoder/encr/n266 [1]), 
            .CO(\encoder/encr/sub_88/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/sub_88/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_88/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \pattern/add_114/i7  (.I0(\pattern/x [7]), .I1(1'b0), .CI(\pattern/add_114/n12 ), 
            .O(\pattern/n73 [7]), .CO(\pattern/add_114/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i7 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_114/i6  (.I0(\pattern/x [6]), .I1(1'b0), .CI(\pattern/add_114/n10 ), 
            .O(\pattern/n73 [6]), .CO(\pattern/add_114/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i6 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_114/i5  (.I0(\pattern/x [5]), .I1(1'b0), .CI(\pattern/add_114/n8 ), 
            .O(\pattern/n73 [5]), .CO(\pattern/add_114/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i5 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_114/i4  (.I0(\pattern/x [4]), .I1(1'b0), .CI(\pattern/add_114/n6 ), 
            .O(\pattern/n73 [4]), .CO(\pattern/add_114/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i4 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_114/i3  (.I0(\pattern/x [3]), .I1(1'b0), .CI(\pattern/add_114/n4 ), 
            .O(\pattern/n73 [3]), .CO(\pattern/add_114/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i3 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_114/i2  (.I0(\pattern/x [2]), .I1(1'b0), .CI(\pattern/add_114/n2 ), 
            .O(\pattern/n73 [2]), .CO(\pattern/add_114/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i2 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_114/i1  (.I0(\pattern/x [1]), .I1(\pattern/x [0]), 
            .CI(1'b0), .O(\pattern/n73 [1]), .CO(\pattern/add_114/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam \pattern/add_114/i1 .I0_POLARITY = 1'b1;
    defparam \pattern/add_114/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \pattern/add_112/i1  (.I0(\pattern/y [1]), .I1(\pattern/y [0]), 
            .CI(1'b0), .O(\pattern/n46 [1]), .CO(\pattern/add_112/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam \pattern/add_112/i1 .I0_POLARITY = 1'b1;
    defparam \pattern/add_112/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_84/add_2/i5  (.I0(\encoder/encr/n232 [4]), .I1(1'b1), 
            .CI(\encoder/encr/sub_84/add_2/n8 ), .O(\encoder/encr/n238 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_84/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_84/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_84/add_2/i4  (.I0(\encoder/encr/n232 [3]), .I1(\encoder/encr/n0q_m [3]), 
            .CI(\encoder/encr/sub_84/add_2/n6 ), .O(\encoder/encr/n238 [3]), 
            .CO(\encoder/encr/sub_84/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_84/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_84/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/sub_84/add_2/i3  (.I0(\encoder/encr/n232 [2]), .I1(\encoder/encr/n0q_m [2]), 
            .CI(\encoder/encr/sub_84/add_2/n4 ), .O(\encoder/encr/n238 [2]), 
            .CO(\encoder/encr/sub_84/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_84/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_84/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \pattern/add_110/i1  (.I0(frames[1]), .I1(frames[0]), .CI(1'b0), 
            .O(\pattern/n119 [1]), .CO(\pattern/add_110/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(31)
    defparam \pattern/add_110/i1 .I0_POLARITY = 1'b1;
    defparam \pattern/add_110/i1 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_84/add_2/i2  (.I0(\encoder/encr/n232 [1]), .I1(\encoder/encr/n1q_m [1]), 
            .CI(n1121), .O(\encoder/encr/n238 [1]), .CO(\encoder/encr/sub_84/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_84/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_84/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/sub_82/add_2/i5  (.I0(\encoder/encr/n219 [4]), .I1(1'b1), 
            .CI(\encoder/encr/sub_82/add_2/n8 ), .O(\encoder/encr/n225 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_82/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_82/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_82/add_2/i4  (.I0(\encoder/encr/n219 [3]), .I1(\encoder/encr/n1q_m [3]), 
            .CI(\encoder/encr/sub_82/add_2/n6 ), .O(\encoder/encr/n225 [3]), 
            .CO(\encoder/encr/sub_82/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_82/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_82/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/sub_82/add_2/i3  (.I0(\encoder/encr/n219 [2]), .I1(\encoder/encr/n1q_m [2]), 
            .CI(\encoder/encr/sub_82/add_2/n4 ), .O(\encoder/encr/n225 [2]), 
            .CO(\encoder/encr/sub_82/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_82/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_82/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/sub_82/add_2/i2  (.I0(\encoder/encr/n219 [1]), .I1(\encoder/encr/n1q_m [1]), 
            .CI(n1122), .O(\encoder/encr/n225 [1]), .CO(\encoder/encr/sub_82/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_82/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_82/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encr/add_93/i5  (.I0(\encoder/encr/n626 ), .I1(\encoder/encr/n285 [4]), 
            .CI(\encoder/encr/add_93/n8 ), .O(\encoder/encr/n292 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/add_93/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_93/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_93/i4  (.I0(\encoder/encr/n621 ), .I1(\encoder/encr/n285 [3]), 
            .CI(\encoder/encr/add_93/n6 ), .O(\encoder/encr/n292 [3]), .CO(\encoder/encr/add_93/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/add_93/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_93/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_93/i3  (.I0(\encoder/encr/n616 ), .I1(\encoder/encr/n285 [2]), 
            .CI(\encoder/encr/add_93/n4 ), .O(\encoder/encr/n292 [2]), .CO(\encoder/encr/add_93/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/add_93/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_93/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_93/i2  (.I0(\encoder/encr/n694 ), .I1(\encoder/encr/n285 [1]), 
            .CI(\encoder/encr/add_93/n2 ), .O(\encoder/encr/n292 [1]), .CO(\encoder/encr/add_93/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/add_93/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_93/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_89/i5  (.I0(\encoder/encr/cnt [4]), .I1(\encoder/encr/n266 [4]), 
            .CI(\encoder/encr/add_89/n8 ), .O(\encoder/encr/n273 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/add_89/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_89/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_89/i4  (.I0(\encoder/encr/cnt [3]), .I1(\encoder/encr/n266 [3]), 
            .CI(\encoder/encr/add_89/n6 ), .O(\encoder/encr/n273 [3]), .CO(\encoder/encr/add_89/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/add_89/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_89/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_89/i3  (.I0(\encoder/encr/cnt [2]), .I1(\encoder/encr/n266 [2]), 
            .CI(\encoder/encr/add_89/n4 ), .O(\encoder/encr/n273 [2]), .CO(\encoder/encr/add_89/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/add_89/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_89/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_92/add_2/i5  (.I0(1'b0), .I1(1'b1), .CI(\encoder/encb/sub_92/add_2/n8 ), 
            .O(\encoder/encb/n285 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/sub_92/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_92/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_92/add_2/i4  (.I0(\encoder/encb/n1q_m [3]), 
            .I1(\encoder/encb/n0q_m [3]), .CI(\encoder/encb/sub_92/add_2/n6 ), 
            .O(\encoder/encb/n285 [3]), .CO(\encoder/encb/sub_92/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/sub_92/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_92/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_92/add_2/i3  (.I0(\encoder/encb/n1q_m [2]), 
            .I1(\encoder/encb/n0q_m [2]), .CI(\encoder/encb/sub_92/add_2/n4 ), 
            .O(\encoder/encb/n285 [2]), .CO(\encoder/encb/sub_92/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/sub_92/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_92/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_92/add_2/i2  (.I0(\encoder/encb/n1q_m [1]), 
            .I1(\encoder/encb/n1q_m [1]), .CI(n1113), .O(\encoder/encb/n285 [1]), 
            .CO(\encoder/encb/sub_92/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/sub_92/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_92/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_88/add_2/i5  (.I0(1'b0), .I1(1'b1), .CI(\encoder/encb/sub_88/add_2/n8 ), 
            .O(\encoder/encb/n266 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/sub_88/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_88/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_88/add_2/i4  (.I0(\encoder/encb/n0q_m [3]), 
            .I1(\encoder/encb/n1q_m [3]), .CI(\encoder/encb/sub_88/add_2/n6 ), 
            .O(\encoder/encb/n266 [3]), .CO(\encoder/encb/sub_88/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/sub_88/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_88/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_88/add_2/i3  (.I0(\encoder/encb/n0q_m [2]), 
            .I1(\encoder/encb/n1q_m [2]), .CI(\encoder/encb/sub_88/add_2/n4 ), 
            .O(\encoder/encb/n266 [2]), .CO(\encoder/encb/sub_88/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/sub_88/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_88/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_88/add_2/i2  (.I0(\encoder/encb/n1q_m [1]), 
            .I1(\encoder/encb/n1q_m [1]), .CI(n1114), .O(\encoder/encb/n266 [1]), 
            .CO(\encoder/encb/sub_88/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/sub_88/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_88/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_84/add_2/i5  (.I0(\encoder/encb/n232 [4]), .I1(1'b1), 
            .CI(\encoder/encb/sub_84/add_2/n8 ), .O(\encoder/encb/n238 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_84/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_84/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_84/add_2/i4  (.I0(\encoder/encb/n232 [3]), .I1(\encoder/encb/n0q_m [3]), 
            .CI(\encoder/encb/sub_84/add_2/n6 ), .O(\encoder/encb/n238 [3]), 
            .CO(\encoder/encb/sub_84/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_84/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_84/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_84/add_2/i3  (.I0(\encoder/encb/n232 [2]), .I1(\encoder/encb/n0q_m [2]), 
            .CI(\encoder/encb/sub_84/add_2/n4 ), .O(\encoder/encb/n238 [2]), 
            .CO(\encoder/encb/sub_84/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_84/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_84/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_84/add_2/i2  (.I0(\encoder/encb/n232 [1]), .I1(\encoder/encb/n1q_m [1]), 
            .CI(n1109), .O(\encoder/encb/n238 [1]), .CO(\encoder/encb/sub_84/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_84/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_84/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_82/add_2/i5  (.I0(\encoder/encb/n219 [4]), .I1(1'b1), 
            .CI(\encoder/encb/sub_82/add_2/n8 ), .O(\encoder/encb/n225 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_82/add_2/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_82/add_2/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_82/add_2/i4  (.I0(\encoder/encb/n219 [3]), .I1(\encoder/encb/n1q_m [3]), 
            .CI(\encoder/encb/sub_82/add_2/n6 ), .O(\encoder/encb/n225 [3]), 
            .CO(\encoder/encb/sub_82/add_2/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_82/add_2/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_82/add_2/i4 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_82/add_2/i3  (.I0(\encoder/encb/n219 [2]), .I1(\encoder/encb/n1q_m [2]), 
            .CI(\encoder/encb/sub_82/add_2/n4 ), .O(\encoder/encb/n225 [2]), 
            .CO(\encoder/encb/sub_82/add_2/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_82/add_2/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_82/add_2/i3 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/sub_82/add_2/i2  (.I0(\encoder/encb/n219 [1]), .I1(\encoder/encb/n1q_m [1]), 
            .CI(n1110), .O(\encoder/encb/n225 [1]), .CO(\encoder/encb/sub_82/add_2/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b0 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_82/add_2/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_82/add_2/i2 .I1_POLARITY = 1'b0;
    EFX_ADD \encoder/encb/add_93/i5  (.I0(\encoder/encb/n626 ), .I1(\encoder/encb/n285 [4]), 
            .CI(\encoder/encb/add_93/n8 ), .O(\encoder/encb/n292 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/add_93/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_93/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_93/i4  (.I0(\encoder/encb/n621 ), .I1(\encoder/encb/n285 [3]), 
            .CI(\encoder/encb/add_93/n6 ), .O(\encoder/encb/n292 [3]), .CO(\encoder/encb/add_93/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/add_93/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_93/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_93/i3  (.I0(\encoder/encb/n616 ), .I1(\encoder/encb/n285 [2]), 
            .CI(\encoder/encb/add_93/n4 ), .O(\encoder/encb/n292 [2]), .CO(\encoder/encb/add_93/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/add_93/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_93/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_93/i2  (.I0(\encoder/encb/n694 ), .I1(\encoder/encb/n285 [1]), 
            .CI(\encoder/encb/add_93/n2 ), .O(\encoder/encb/n292 [1]), .CO(\encoder/encb/add_93/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/add_93/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_93/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_89/i5  (.I0(\encoder/encb/cnt [4]), .I1(\encoder/encb/n266 [4]), 
            .CI(\encoder/encb/add_89/n8 ), .O(\encoder/encb/n273 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/add_89/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_89/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_89/i4  (.I0(\encoder/encb/cnt [3]), .I1(\encoder/encb/n266 [3]), 
            .CI(\encoder/encb/add_89/n6 ), .O(\encoder/encb/n273 [3]), .CO(\encoder/encb/add_89/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/add_89/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_89/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_89/i3  (.I0(\encoder/encb/cnt [2]), .I1(\encoder/encb/n266 [2]), 
            .CI(\encoder/encb/add_89/n4 ), .O(\encoder/encb/n273 [2]), .CO(\encoder/encb/add_89/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/add_89/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_89/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_89/i2  (.I0(\encoder/encb/cnt [1]), .I1(\encoder/encb/n266 [1]), 
            .CI(\encoder/encb/add_89/n2 ), .O(\encoder/encb/n273 [1]), .CO(\encoder/encb/add_89/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/add_89/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_89/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_83/i5  (.I0(\encoder/encb/cnt [4]), .I1(1'b0), 
            .CI(\encoder/encb/add_83/n8 ), .O(\encoder/encb/n232 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_83/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_83/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_83/i4  (.I0(\encoder/encb/cnt [3]), .I1(\encoder/encb/n1q_m [3]), 
            .CI(\encoder/encb/add_83/n6 ), .O(\encoder/encb/n232 [3]), .CO(\encoder/encb/add_83/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_83/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_83/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_83/i3  (.I0(\encoder/encb/cnt [2]), .I1(\encoder/encb/n1q_m [2]), 
            .CI(\encoder/encb/add_83/n4 ), .O(\encoder/encb/n232 [2]), .CO(\encoder/encb/add_83/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_83/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_83/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_83/i2  (.I0(\encoder/encb/cnt [1]), .I1(\encoder/encb/n1q_m [1]), 
            .CI(n1104), .O(\encoder/encb/n232 [1]), .CO(\encoder/encb/add_83/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_83/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_83/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_81/i5  (.I0(\encoder/encb/cnt [4]), .I1(1'b0), 
            .CI(\encoder/encb/add_81/n8 ), .O(\encoder/encb/n219 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_81/i5 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_81/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_81/i4  (.I0(\encoder/encb/cnt [3]), .I1(\encoder/encb/n0q_m [3]), 
            .CI(\encoder/encb/add_81/n6 ), .O(\encoder/encb/n219 [3]), .CO(\encoder/encb/add_81/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_81/i4 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_81/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_81/i3  (.I0(\encoder/encb/cnt [2]), .I1(\encoder/encb/n0q_m [2]), 
            .CI(\encoder/encb/add_81/n4 ), .O(\encoder/encb/n219 [2]), .CO(\encoder/encb/add_81/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_81/i3 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_81/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_81/i2  (.I0(\encoder/encb/cnt [1]), .I1(\encoder/encb/n1q_m [1]), 
            .CI(n1105), .O(\encoder/encb/n219 [1]), .CO(\encoder/encb/add_81/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_81/i2 .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_81/i2 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i24  (.I0(led0), .I1(1'b0), .CI(\add_51/n46 ), .O(n6[24])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i24 .I0_POLARITY = 1'b1;
    defparam \add_51/i24 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i23  (.I0(reference_ticks[23]), .I1(1'b0), .CI(\add_51/n44 ), 
            .O(n6[23]), .CO(\add_51/n46 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i23 .I0_POLARITY = 1'b1;
    defparam \add_51/i23 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i22  (.I0(reference_ticks[22]), .I1(1'b0), .CI(\add_51/n42 ), 
            .O(n6[22]), .CO(\add_51/n44 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i22 .I0_POLARITY = 1'b1;
    defparam \add_51/i22 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i21  (.I0(reference_ticks[21]), .I1(1'b0), .CI(\add_51/n40 ), 
            .O(n6[21]), .CO(\add_51/n42 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i21 .I0_POLARITY = 1'b1;
    defparam \add_51/i21 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i20  (.I0(reference_ticks[20]), .I1(1'b0), .CI(\add_51/n38 ), 
            .O(n6[20]), .CO(\add_51/n40 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i20 .I0_POLARITY = 1'b1;
    defparam \add_51/i20 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i19  (.I0(reference_ticks[19]), .I1(1'b0), .CI(\add_51/n36 ), 
            .O(n6[19]), .CO(\add_51/n38 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i19 .I0_POLARITY = 1'b1;
    defparam \add_51/i19 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i18  (.I0(reference_ticks[18]), .I1(1'b0), .CI(\add_51/n34 ), 
            .O(n6[18]), .CO(\add_51/n36 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i18 .I0_POLARITY = 1'b1;
    defparam \add_51/i18 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i17  (.I0(reference_ticks[17]), .I1(1'b0), .CI(\add_51/n32 ), 
            .O(n6[17]), .CO(\add_51/n34 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i17 .I0_POLARITY = 1'b1;
    defparam \add_51/i17 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i16  (.I0(reference_ticks[16]), .I1(1'b0), .CI(\add_51/n30 ), 
            .O(n6[16]), .CO(\add_51/n32 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i16 .I0_POLARITY = 1'b1;
    defparam \add_51/i16 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i15  (.I0(reference_ticks[15]), .I1(1'b0), .CI(\add_51/n28 ), 
            .O(n6[15]), .CO(\add_51/n30 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i15 .I0_POLARITY = 1'b1;
    defparam \add_51/i15 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i14  (.I0(reference_ticks[14]), .I1(1'b0), .CI(\add_51/n26 ), 
            .O(n6[14]), .CO(\add_51/n28 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i14 .I0_POLARITY = 1'b1;
    defparam \add_51/i14 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i13  (.I0(reference_ticks[13]), .I1(1'b0), .CI(\add_51/n24 ), 
            .O(n6[13]), .CO(\add_51/n26 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i13 .I0_POLARITY = 1'b1;
    defparam \add_51/i13 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i12  (.I0(reference_ticks[12]), .I1(1'b0), .CI(\add_51/n22 ), 
            .O(n6[12]), .CO(\add_51/n24 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i12 .I0_POLARITY = 1'b1;
    defparam \add_51/i12 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i11  (.I0(reference_ticks[11]), .I1(1'b0), .CI(\add_51/n20 ), 
            .O(n6[11]), .CO(\add_51/n22 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i11 .I0_POLARITY = 1'b1;
    defparam \add_51/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i10  (.I0(reference_ticks[10]), .I1(1'b0), .CI(\add_51/n18 ), 
            .O(n6[10]), .CO(\add_51/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i10 .I0_POLARITY = 1'b1;
    defparam \add_51/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i9  (.I0(reference_ticks[9]), .I1(1'b0), .CI(\add_51/n16 ), 
            .O(n6[9]), .CO(\add_51/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i9 .I0_POLARITY = 1'b1;
    defparam \add_51/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i8  (.I0(reference_ticks[8]), .I1(1'b0), .CI(\add_51/n14 ), 
            .O(n6[8]), .CO(\add_51/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i8 .I0_POLARITY = 1'b1;
    defparam \add_51/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i7  (.I0(reference_ticks[7]), .I1(1'b0), .CI(\add_51/n12 ), 
            .O(n6[7]), .CO(\add_51/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i7 .I0_POLARITY = 1'b1;
    defparam \add_51/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i6  (.I0(reference_ticks[6]), .I1(1'b0), .CI(\add_51/n10 ), 
            .O(n6[6]), .CO(\add_51/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i6 .I0_POLARITY = 1'b1;
    defparam \add_51/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i5  (.I0(reference_ticks[5]), .I1(1'b0), .CI(\add_51/n8 ), 
            .O(n6[5]), .CO(\add_51/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i5 .I0_POLARITY = 1'b1;
    defparam \add_51/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i4  (.I0(reference_ticks[4]), .I1(1'b0), .CI(\add_51/n6 ), 
            .O(n6[4]), .CO(\add_51/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i4 .I0_POLARITY = 1'b1;
    defparam \add_51/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \add_51/i3  (.I0(reference_ticks[3]), .I1(1'b0), .CI(\add_51/n4 ), 
            .O(n6[3]), .CO(\add_51/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(12)
    defparam \add_51/i3 .I0_POLARITY = 1'b1;
    defparam \add_51/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i24  (.I0(ref27_ticks[24]), .I1(1'b0), .CI(\add_53/n46 ), 
            .O(n226_25[24])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i24 .I0_POLARITY = 1'b1;
    defparam \add_53/i24 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i23  (.I0(ref27_ticks[23]), .I1(1'b0), .CI(\add_53/n44 ), 
            .O(n226_24[23]), .CO(\add_53/n46 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i23 .I0_POLARITY = 1'b1;
    defparam \add_53/i23 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i22  (.I0(ref27_ticks[22]), .I1(1'b0), .CI(\add_53/n42 ), 
            .O(n226_23[22]), .CO(\add_53/n44 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i22 .I0_POLARITY = 1'b1;
    defparam \add_53/i22 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i21  (.I0(ref27_ticks[21]), .I1(1'b0), .CI(\add_53/n40 ), 
            .O(n226_22[21]), .CO(\add_53/n42 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i21 .I0_POLARITY = 1'b1;
    defparam \add_53/i21 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i20  (.I0(ref27_ticks[20]), .I1(1'b0), .CI(\add_53/n38 ), 
            .O(n226_21[20]), .CO(\add_53/n40 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i20 .I0_POLARITY = 1'b1;
    defparam \add_53/i20 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i19  (.I0(ref27_ticks[19]), .I1(1'b0), .CI(\add_53/n36 ), 
            .O(n226_20[19]), .CO(\add_53/n38 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i19 .I0_POLARITY = 1'b1;
    defparam \add_53/i19 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i18  (.I0(ref27_ticks[18]), .I1(1'b0), .CI(\add_53/n34 ), 
            .O(n226_19[18]), .CO(\add_53/n36 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i18 .I0_POLARITY = 1'b1;
    defparam \add_53/i18 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i17  (.I0(ref27_ticks[17]), .I1(1'b0), .CI(\add_53/n32 ), 
            .O(n226_18[17]), .CO(\add_53/n34 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i17 .I0_POLARITY = 1'b1;
    defparam \add_53/i17 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i16  (.I0(ref27_ticks[16]), .I1(1'b0), .CI(\add_53/n30 ), 
            .O(n226_17[16]), .CO(\add_53/n32 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i16 .I0_POLARITY = 1'b1;
    defparam \add_53/i16 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i15  (.I0(ref27_ticks[15]), .I1(1'b0), .CI(\add_53/n28 ), 
            .O(n226_16[15]), .CO(\add_53/n30 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i15 .I0_POLARITY = 1'b1;
    defparam \add_53/i15 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i14  (.I0(ref27_ticks[14]), .I1(1'b0), .CI(\add_53/n26 ), 
            .O(n226_15[14]), .CO(\add_53/n28 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i14 .I0_POLARITY = 1'b1;
    defparam \add_53/i14 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i13  (.I0(ref27_ticks[13]), .I1(1'b0), .CI(\add_53/n24 ), 
            .O(n226_14[13]), .CO(\add_53/n26 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i13 .I0_POLARITY = 1'b1;
    defparam \add_53/i13 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i12  (.I0(ref27_ticks[12]), .I1(1'b0), .CI(\add_53/n22 ), 
            .O(n226_13[12]), .CO(\add_53/n24 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i12 .I0_POLARITY = 1'b1;
    defparam \add_53/i12 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i11  (.I0(ref27_ticks[11]), .I1(1'b0), .CI(\add_53/n20 ), 
            .O(n226_12[11]), .CO(\add_53/n22 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i11 .I0_POLARITY = 1'b1;
    defparam \add_53/i11 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i10  (.I0(ref27_ticks[10]), .I1(1'b0), .CI(\add_53/n18 ), 
            .O(n226_11[10]), .CO(\add_53/n20 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i10 .I0_POLARITY = 1'b1;
    defparam \add_53/i10 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i9  (.I0(ref27_ticks[9]), .I1(1'b0), .CI(\add_53/n16 ), 
            .O(n226_10[9]), .CO(\add_53/n18 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i9 .I0_POLARITY = 1'b1;
    defparam \add_53/i9 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i8  (.I0(ref27_ticks[8]), .I1(1'b0), .CI(\add_53/n14 ), 
            .O(n226_9[8]), .CO(\add_53/n16 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i8 .I0_POLARITY = 1'b1;
    defparam \add_53/i8 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i7  (.I0(ref27_ticks[7]), .I1(1'b0), .CI(\add_53/n12 ), 
            .O(n226_8[7]), .CO(\add_53/n14 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i7 .I0_POLARITY = 1'b1;
    defparam \add_53/i7 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i6  (.I0(ref27_ticks[6]), .I1(1'b0), .CI(\add_53/n10 ), 
            .O(n226_7[6]), .CO(\add_53/n12 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i6 .I0_POLARITY = 1'b1;
    defparam \add_53/i6 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i5  (.I0(ref27_ticks[5]), .I1(1'b0), .CI(\add_53/n8 ), 
            .O(n226_6[5]), .CO(\add_53/n10 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i5 .I0_POLARITY = 1'b1;
    defparam \add_53/i5 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i4  (.I0(ref27_ticks[4]), .I1(1'b0), .CI(\add_53/n6 ), 
            .O(n226_5[4]), .CO(\add_53/n8 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i4 .I0_POLARITY = 1'b1;
    defparam \add_53/i4 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i3  (.I0(ref27_ticks[3]), .I1(1'b0), .CI(\add_53/n4 ), 
            .O(n226_4[3]), .CO(\add_53/n6 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i3 .I0_POLARITY = 1'b1;
    defparam \add_53/i3 .I1_POLARITY = 1'b1;
    EFX_ADD \add_53/i2  (.I0(ref27_ticks[2]), .I1(1'b0), .CI(\add_53/n2 ), 
            .O(n226_3[2]), .CO(\add_53/n4 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(26)
    defparam \add_53/i2 .I0_POLARITY = 1'b1;
    defparam \add_53/i2 .I1_POLARITY = 1'b1;
    EFX_LUT4 LUT__2322 (.I0(reference_ticks[17]), .I1(reference_ticks[18]), 
            .O(n281_2[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam LUT__2322.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2323 (.I0(ref27_ticks[17]), .I1(ref27_ticks[18]), .O(n300_2[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam LUT__2323.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2324 (.I0(frames[1]), .I1(frames[0]), .O(n319_2[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam LUT__2324.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2325 (.I0(\encoder/encb/n1q_m [1]), .I1(\encoder/encb/n1q_m [2]), 
            .I2(\encoder/encb/n0q_m [2]), .O(n996)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7171 */ ;
    defparam LUT__2325.LUTMASK = 16'h7171;
    EFX_LUT4 LUT__2326 (.I0(\encoder/encb/n1q_m [3]), .I1(n996), .I2(\encoder/encb/n0q_m [3]), 
            .I3(\encoder/encb/cnt [4]), .O(n997)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h00d4 */ ;
    defparam LUT__2326.LUTMASK = 16'h00d4;
    EFX_LUT4 LUT__2327 (.I0(\encoder/encb/n1q_m [2]), .I1(\encoder/encb/n1q_m [1]), 
            .I2(\encoder/encb/n0q_m [2]), .O(n998)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h2b2b */ ;
    defparam LUT__2327.LUTMASK = 16'h2b2b;
    EFX_LUT4 LUT__2328 (.I0(\encoder/encb/n1q_m [3]), .I1(\encoder/encb/n0q_m [3]), 
            .I2(n998), .I3(\encoder/encb/cnt [4]), .O(n999)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb200 */ ;
    defparam LUT__2328.LUTMASK = 16'hb200;
    EFX_LUT4 LUT__2329 (.I0(\encoder/encb/cnt [0]), .I1(\encoder/encb/cnt [1]), 
            .I2(\encoder/encb/cnt [2]), .I3(\encoder/encb/cnt [3]), .O(n1000)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2329.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2331 (.I0(\encoder/encb/n1q_m [2]), .I1(\encoder/encb/n0q_m [2]), 
            .I2(\encoder/encb/n1q_m [3]), .I3(\encoder/encb/n0q_m [3]), 
            .O(n1002)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9009 */ ;
    defparam LUT__2331.LUTMASK = 16'h9009;
    EFX_LUT4 LUT__2332 (.I0(n1002), .I1(\encoder/encb/cnt [4]), .I2(n1000), 
            .O(n1003)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4545 */ ;
    defparam LUT__2332.LUTMASK = 16'h4545;
    EFX_LUT4 LUT__2333 (.I0(n999), .I1(n997), .I2(\encoder/encb/q_m_reg [8]), 
            .I3(n1003), .O(n1004)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heef0 */ ;
    defparam LUT__2333.LUTMASK = 16'heef0;
    EFX_LUT4 LUT__2334 (.I0(\encoder/encb/c0_reg ), .I1(\encoder/encb/q_m_reg [7]), 
            .I2(n1004), .I3(\encoder/encb/de_reg ), .O(\encoder/encb/n339 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hc3aa */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2334.LUTMASK = 16'hc3aa;
    EFX_LUT4 LUT__2335 (.I0(\encoder/encb/c0_reg ), .I1(\encoder/encb/q_m_reg [6]), 
            .I2(n1004), .I3(\encoder/encb/de_reg ), .O(\encoder/encb/n339 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hc355 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2335.LUTMASK = 16'hc355;
    EFX_LUT4 LUT__2336 (.I0(\encoder/encb/c0_reg ), .I1(\encoder/encb/q_m_reg [5]), 
            .I2(n1004), .I3(\encoder/encb/de_reg ), .O(\encoder/encb/n339 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hc3aa */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2336.LUTMASK = 16'hc3aa;
    EFX_LUT4 LUT__2338 (.I0(\encoder/encb/n1d [3]), .I1(\encoder/encb/n1d [1]), 
            .O(\encoder/encb/q_m [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(101)
    defparam LUT__2338.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2339 (.I0(\encoder/encb/din_q [6]), .I1(\encoder/encb/din_q [0]), 
            .I2(\encoder/encb/q_m [5]), .O(\encoder/encb/q_m [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9696 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(101)
    defparam LUT__2339.LUTMASK = 16'h9696;
    EFX_LUT4 LUT__2340 (.I0(n1004), .I1(\encoder/encb/c0_reg ), .I2(\encoder/encb/c1_reg ), 
            .I3(\encoder/encb/de_reg ), .O(\encoder/encb/n339 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h55c3 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2340.LUTMASK = 16'h55c3;
    EFX_LUT4 LUT__2341 (.I0(\encoder/encb/c0_reg ), .I1(\encoder/encb/q_m_reg [8]), 
            .I2(\encoder/encb/de_reg ), .O(\encoder/encb/n339 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hc5c5 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2341.LUTMASK = 16'hc5c5;
    EFX_LUT4 LUT__2342 (.I0(\encoder/encb/n273 [0]), .I1(\encoder/encb/n292 [0]), 
            .I2(n999), .I3(n997), .O(n1006)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2342.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2343 (.I0(n1006), .I1(\encoder/encb/n225 [0]), .I2(n1003), 
            .I3(\encoder/encb/de_reg ), .O(\encoder/encb/n350 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5c00 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2343.LUTMASK = 16'h5c00;
    EFX_LUT4 LUT__2344 (.I0(\encoder/encb/c0_reg ), .I1(\encoder/encb/q_m_reg [4]), 
            .I2(n1004), .I3(\encoder/encb/de_reg ), .O(\encoder/encb/n339 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hc355 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2344.LUTMASK = 16'hc355;
    EFX_LUT4 LUT__2349 (.I0(\encoder/encb/c0_reg ), .I1(\encoder/encb/q_m_reg [4]), 
            .I2(n1004), .I3(\encoder/encb/de_reg ), .O(\encoder/encb/n339 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hc3aa */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2349.LUTMASK = 16'hc3aa;
    EFX_LUT4 LUT__2320 (.I0(debug_shift[1]), .I1(status_sync[0]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_2[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2320.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2350 (.I0(\encoder/encb/n273 [1]), .I1(\encoder/encb/n292 [1]), 
            .I2(n999), .I3(n997), .O(n1007)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2350.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2351 (.I0(\encoder/encb/n225 [1]), .I1(\encoder/encb/n238 [1]), 
            .I2(\encoder/encb/q_m_reg [8]), .O(n1008)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2351.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2352 (.I0(n1008), .I1(n1007), .I2(n1003), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encb/n350 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2352.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2353 (.I0(\encoder/encb/n273 [2]), .I1(\encoder/encb/n292 [2]), 
            .I2(n999), .I3(n997), .O(n1009)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2353.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2354 (.I0(\encoder/encb/n225 [2]), .I1(\encoder/encb/n238 [2]), 
            .I2(\encoder/encb/q_m_reg [8]), .O(n1010)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2354.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2355 (.I0(n1010), .I1(n1009), .I2(n1003), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encb/n350 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2355.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2356 (.I0(\encoder/encb/n273 [3]), .I1(\encoder/encb/n292 [3]), 
            .I2(n999), .I3(n997), .O(n1011)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2356.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2357 (.I0(\encoder/encb/n225 [3]), .I1(\encoder/encb/n238 [3]), 
            .I2(\encoder/encb/q_m_reg [8]), .O(n1012)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2357.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2358 (.I0(n1012), .I1(n1011), .I2(n1003), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encb/n350 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2358.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2359 (.I0(\encoder/encb/n273 [4]), .I1(\encoder/encb/n292 [4]), 
            .I2(n999), .I3(n997), .O(n1013)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2359.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2360 (.I0(\encoder/encb/n225 [4]), .I1(\encoder/encb/n238 [4]), 
            .I2(\encoder/encb/q_m_reg [8]), .O(n1014)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2360.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2361 (.I0(n1014), .I1(n1013), .I2(n1003), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encb/n350 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2361.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2362 (.I0(\encoder/encb/din_q [6]), .I1(\encoder/encb/din_q [0]), 
            .I2(\encoder/encb/q_m [5]), .O(\encoder/encb/n505 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4242 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2362.LUTMASK = 16'h4242;
    EFX_LUT4 LUT__2363 (.I0(\encoder/encb/din_q [6]), .I1(\encoder/encb/din_q [0]), 
            .I2(\encoder/encb/q_m [5]), .O(\encoder/encb/n510 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7c7c */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2363.LUTMASK = 16'h7c7c;
    EFX_LUT4 LUT__2364 (.I0(\encoder/encb/din_q [6]), .I1(\encoder/encb/din_q [0]), 
            .I2(\encoder/encb/q_m [5]), .O(\encoder/encb/n515 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2364.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2365 (.I0(\encoder/encb/din_q [6]), .I1(\encoder/encb/din_q [0]), 
            .I2(\encoder/encb/q_m [5]), .O(\encoder/encb/n601 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3e3e */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2365.LUTMASK = 16'h3e3e;
    EFX_LUT4 LUT__2366 (.I0(\encoder/encb/din_q [6]), .I1(\encoder/encb/din_q [0]), 
            .I2(\encoder/encb/q_m [5]), .O(\encoder/encb/n606 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2366.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2367 (.I0(b[6]), .I1(b[0]), .O(\encoder/encb/n464 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2367.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2368 (.I0(b[0]), .I1(b[6]), .O(\encoder/encb/n474 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2368.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2369 (.I0(\encoder/encr/n1q_m [1]), .I1(\encoder/encr/n1q_m [2]), 
            .I2(\encoder/encr/n0q_m [2]), .O(n1015)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7171 */ ;
    defparam LUT__2369.LUTMASK = 16'h7171;
    EFX_LUT4 LUT__2370 (.I0(\encoder/encr/n1q_m [3]), .I1(n1015), .I2(\encoder/encr/n0q_m [3]), 
            .I3(\encoder/encr/cnt [4]), .O(n1016)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h00d4 */ ;
    defparam LUT__2370.LUTMASK = 16'h00d4;
    EFX_LUT4 LUT__2371 (.I0(\encoder/encr/n1q_m [2]), .I1(\encoder/encr/n1q_m [1]), 
            .I2(\encoder/encr/n0q_m [2]), .O(n1017)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h2b2b */ ;
    defparam LUT__2371.LUTMASK = 16'h2b2b;
    EFX_LUT4 LUT__2372 (.I0(\encoder/encr/n1q_m [3]), .I1(\encoder/encr/n0q_m [3]), 
            .I2(n1017), .I3(\encoder/encr/cnt [4]), .O(n1018)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb200 */ ;
    defparam LUT__2372.LUTMASK = 16'hb200;
    EFX_LUT4 LUT__2373 (.I0(\encoder/encr/cnt [0]), .I1(\encoder/encr/cnt [1]), 
            .I2(\encoder/encr/cnt [2]), .I3(\encoder/encr/cnt [3]), .O(n1019)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2373.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2375 (.I0(\encoder/encr/n1q_m [2]), .I1(\encoder/encr/n0q_m [2]), 
            .I2(\encoder/encr/n1q_m [3]), .I3(\encoder/encr/n0q_m [3]), 
            .O(n1021)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9009 */ ;
    defparam LUT__2375.LUTMASK = 16'h9009;
    EFX_LUT4 LUT__2376 (.I0(n1021), .I1(\encoder/encr/cnt [4]), .I2(n1019), 
            .O(n1022)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4545 */ ;
    defparam LUT__2376.LUTMASK = 16'h4545;
    EFX_LUT4 LUT__2377 (.I0(n1018), .I1(n1016), .I2(\encoder/encr/q_m_reg [8]), 
            .I3(n1022), .O(n1023)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heef0 */ ;
    defparam LUT__2377.LUTMASK = 16'heef0;
    EFX_LUT4 LUT__2378 (.I0(\encoder/encr/q_m_reg [7]), .I1(n1023), .I2(\encoder/encb/de_reg ), 
            .O(\encoder/encr/n339 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9090 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2378.LUTMASK = 16'h9090;
    EFX_LUT4 LUT__2379 (.I0(\encoder/encr/q_m_reg [6]), .I1(n1023), .I2(\encoder/encb/de_reg ), 
            .O(\encoder/encr/n339 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9f9f */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2379.LUTMASK = 16'h9f9f;
    EFX_LUT4 LUT__2380 (.I0(\encoder/encr/q_m_reg [5]), .I1(n1023), .I2(\encoder/encb/de_reg ), 
            .O(\encoder/encr/n339 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9090 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2380.LUTMASK = 16'h9090;
    EFX_LUT4 LUT__2382 (.I0(\encoder/encr/n1d [3]), .I1(\encoder/encr/n1d [1]), 
            .O(\encoder/encr/q_m [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(101)
    defparam LUT__2382.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2383 (.I0(\encoder/encr/din_q [6]), .I1(\encoder/encr/din_q [0]), 
            .I2(\encoder/encr/q_m [5]), .O(\encoder/encr/q_m [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9696 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(101)
    defparam LUT__2383.LUTMASK = 16'h9696;
    EFX_LUT4 LUT__2384 (.I0(\encoder/encb/de_reg ), .I1(n1023), .O(\encoder/encr/n339 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7777 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2384.LUTMASK = 16'h7777;
    EFX_LUT4 LUT__2385 (.I0(\encoder/encr/q_m_reg [8]), .I1(\encoder/encb/de_reg ), 
            .O(\encoder/encr/n339 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hbbbb */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2385.LUTMASK = 16'hbbbb;
    EFX_LUT4 LUT__2386 (.I0(\encoder/encr/n273 [0]), .I1(\encoder/encr/n292 [0]), 
            .I2(n1018), .I3(n1016), .O(n1025)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2386.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2387 (.I0(n1025), .I1(\encoder/encr/n238 [0]), .I2(n1022), 
            .I3(\encoder/encb/de_reg ), .O(\encoder/encr/n350 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5c00 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2387.LUTMASK = 16'h5c00;
    EFX_LUT4 LUT__2388 (.I0(\encoder/encr/q_m_reg [4]), .I1(n1023), .I2(\encoder/encb/de_reg ), 
            .O(\encoder/encr/n339 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9f9f */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2388.LUTMASK = 16'h9f9f;
    EFX_LUT4 LUT__2393 (.I0(\encoder/encr/q_m_reg [4]), .I1(n1023), .I2(\encoder/encb/de_reg ), 
            .O(\encoder/encr/n339 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9090 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2393.LUTMASK = 16'h9090;
    EFX_LUT4 LUT__2394 (.I0(\encoder/encr/n273 [1]), .I1(\encoder/encr/n292 [1]), 
            .I2(n1018), .I3(n1016), .O(n1026)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2394.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2395 (.I0(\encoder/encr/n225 [1]), .I1(\encoder/encr/n238 [1]), 
            .I2(\encoder/encr/q_m_reg [8]), .O(n1027)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2395.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2396 (.I0(n1027), .I1(n1026), .I2(n1022), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encr/n350 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2396.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2397 (.I0(\encoder/encr/n273 [2]), .I1(\encoder/encr/n292 [2]), 
            .I2(n1018), .I3(n1016), .O(n1028)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2397.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2398 (.I0(\encoder/encr/n225 [2]), .I1(\encoder/encr/n238 [2]), 
            .I2(\encoder/encr/q_m_reg [8]), .O(n1029)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2398.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2399 (.I0(n1029), .I1(n1028), .I2(n1022), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encr/n350 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2399.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2400 (.I0(\encoder/encr/n273 [3]), .I1(\encoder/encr/n292 [3]), 
            .I2(n1018), .I3(n1016), .O(n1030)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2400.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2401 (.I0(\encoder/encr/n225 [3]), .I1(\encoder/encr/n238 [3]), 
            .I2(\encoder/encr/q_m_reg [8]), .O(n1031)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2401.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2402 (.I0(n1031), .I1(n1030), .I2(n1022), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encr/n350 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2402.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2403 (.I0(\encoder/encr/n273 [4]), .I1(\encoder/encr/n292 [4]), 
            .I2(n1018), .I3(n1016), .O(n1032)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2403.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2404 (.I0(\encoder/encr/n225 [4]), .I1(\encoder/encr/n238 [4]), 
            .I2(\encoder/encr/q_m_reg [8]), .O(n1033)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2404.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2405 (.I0(n1033), .I1(n1032), .I2(n1022), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encr/n350 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2405.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2406 (.I0(\encoder/encr/din_q [6]), .I1(\encoder/encr/din_q [0]), 
            .I2(\encoder/encr/q_m [5]), .O(\encoder/encr/n505 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4242 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2406.LUTMASK = 16'h4242;
    EFX_LUT4 LUT__2407 (.I0(\encoder/encr/din_q [6]), .I1(\encoder/encr/din_q [0]), 
            .I2(\encoder/encr/q_m [5]), .O(\encoder/encr/n510 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7c7c */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2407.LUTMASK = 16'h7c7c;
    EFX_LUT4 LUT__2408 (.I0(\encoder/encr/din_q [6]), .I1(\encoder/encr/din_q [0]), 
            .I2(\encoder/encr/q_m [5]), .O(\encoder/encr/n515 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2408.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2409 (.I0(\encoder/encr/din_q [6]), .I1(\encoder/encr/din_q [0]), 
            .I2(\encoder/encr/q_m [5]), .O(\encoder/encr/n601 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3e3e */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2409.LUTMASK = 16'h3e3e;
    EFX_LUT4 LUT__2410 (.I0(\encoder/encr/din_q [6]), .I1(\encoder/encr/din_q [0]), 
            .I2(\encoder/encr/q_m [5]), .O(\encoder/encr/n606 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2410.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2411 (.I0(g[6]), .I1(g[0]), .O(\encoder/encr/n464 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2411.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2412 (.I0(g[0]), .I1(g[6]), .O(\encoder/encr/n474 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2412.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2413 (.I0(\encoder/encg/n1q_m [1]), .I1(\encoder/encg/n1q_m [2]), 
            .I2(\encoder/encg/n0q_m [2]), .O(n1034)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7171 */ ;
    defparam LUT__2413.LUTMASK = 16'h7171;
    EFX_LUT4 LUT__2414 (.I0(\encoder/encg/n1q_m [3]), .I1(n1034), .I2(\encoder/encg/n0q_m [3]), 
            .I3(\encoder/encg/cnt [4]), .O(n1035)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h00d4 */ ;
    defparam LUT__2414.LUTMASK = 16'h00d4;
    EFX_LUT4 LUT__2415 (.I0(\encoder/encg/n1q_m [2]), .I1(\encoder/encg/n1q_m [1]), 
            .I2(\encoder/encg/n0q_m [2]), .O(n1036)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h2b2b */ ;
    defparam LUT__2415.LUTMASK = 16'h2b2b;
    EFX_LUT4 LUT__2416 (.I0(\encoder/encg/n1q_m [3]), .I1(\encoder/encg/n0q_m [3]), 
            .I2(n1036), .I3(\encoder/encg/cnt [4]), .O(n1037)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hb200 */ ;
    defparam LUT__2416.LUTMASK = 16'hb200;
    EFX_LUT4 LUT__2417 (.I0(\encoder/encg/cnt [0]), .I1(\encoder/encg/cnt [1]), 
            .I2(\encoder/encg/cnt [2]), .I3(\encoder/encg/cnt [3]), .O(n1038)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2417.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2419 (.I0(\encoder/encg/n1q_m [2]), .I1(\encoder/encg/n0q_m [2]), 
            .I2(\encoder/encg/n1q_m [3]), .I3(\encoder/encg/n0q_m [3]), 
            .O(n1040)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9009 */ ;
    defparam LUT__2419.LUTMASK = 16'h9009;
    EFX_LUT4 LUT__2420 (.I0(n1040), .I1(\encoder/encg/cnt [4]), .I2(n1038), 
            .O(n1041)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4545 */ ;
    defparam LUT__2420.LUTMASK = 16'h4545;
    EFX_LUT4 LUT__2421 (.I0(n1037), .I1(n1035), .I2(\encoder/encg/q_m_reg [8]), 
            .I3(n1041), .O(n1042)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heef0 */ ;
    defparam LUT__2421.LUTMASK = 16'heef0;
    EFX_LUT4 LUT__2422 (.I0(\encoder/encg/q_m_reg [7]), .I1(n1042), .I2(\encoder/encb/de_reg ), 
            .O(\encoder/encg/n339 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9090 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2422.LUTMASK = 16'h9090;
    EFX_LUT4 LUT__2423 (.I0(\encoder/encg/q_m_reg [6]), .I1(n1042), .I2(\encoder/encb/de_reg ), 
            .O(\encoder/encg/n339 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9f9f */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2423.LUTMASK = 16'h9f9f;
    EFX_LUT4 LUT__2424 (.I0(\encoder/encg/q_m_reg [5]), .I1(n1042), .I2(\encoder/encb/de_reg ), 
            .O(\encoder/encg/n339 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9090 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2424.LUTMASK = 16'h9090;
    EFX_LUT4 LUT__2426 (.I0(\encoder/encg/n1d [3]), .I1(\encoder/encg/n1d [1]), 
            .O(\encoder/encg/q_m [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'heeee */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(101)
    defparam LUT__2426.LUTMASK = 16'heeee;
    EFX_LUT4 LUT__2427 (.I0(\encoder/encg/cnt [2]), .I1(\encoder/encg/cnt [3]), 
            .O(n1044)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;
    defparam LUT__2427.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2428 (.I0(\encoder/encg/q_m_reg [8]), .I1(\encoder/encg/cnt [1]), 
            .I2(n1044), .I3(\encoder/encg/cnt [4]), .O(\encoder/encg/n626 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hef10 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2428.LUTMASK = 16'hef10;
    EFX_LUT4 LUT__2429 (.I0(\encoder/encg/q_m_reg [8]), .I1(\encoder/encg/cnt [1]), 
            .I2(\encoder/encg/cnt [2]), .I3(\encoder/encg/cnt [3]), .O(\encoder/encg/n621 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hfe01 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2429.LUTMASK = 16'hfe01;
    EFX_LUT4 LUT__2430 (.I0(\encoder/encg/din_q [6]), .I1(\encoder/encg/din_q [0]), 
            .I2(\encoder/encg/q_m [5]), .O(\encoder/encg/q_m [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9696 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(101)
    defparam LUT__2430.LUTMASK = 16'h9696;
    EFX_LUT4 LUT__2431 (.I0(\encoder/encb/de_reg ), .I1(n1042), .O(\encoder/encg/n339 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7777 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2431.LUTMASK = 16'h7777;
    EFX_LUT4 LUT__2432 (.I0(\encoder/encg/q_m_reg [8]), .I1(\encoder/encg/cnt [1]), 
            .I2(\encoder/encg/cnt [2]), .O(\encoder/encg/n616 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he1e1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2432.LUTMASK = 16'he1e1;
    EFX_LUT4 LUT__2433 (.I0(\encoder/encg/q_m_reg [8]), .I1(\encoder/encb/de_reg ), 
            .O(\encoder/encg/n339 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hbbbb */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2433.LUTMASK = 16'hbbbb;
    EFX_LUT4 LUT__2434 (.I0(\encoder/encg/n273 [0]), .I1(\encoder/encg/n292 [0]), 
            .I2(n1037), .I3(n1035), .O(n1045)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2434.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2435 (.I0(n1045), .I1(\encoder/encg/n238 [0]), .I2(n1041), 
            .I3(\encoder/encb/de_reg ), .O(\encoder/encg/n350 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5c00 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2435.LUTMASK = 16'h5c00;
    EFX_LUT4 LUT__2436 (.I0(\encoder/encg/q_m_reg [8]), .I1(\encoder/encg/cnt [1]), 
            .O(\encoder/encg/n694 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2436.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2437 (.I0(\encoder/encg/q_m_reg [4]), .I1(n1042), .I2(\encoder/encb/de_reg ), 
            .O(\encoder/encg/n339 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9f9f */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2437.LUTMASK = 16'h9f9f;
    EFX_LUT4 LUT__2442 (.I0(\encoder/encg/q_m_reg [4]), .I1(n1042), .I2(\encoder/encb/de_reg ), 
            .O(\encoder/encg/n339 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9090 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2442.LUTMASK = 16'h9090;
    EFX_LUT4 LUT__2443 (.I0(\encoder/encg/n273 [1]), .I1(\encoder/encg/n292 [1]), 
            .I2(n1037), .I3(n1035), .O(n1046)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2443.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2444 (.I0(\encoder/encg/n225 [1]), .I1(\encoder/encg/n238 [1]), 
            .I2(\encoder/encg/q_m_reg [8]), .O(n1047)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2444.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2445 (.I0(n1047), .I1(n1046), .I2(n1041), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encg/n350 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2445.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2446 (.I0(\encoder/encg/n273 [2]), .I1(\encoder/encg/n292 [2]), 
            .I2(n1037), .I3(n1035), .O(n1048)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2446.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2447 (.I0(\encoder/encg/n225 [2]), .I1(\encoder/encg/n238 [2]), 
            .I2(\encoder/encg/q_m_reg [8]), .O(n1049)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2447.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2448 (.I0(n1049), .I1(n1048), .I2(n1041), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encg/n350 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2448.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2449 (.I0(\encoder/encg/n273 [3]), .I1(\encoder/encg/n292 [3]), 
            .I2(n1037), .I3(n1035), .O(n1050)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2449.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2450 (.I0(\encoder/encg/n225 [3]), .I1(\encoder/encg/n238 [3]), 
            .I2(\encoder/encg/q_m_reg [8]), .O(n1051)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2450.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2451 (.I0(n1051), .I1(n1050), .I2(n1041), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encg/n350 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2451.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2452 (.I0(\encoder/encg/n273 [4]), .I1(\encoder/encg/n292 [4]), 
            .I2(n1037), .I3(n1035), .O(n1052)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3335 */ ;
    defparam LUT__2452.LUTMASK = 16'h3335;
    EFX_LUT4 LUT__2453 (.I0(\encoder/encg/n225 [4]), .I1(\encoder/encg/n238 [4]), 
            .I2(\encoder/encg/q_m_reg [8]), .O(n1053)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3535 */ ;
    defparam LUT__2453.LUTMASK = 16'h3535;
    EFX_LUT4 LUT__2454 (.I0(n1053), .I1(n1052), .I2(n1041), .I3(\encoder/encb/de_reg ), 
            .O(\encoder/encg/n350 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3500 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(187)
    defparam LUT__2454.LUTMASK = 16'h3500;
    EFX_LUT4 LUT__2455 (.I0(\encoder/encg/din_q [6]), .I1(\encoder/encg/din_q [0]), 
            .I2(\encoder/encg/q_m [5]), .O(\encoder/encg/n505 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4242 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2455.LUTMASK = 16'h4242;
    EFX_LUT4 LUT__2456 (.I0(\encoder/encg/din_q [6]), .I1(\encoder/encg/din_q [0]), 
            .I2(\encoder/encg/q_m [5]), .O(\encoder/encg/n510 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7c7c */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2456.LUTMASK = 16'h7c7c;
    EFX_LUT4 LUT__2457 (.I0(\encoder/encg/din_q [6]), .I1(\encoder/encg/din_q [0]), 
            .I2(\encoder/encg/q_m [5]), .O(\encoder/encg/n515 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2457.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2458 (.I0(\encoder/encg/din_q [6]), .I1(\encoder/encg/din_q [0]), 
            .I2(\encoder/encg/q_m [5]), .O(\encoder/encg/n601 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h3e3e */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2458.LUTMASK = 16'h3e3e;
    EFX_LUT4 LUT__2459 (.I0(\encoder/encg/din_q [6]), .I1(\encoder/encg/din_q [0]), 
            .I2(\encoder/encg/q_m [5]), .O(\encoder/encg/n606 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2459.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2460 (.I0(r[6]), .I1(r[0]), .O(\encoder/encg/n464 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2460.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2461 (.I0(r[0]), .I1(r[6]), .O(\encoder/encg/n474 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(41)
    defparam LUT__2461.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2462 (.I0(\pattern/x [0]), .I1(\pattern/x [1]), .I2(\pattern/x [10]), 
            .I3(\pattern/x [11]), .O(n1054)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2462.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2463 (.I0(\pattern/x [5]), .I1(\pattern/x [6]), .I2(\pattern/x [8]), 
            .I3(\pattern/x [9]), .O(n1055)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2463.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2464 (.I0(\pattern/x [2]), .I1(\pattern/x [4]), .I2(\pattern/x [7]), 
            .O(n1056)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;
    defparam LUT__2464.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2465 (.I0(\pattern/x [3]), .I1(n1054), .I2(n1055), .I3(n1056), 
            .O(n1057)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4000 */ ;
    defparam LUT__2465.LUTMASK = 16'h4000;
    EFX_LUT4 LUT__2466 (.I0(\pattern/y [9]), .I1(\pattern/y [11]), .I2(\pattern/y [10]), 
            .O(n1058)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1010 */ ;
    defparam LUT__2466.LUTMASK = 16'h1010;
    EFX_LUT4 LUT__2467 (.I0(\pattern/y [3]), .I1(\pattern/y [4]), .I2(\pattern/y [5]), 
            .O(n1059)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2467.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2468 (.I0(\pattern/y [6]), .I1(\pattern/y [7]), .I2(\pattern/y [8]), 
            .O(n1060)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0101 */ ;
    defparam LUT__2468.LUTMASK = 16'h0101;
    EFX_LUT4 LUT__2469 (.I0(\pattern/y [0]), .I1(\pattern/y [2]), .I2(n1059), 
            .I3(n1060), .O(n1061)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2469.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2470 (.I0(\pattern/y [1]), .I1(n1057), .I2(n1058), .I3(n1061), 
            .O(\pattern/n114 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4000 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(30)
    defparam LUT__2470.LUTMASK = 16'h4000;
    EFX_LUT4 LUT__2471 (.I0(frames[2]), .I1(\pattern/x [8]), .I2(\pattern/x [6]), 
            .I3(frames[0]), .O(n1062)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9009 */ ;
    defparam LUT__2471.LUTMASK = 16'h9009;
    EFX_LUT4 LUT__2472 (.I0(frames[3]), .I1(\pattern/x [9]), .I2(\pattern/x [7]), 
            .I3(frames[1]), .O(n1063)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9009 */ ;
    defparam LUT__2472.LUTMASK = 16'h9009;
    EFX_LUT4 LUT__2473 (.I0(\pattern/x [10]), .I1(\pattern/x [11]), .O(n1064)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;
    defparam LUT__2473.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2474 (.I0(\pattern/y [10]), .I1(\pattern/y [11]), .I2(\pattern/y [9]), 
            .I3(n1064), .O(n1065)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2474.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2475 (.I0(n1060), .I1(n1062), .I2(n1063), .I3(n1065), 
            .O(n1066)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2475.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2476 (.I0(\pattern/x [6]), .I1(\pattern/x [7]), .I2(\pattern/x [8]), 
            .I3(\pattern/x [9]), .O(n1067)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2476.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2477 (.I0(\pattern/x [5]), .I1(\pattern/x [6]), .I2(\pattern/x [10]), 
            .O(n1068)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1717 */ ;
    defparam LUT__2477.LUTMASK = 16'h1717;
    EFX_LUT4 LUT__2478 (.I0(n1068), .I1(\pattern/x [8]), .I2(\pattern/x [7]), 
            .I3(\pattern/x [9]), .O(n1069)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h00bf */ ;
    defparam LUT__2478.LUTMASK = 16'h00bf;
    EFX_LUT4 LUT__2479 (.I0(\pattern/x [10]), .I1(n1067), .I2(n1069), 
            .I3(\pattern/x [11]), .O(n1070)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h00f4 */ ;
    defparam LUT__2479.LUTMASK = 16'h00f4;
    EFX_LUT4 LUT__2480 (.I0(\pattern/y [4]), .I1(\pattern/y [5]), .O(n1071)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2480.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2481 (.I0(\pattern/y [3]), .I1(\pattern/y [1]), .I2(\pattern/y [2]), 
            .I3(\pattern/y [0]), .O(n1072)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4000 */ ;
    defparam LUT__2481.LUTMASK = 16'h4000;
    EFX_LUT4 LUT__2482 (.I0(n1058), .I1(n1071), .I2(n1060), .I3(n1072), 
            .O(n1073)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2482.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2483 (.I0(\pattern/x [11]), .I1(\pattern/x [9]), .I2(\pattern/x [10]), 
            .I3(\pattern/x [6]), .O(n1074)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4000 */ ;
    defparam LUT__2483.LUTMASK = 16'h4000;
    EFX_LUT4 LUT__2484 (.I0(\pattern/x [0]), .I1(\pattern/x [1]), .I2(\pattern/x [2]), 
            .I3(\pattern/x [4]), .O(n1075)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2484.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2485 (.I0(\pattern/x [7]), .I1(\pattern/x [5]), .I2(\pattern/x [3]), 
            .I3(\pattern/x [8]), .O(n1076)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4000 */ ;
    defparam LUT__2485.LUTMASK = 16'h4000;
    EFX_LUT4 LUT__2486 (.I0(n1074), .I1(n1075), .I2(n1076), .O(n1077)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8080 */ ;
    defparam LUT__2486.LUTMASK = 16'h8080;
    EFX_LUT4 LUT__2487 (.I0(\pattern/y [1]), .I1(\pattern/y [2]), .I2(\pattern/y [4]), 
            .I3(\pattern/y [5]), .O(n1078)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2487.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2488 (.I0(\pattern/y [0]), .I1(\pattern/y [3]), .I2(\pattern/y [10]), 
            .I3(\pattern/y [11]), .O(n1079)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2488.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2489 (.I0(\pattern/y [9]), .I1(n1060), .I2(n1078), .I3(n1079), 
            .O(n1080)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4000 */ ;
    defparam LUT__2489.LUTMASK = 16'h4000;
    EFX_LUT4 LUT__2490 (.I0(n1057), .I1(n1073), .I2(n1077), .I3(n1080), 
            .O(n1081)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;
    defparam LUT__2490.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2491 (.I0(n1066), .I1(n1070), .I2(n1081), .O(\pattern/n236 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4f4f */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(42)
    defparam LUT__2491.LUTMASK = 16'h4f4f;
    EFX_LUT4 LUT__2492 (.I0(\pattern/y [9]), .I1(n1059), .I2(n1060), .I3(\pattern/y [10]), 
            .O(n1082)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hef00 */ ;
    defparam LUT__2492.LUTMASK = 16'hef00;
    EFX_LUT4 LUT__2493 (.I0(\pattern/x [7]), .I1(\pattern/x [8]), .I2(\pattern/x [9]), 
            .I3(\pattern/x [10]), .O(n1083)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8000 */ ;
    defparam LUT__2493.LUTMASK = 16'h8000;
    EFX_LUT4 LUT__2494 (.I0(\pattern/y [11]), .I1(\pattern/x [11]), .I2(n1082), 
            .I3(n1083), .O(\pattern/n187 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0001 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(32)
    defparam LUT__2494.LUTMASK = 16'h0001;
    EFX_LUT4 LUT__2495 (.I0(reset_pipe[2]), .I1(\pattern/n187 ), .O(\pattern/n567 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(18)
    defparam LUT__2495.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2496 (.I0(\pattern/y [4]), .I1(\pattern/y [7]), .I2(\pattern/y [8]), 
            .I3(\pattern/y [5]), .O(n1084)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;
    defparam LUT__2496.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2497 (.I0(\pattern/y [0]), .I1(\pattern/y [3]), .I2(\pattern/y [6]), 
            .I3(n1084), .O(n1085)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2497.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2498 (.I0(\pattern/y [1]), .I1(\pattern/y [2]), .I2(n1058), 
            .I3(n1085), .O(n1086)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4000 */ ;
    defparam LUT__2498.LUTMASK = 16'h4000;
    EFX_LUT4 LUT__2499 (.I0(\pattern/y [0]), .I1(n1086), .O(\pattern/n59 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2499.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2500 (.I0(\pattern/x [3]), .I1(n1055), .O(n1087)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__2500.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2501 (.I0(\pattern/x [10]), .I1(\pattern/x [11]), .O(n1088)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;
    defparam LUT__2501.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2502 (.I0(\pattern/x [7]), .I1(n1087), .I2(n1075), .I3(n1088), 
            .O(\pattern/equal_24/n23 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7fff */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2502.LUTMASK = 16'h7fff;
    EFX_LUT4 LUT__2503 (.I0(reset_pipe[2]), .I1(\pattern/equal_24/n23 ), 
            .O(\pattern/n561 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h7777 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(29)
    defparam LUT__2503.LUTMASK = 16'h7777;
    EFX_LUT4 LUT__2504 (.I0(n1067), .I1(n1066), .I2(n1064), .I3(n1081), 
            .O(\pattern/n245 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h10ff */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(42)
    defparam LUT__2504.LUTMASK = 16'h10ff;
    EFX_LUT4 LUT__2505 (.I0(\pattern/x [5]), .I1(\pattern/x [9]), .I2(\pattern/x [6]), 
            .I3(\pattern/x [8]), .O(n1089)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h320f */ ;
    defparam LUT__2505.LUTMASK = 16'h320f;
    EFX_LUT4 LUT__2506 (.I0(\pattern/x [4]), .I1(\pattern/x [5]), .I2(\pattern/x [9]), 
            .O(n1090)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1717 */ ;
    defparam LUT__2506.LUTMASK = 16'h1717;
    EFX_LUT4 LUT__2507 (.I0(n1090), .I1(\pattern/x [7]), .I2(n1089), .I3(\pattern/x [8]), 
            .O(n1091)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hc0b3 */ ;
    defparam LUT__2507.LUTMASK = 16'hc0b3;
    EFX_LUT4 LUT__2508 (.I0(n1067), .I1(\pattern/x [10]), .I2(\pattern/x [11]), 
            .O(n1092)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0e0e */ ;
    defparam LUT__2508.LUTMASK = 16'h0e0e;
    EFX_LUT4 LUT__2509 (.I0(\pattern/x [4]), .I1(\pattern/x [8]), .I2(\pattern/x [9]), 
            .I3(\pattern/x [5]), .O(n1093)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h01df */ ;
    defparam LUT__2509.LUTMASK = 16'h01df;
    EFX_LUT4 LUT__2510 (.I0(\pattern/x [6]), .I1(\pattern/x [7]), .O(n1094)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h8888 */ ;
    defparam LUT__2510.LUTMASK = 16'h8888;
    EFX_LUT4 LUT__2511 (.I0(n1093), .I1(n1094), .I2(\pattern/x [8]), .I3(n1064), 
            .O(n1095)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4b00 */ ;
    defparam LUT__2511.LUTMASK = 16'h4b00;
    EFX_LUT4 LUT__2512 (.I0(n1091), .I1(\pattern/x [10]), .I2(n1092), 
            .I3(n1095), .O(n1096)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h004f */ ;
    defparam LUT__2512.LUTMASK = 16'h004f;
    EFX_LUT4 LUT__2513 (.I0(n1066), .I1(n1096), .I2(n1081), .O(\pattern/n254 [0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1f1f */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(42)
    defparam LUT__2513.LUTMASK = 16'h1f1f;
    EFX_LUT4 LUT__2514 (.I0(\pattern/x [4]), .I1(\pattern/x [3]), .I2(\pattern/x [5]), 
            .O(n1097)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0707 */ ;
    defparam LUT__2514.LUTMASK = 16'h0707;
    EFX_LUT4 LUT__2515 (.I0(\pattern/x [11]), .I1(n1097), .I2(n1083), 
            .I3(\pattern/x [6]), .O(n1098)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2515.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2516 (.I0(n1087), .I1(n1056), .I2(n1088), .I3(n1098), 
            .O(\pattern/n190 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hff80 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(33)
    defparam LUT__2516.LUTMASK = 16'hff80;
    EFX_LUT4 LUT__2517 (.I0(\pattern/y [0]), .I1(\pattern/y [3]), .I2(\pattern/y [6]), 
            .I3(n1078), .O(n1099)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1000 */ ;
    defparam LUT__2517.LUTMASK = 16'h1000;
    EFX_LUT4 LUT__2518 (.I0(\pattern/y [6]), .I1(n1059), .I2(\pattern/y [2]), 
            .I3(n1099), .O(n1100)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h00bf */ ;
    defparam LUT__2518.LUTMASK = 16'h00bf;
    EFX_LUT4 LUT__2519 (.I0(\pattern/y [7]), .I1(\pattern/y [8]), .I2(n1100), 
            .I3(n1058), .O(\pattern/n193 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h0100 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(34)
    defparam LUT__2519.LUTMASK = 16'h0100;
    EFX_LUT4 LUT__2520 (.I0(n1086), .I1(\pattern/n46 [1]), .O(\pattern/n59 [1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2520.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2521 (.I0(n1086), .I1(\pattern/n46 [2]), .O(\pattern/n59 [2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2521.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2522 (.I0(n1086), .I1(\pattern/n46 [3]), .O(\pattern/n59 [3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2522.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2523 (.I0(n1086), .I1(\pattern/n46 [4]), .O(\pattern/n59 [4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2523.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2524 (.I0(n1086), .I1(\pattern/n46 [5]), .O(\pattern/n59 [5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2524.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2525 (.I0(n1086), .I1(\pattern/n46 [6]), .O(\pattern/n59 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2525.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2526 (.I0(n1086), .I1(\pattern/n46 [7]), .O(\pattern/n59 [7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2526.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2527 (.I0(n1086), .I1(\pattern/n46 [8]), .O(\pattern/n59 [8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2527.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2528 (.I0(n1086), .I1(\pattern/n46 [9]), .O(\pattern/n59 [9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2528.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2529 (.I0(n1086), .I1(\pattern/n46 [10]), .O(\pattern/n59 [10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2529.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2530 (.I0(n1086), .I1(\pattern/n46 [11]), .O(\pattern/n59 [11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h4444 */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(28)
    defparam LUT__2530.LUTMASK = 16'h4444;
    EFX_LUT4 LUT__2531 (.I0(\encoder/encr/cnt [2]), .I1(\encoder/encr/cnt [3]), 
            .O(n1101)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;
    defparam LUT__2531.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2532 (.I0(\encoder/encr/q_m_reg [8]), .I1(\encoder/encr/cnt [1]), 
            .I2(n1101), .I3(\encoder/encr/cnt [4]), .O(\encoder/encr/n626 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hef10 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2532.LUTMASK = 16'hef10;
    EFX_LUT4 LUT__2533 (.I0(\encoder/encr/q_m_reg [8]), .I1(\encoder/encr/cnt [1]), 
            .I2(\encoder/encr/cnt [2]), .I3(\encoder/encr/cnt [3]), .O(\encoder/encr/n621 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hfe01 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2533.LUTMASK = 16'hfe01;
    EFX_LUT4 LUT__2534 (.I0(\encoder/encr/q_m_reg [8]), .I1(\encoder/encr/cnt [1]), 
            .I2(\encoder/encr/cnt [2]), .O(\encoder/encr/n616 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he1e1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2534.LUTMASK = 16'he1e1;
    EFX_LUT4 LUT__2535 (.I0(\encoder/encr/q_m_reg [8]), .I1(\encoder/encr/cnt [1]), 
            .O(\encoder/encr/n694 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(32)
    defparam LUT__2535.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2536 (.I0(\encoder/encb/cnt [2]), .I1(\encoder/encb/cnt [3]), 
            .O(n1102)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;
    defparam LUT__2536.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2537 (.I0(\encoder/encb/q_m_reg [8]), .I1(\encoder/encb/cnt [1]), 
            .I2(n1102), .I3(\encoder/encb/cnt [4]), .O(\encoder/encb/n626 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hef10 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2537.LUTMASK = 16'hef10;
    EFX_LUT4 LUT__2538 (.I0(\encoder/encb/q_m_reg [8]), .I1(\encoder/encb/cnt [1]), 
            .I2(\encoder/encb/cnt [2]), .I3(\encoder/encb/cnt [3]), .O(\encoder/encb/n621 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hfe01 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2538.LUTMASK = 16'hfe01;
    EFX_LUT4 LUT__2539 (.I0(\encoder/encb/q_m_reg [8]), .I1(\encoder/encb/cnt [1]), 
            .I2(\encoder/encb/cnt [2]), .O(\encoder/encb/n616 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'he1e1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2539.LUTMASK = 16'he1e1;
    EFX_LUT4 LUT__2540 (.I0(\encoder/encb/q_m_reg [8]), .I1(\encoder/encb/cnt [1]), 
            .O(\encoder/encb/n694 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h9999 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\dvi_encoder.v(23)
    defparam LUT__2540.LUTMASK = 16'h9999;
    EFX_LUT4 LUT__2541 (.I0(n1070), .I1(n1066), .I2(n1081), .O(\pattern/n236 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hefef */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(42)
    defparam LUT__2541.LUTMASK = 16'hefef;
    EFX_LUT4 LUT__2542 (.I0(n1067), .I1(n1064), .I2(n1066), .I3(n1081), 
            .O(\pattern/n245 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hf4ff */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(42)
    defparam LUT__2542.LUTMASK = 16'hf4ff;
    EFX_LUT4 LUT__2543 (.I0(n1066), .I1(n1081), .I2(n1096), .O(\pattern/n254 [6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hbfbf */ ;   // F:\Project\fpga\vision_base\rtl\video_test_pattern.sv(42)
    defparam LUT__2543.LUTMASK = 16'hbfbf;
    EFX_LUT4 LUT__2544 (.I0(debug_shift[2]), .I1(status_sync[1]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_3[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2544.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2545 (.I0(debug_shift[3]), .I1(status_sync[2]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_4[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2545.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2546 (.I0(debug_shift[4]), .I1(status_sync[3]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_5[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2546.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2547 (.I0(debug_shift[5]), .I1(status_sync[4]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_6[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2547.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2548 (.I0(debug_shift[6]), .I1(status_sync[5]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_7[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2548.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2549 (.I0(debug_shift[7]), .I1(status_sync[6]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_8[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2549.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2550 (.I0(debug_shift[8]), .I1(status_sync[7]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_9[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2550.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2551 (.I0(debug_shift[9]), .I1(status_sync[8]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_10[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2551.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2552 (.I0(debug_shift[10]), .I1(status_sync[9]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_11[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2552.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2553 (.I0(debug_shift[11]), .I1(status_sync[10]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_12[10])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2553.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2554 (.I0(debug_shift[12]), .I1(status_sync[11]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_13[11])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2554.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2555 (.I0(debug_shift[13]), .I1(status_sync[12]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_14[12])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2555.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2556 (.I0(debug_shift[14]), .I1(status_sync[13]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_15[13])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2556.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2557 (.I0(debug_shift[15]), .I1(status_sync[14]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_16[14])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2557.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2558 (.I0(debug_shift[16]), .I1(status_sync[15]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_17[15])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2558.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2559 (.I0(debug_shift[17]), .I1(status_sync[16]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_18[16])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2559.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2560 (.I0(debug_shift[18]), .I1(status_sync[17]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_19[17])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2560.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2561 (.I0(debug_shift[19]), .I1(status_sync[18]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_20[18])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2561.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2562 (.I0(debug_shift[20]), .I1(status_sync[19]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_21[19])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2562.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2563 (.I0(debug_shift[21]), .I1(status_sync[20]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_22[20])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2563.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2564 (.I0(debug_shift[22]), .I1(status_sync[21]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_23[21])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2564.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2565 (.I0(debug_shift[23]), .I1(status_sync[22]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_24[22])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2565.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2566 (.I0(debug_shift[24]), .I1(status_sync[23]), .I2(jtag_inst1_CAPTURE), 
            .O(n420_25[23])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'hcaca */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(40)
    defparam LUT__2566.LUTMASK = 16'hcaca;
    EFX_LUT4 LUT__2567 (.I0(reference_ticks[18]), .I1(reference_ticks[19]), 
            .O(n281[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam LUT__2567.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2568 (.I0(reference_ticks[19]), .I1(reference_ticks[20]), 
            .O(n281[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam LUT__2568.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2569 (.I0(reference_ticks[20]), .I1(reference_ticks[21]), 
            .O(n281[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam LUT__2569.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2570 (.I0(reference_ticks[21]), .I1(reference_ticks[22]), 
            .O(n281[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam LUT__2570.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2571 (.I0(reference_ticks[22]), .I1(reference_ticks[23]), 
            .O(n281[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam LUT__2571.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2572 (.I0(reference_ticks[23]), .I1(led0), .O(n281[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(29)
    defparam LUT__2572.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2573 (.I0(ref27_ticks[18]), .I1(ref27_ticks[19]), .O(n300[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam LUT__2573.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2574 (.I0(ref27_ticks[19]), .I1(ref27_ticks[20]), .O(n300[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam LUT__2574.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2575 (.I0(ref27_ticks[20]), .I1(ref27_ticks[21]), .O(n300[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam LUT__2575.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2576 (.I0(ref27_ticks[21]), .I1(ref27_ticks[22]), .O(n300[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam LUT__2576.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2577 (.I0(ref27_ticks[22]), .I1(ref27_ticks[23]), .O(n300[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam LUT__2577.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2578 (.I0(ref27_ticks[23]), .I1(ref27_ticks[24]), .O(n300[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(30)
    defparam LUT__2578.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2579 (.I0(frames[2]), .I1(frames[1]), .O(n319_3[1])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam LUT__2579.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2580 (.I0(frames[3]), .I1(frames[2]), .O(n319_4[2])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam LUT__2580.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2581 (.I0(frames[4]), .I1(frames[3]), .O(n319_5[3])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam LUT__2581.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2582 (.I0(led1), .I1(frames[4]), .O(n319_6[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam LUT__2582.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2583 (.I0(frames[6]), .I1(led1), .O(n319_7[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h6666 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(31)
    defparam LUT__2583.LUTMASK = 16'h6666;
    EFX_LUT4 LUT__2607 (.I0(d0[9]), .O(tmds_data0_o[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2607.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2608 (.I0(d0[8]), .O(tmds_data0_o[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2608.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2609 (.I0(d0[7]), .O(tmds_data0_o[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2609.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2610 (.I0(d0[6]), .O(tmds_data0_o[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2610.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2611 (.I0(d0[5]), .O(tmds_data0_o[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2611.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2612 (.I0(d0[4]), .O(tmds_data0_o[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2612.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2616 (.I0(d0[0]), .O(tmds_data0_o[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2616.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2617 (.I0(d1[9]), .O(tmds_data1_o[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2617.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2321 (.I0(jtag_inst1_CAPTURE), .I1(jtag_inst1_SHIFT), 
            .O(ceg_net2)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h1111 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(3)
    defparam LUT__2321.LUTMASK = 16'h1111;
    EFX_LUT4 LUT__2618 (.I0(d1[8]), .O(tmds_data1_o[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2618.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2619 (.I0(d1[7]), .O(tmds_data1_o[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2619.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2620 (.I0(d1[6]), .O(tmds_data1_o[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2620.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2621 (.I0(d1[5]), .O(tmds_data1_o[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2621.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2622 (.I0(d1[4]), .O(tmds_data1_o[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2622.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2626 (.I0(d1[0]), .O(tmds_data1_o[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2626.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2627 (.I0(d2[9]), .O(tmds_data2_o[9])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2627.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2628 (.I0(d2[8]), .O(tmds_data2_o[8])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2628.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2629 (.I0(d2[7]), .O(tmds_data2_o[7])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2629.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2630 (.I0(d2[6]), .O(tmds_data2_o[6])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2630.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2631 (.I0(d2[5]), .O(tmds_data2_o[5])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2631.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2632 (.I0(d2[4]), .O(tmds_data2_o[4])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2632.LUTMASK = 16'h5555;
    EFX_LUT4 LUT__2636 (.I0(d2[0]), .O(tmds_data2_o[0])) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_LUT4, LUTMASK=16'h5555, EFX_ATTRIBUTE_INSTANCE__IS_LUT_SOP_INF_INV=TRUE */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\hdmi_bringup.sv(22)
    defparam LUT__2636.LUTMASK = 16'h5555;
    EFX_ADD \encoder/encg/sub_84/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encg/sub_84/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1134)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_84/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_84/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_82/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encg/sub_84/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1133)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_82/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_82/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_84/add_2/i1__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1132), .O(\encoder/encg/sub_84/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_84/add_2/i1__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_84/add_2/i1__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/sub_84/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1131)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/sub_84/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encg/sub_84/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_89/i1__AUX_ADD_CI  (.I0(\encoder/encg/q_m_reg [8]), 
            .I1(1'b1), .CI(1'b0), .CO(n1130)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encg/add_89/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_89/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_83/i2__AUX_ADD_CI  (.I0(\encoder/encg/add_81/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1129)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_83/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_83/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_81/i2__AUX_ADD_CI  (.I0(\encoder/encg/add_81/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1128)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_81/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_81/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encg/add_81/i1__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1127), .O(\encoder/encg/add_81/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encg/add_81/i1__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \encoder/encg/add_81/i1__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_88/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encr/sub_92/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1126)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/sub_88/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_88/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_92/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encr/sub_92/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1125)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/sub_92/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_92/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_92/add_2/i1__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1124), .O(\encoder/encr/sub_92/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/sub_92/add_2/i1__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_92/add_2/i1__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_92/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1123)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encr/sub_92/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_92/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_82/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encr/sub_84/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1122)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_82/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_82/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_84/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encr/sub_84/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1121)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_84/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_84/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_84/add_2/i1__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1120), .O(\encoder/encr/sub_84/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_84/add_2/i1__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_84/add_2/i1__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/sub_84/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1119)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/sub_84/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encr/sub_84/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_89/i1__AUX_ADD_CI  (.I0(\encoder/encr/q_m_reg [8]), 
            .I1(1'b1), .CI(1'b0), .CO(n1118)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encr/add_89/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_89/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_83/i2__AUX_ADD_CI  (.I0(\encoder/encr/add_81/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1117)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_83/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_83/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_81/i2__AUX_ADD_CI  (.I0(\encoder/encr/add_81/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1116)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_81/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_81/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encr/add_81/i1__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1115), .O(\encoder/encr/add_81/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encr/add_81/i1__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \encoder/encr/add_81/i1__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_88/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encb/sub_92/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1114)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/sub_88/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_88/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_92/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encb/sub_92/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1113)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/sub_92/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_92/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_92/add_2/i1__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1112), .O(\encoder/encb/sub_92/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/sub_92/add_2/i1__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_92/add_2/i1__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_92/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1111)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(175)
    defparam \encoder/encb/sub_92/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_92/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_82/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encb/sub_82/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1110)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_82/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_82/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_84/add_2/i2__AUX_ADD_CI  (.I0(\encoder/encb/sub_82/add_2/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1109)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_84/add_2/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_84/add_2/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_82/add_2/i1__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1108), .O(\encoder/encb/sub_82/add_2/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_82/add_2/i1__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_82/add_2/i1__AUX_ADD_CO .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/sub_82/add_2/i1__AUX_ADD_CI  (.I0(1'b1), .I1(1'b1), 
            .CI(1'b0), .CO(n1107)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/sub_82/add_2/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encb/sub_82/add_2/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_89/i1__AUX_ADD_CI  (.I0(\encoder/encb/q_m_reg [8]), 
            .I1(1'b1), .CI(1'b0), .CO(n1106)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(169)
    defparam \encoder/encb/add_89/i1__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_89/i1__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_81/i2__AUX_ADD_CI  (.I0(\encoder/encb/add_83/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1105)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_81/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_81/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_83/i2__AUX_ADD_CI  (.I0(\encoder/encb/add_83/n2 ), 
            .I1(1'b1), .CI(1'b0), .CO(n1104)) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_83/i2__AUX_ADD_CI .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_83/i2__AUX_ADD_CI .I1_POLARITY = 1'b1;
    EFX_ADD \encoder/encb/add_83/i1__AUX_ADD_CO  (.I0(1'b0), .I1(1'b0), 
            .CI(n1103), .O(\encoder/encb/add_83/n2 )) /* verific EFX_ATTRIBUTE_CELL_NAME=EFX_ADD, I0_POLARITY=1'b1, I1_POLARITY=1'b1 */ ;   // F:\Project\fpga\vision_base\board\hdmi_bringup\rtl\encode.v(162)
    defparam \encoder/encb/add_83/i1__AUX_ADD_CO .I0_POLARITY = 1'b1;
    defparam \encoder/encb/add_83/i1__AUX_ADD_CO .I1_POLARITY = 1'b1;
    
endmodule

//
// Verific Verilog Description of module EFX_ADD_8a21bc6b_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_8a21bc6b_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_8a21bc6b_1
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_8a21bc6b_2
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_8a21bc6b_3
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_8a21bc6b_4
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_8a21bc6b_5
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_8a21bc6b_6
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_FF_8a21bc6b_7
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_ADD_8a21bc6b_1
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_0
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_1
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_2
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_3
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_4
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_5
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_6
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_7
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_8
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_9
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_10
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_11
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_12
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_13
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_14
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_15
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_16
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_17
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_18
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_19
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_20
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_21
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_22
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_23
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_24
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_25
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_26
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_27
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_28
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_29
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_30
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_31
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_32
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_33
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_34
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_35
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_36
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_37
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_38
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_39
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_40
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_41
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_42
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_43
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_44
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_45
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_46
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_47
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_48
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_49
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_50
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_51
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_52
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_53
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_54
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_55
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_56
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_57
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_58
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_59
// module not written out since it is a black box. 
//


//
// Verific Verilog Description of module EFX_LUT4_8a21bc6b_60
// module not written out since it is a black box. 
//

