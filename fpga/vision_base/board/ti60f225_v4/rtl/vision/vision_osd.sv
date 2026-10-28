module vision_osd #(parameter MOTION_HINT=0,M7_FACE=0)(input[11:0]x,y,input[2:0]mode,input[10:0]threshold,input median_en,input[1:0]memory_mode,input[2:0]history_index,input canny_ready,input[1:0]shape_class,input shape_valid,input shape_enable,output reg active=0,output ink,input[10:0]requested_threshold,input fusion_enabled,input[351:0]fusion_result,input fusion_match,input[15:0]fusion_age,input clk,input[23:0]ui_state,input[12:0]geometry_counts);
function automatic[34:0]glyph(input[7:0]ch);
 begin case(ch)
8'd48:glyph=35'b01110100011001110101110011000101110;
8'd49:glyph=35'b00100011000010000100001000010001110;
8'd50:glyph=35'b01110100010000100010001000100011111;
8'd51:glyph=35'b11110000010000101110000010000111110;
8'd52:glyph=35'b00010001100101010010111110001000010;
8'd53:glyph=35'b11111100001000011110000010000111110;
8'd54:glyph=35'b01110100001000011110100011000101110;
8'd55:glyph=35'b11111000010001000100010000100001000;
8'd56:glyph=35'b01110100011000101110100011000101110;
8'd57:glyph=35'b01110100011000101111000010000101110;
8'd65:glyph=35'b01110100011000111111100011000110001;
8'd66:glyph=35'b11110100011000111110100011000111110;
8'd67:glyph=35'b01111100001000010000100001000001111;
8'd68:glyph=35'b11110100011000110001100011000111110;
8'd69:glyph=35'b11111100001000011110100001000011111;
8'd70:glyph=35'b11111100001000011110100001000010000;
8'd71:glyph=35'b01110100011000010111100011000101110;
8'd72:glyph=35'b10001100011000111111100011000110001;
8'd73:glyph=35'b11111001000010000100001000010011111;
8'd74:glyph=35'b00111000100001000010100101001001100;
8'd75:glyph=35'b10001100101010011000101001001010001;
8'd76:glyph=35'b10000100001000010000100001000011111;
8'd77:glyph=35'b10001110111010110101100011000110001;
8'd78:glyph=35'b10001110011010110011100011000110001;
8'd79:glyph=35'b01110100011000110001100011000101110;
8'd80:glyph=35'b11110100011000111110100001000010000;
8'd81:glyph=35'b01110100011000110001101011001001101;
8'd82:glyph=35'b11110100011000111110101001001010001;
8'd83:glyph=35'b01111100001000001110000010000111110;
8'd84:glyph=35'b11111001000010000100001000010000100;
8'd85:glyph=35'b10001100011000110001100011000101110;
8'd86:glyph=35'b10001100011000110001100010101000100;
8'd87:glyph=35'b10001100011000110101101011101110001;
8'd88:glyph=35'b10001100010101000100010101000110001;
8'd89:glyph=35'b10001100010101000100001000010000100;
8'd90:glyph=35'b11111000010001000100010001000011111;
8'd43:glyph=35'b00000001000010011111001000010000000;
8'd58:glyph=35'b00000001000010000000001000010000000;
 default:glyph=0;endcase end
endfunction
// BEGIN GENERATED CHINESE SIDEBAR
// Noto Sans SC Medium, 15px in 16x16 cells; regenerate with scripts/generate_sidebar_chinese.py.
localparam integer CHINESE_GLYPHS=121;
localparam[63:0] ZH_MENU=64'h8081202020202020; // 菜单
localparam[63:0] ZH_IMAGE=64'h8283202020202020; // 图像
localparam[63:0] ZH_VIEW=64'h8482202020202020; // 视图
localparam[63:0] ZH_TARGET=64'h8586202020202020; // 目标
localparam[63:0] ZH_AI=64'h8788202020202020; // 智能
localparam[63:0] ZH_MODE=64'h898a8b8c20202020; // 显示模式
localparam[63:0] ZH_THRESHOLD=64'h8d8e8f9020202020; // 边缘阈值
localparam[63:0] ZH_MEDIAN=64'h9190929320202020; // 中值滤波
localparam[63:0] ZH_ZOOM=64'h8283949520202020; // 图像缩放
localparam[63:0] ZH_PAN_X=64'h9697979820202020; // 水平平移
localparam[63:0] ZH_PAN_Y=64'h999a979820202020; // 垂直平移
localparam[63:0] ZH_SIZE=64'h9b9c9d9e20202020; // 输出尺寸
localparam[63:0] ZH_POS_X=64'h96979fa020202020; // 水平位置
localparam[63:0] ZH_POS_Y=64'h999a9fa020202020; // 垂直位置
localparam[63:0] ZH_AI_MODE=64'ha1a28b8c20202020; // 推理模式
localparam[63:0] ZH_RUN=64'ha3a4a1a220202020; // 立即推理
localparam[63:0] ZH_SELFTEST=64'ha5a6202020202020; // 自检
localparam[63:0] ZH_MODEL=64'h8ba7202020202020; // 模型
localparam[63:0] ZH_CENTER=64'ha8a9aa9120202020; // 一键居中
localparam[63:0] ZH_TARGET_ZOOM=64'h95abacad20202020; // 放大倍率
localparam[63:0] ZH_FULLVIEW=64'haeafb0b120202020; // 恢复全幅
localparam[63:0] ZH_CAMERA=64'hb2b3b48220202020; // 彩色原图
localparam[63:0] ZH_GRAY=64'hb5b6822020202020; // 灰度图
localparam[63:0] ZH_SOBEL=64'h534f42454c8d8e20; // SOBEL边缘
localparam[63:0] ZH_SPLIT=64'hb7b8b9ba20202020; // 左右分屏
localparam[63:0] ZH_SOBEL_OVERLAY=64'h534f42454cbbbc20; // SOBEL叠加
localparam[63:0] ZH_CANNY=64'h43414e4e598d8e20; // CANNY边缘
localparam[63:0] ZH_CANNY_OVERLAY=64'h43414e4e59bbbc20; // CANNY叠加
localparam[63:0] ZH_SHAPE=64'hbdbebfc020202020; // 几何识别
localparam[63:0] ZH_ON=64'hc1c2202020202020; // 开启
localparam[63:0] ZH_OFF=64'hc3c4202020202020; // 关闭
localparam[63:0] ZH_WIDTH=64'hc520202020202020; // 宽
localparam[63:0] ZH_PIXELS=64'h83c6202020202020; // 像素
localparam[63:0] ZH_FIXED=64'hc7c881c920202020; // 固定单帧
localparam[63:0] ZH_AUTO=64'ha5ca202020202020; // 自动
localparam[63:0] ZH_BASE=64'hcbcc8ba720202020; // 基础模型
localparam[63:0] ZH_TIMES=64'hac20202020202020; // 倍
localparam[63:0] ZH_CONFIRM=64'h4b30cdce20202020; // K0确认
localparam[63:0] ZH_ENTER=64'h4b30cfd020202020; // K0进入
localparam[63:0] ZH_UP=64'h4b32d1d220202020; // K2上选
localparam[63:0] ZH_DOWN=64'h4b33d3d220202020; // K3下选
localparam[63:0] ZH_CLOSE=64'hd4d5c3c420202020; // 长按关闭
localparam[63:0] ZH_BACK=64'hd4d5d6d720202020; // 长按返回
localparam[63:0] ZH_CANCEL=64'hd4d5d8d920202020; // 长按取消
localparam[63:0] ZH_EDIT=64'hdadb202020202020; // 编辑
localparam[63:0] ZH_READY=64'hdcdd202020202020; // 就绪
localparam[63:0] ZH_WAIT=64'hdedf202020202020; // 等待
localparam[63:0] ZH_DONE=64'he0e1202020202020; // 完成
localparam[63:0] ZH_NO_TARGET=64'he285862020202020; // 无目标
localparam[63:0] ZH_BUSY=64'he3e4202020202020; // 正忙
localparam[63:0] ZH_STALE=64'he5e6e72020202020; // 已过期
localparam[63:0] ZH_ERROR=64'h9ce8202020202020; // 出错
localparam[63:0] ZH_TEST_NONE=64'he9a5a62020202020; // 未自检
localparam[63:0] ZH_TEST_WAIT=64'ha5a6912020202020; // 自检中
localparam[63:0] ZH_TEST_PASS=64'ha5a6eae620202020; // 自检通过
localparam[63:0] ZH_TEST_FAIL=64'ha5a6ebec20202020; // 自检失败
localparam[63:0] ZH_AI_IDLE=64'ha1a2edee20202020; // 推理空闲
localparam[63:0] ZH_AI_RUN=64'ha1a2912020202020; // 推理中
localparam[63:0] ZH_AI_DONE=64'ha1a2e0e120202020; // 推理完成
localparam[63:0] ZH_AI_ERROR=64'ha1a29ce820202020; // 推理出错
localparam[63:0] ZH_AI_OLD=64'heff0e6e720202020; // 结果过期
localparam[63:0] ZH_MOTION=64'hf1caf28a20202020; // 运动提示
localparam[63:0] ZH_LEFT=64'hf3b7202020202020; // 向左
localparam[63:0] ZH_RIGHT=64'hf3b8202020202020; // 向右
localparam[63:0] ZH_MOVE_UP=64'hf3d1202020202020; // 向上
localparam[63:0] ZH_MOVE_DOWN=64'hf3d3202020202020; // 向下
localparam[63:0] ZH_STILL=64'hf4f5202020202020; // 静止
localparam[63:0] ZH_UNKNOWN=64'hdff6202020202020; // 待判
localparam[63:0] ZH_HOLD=64'hf7f8202020202020; // 保持
function automatic[255:0]chinese_glyph(input[6:0]code);
 begin case(code)
 7'd0:chinese_glyph=256'h0c607ffc0c600cf87ff003183318113001007ffc07c00f603938711c01000000; // 菜
 7'd1:chinese_glyph=256'h08200c300c603ff8311831183ff831183ff8030003807ffc0100010001000000; // 单
 7'd2:chinese_glyph=256'h00007ffc620c660c6fec7e6c638c6fec7e7c638c640c67cc604c7ffc600c0000; // 图
 7'd3:chinese_glyph=256'h09001bf0126036603ffc764cf7fc718037dc35f8377834e833ec3e6430c00000; // 像
 7'd4:chinese_glyph=256'h100031fc110c7d2c0d6c196c196c396c7f6c746010e010e411a41324163c0000; // 视
 7'd5:chinese_glyph=256'h00003ff83018301830183ff83018301830183ff8301830183ff8301830100000; // 目
 7'd6:chinese_glyph=256'h100011fc10007c0038003bfc38603c6075685168d36c136c166410e410e00000; // 标
 7'd7:chinese_glyph=256'h200030007efc48cc7fcc1ccc36fc62001ff0101010101ff010101ff010100000; // 智
 7'd8:chinese_glyph=256'h10c034c826f87ee07fc400c47efc66007ec066dc66f07ec066c466c46e7c0000; // 能
 7'd9:chinese_glyph=256'h00003ff8301830183ff830183ff8040026c836d816d016f006c07ffc00000000; // 显
 7'd10:chinese_glyph=256'h000000003ff8000000007ffc7ffc0100193031183118610c610c47000f000000; // 示
 7'd11:chinese_glyph=256'h319037fc319078903bfc320c3bfc3a0c7bfc704077fc30f031b8371c36040000; // 模
 7'd12:chinese_glyph=256'h00d000d800c87ffc00c000c000407f4008600860086008641f347e3c401c0000; // 式
 7'd13:chinese_glyph=256'h00c060c030c017fc01cc008c708c318c318c330c361834787c00cffc00400000; // 边
 7'd14:chinese_glyph=256'h118011f8311823f06c107ffc71c033cc3e7879f843681cec7bac676400e00000; // 缘
 7'd15:chinese_glyph=256'h200037fc180c08ec60ac7ffc608c6eac6aec6ecc60dc7ffc616c600c60380000; // 阈
 7'd16:chinese_glyph=256'h084018c017fc30c033f87208f20873f8320833f8320833f832083ffc30000000; // 值
 7'd17:chinese_glyph=256'h0100010001007ffc638c610c610c610c638c7ffc610c01000100010001000000; // 中
 7'd18:chinese_glyph=256'h00c070fc10c007fc448464f03780048c04f81c603fa82fa46a8c7a8e48f00000; // 滤
 7'd19:chinese_glyph=256'h0040304018e007fc064c764837f80798079814f034f034606cf86f9c0a040000; // 波
 7'd20:chinese_glyph=256'h1040106037fc26046f047bfc733037fc7fcc7fcc43fc1bcc7bcc43fc03c40000; // 缩
 7'd21:chinese_glyph=256'h1040184018c07efe30dc31c83fd83758367036703630267066f867cc5d040000; // 放
 7'd22:chinese_glyph=256'h01000100010001087d987db00de00dc0196019303138711c610c070007000000; // 水
 7'd23:chinese_glyph=256'h00007ff80380111019301930192001007ffc7ffc010001000100010001000000; // 平
 7'd24:chinese_glyph=256'h08607ce071f813981af07ce03be0387c7ccc738cd278107010e013c012000000; // 移
 7'd25:chinese_glyph=256'h00783ff0010003807ffc193019307ffc1bb019307ffc038001003ff800000000; // 垂
 7'd26:chinese_glyph=256'h010003007ffc03001ff010101ff010101ff0101010101ff010107ffc00000000; // 直
 7'd27:chinese_glyph=256'h306030607df0239c27fc78005bd47e541bd41a541e547bd41a541a441adc0000; // 输
 7'd28:chinese_glyph=256'h0100010831183118311833983ff80100610c610c610c610c7ffc7ffc000c0000; // 出
 7'd29:chinese_glyph=256'h00003ff838183018301830183ff839c030c030c0306020606038601c40040000; // 尺
 7'd30:chinese_glyph=256'h0060006000607ffc7ffc00600060186018600c6004600060006003e003c00000; // 寸
 7'd31:chinese_glyph=256'h08401840184017fc30007118711871183110319031b031b0303037fc10000000; // 位
 7'd32:chinese_glyph=256'h00003ffc26cc3ffc03007ffc03001ff01ff010101ff010301ff07ffc00000000; // 置
 7'd33:chinese_glyph=256'h31a031a033307ffc3730372037fc3b307b2073fc33303320333033fc73000000; // 推
 7'd34:chinese_glyph=256'h00007ffc336c336c33fc326c7b6c33fc306030603bfc7860606007fe00000000; // 理
 7'd35:chinese_glyph=256'h0300030001007ffc3ff8083008300c600c600c600c4004c07ffc7ffc00000000; // 立
 7'd36:chinese_glyph=256'h00007f7c634c634c7f4c634c634c7f4c604c644c664c66587f40734000400000; // 即
 7'd37:chinese_glyph=256'h030003003ff83018301830183ff8301830183ff83018301830183ff830180000; // 自
 7'd38:chinese_glyph=256'h104030e031f07998370c3ffc380078487248734873783110303037fc10000000; // 检
 7'd39:chinese_glyph=256'h00087f6c126c126c7fec366c320c620c433801003ff8038001007ffc00000000; // 型
 7'd40:chinese_glyph=256'h0000000000000000000000007ffc7ffc00000000000000000000000000000000; // 一
 7'd41:chinese_glyph=256'h202027fc7f3c433cc3fe7a3c37fc31307dfc373033fc3b303fe02cfc00000000; // 键
 7'd42:chinese_glyph=256'h00003ff8300830083ff830c030c03ffc30c020c02ff86c186c184ff84c180000; // 居
 7'd43:chinese_glyph=256'h01000100010003007ffc7ffc0380038006c006c00c601c703838701c40040000; // 大
 7'd44:chinese_glyph=256'h0840184017fc331833187110713077fc300033f833183208320833f832180000; // 倍
 7'd45:chinese_glyph=256'h010003807ffc030066d837b003803ff867ec01007ffc03800100010001000000; // 率
 7'd46:chinese_glyph=256'h3180318031803ffc79007d30737473fc32a836b836703c7030d8318c31040000; // 恢
 7'd47:chinese_glyph=256'h080018003ffc70007ff818181ff818181ff80c001ff03c7027c03ff8783c0000; // 复
 7'd48:chinese_glyph=256'h0100038007c00c601830701c7ffc0380010003801ff0010001007ffc00000000; // 全
 7'd49:chinese_glyph=256'h100013fc10007dfc558c558c55fc540057fc57645f6413fc132413fc11040000; // 幅
 7'd50:chinese_glyph=256'h01003f1c7e3809706d60270c0c180c707fe01e041f0c3d1c6c384ce00c400000; // 彩
 7'd51:chinese_glyph=256'h04000c000fe018c031c07ff87118311831983ff830083004300c1ffc00000000; // 色
 7'd52:chinese_glyph=256'h00003ffc31c021802ff82c182ff82c182c182ff8608066906c98588c43800000; // 原
 7'd53:chinese_glyph=256'h0c000c007ffc0c0008c008c01ac81ad81ed030c031e061b043180e0c04040000; // 灰
 7'd54:chinese_glyph=256'h018001803ffc221022303ffc223023f020002ff86630637063e05ffc581c0000; // 度
 7'd55:chinese_glyph=256'h0600060006007ffc0c000c000c001ffc18c010c030c060c060c05ffc00000000; // 左
 7'd56:chinese_glyph=256'h0200020006007ffc0e000c000c001c001ff83818681848180c180ff808180000; // 右
 7'd57:chinese_glyph=256'h00000c600c2018303018700c7ffc1ff0063006300c300c30383071e000000000; // 分
 7'd58:chinese_glyph=256'h00003ffc300c300c3ffc361032303ffc233023303ffc663066304c3048300000; // 屏
 7'd59:chinese_glyph=256'h1ff00e6007c01c707ef83cf87ef87ffc600c5ff4183018301ff018307ffc0000; // 叠
 7'd60:chinese_glyph=256'h1000100010fc7fcc3bcc13cc12cc32cc32cc32cc32cc22cc66fc4ecc40400000; // 加
 7'd61:chinese_glyph=256'h00000fe00c600860086008600860186018601860186430663064603c40000000; // 几
 7'd62:chinese_glyph=256'h080018001ffe300c300c77cc764c764c364c364c37cc360c300c303830780000; // 何
 7'd63:chinese_glyph=256'h200033fc1b0c030c030c730c330c13fc1000100015981d983b0c330c02040000; // 识
 7'd64:chinese_glyph=256'h00007f0c636c636c636c7f6c186c186c7f6c1b6c136c330c330c623c4e380000; // 别
 7'd65:chinese_glyph=256'h00007ffc0c600c600c600c600c607ffc0c600c60186018603060706060600000; // 开
 7'd66:chinese_glyph=256'h0100010001803ff8300830183ff8300030003ffc2c0c2c0c6c0c6ffc4c080000; // 启
 7'd67:chinese_glyph=256'h083018300c600ce03ff80100010003807ffc038007c00e601c78781c600c0000; // 关
 7'd68:chinese_glyph=256'h200037fc100c00cc60cc60cc6ffc61cc63cc66cc6ccc78cc63cc600c601c0000; // 闭
 7'd69:chinese_glyph=256'h010003807ffc644c3ff8044004401ff01130133013b013b406841cc470fc0000; // 宽
 7'd70:chinese_glyph=256'h01007ffc01003ff801007ffc06000c601fc00f303ffc298c19b0719c670c0000; // 素
 7'd71:chinese_glyph=256'h00007ffc600c610c610c7ffc610c6fec6c6c6c6c6fec600c600c7ffc600c0000; // 固
 7'd72:chinese_glyph=256'h030001007ffc600c600c5ff403801100198019f839003d00270063fc403c0000; // 定
 7'd73:chinese_glyph=256'h10201060107c18607dfc558c558c55ac55ac55ac5dec116010d8138c13040000; // 帧
 7'd74:chinese_glyph=256'h000000607e60006001fc7f6430643064366c224c6ecc7fcc418c01b800000000; // 动
 7'd75:chinese_glyph=256'h082018307ffc18301ff018301ff018307ffc193039186fec01003ff800000000; // 基
 7'd76:chinese_glyph=256'h00607d60316c316c216c216c7dfc6c60ef6c6f6c2f6c2f6c3f6c23fc00040000; // 础
 7'd77:chinese_glyph=256'h00807d8031f8333027fc276c7f6c6ffc6f6c6f6c2ffc2f6c3e6c266c001c0000; // 确
 7'd78:chinese_glyph=256'h0060306018600860006078601860186018e018f01c901d98199c330c02040000; // 认
 7'd79:chinese_glyph=256'h01106190319017fc01b00190719037fc13b01310131036107c0047fc00000000; // 进
 7'd80:chinese_glyph=256'h00000400060003000300038003c003c0066006600c301818301c600c00000000; // 入
 7'd81:chinese_glyph=256'h0300030003000300030003f803f8030003000300030003007ffc7ffc00000000; // 上
 7'd82:chinese_glyph=256'h0040634033fc16600440006077fc31b031b033343734363c38006f1c47fc0000; // 选
 7'd83:chinese_glyph=256'h00007ffc7ffc03000300038003c0037003380308030003000300030003000000; // 下
 7'd84:chinese_glyph=256'h08001838187018e01b8019001c007ffc198018c018c018701fb81f1c10000000; // 长
 7'd85:chinese_glyph=256'h1040306033fc7e0c32c432c430c037fc3d98791873b030f030f033dc730c0000; // 按
 7'd86:chinese_glyph=256'h001863f83200120003f80218769836d0367036703dd835887c004ffc00000000; // 返
 7'd87:chinese_glyph=256'h00007ffc7ffc600c600c6fec6c6c6c6c6c6c6fec600c600c600c7ffc600c0000; // 回
 7'd88:chinese_glyph=256'h00007f0067fc26cc3ecc2648264826783e78263027307f7866f807cc06840000; // 取
 7'd89:chinese_glyph=256'h2040764c1b4c0358006063fc320c020c03fc120c13fc320c220c620c62380000; // 消
 7'd90:chinese_glyph=256'h1060106033fc230c6b0c7bfc730033fc7bd47b5403fc3fd477544554000c0000; // 编
 7'd91:chinese_glyph=256'h100011f87d8831f838003bfc79887df8198819881df879881bfc180808080000; // 辑
 7'd92:chinese_glyph=256'h182008287f2c002400fc7e6062707e7008702e706ad04bd64996199c19000000; // 就
 7'd93:chinese_glyph=256'h1040104c33fc20d86c507ffc78e031c03bfc7f8c01fc1d8c7d8c61fc018c0000; // 绪
 7'd94:chinese_glyph=256'h104030c03ffc69b049103ff801007ffc006000607ffc08200c20066000e00000; // 等
 7'd95:chinese_glyph=256'h1840384073fc606018403ffe3018701857fc1118131811981198101010700000; // 待
 7'd96:chinese_glyph=256'h030001007ffc600c600c7ffc000000007ffc04c00cc00cc418c4707c40000000; // 完
 7'd97:chinese_glyph=256'h00b000d800dc3ffc20c020c83ed836d82270267066646ee461f4431c40080000; // 成
 7'd98:chinese_glyph=256'h00003ffc03000300030003007ffc07c00380078005800d84388470fc40000000; // 无
 7'd99:chinese_glyph=256'h00007ffc0180018001801180118011f8118011801180118039807ffc00000000; // 正
 7'd100:chinese_glyph=256'h10403060306078207ffe7d80718071803180318031803180318031fc30000000; // 忙
 7'd101:chinese_glyph=256'h00007ff0003000103010301030303ff03010300030043004300c3ffc07e00000; // 已
 7'd102:chinese_glyph=256'h00106010301017fc00380210731031101190101010f030f07c0047fc00000000; // 过
 7'd103:chinese_glyph=256'h220026fc7fcc36cc26cc3efc26cc3ecc26fc36ccffcc34cc368c638c409c0000; // 期
 7'd104:chinese_glyph=256'h309030903ffc60d840907ffc100010007dfc198c11fc158c1d8c39fc01880000; // 错
 7'd105:chinese_glyph=256'h0100010003803ff80100010003807ffc078007c00d603938711c410c01000000; // 未
 7'd106:chinese_glyph=256'h000067fc31b810e007fc064c77fc364c164c17fc164c365c7c0047fc00000000; // 通
 7'd107:chinese_glyph=256'h0100190011003ff83ff8610003007ffc7ffc038006c00c603c38701c40040000; // 失
 7'd108:chinese_glyph=256'h00407e4066407afc7ac87b887b887bd87a587a7052301c30367867cc40840000; // 败
 7'd109:chinese_glyph=256'h030001007ffc600c644c4c70383820081ff003800100010001007ffc00000000; // 空
 7'd110:chinese_glyph=256'h000037fc180c180c610c610c7ffc638c67cc6d6c792c610c610c603c40000000; // 闲
 7'd111:chinese_glyph=256'h1060106033fc24606c60f8607bfc300034007dfc610c050c7d8c61fc01080000; // 结
 7'd112:chinese_glyph=256'h00003ff8311831183ff831183ff8038003807ffc07c00d70393c610c01000000; // 果
 7'd113:chinese_glyph=256'h000063f830001000000007fc718031b03318337837fc30047c0067fc00000000; // 运
 7'd114:chinese_glyph=256'h300033f833087bf8330833f830003ffc786073603378334037c036fc6c000000; // 提
 7'd115:chinese_glyph=256'h0300030002007ffc600c600c6fec6c6c6c6c6c6c6fec6c0c640c603c60380000; // 向
 7'd116:chinese_glyph=256'h18407ec018f87fb019fcfe6c006c7ffe666c7e6c66fc7e6c666066606ce00000; // 静
 7'd117:chinese_glyph=256'h0180018001800180118011f811fc118011801180118011807ffc7ffc00000000; // 止
 7'd118:chinese_glyph=256'h08006d0c6d6c3f6c2e6c7f6c0c6c0c6c0c6c7fec186c180c180c303c60380000; // 判
 7'd119:chinese_glyph=256'h08001bfc1a0c320c320c73fcf040704037fc31f031f03358364c3c4410400000; // 保
 7'd120:chinese_glyph=256'h3060306033fc7860306037fc30183818fffc7018311831983098301870700000; // 持
 default:chinese_glyph=0;endcase end
endfunction
// END GENERATED CHINESE SIDEBAR
function automatic[7:0]char8(input[63:0]text,input[2:0]slot);begin char8=text[{~slot,3'b0}+:8];end endfunction
function automatic[7:0]char4(input[31:0]text,input[1:0]slot);begin char4=text[{~slot,3'b0}+:8];end endfunction
function automatic[3:0]nibble(input[31:0]value,input[2:0]slot);begin nibble=value[{slot,2'b0}+:4];end endfunction
function automatic[7:0]hexchar(input[3:0]n);begin hexchar=n<10?8'd48+n:8'd55+n;end endfunction
function automatic[15:0]decimal(input[10:0]value);
 reg[15:0]bcd;integer bitno,digit;
 begin
  bcd=0;
  for(bitno=10;bitno>=0;bitno=bitno-1)begin
   for(digit=0;digit<4;digit=digit+1)
    if(bcd[digit*4+:4]>=5)bcd[digit*4+:4]=bcd[digit*4+:4]+4'd3;
   bcd={bcd[14:0],value[bitno]};
  end
  decimal=bcd;
 end
endfunction
reg[7:0]ch;reg[5:0]idx,bitidx;reg[2:0]row;reg[6:0]origin;reg[31:0]status_text;
// Only the visible 420x88 HUD uses these coordinates.
wire[8:0]local_x=x[8:0]-9'd8;wire[3:0]local_y=y[3:0]-origin[3:0];
wire[3:0]column=local_x%9'd12;
reg[7:0]ch_q=32;reg[5:0]bitidx_q=0;reg ink_region_q=0;
// Keep the original ASCII HUD font and a separate compact Chinese menu subset.
reg font[0:8191];reg font_ink=0;integer letter,position;reg[34:0]pattern;
// Three fixed 5bit row banks avoid address multiplication; last column stays blank.
(* syn_ramdecomp="area" *)reg[4:0]chinese_font0[0:CHINESE_GLYPHS*16-1],chinese_font1[0:CHINESE_GLYPHS*16-1],chinese_font2[0:CHINESE_GLYPHS*16-1];
reg[14:0]chinese_word=0;reg[3:0]chinese_position=15;reg chinese_q=0;
wire chinese_ink=chinese_position!=15&&chinese_word[14-chinese_position];
integer cn_letter,cn_position;reg[255:0]cn_pattern;
initial begin
 for(letter=0;letter<128;letter=letter+1)begin
  pattern=glyph(letter);
  for(position=0;position<64;position=position+1)font[letter*64+position]=position<35?pattern[position]:1'b0;
 end
 for(cn_letter=0;cn_letter<CHINESE_GLYPHS;cn_letter=cn_letter+1)begin
  cn_pattern=chinese_glyph(cn_letter);
  for(cn_position=0;cn_position<16;cn_position=cn_position+1)begin
   chinese_font0[cn_letter*16+cn_position]=cn_pattern[255-cn_position*16-:5];
   chinese_font1[cn_letter*16+cn_position]=cn_pattern[250-cn_position*16-:5];
   chinese_font2[cn_letter*16+cn_position]=cn_pattern[245-cn_position*16-:5];
  end
 end
end
wire sidebar=ui_state[23],editing=ui_state[22];
wire[4:0]selected={ui_state[14],ui_state[21:18]};wire[2:0]center_status=ui_state[17:15];
wire root_only=center_status==7,side_left=x<144;
wire mode_popup=editing&&selected==0&&!root_only;
wire side_modes=mode_popup&&x>=304;
wire[1:0]side_group=root_only?selected[1:0]:selected<3?0:selected<9?1:selected<13?3:2;
wire[4:0]side_first=side_group==0?0:side_group==1?3:side_group==2?13:9;
wire[3:0]side_count=side_group==1?6:side_group==2||side_group==3?4:3;
wire[4:0]side_index=selected-side_first;wire[3:0]side_lines=side_count+4'd3;
// Keep the original status HUD above the menu, including its right-hand fields.
wire[5:0]side_row=y[11:6]-6'd2;wire[8:0]side_x=(side_left||!sidebar)?x[8:0]:x[8:0]-(side_modes?9'd304:9'd144);
wire[4:0]side_slot=(side_x-9'd16)>>4;reg[5:0]side_py;reg marker_q=0;
wire side_selected=side_row=={1'b0,side_index}+6'd1;
wire side_active=y>=128&&((x<144&&y<576)||(!root_only&&x>=144&&x<304&&side_row<{2'b0,side_lines})||
                                         (mode_popup&&x>=304&&x<464&&side_row<10));
wire motion_on=MOTION_HINT&&fusion_result[19];
wire motion_active=motion_on&&x<160&&y>=96&&y<120;
reg[63:0]motion_text;
always @*begin
 case(fusion_result[18:16])
  1:motion_text=ZH_STILL;2:motion_text=ZH_LEFT;3:motion_text=ZH_RIGHT;
  4:motion_text=ZH_MOVE_UP;5:motion_text=ZH_MOVE_DOWN;default:motion_text=ZH_UNKNOWN;
 endcase
 motion_text={ZH_MOTION[63:48],motion_text[63:48],fusion_result[15]?ZH_HOLD[63:48]:16'h2020,16'h2020};
end
function automatic[63:0]group_label(input[1:0]group);
 begin case(group)
 0:group_label=ZH_IMAGE;1:group_label=ZH_VIEW;2:group_label=ZH_TARGET;3:group_label=ZH_AI;
 endcase end
endfunction
function automatic[63:0]mode_label(input[2:0]value);
 begin case(value)
 0:mode_label=ZH_CAMERA;1:mode_label=ZH_GRAY;2:mode_label=ZH_SOBEL;3:mode_label=ZH_SPLIT;
 4:mode_label=ZH_SOBEL_OVERLAY;5:mode_label=ZH_CANNY;6:mode_label=ZH_CANNY_OVERLAY;7:mode_label=ZH_SHAPE;
 endcase end
endfunction
wire[63:0]side_title=group_label(side_left?side_row[1:0]-1'b1:side_group);
function automatic[63:0]side_label(input[4:0]item);
 begin case(item)
 0:side_label=ZH_MODE;1:side_label=ZH_THRESHOLD;2:side_label=ZH_MEDIAN;3:side_label=ZH_ZOOM;
 4:side_label=ZH_PAN_X;5:side_label=ZH_PAN_Y;6:side_label=ZH_SIZE;7:side_label=ZH_POS_X;
 8:side_label=ZH_POS_Y;9:side_label=ZH_AI_MODE;10:side_label=ZH_RUN;11:side_label=ZH_SELFTEST;
 12:side_label=ZH_MODEL;13:side_label=ZH_CENTER;14:side_label=ZH_TARGET_ZOOM;15:side_label=ZH_FULLVIEW;
 16:side_label=ZH_MOTION;default:side_label=0;
 endcase end
endfunction
reg[63:0]side_text,side_value;
wire[3:0]menu=ui_state[14:11];
wire[10:0]shown=(menu!=0||sidebar)?ui_state[10:0]:threshold;
wire[63:0]mode_text=mode_label(side_modes?side_row[2:0]-3'd1:shown[2:0]);
wire[63:0]side_action=selected==2?{16'h4b30,shown[0]?ZH_OFF[63:48]:ZH_ON[63:48],32'h20202020}:
                                 editing?ZH_CONFIRM:ZH_ENTER;
wire[63:0]side_return=editing&&selected!=1?ZH_CANCEL:ZH_BACK;
wire[15:0]shown_decimal=decimal(shown),requested_decimal=decimal(requested_threshold);
wire[31:0]side_number={8'd48+shown_decimal[15:12],8'd48+shown_decimal[11:8],8'd48+shown_decimal[7:4],8'd48+shown_decimal[3:0]};
reg[63:0]menu_text;reg[31:0]run_text,test_text;
wire ai_page=menu>=8;
wire hud=fusion_enabled||ai_page;
always @*begin
 case(menu)
  1:menu_text=64'h4d454449414e2020; // MEDIAN
  2:menu_text=64'h5a4f4f4d20202020; // ZOOM (source width)
  3:menu_text=64'h50414e2058202020;4:menu_text=64'h50414e2059202020;
  5:menu_text=64'h53495a4520202020;
  6:menu_text=64'h504f532058202020;7:menu_text=64'h504f532059202020;
  8:case(ui_state[1:0])
     0:menu_text=64'h4149204f46462020;1:menu_text=64'h4149204649582020;
     default:menu_text=64'h4149204155544f20;
    endcase
  9:menu_text=64'h53454c4654455354;
  10:menu_text=ui_state[0]?64'h4e4e20464f4d4f20:64'h4e4e204241534520;
  default:menu_text=0;
 endcase
 row=y>=76?4:y>=58?3:y>=40?2:y>=22?1:0;origin=4+18*row;
 idx=local_x/9'd12;ch=32;status_text=32'h4e4f4e45; // NONE
 case(fusion_result[10:8])
  1:status_text=32'h57414954;2:status_text=32'h54455354;3:status_text=32'h4f4b2020;
  4:status_text=32'h44494646;5:status_text=32'h554e4b4e;6:status_text=32'h45525220;
 endcase
 if(fusion_result[0]&&!fusion_match)status_text=32'h4f4c4420; // OLD, never a fresh box
 case(fusion_result[12:11])
  0:run_text=32'h49444c45;1:run_text=32'h52554e20;
  2:run_text=32'h444f4e45;3:run_text=32'h45525220;
 endcase
 case(fusion_result[14:13])
  0:test_text=32'h4e4f4e45;1:test_text=32'h57414954;
  2:test_text=32'h50415353;3:test_text=32'h4641494c;
 endcase
 if(fusion_result[0]&&fusion_result[12:11]==2&&!fusion_match)run_text=32'h4f4c4420;
 // The sidebar instance never renders the legacy HUD.
 if(!MOTION_HINT&&row==0)begin
  if(idx<8)case(mode)
   0:ch=char8(64'h43414d4552412020,idx[2:0]); // CAMERA
   1:ch=char8(64'h4752415920202020,idx[2:0]);
   2:ch=char8(64'h534f42454c202020,idx[2:0]);
   3:ch=char8(64'h53504c4954202020,idx[2:0]);
   4:ch=char8(64'h534f42454c204f56,idx[2:0]);
   5:ch=char8(64'h43414e4e59202020,idx[2:0]);
   6:ch=char8(64'h43414e4e59204f56,idx[2:0]);
   7:ch=char8(64'h5348415045202020,idx[2:0]);
  endcase
  else case(idx)
   9:ch=menu!=0?"V":"T";10:ch=48+shown_decimal[15:12];11:ch=48+shown_decimal[11:8];
   12:ch=48+shown_decimal[7:4];13:ch=48+shown_decimal[3:0];
   15:ch="M";16:ch="E";17:ch="D";18:ch=median_en?"1":"0";
   20:ch="F";21:ch=hexchar({2'b0,memory_mode});23:ch="I";24:ch=hexchar({1'b0,history_index});
   26:ch=menu==0?"C":"M";27:ch=menu==0?(canny_ready?"1":"0"):hexchar({1'b0,mode});
   29:ch=(mode==5||mode==6)?"R":" ";
   30:ch=(mode==5||mode==6)?48+requested_decimal[15:12]:32;
   31:ch=(mode==5||mode==6)?48+requested_decimal[11:8]:32;
   32:ch=(mode==5||mode==6)?48+requested_decimal[7:4]:32;
   33:ch=(mode==5||mode==6)?48+requested_decimal[3:0]:32;
   default:ch=32;
  endcase
  if(menu!=0&&idx<8)ch=char8(menu_text,idx[2:0]);
 end
 else if(!MOTION_HINT&&row==1&&shape_enable)begin
  case(idx)
   0:ch="S";1:ch="H";2:ch="A";3:ch="P";4:ch="E";5:ch=":";
   7:ch=!shape_valid?"N":shape_class==1?"C":shape_class==2?"R":((M7_FACE&&mode==7)?"F":"O");
   8:ch=!shape_valid?"O":shape_class==1?"I":shape_class==2?"E":((M7_FACE&&mode==7)?"A":"T");
   9:ch=!shape_valid?"N":shape_class==1?"R":shape_class==2?"C":((M7_FACE&&mode==7)?"C":"H");
   10:ch=!shape_valid?"E":shape_class==1?"C":shape_class==2?"T":((M7_FACE&&mode==7)?"E":"E");
   11:ch=!shape_valid?" ":shape_class==1?"L":shape_class==2?" ":((M7_FACE&&mode==7)?" ":"R");
   12:ch=(shape_valid&&shape_class==1)?"E":" ";
   14:ch=(M7_FACE&&mode==7)?"N":" ";15:ch=(M7_FACE&&mode==7)?8'(48+geometry_counts[2:0]):" ";
   16:ch=(M7_FACE&&mode==7&&geometry_counts[3])?"+":" ";
   18:ch=(M7_FACE&&mode==7)?"C":" ";19:ch=(M7_FACE&&mode==7)?8'(48+geometry_counts[6:4]):" ";
   21:ch=(M7_FACE&&mode==7)?"R":" ";22:ch=(M7_FACE&&mode==7)?8'(48+geometry_counts[9:7]):" ";
   24:ch=(M7_FACE&&mode==7)?"F":" ";25:ch=(M7_FACE&&mode==7)?8'(48+geometry_counts[12:10]):" ";
   default:ch=32;
  endcase
 end
 if(!MOTION_HINT&&hud&&row==2)begin
  if(idx==0)ch="A";else if(idx==1)ch="I";
  else if(idx>=3&&idx<=6)ch=char4(status_text,idx-3);
  else if(idx==8)ch="C";else if(idx==9)ch=hexchar({2'b0,fusion_result[7:6]});
  else if(idx==11)ch="G";else if(idx==12)ch=hexchar({2'b0,fusion_result[5:4]});
  else if(idx==14)ch="A";else if(idx>=15&&idx<=18)ch=hexchar(nibble(fusion_age,18-idx));
  if(ai_page)begin
   ch=32;
   if(idx==0)ch="A";else if(idx==1)ch="I";
   else if(idx>=3&&idx<=6)ch=char4(run_text,idx-3);
   else if(idx==8)ch="S";else if(idx==9)ch="T";
   else if(idx>=11&&idx<=14)ch=char4(test_text,idx-11);
   else if(idx==16)ch="N";else if(idx>=17&&idx<=20)ch=hexchar(nibble(fusion_result[31:16],20-idx));
   else if(idx==22)ch="A";else if(idx>=23&&idx<=26)ch=hexchar(nibble(fusion_age,26-idx));
   else if(idx>=28&&idx<=31&&fusion_result[1])ch=char4(32'h54455354,idx-28);
  end
 end
 if(!MOTION_HINT&&hud&&row==3)begin
  if(idx==0)ch="F";else if(idx>=1&&idx<=8)ch=hexchar(nibble(fusion_result[63:32],8-idx));
  else if(idx==10)ch="R";else if(idx>=11&&idx<=18)ch=hexchar(nibble(fusion_result[127:96],18-idx));
  else if(idx==20)ch="M";else if(idx>=21&&idx<=24)ch=hexchar(nibble(fusion_result[159:128],24-idx));
 end
 if(!MOTION_HINT&&hud&&row==4)begin
  if(idx==0)ch="S";else if(idx>=1&&idx<=8)ch=hexchar(nibble(fusion_result[95:64],8-idx));
  else if(idx>=10&&idx<=24)case((idx-10)%4)
   0:ch="Q";1:ch=hexchar(nibble(fusion_result[287:256],2*((idx-10)/4)+1));
   2:ch=hexchar(nibble(fusion_result[287:256],2*((idx-10)/4)));default:ch=32;
  endcase
  if(ai_page)begin
   ch=32;
   if(idx==0)ch=fusion_result[159:128]==2?"M":"U";else if(idx==1)ch="S";
   else if(idx==3)ch="I";else if(idx>=4&&idx<=7)ch=hexchar(nibble(fusion_result[303:288],7-idx));
   else if(idx==9)ch="H";else if(idx>=10&&idx<=13)ch=hexchar(nibble(fusion_result[319:304],13-idx));
   else if(idx==15)ch="N";else if(idx>=16&&idx<=19)ch=hexchar(nibble(fusion_result[335:320],19-idx));
   else if(idx==21)ch="H";else if(idx==22)ch="E";else if(idx==23)ch="X";
  end
 end
 bitidx=MOTION_HINT?6'd0:34-((local_y/2)*5)-(column/2);
 side_text=0;side_value={side_number,"    "};side_py=y[5:0]-6'd24;
 case(selected)
  0:side_value=mode_text;
  2,16:side_value=shown[0]?ZH_ON:ZH_OFF;
  3,6:side_value={ZH_WIDTH[63:56],side_number,ZH_PIXELS[63:48],8'd32};
  4,5,7,8:side_value={side_number,ZH_PIXELS[63:48],16'h2020};
  9:case(shown[1:0])
   0:side_value=ZH_OFF;1:side_value=ZH_FIXED;2:side_value=ZH_AUTO;default:side_value=0;
  endcase
  12:side_value=shown[0]?"FOMO    ":ZH_BASE;
  14:case(shown[3:0])
   0:side_value=ZH_AUTO;1,2,4,8:side_value={8'd48+{4'b0,shown[3:0]},ZH_TIMES[63:56],48'h202020202020};default:side_value=0;
  endcase
  10,11,13,15:side_value=editing?ZH_CONFIRM:ZH_ENTER;
 endcase
 if(sidebar)begin
  ch=32;
  if(side_left)begin
   if(side_row==0)side_text=ZH_MENU;
   else if(side_row<=4)side_text=side_title;
   else if(side_row==5)begin side_text=y[5]?ZH_DOWN:ZH_UP;side_py=y[5:0]-(y[5]?6'd36:6'd12);end
   else if(side_row==6)begin side_text=y[5]?(root_only?ZH_CLOSE:side_return):side_action;side_py=y[5:0]-(y[5]?6'd36:6'd12);end
  end else if(side_modes)begin
   if(side_row==0)side_text=ZH_MODE;
   else if(side_row<=8)side_text=mode_text;
   else if(side_row==9)begin side_text=y[5]?ZH_CANCEL:ZH_CONFIRM;side_py=y[5:0]-(y[5]?6'd36:6'd12);end
  end else if(!root_only)begin
   if(side_row==0)side_text=editing?ZH_EDIT:side_title;
   else if(side_row<=side_count)begin
    if(y[5])begin if(side_selected)side_text=side_value;end
    else side_text=side_label(side_first+side_row[3:0]-1'b1);
    side_py=y[5:0]-(y[5]?6'd36:6'd12);
   end else if(side_row==side_count+1'b1)begin
    if(selected==11)case(fusion_result[14:13])
     0:side_text=ZH_TEST_NONE;1:side_text=ZH_TEST_WAIT;2:side_text=ZH_TEST_PASS;3:side_text=ZH_TEST_FAIL;
    endcase
    else if(selected==9||selected==10||selected==12)begin
     case(fusion_result[12:11])
      0:side_text=ZH_AI_IDLE;1:side_text=ZH_AI_RUN;2:side_text=ZH_AI_DONE;3:side_text=ZH_AI_ERROR;
     endcase
     if(fusion_result[0]&&fusion_result[12:11]==2&&!fusion_match)side_text=ZH_AI_OLD;
    end
    else if(selected==16)side_text=motion_on?motion_text:ZH_OFF;
    else case(center_status)
     0:side_text=ZH_READY;1:side_text=ZH_WAIT;2:side_text=ZH_DONE;3:side_text=ZH_NO_TARGET;
     4:side_text=ZH_BUSY;5:side_text=ZH_STALE;6:side_text=ZH_ERROR;default:side_text=0;
    endcase
   end else if(side_row==side_count+2'd2)begin
    side_text=y[5]?side_return:side_action;side_py=y[5:0]-(y[5]?6'd36:6'd12);
   end
  end
  if(side_slot<8)ch=char8(side_text,side_slot[2:0]);
  bitidx=34-(side_py>>1)*5-(side_x[3:0]>>1);
 end
 if(!sidebar&&motion_active)begin
  side_py=y-12'd100;ch=side_slot<8?char8(motion_text,side_slot[2:0]):8'd32;
  bitidx=34-(side_py>>1)*5-(side_x[3:0]>>1);
 end
end
wire[10:0]chinese_row={ch[6:0],side_py[3:0]};
// Split character selection from font decode; RGB/control use the same extra beat.
always @(posedge clk)begin
 ch_q<=ch;bitidx_q<=bitidx;
 font_ink<=font[{ch[6:0],bitidx}];
 chinese_word<={chinese_font0[chinese_row],chinese_font1[chinese_row],chinese_font2[chinese_row]};
 chinese_position<=side_x[3:0];chinese_q<=ch[7];
 active<=sidebar?side_active:MOTION_HINT?motion_active:(x>=8&&x<((mode==5||mode==6||ai_page)?428:356)&&((y>=4&&y<20)||(shape_enable&&y>=22&&y<38)||(hud&&((y>=40&&y<56)||(y>=58&&y<74)||(y>=76&&y<92)))));
 ink_region_q<=(sidebar||motion_active)?(side_x>=16&&side_slot<8&&(ch[7]?side_py<16:(side_x[3:0]<10&&side_py<14&&bitidx<35))):(!MOTION_HINT&&column<10&&local_y<14&&bitidx<35);
 marker_q<=sidebar&&side_active&&((side_left&&side_row=={4'b0,side_group}+6'd1&&(side_x<4||(root_only&&(y[5:0]==0||y[5:0]==63))))||
             (!side_left&&!side_modes&&side_selected&&(side_x<4||y[5:0]==0||y[5:0]==63))||
             (side_modes&&side_row=={3'd0,shown[2:0]}+6'd1&&(side_x<4||y[5:0]==0||y[5:0]==63)));
end
assign ink=active&&((ink_region_q&&(chinese_q?chinese_ink:font_ink))||marker_q);
endmodule
