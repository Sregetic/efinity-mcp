from pathlib import Path
from xml.sax.saxutils import escape
from reportlab.pdfgen import canvas
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import Paragraph, Table, TableStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
import json

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'output' / 'pdf'
OUT.mkdir(parents=True, exist_ok=True)
(ROOT / "tmp" / "pdfs" / "v1_1").mkdir(parents=True, exist_ok=True)
FILE = OUT / '易灵思赛题四_MIPI视觉检测系统技术方案_V1.1.pdf'
pdfmetrics.registerFont(TTFont('CN', r'C:\Windows\Fonts\msyh.ttc', subfontIndex=0))
pdfmetrics.registerFont(TTFont('CNB', r'C:\Windows\Fonts\msyhbd.ttc', subfontIndex=0))
pdfmetrics.registerFontFamily('CN', normal='CN', bold='CNB', italic='CN', boldItalic='CNB')
W,H = A4
L,R = 44,44
CW = W-L-R
INK = colors.HexColor('#172B44')
TEAL = colors.HexColor('#087F8C')
GRAY = colors.HexColor('#596777')
PALE = colors.HexColor('#EFF5F8')
LINE = colors.HexColor('#D8E2E8')
GOLD = colors.HexColor('#C88026')
S = ParagraphStyle('body',fontName='CN',fontSize=10.2,leading=17,textColor=INK,wordWrap='CJK')
SM = ParagraphStyle('small',parent=S,fontSize=8.8,leading=14)
TB = ParagraphStyle('table',parent=S,fontSize=9,leading=14)
TH = ParagraphStyle('thead',parent=TB,fontName='CNB',textColor=colors.white)
c = canvas.Canvas(str(FILE),pagesize=A4,pageCompression=1)
c.setTitle('易灵思赛题四 | MIPI视觉检测系统技术方案 V1.1')
c.setAuthor('FPGA 项目技术方案')
c.setSubject('Ti60 / MIPI CSI-2 / RISC-V / TinyML / 实时边缘检测')
y=0
page=0
log=[]

def par(text, style=S, x=L, width=CW, gap=7):
    global y
    p=Paragraph(text,style)
    _,h=p.wrap(width,800)
    if y-h<58: raise RuntimeError(f'Page {page} overflow at: {text[:55]}, y={y}, h={h}')
    p.drawOn(c,x,y-h)
    y-=h+gap

def h2(text):
    global y
    y-=5
    par(text,ParagraphStyle('h2',parent=S,fontName='CNB',fontSize=12,leading=19,textColor=TEAL),gap=7)

def bullet(title,body):
    par(f'<b>{title}</b>　{body}')

def note(title,body):
    global y
    p=Paragraph(f'<b>{title}</b><br/>{body}',SM)
    _,h=p.wrap(CW-24,700)
    if y-h-22<58: raise RuntimeError(f'Note overflow page {page}')
    c.setFillColor(PALE); c.roundRect(L,y-h-20,CW,h+20,5,fill=1,stroke=0)
    c.setFillColor(TEAL);c.rect(L,y-h-20,3,h+20,fill=1,stroke=0)
    p.drawOn(c,L+12,y-h-10)
    y-=h+32

def table(headers,rows,widths):
    global y
    data=[[Paragraph(escape(str(v)),TH) for v in headers]]
    data += [[Paragraph(escape(str(v)).replace('\n','<br/>'),TB) for v in row] for row in rows]
    t=Table(data,colWidths=[CW*v for v in widths],hAlign='LEFT')
    t.setStyle(TableStyle([
        ('BACKGROUND',(0,0),(-1,0),INK),('VALIGN',(0,0),(-1,-1),'TOP'),
        ('LEFTPADDING',(0,0),(-1,-1),8),('RIGHTPADDING',(0,0),(-1,-1),8),
        ('TOPPADDING',(0,0),(-1,-1),7),('BOTTOMPADDING',(0,0),(-1,-1),7),
        ('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,PALE]),
        ('LINEBELOW',(0,0),(-1,-1),0.4,LINE)]))
    _,h=t.wrap(CW,800)
    if y-h<58: raise RuntimeError(f'Table overflow page {page}: y={y}, h={h}')
    t.drawOn(c,L,y-h);y-=h+12

def new(title,kicker='TECHNICAL DESIGN / V1.1'):
    global page,y
    if page:
        log.append({'page':page,'bottom':round(y,1)})
        c.showPage()
    page+=1
    c.setFillColor(TEAL);c.rect(0,H-8,W,8,fill=1,stroke=0)
    c.setFont('CN',8);c.setFillColor(GRAY)
    c.drawString(L,H-30,'FPGA 2026  /  易灵思赛题四')
    c.drawRightString(W-R,H-30,kicker)
    c.setStrokeColor(LINE);c.line(L,43,W-R,43)
    c.setFont('CN',8);c.setFillColor(GRAY)
    c.drawString(L,28,'设计方案 · 非上板实测报告  |  2026-09-08')
    c.drawRightString(W-R,28,f'{page:02d}')
    c.bookmarkPage(f'p{page}');c.addOutlineEntry(title,f'p{page}',0,False)
    y=H-69
    par(title,ParagraphStyle('h1',parent=S,fontName='CNB',fontSize=20,leading=29),gap=17)

def box(x,top,w,h,title,body='',dark=False):
    c.setFillColor(INK if dark else PALE);c.setStrokeColor(LINE)
    c.roundRect(x,top-h,w,h,5,fill=1,stroke=not dark)
    st=ParagraphStyle('box',parent=SM,fontName='CNB',textColor=colors.white if dark else INK,alignment=1)
    pp=Paragraph(title,st);_,hh=pp.wrap(w-12,h);pp.drawOn(c,x+6,top-10-hh)
    if body:
        st2=ParagraphStyle('box2',parent=SM,fontSize=8,leading=12,alignment=1,textColor=colors.white if dark else GRAY)
        pp=Paragraph(body,st2);_,hh2=pp.wrap(w-12,h);pp.drawOn(c,x+6,top-14-hh-hh2)

def arrow(x1,y1,x2,y2):
    import math
    c.setStrokeColor(TEAL);c.setLineWidth(1.3);c.line(x1,y1,x2,y2)
    a=math.atan2(y2-y1,x2-x1)
    for b in [a+2.65,a-2.65]:c.line(x2,y2,x2+5*math.cos(b),y2+5*math.sin(b))

# 01
new('MIPI 实时视觉检测系统','PROJECT PLAN / V1.1')
par('易灵思赛题四 · 技术方案与实施计划',ParagraphStyle('sub',parent=S,fontSize=17,leading=26,textColor=TEAL),gap=20)
par('固定 1080p60 视频主链，以可配置 ROI 和帧任务底座支撑边缘、几何及局部 AI 分析。',ParagraphStyle('lead',parent=S,fontSize=14,leading=24),gap=22)
table(['版本','当前阶段','项目基线'],[['V1.1 / 2026-09-08','硬件前 RTL 与构建验收完成','Ti60F225I3 + SC431HAI；实物版本待核对'],['目标保留','全部基础 + 六项高阶挑战','RISC-V 与 AI 按实际资源和性能集成'],['应用边界','暂不固定检测对象','统一底座适配几何、计数、外观与增强']],[.24,.32,.44])
h2('本版收敛的四项决策')
bullet('01 显示时序固定，工作图尺寸灵活','主显示目标为 1920×1080@60；内部 ROI、分析分辨率与结果更新率独立定义。')
bullet('02 图像先成为稳定帧，再交给任务','帧号、配置号与读者持有权贯穿读取、处理和写回；冻结时采集继续使用其他可用 bank。')
bullet('03 主链与分析分开验收','以 2PPC、行预取和结果缓存支撑帧预算；完整 Canny 与 AI 按自身更新率运行，不占用显示连续供数通道。')
bullet('04 方案与工程证据同步','已完成项给出仿真及 P&R 记录，未接入模块列明下一步产物；不以位流生成代替上板成功。')
note('本版范围','保留原方案的算法、软硬件协同和创新方向，更新架构、预算、状态与实施次序。本轮为文档修订；硬件联调及真实 DDR 新链路接入尚待完成。')

# 02
new('01 / 项目边界与阅读导航')
table(['信息类别','V1.1 冻结内容'],[['系统目标','固定 1080p60 主视频链；基础、高阶、RISC-V、AI 全部保留，分阶段接受。'],['器件与接口','Ti60F225I3 + SC431HAI；参考 CSI-2 RAW10 四 lane 示例；电气、lane 和实际帧率按实物核对。'],['屏幕与交互','HDMI 优先；JJX035FHD05-V9 为 1920×1080 四 lane DSI、无触摸。实体按键 + UART 为首版输入。'],['应用方向','先做统一帧/ROI/算法底座；用样本可得性、成像条件和指标收益选择应用，不预先绑定单一工件。'],['当前工程','vision_base 已有板级基线和 RGB565 帧引擎；9 项 full 测试通过，三种板级制品通过 P&R。'],['尚待接入','RAW→RGB565 采集适配、真实 DDR 仲裁、结果扫描 DMA；算法、SoC 与模型随后集成。']],[.23,.77])
h2('阅读导航')
table(['页码','内容','页码','内容'],[['03','赛题需求与验收映射','10-11','RISC-V、输入与配置一致性'],['04-06','目标架构、硬件与 CDC','12-14','AI、数据与创新对照'],['07-08','基础算法、Canny 与几何','15','现有工程证据与性能边界'],['09','1080p 内存与带宽预算','16-18','里程碑、接入任务和依据']],[.11,.39,.11,.39])
note('状态用词','“已验证”仅覆盖记录中的 RTL、配置和测试模型；“已编译”表示生成指定制品；“待上板”表示物理链路尚未接受。文档中的拟定寄存器和算法路线不视为已有实现。')

# 03
new('02 / 赛题需求与验收映射')
par('依据《易灵思.pdf》PDF 第 12-17 页，建立以下完整覆盖清单。高阶挑战全部纳入项目目标；不把实现提示误当成额外独立功能。[R1]',SM)
table(['编号 / 要求','实现方案','验收证据'],[
['B1 摄像头采集','MIPI CSI-2；有效图像至少 640×480；像素解包与帧标记','帧尺寸、帧率与错误计数；稳定采集录像'],
['B2 灰度','彩色格式归一后，移位加法或 DSP 定点转换','固定图像逐像素对照；定点误差说明'],
['B3 Sobel','两行缓存、3×3 窗口、Gx/Gy、L1 幅值和阈值','边界与位宽验证；仿真/参考输出对照'],
['B4 HDMI 显示','至少 640×480@60 Hz；灰度/边缘分屏或画中画','显示时序、叠加对齐与连续运行录像'],
['B5 提交物','完整 RTL、约束、必要固件、配置与演示视频','按说明重建与独立上电演示'],
['A1 中值滤波','3×3 完整中值选择网络','输出等于九像素真实中位数'],
['A2 实时阈值','实体按键/拨码；消抖与寄存器更新','加减阈值可见；重复触发与边界测试'],
['A3 DDR 帧缓存','采集-存储-读取-处理；冻结、回放、多帧对比','缓存所有权日志与同帧复核'],
['A4 Canny','高斯、梯度、NMS、双阈值、完整滞后连接','长弱边缘链等对照；帧级时间统计'],
['A5 彩色叠加','原始彩色图与边缘按坐标、帧号对齐','静态/移动目标叠加无位置偏差'],
['A6 简易识别','圆形/矩形轮廓和几何特征','独立形状样本及误判案例']],[.22,.43,.35])
note('范围说明','RISC-V、TinyML、自适应控制和工业检测属于本项目增强设计。技术提示中的“零延迟”、示例频率和排序步骤需经过工程解释与正确性验证；不直接作为性能结论。')

# 04
new('03 / 两层架构与集成边界')
par('保留可回退的相机直通基线，同时建设可配置 RGB565 帧任务链。两层当前分别验证，下一阶段通过格式适配、仲裁和扫描读出连接，而不是替换文件列表后直接宣称整机完成。')
h2('现有板级基线：用于先验收外设')
note('camera 模式','SC431HAI → CSI/RAW10 取高 8 位 → RAW8 DDR 三帧缓存 → 去 Bayer → HDMI。当前路径用于确认板卡、相机、DDR 与显示；它不等于新 RGB565 帧引擎已上板。')
h2('目标数据链：源帧与结果帧分离')
top=y;gap=12;bw=(CW-2*gap)/3;xs=[L,L+bw+gap,L+2*(bw+gap)]
box(xs[0],top,bw,67,'采集适配【待接】','CSI/去 Bayer/RGB565<br/>CDC + 采集 DMA')
box(xs[1],top,bw,67,'源帧池【RTL 已验】','四个源 bank / frame_id<br/>显示处理与分析独立持有',True)
box(xs[2],top,bw,67,'ROI 渲染【RTL 已验】','AXI 读取 / 双行预取<br/>2PPC 缩放 / 结果写回')
arrow(xs[0]+bw,top-32,xs[1],top-32);arrow(xs[1]+bw,top-32,xs[2],top-32)
top2=top-100
box(xs[0],top2,bw,66,'帧级分析【待接】','完整 Canny / 几何 / AI<br/>同帧结果与结果年龄')
box(xs[1],top2,bw,66,'结果发布【RTL 已验】','非显示 bank 写入<br/>最后 B 响应 + vblank')
box(xs[2],top2,bw,66,'扫描合成【待接】','扫描 DMA / 异步 FIFO<br/>固定 1080p60 / HDMI')
arrow(xs[1]+bw/2,top-67,xs[0]+bw/2,top2)
arrow(xs[2]+bw/2,top-67,xs[1]+bw/2,top2)
arrow(xs[1]+bw,top2-32,xs[2],top2-32)
y=top2-84
bullet('处理与显示各自有时钟契约','AXI/帧任务目标 100 MHz、2PPC；显示像素时钟 148.5 MHz。异步 FIFO 吸收短时差异，结果帧缓存隔离计算背压。')
bullet('真实 DDR 是下一次集成重点','采集写、渲染读、结果写、显示读通过同一仲裁层连接；分析请求按限额调度。读写响应和帧持有权同时校验。')
note('时序探针的含义','timing_probe 在真实板级时钟/引脚工程中保留新引擎，使用片内 AXI 数据发生器。它验证一组配置的物理时序，不验证真实 DDR，也不代表完整相机 + 算法 + AI 的资源总量。')

# 05
new('04 / MIPI 硬件与像素格式契约')
par('MIPI 只是接口族名称。首版按 CSI-2 over D-PHY 建立接入契约；连接器外形相同不代表引脚、电压或 lane 映射相同。官方 RX IP 支持多种 RAW/RGB/YUV 格式，具体输出取决于所选 IP 与传感器配置。[R4]')
table(['需要确认','冻结内容','影响'],[['相机身份','传感器型号、模组版本、镜头与视场','寄存器表、成像质量、最小可见缺陷'],['电气与连接','FPC 方向、pinout、供电、I/O 电平、复位、MCLK','实物连接与供电时序'],['链路参数','数据 lane 数、lane 顺序/极性、每 lane 速率、时钟模式','D-PHY 与 CSI-2 IP 配置'],['数据描述','RAW 位深/Bayer 排列或 YUV/RGB；VC、DT、有效尺寸','解包、行字节数和 ISP 路径'],['工作模式','实际支持的尺寸/FPS、曝光、增益、裁剪/binning','带宽、运动模糊与训练分布'],['工具基线','板卡工程、Efinity、IP 版本和约束文件','编译一致性与已知问题复现']],[.19,.49,.32])
h2('必须补上的 RAW / ISP 分支')
bullet('相机输出 RGB/YUV','按通道顺序、量化范围和打包方式归一。YUV 可提取 Y 供算法使用，彩色显示还需对应色彩转换。')
bullet('相机输出 Bayer RAW','先按 RAW10/RAW12 等格式解包，核对黑电平、有效位深和 Bayer 排列。彩色叠加要求保留可用彩色图，首版可使用经过验证的轻量去马赛克及定点颜色处理。')
bullet('算法输入契约','基础边缘算法暂定 Gray8；显示暂定 RGB565 或 RGB888；训练与板端必须采用同一裁剪、缩放和归一化流程。')
par('链路预算：有效像素负载 = 宽 × 高 × 帧率 × 传输位深。1080p60、RAW10 的有效负载为 1,244.16 Mbps；四条数据 lane 平均分摊为 311.04 Mbps/lane，另计包头、校验、嵌入数据和 HS/LP 切换开销。实际 lane 速率还由传感器行时序和突发发送决定，以上均不是链路配置值。',SM)
note('当前决策','MIPI 为设计基线，相机基线已明确为 SC431HAI，板级示例为 RAW10 四 lane；只沿用与实物匹配的配置。采集实际尺寸/帧率、Bayer 顺序及寄存器应答仍以上板证据为准。')

# 06
new('05 / MIPI 接入与跨时钟域设计')
h2('按可观测结果逐步调通')
table(['步骤','工作内容','进入下一步的条件'],[['M1 电气/时钟','核对接口、电源顺序、复位和参考时钟','实测供电与时钟符合模组要求'],['M2 I²C 配置','读取芯片 ID；写入选定模式；核查关键寄存器','ID 与模组一致，配置读回合理'],['M3 链路接收','启用 D-PHY/CSI-2；优先传感器测试图','IP 锁定/状态有效，包错误计数稳定'],['M4 图像解包','VC/DT 过滤；像素位序、行长度和帧尺寸检查','色条/灰阶与预期一致，无周期条纹'],['M5 显示直通','格式归一、帧缓存和 HDMI 输出','图像方向、颜色、尺寸和更新率正确'],['M6 算法接入','按灰度、中值、Sobel、Canny、AI 顺序集成','每步保留直通对照与计数证据']],[.16,.46,.38])
h2('时钟域与数据流')
bullet('独立时钟域','至少区分接收恢复/字节时钟、系统处理时钟、DDR 用户时钟及显示像素时钟。同标称频率也可能互为异步。')
bullet('像素跨域','用合适的异步 FIFO 或跨域视频缓冲连接；像素、SOF、EOL 和必要标记作为同一数据单元传输。核对 IP 是否多像素/周期输出，再转换到内部格式。')
bullet('真实输入约束','摄像头通常按固定节奏发送。下游背压需要足够缓冲；FIFO 溢出时记录并丢弃损坏帧，在新帧边界重新对齐，测试中明确计为采集失败。')
bullet('长期速率匹配','异步 FIFO 只吸收短时相位与突发差异。帧率差需通过已验证的相机模式、帧缓存策略和显示重复解决；基础验收工作点要求采集无意外丢帧。')
note('可观测寄存器','至少记录 frame_count、frame_size_error、fifo_overflow、display_underflow；ECC/CRC/SoT 等计数按所选 IP 暴露能力接入。计数复位与采样窗口由软件统一管理。')

# 07
new('06 / 灰度、中值与 Sobel 实现')
h2('像素流水线与边界')
par('在支持背压的内部接口上，仅当 valid 与 ready 同时成立时推进像素状态；在固定速率接口上按有效像素使能推进。消隐期间保持窗口计数逻辑一致。行首、帧首重新初始化必要的窗口状态。')
table(['模块','首版实现','正确性要点'],[['灰度','Y = (77R + 150G + 29B + 128) >> 8','RGB565 先扩展到 8 位通道；权重和为 256，舍入得到 Gray8；参考使用相同扩展规则'],['3×3 窗口','两条行缓存 + 三行移位寄存器','宽度由工作模式冻结；相邻滤波级各自承担所需行缓存'],['中值','九输入比较/选择网络，输出第 5 顺序统计量','行排序再列排序取中心不保证中位数；使用完整网络'],['Sobel','Gx/Gy 分级求和，G = |Gx| + |Gy|','Gx/Gy 用至少 11 位有符号数；幅值用至少 11 位无符号数'],['阈值','边缘 = G 大于阈值；关系在软件参考中一致','先使用完整梯度范围比较，再转换为显示亮度'],['边界策略','首版固定边缘填零，输出仍保持原始尺寸','参考算法使用同一规则；卷积中心与原彩色图对齐']],[.17,.43,.40])
h2('流水线与性能描述')
bullet('设计目标','完成流水线填充后，在选定内部数据率下持续接收有效像素。100 MHz 主处理域按 2PPC 设计；2,073,600 pixels/frame 的连续输出下限为 1,036,800 拍。后续窗口算子也需处理每拍两相邻像素及跨行边界。')
bullet('不使用虚假零延迟表述','两行缓存带来窗口形成等待，各级还存在寄存器延迟。分别记录输入到算法输出、输入到显示的实际延迟。')
bullet('复用策略','Sobel 与 Canny 的梯度模块可按互斥模式复用；若要求同帧同时比较，应通过缓存重放、时分调度或资源评估后增加并行实例。')
note('窄范围验证','使用斜线、棋盘格、脉冲点、椒盐噪声及随机窗口；灰度检查定点误差，中值与 Sobel 对照相同位宽和边界规则的参考实现。')

# 08
new('07 / 完整 Canny 与几何分析')
par('Canny 路径保留题目要求的五个阶段。高斯核、梯度度量、方向量化、NMS 相等值处理和边界规则都需要写入实现规格，防止只比较最终画面而忽略算法差异。[R1][R8]')
table(['阶段','建议实现','关键验证'],[['高斯与梯度','3×3 可分离定点高斯作为首版候选；复用梯度运算','与同核/同定点参考一致；噪声与细边缘权衡'],['方向与 NMS','用符号/比较方法量化到 4 个方向，再比较方向邻域','避免直接依赖浮点 atan；处理等幅值与图像边界'],['双阈值','生成强、弱、背景三类状态','约束低阈值小于高阈值；分类型状态可复核'],['滞后连接','首版候选：帧状态图 + 强边缘种子队列 + 8 邻域遍历','弱边缘入队前立即标记，避免重复；队列按最坏规模设计'],['几何提取','连通域/轮廓与面积、包围框、质心、周长等特征','圆/矩形判定对噪声、旋转和遮挡有明确范围']],[.19,.43,.38])
h2('为什么滞后连接单独作为帧级任务')
par('与强边缘相连的弱边缘可能形成任意长度路径。单次局部 3×3 检查或固定次数的邻域传播通常只构成近似。首版通过帧状态与工作队列实现完整连通性；RTL 控制器执行邻域访问，RISC-V 负责启动、完成事件和状态管理。')
par('每个候选像素最多入队一次，可将节点访问数量限制在有效像素数量级，但实际时延还受 DDR 随机访问、缓存和仲裁影响。先验证完整性，再决定是否改进为行程编码/连通域标号；两条实现路线不同时铺开。')
h2('测量与应用输出')
bullet('基础形状识别','先完成题目中的圆形和矩形；再扩展到选定工件的孔位、外轮廓与缺角。')
bullet('尺寸标定','初期输出像素单位。只有经过镜头畸变、平面尺度及姿态条件标定后，才输出物理尺寸和误差范围。')
note('Canny 验收边界','视频显示刷新率与完整 Canny 结果更新率分别报告。长弱边缘链、孤立弱边缘、对角连接、大连通区域都应进入针对性测试。')

# 09
new('08 / 1080p 内存与带宽预算')
par('以下按 1920×1080、RGB565、60 frames/s 规划。新引擎采用 4 MiB bank 步长：源区 0x00000000 起四帧，结果区 0x01000000 起两帧，合计 24 MiB。真实 DDR 容量与映射仍按实物确认。[R2][R9]',SM)
table(['对象 / 访问','预算','实现含义'],[['RGB565 单帧','4,147,200 B ≈ 3.955 MiB','4 MiB bank 留有行 padding 空间'],['源帧 / 结果帧','16 MiB / 8 MiB','四源 bank + 两结果 bank；未含回放与算法中间图'],['单路全帧访问','248.832 MB/s','一次完整读或写的有效数据量'],['采集写 + 渲染读 + 结果写 + 显示读','995.328 MB/s','全帧 1:1、每帧渲染时；另计仲裁/刷新/响应开销'],['完整 Canny 队列','32-bit 索引最坏约 7.91 MiB','另留状态图、梯度和算法中间数据'],['1 秒全帧回放','约 237.30 MiB','按紧凑 RGB565、60 帧计算；不作为默认缓存能力']],[.32,.29,.39])
par('MB = 1,000,000 B，MiB = 1,048,576 B。若实物为参考 V4 的 16-bit DDR3、800 Mbps/引脚，理论峰值为 1.6 GB/s；995.328 MB/s 已相当于其 62.2%，尚未包含实际开销，必须做混合访问实测。',SM)
h2('所有权、发布与服务保证')
bullet('源帧有效性','采集 DMA 获得可写 bank 后写入，完整帧且全部写响应成功才发布。处理和分析持有期间禁止覆盖；无空闲 bank 时丢弃新采集整帧并计数。')
bullet('结果双缓冲','非显示 bank 写入完成后置 pending；vblank 且扫描端排空旧帧读请求后切换描述符。当前 pending 期间暂不接受新渲染任务。')
bullet('冻结与分析','冻结保留同一源帧，可修改 ROI 重渲染；恢复实时重新申请最新帧。分析完成带回 frame_id、config_id、ROI 与结果年龄。')
note('带宽不足时的处理顺序','先测长突发、读写切换及最坏服务间隔；优先保护采集与显示，再限额分析/回放。ROI 缩小可减少源读取；必要时降低分析更新率，并明确报告掉帧和重复帧，显示 60 Hz 不等于新结果 60 fps。')

# 10
new('09 / RISC-V 固件与控制接口')
par('首版按单核 Sapphire RISC-V 候选设计，裸机事件循环或轻量调度；不预先引入 Linux、多核或浮点需求。像素级运算留在 FPGA，固件负责配置、任务和结果。实际外设总线由生成的 SoC 决定。')
table(['固件单元','职责'],[['board / camera','I²C 初始化、相机模式配置、屏幕与按键初始化'],['video_control','模式和参数检查；提交 shadow 配置；等待 ACK'],['frame_manager','帧描述符、读者引用、DMA 缓冲和帧任务队列'],['inference','TFLM 调用、张量预处理、逐层计时和推理状态'],['decision','几何结果与 AI 分数汇总；复核/未知状态'],['ui / telemetry','统一按钮、UART 事件；OSD 和统计日志；当前无触摸输入']],[.29,.71])
h2('寄存器契约草案：地址在实现阶段分配')
table(['寄存器组','建议字段 / 行为'],[['身份和能力（RO）','VERSION、CAPS、实现分辨率、可用算法及加速能力'],['待生效配置（RW）','MODE、THRESHOLD、CANNY_LOW/HIGH、ROI、LAYOUT'],['提交/应答','COMMIT_ID、APPLIED_ID、BUSY、ERROR；每次提交唯一序号'],['帧与任务状态','FRAME_ID、RESULT_FRAME_ID、CONFIG_ID、任务完成标志'],['统计和异常','采集计数、格式错误、溢出/欠载、推理耗时；明确清零语义']],[.29,.71])
bullet('中断最小集合','帧任务完成、配置生效、推理完成、需处理的链路异常。中断内只登记事件，较长工作放入主循环。')
bullet('配置检查','检查 ROI 范围、阈值顺序和当前硬件能力；非法参数返回错误并保持原配置，不让界面显示未经应用的值。')
note('实现说明','本页是自研接口设计草案，不是厂商 IP 寄存器表。已有 Efinix IP 的寄存器与地址保持其生成文档定义；自研控制层对其进行封装。')

# 11
new('10 / 模式、LCD 与一致性切换')
table(['模式','画面内容','主要控制'],[['基础算法','原图/灰度/中值/Sobel/Canny；当前阈值','切换算法、加减阈值、启停滤波'],['应用分析','彩色原图、ROI、形状/计数/AI 与结果状态','选择算法参数、自动/手动、触发分析'],['冻结复核','被分析原帧、边缘和缺陷依据','冻结/恢复、上一帧/下一帧、同帧对比'],['性能状态','采集 FPS、显示刷新、分析更新率、异常计数','开始/结束统计窗口、保存 UART 日志']],[.18,.48,.34])
h2('输入设计')
par('已提供的 JJX035FHD05-V9 为无触摸 DSI 屏，首版不规划触控驱动。HDMI 先验收，LCD 随后接入；实体按键/拨码保留阈值调节，按键与 UART 共用一个事件队列。')
par('按键数量待实物核实：板级资料正文与管脚表存在数量差异。本版只定义 NEXT、PREV、CONFIRM、BACK、FREEZE 等逻辑动作，不冻结 KEY 引脚。消抖、短按、长按和连发阈值由按键实测确定。[R2]')
h2('一次模式切换的完整流程')
table(['顺序','动作'],[['1 请求','UI 生成目标配置；RISC-V 校验后写入 shadow 配置及序号'],['2 跨域提交','配置保持稳定，通过握手跨域；同一时刻最多一个待应答提交'],['3 生效边界','在处理入口的帧边界接收配置，给该帧附带 CONFIG_ID'],['4 处理对齐','参数与像素一同传播，或等待旧流水线排空后切换；分支按帧关联'],['5 应答/显示','返回 APPLIED_ID，UI 显示实际生效状态；旧 AI 结果按帧号处理']],[.18,.82])
note('两类切换分开','阈值、布局等属于运行时配置；lane 数、接收 IP 格式能力或 Lite/Standard 硬件结构可能需要重新生成/编译。相机工作模式变更需单独停止接收、重配和重同步，避免冒充普通菜单切换。')

# 12
new('11 / AI 任务、输入与数据集')
h2('首版 AI 定位')
par('AI 不替代基础边缘检测，也不提前绑定单一应用。先保留几何测量/计数、外观分类与局部异常三类候选，用可获得样本及成像质量做小规模对照，再选择一种主演示任务。外观缺陷仅为候选方向，不据此冻结标签或模型。')
table(['环节','首版设计建议','决策依据'],[['对象区域','保留原始分辨率图；边缘/几何定位 ROI','定位召回率与目标覆盖程度'],['局部分析','64×64 或 96×96 图块作为候选，不预先冻结','最小缺陷像素尺寸与模型效果'],['模型结构','小型卷积 + 深度可分离卷积 + 汇聚/分类头候选','支持的算子、激活内存、量化损失'],['输入对照','灰度；边缘；灰度+边缘双通道','同一测试集上的收益与额外代价'],['多缺陷','多标签或多 ROI 分别分类；保留未知/待复核','同一实物是否可能存在多类缺陷'],['定位输出','先标分析 ROI；定位验证后再标缺陷框','局部分类仅输出区域类别；精确定位另需验证']],[.17,.45,.38])
h2('数据采集与防泄漏')
bullet('采集记录','记录实物 ID、批次、光照、曝光、距离、姿态、正常/异常标签和标注方式。合成噪声可辅助测试，实物样本仍是应用验收依据。')
bullet('数据划分','按实物和采集批次划分训练、验证、测试，避免同一实物相邻帧跨集合。模型选型和门限只使用训练/验证集，测试集最终锁定。')
bullet('指标','分类统计每类召回与 Macro-F1；检测统计对象级漏检、误报/百件；定位使用 IoU 等指标。低置信或几何/AI 冲突进入待复核。')
note('最小缺陷约束','缩放前先量化“缺陷在原图占多少像素”。例如宽 2 像素的细线在整图大幅缩小时可能丢失；通过 ROI 裁剪、局部图块或更近成像保留可判别信息。')

# 13
new('12 / TinyML 部署与加速策略')
par('采用完整整数 INT8 模型作为首版候选。先在软件参考路径验证静态输入，再集成相机 ROI 和硬件加速。官方生成器按模型算子定制加速配置，Lite/Standard 对同类算子是互斥的综合选择。[R5]')
table(['阶段','需要完成的工作','输出证据'],[['D1 主机模型','训练/验证；固定裁剪、缩放和标签定义','模型版本、数据划分、参考输入输出'],['D2 INT8 量化','有代表性校准数据；逐算子支持核查','量化前后指标、scale/zero-point'],['D3 RISC-V 静态输入','TFLM 纯软件或已知正确参考路径','逐层耗时、总耗时、arena 峰值'],['D4 加速配置','按实际瓶颈配置 Conv/DWConv 等所需模块','资源估算与综合报告'],['D5 板端对照','相同输入比较软件/硬件输出','误差、最终类别、端到端加速比'],['D6 实时集成','DMA/ROI/任务调度；帧与结果绑定','并行视频稳定性与结果年龄']],[.19,.47,.34])
h2('自定义指令只围绕真实瓶颈设计')
par('可评估打包点积、定点重定标、像素打包或特征统计，但先查看 profiling。如果模型主要耗时在卷积，单独加速很小的全连接层，整体收益可能有限。避免重复实现已由 TinyML 加速器承担的功能。[R6]')
bullet('量化数学','加速核需覆盖输入/权重偏移、INT32 累加、bias、逐通道尺度、舍入与饱和；不是只完成有符号乘加就等价于量化卷积。')
bullet('指令/总线边界','短、寄存器级运算适合 CI；大块图像搬运和长时矩阵任务优先 DMA + 内存映射启动/完成协议。CI 编码遵循所选 SoC 扩展接口，不在本版分配指令号。')
bullet('评价边界','报告整个预处理+推理+后处理时间，同时给出单算子数据。软件绕过硬件的对照不释放已综合的逻辑资源。')
note('旧示例的迁移边界','参考 EVSoC 手册为 2024 年 Draft，示例使用 Pi V2、HyperRAM 与 DSI；板卡若采用 SC431HAI、DDR3、HDMI，需逐项迁移，不能把参考工程视作即插即用。'.replace('不能','不应')+' [R3]')

# 14
new('13 / 创新主线与对照实验')
par('创新应体现“边缘检测为何帮助应用”和“FPGA/RISC-V 协同为何值得”。以下为待验证贡献，不预先宣称原创性或性能提升；原创程度还需针对具体方法补充文献检索。')
table(['候选贡献','实现内容','必须回答的问题'],[['I1 ROI 引导局部 AI','轮廓定位对象，保留局部细节，减少无关区域推理','相比整图缩放，小缺陷召回是否提高？相比全区域分块，计算量是否下降？'],['I2 自适应检测闭环','FPGA 提供亮度/梯度统计，RISC-V 有约束地更新阈值','相同光照变化下，是否降低误检且不引入振荡？'],['I3 同帧解释与复核','原帧、边缘、几何量、AI 分数和判定原因关联','不同模块是否使用同一对象/帧？误判是否可复现？']],[.23,.38,.39])
h2('最小有说服力的消融组合')
table(['对照','保持一致','主要观察'],[['规则几何 vs AI vs 融合','同一独立实物测试集','各类漏检/误报；融合是否优于单路'],['灰度 vs 边缘 vs 双通道','模型预算尽量匹配；训练协议一致','识别效果、推理耗时与输入开销'],['固定参数 vs 自适应参数','同一光照/噪声变化序列','轮廓稳定性、调节时间和参数抖动'],['软件路径 vs 硬件加速','模型、输入、频率与计时范围一致','端到端加速比、资源和输出一致性']],[.32,.36,.32])
bullet('自适应先用简单方法','先做分位数/直方图统计等确定性基线，给出参数上下限和滞回。只有其效果不足且数据充足时，再评估学习型控制。')
bullet('保留异常覆盖','边缘引导的采样还需覆盖对象内部，防止低对比污点缺少明显边缘而被跳过；记录 ROI 阶段造成的漏检。')
note('推荐集中投入','先以统一帧/ROI 底座选出有数据支持的主应用，再把 I1、I2 中收益明确的一项作为主创新，I3 用于系统展示和调试。语音、云端、多摄像头、复杂触控动画等与主线关联较弱，首版不扩展。')

# 15
new('14 / 当前证据与性能接受边界')
par('截至 2026-09-08，统一 full 回归 9/9 通过。下表周期覆盖 AXI 读取、ROI/缩放、结果写回及最后一个 B 响应；每项核对 2,073,600 个实际写回像素。预算为 100 MHz 下 1,666,667 cycles/frame。[R9]',SM)
table(['结果场景','周期','100 MHz 换算'],[['1280×720 → 1920×1080','1,039,655','10.397 ms'],['1920×1080 → 1920×1080','1,046,902','10.469 ms'],['960×540 ROI → 1920×1080','1,039,496','10.395 ms']],[.51,.23,.26])
par('上述为带确定背压与响应延迟的 AXI 模型，不是物理 DDR FPS。直接行流压力模型的三例为 3,461,340 / 1,944,505 / 1,474,264 cycles，前两项超过帧预算；输入供给不足时 2PPC 本身不保证实时。',SM)
h2('实际 Efinity P&R：Ti60F225 / I3')
table(['模式','XLR / RAM / DSP','最终 WNS / WHS'],[['camera 直通','28,424 / 89 / 4','+0.461 / +0.027 ns'],['pattern 彩条','16,080 / 84 / 0','+0.497 / +0.026 ns'],['timing_probe 帧引擎','20,074 / 114 / 6','+0.409 / +0.026 ns']],[.31,.34,.35])
par('工具 Efinity 2026.1.132.3.9；资源总量为 60,800 XLR、256 RAM、160 DSP。三版未分配核心引脚均为 0，保留 7 个未使用接口提示供实物核查。时序探针会裁减未使用分支，资源不与直通版直接相加。[R9]',SM)
bullet('完整动态参数核心','frame_render_engine 独立 map 为 LUT4 3,947、FF 2,539、DSP48 22、RAM10 14 + DPRAM10 16；这不是同一配置的整机 P&R。')
bullet('时序接受规则','关键结构改动后运行真实 P&R，检查临界路径、setup/hold、约束与源码身份。通过流水分级、比较并行化或存储结构修正问题，不用未解释的 false path 掩盖。')
note('后续分别报告四项速率','真实采集 fps、HDMI 刷新 Hz、新结果帧更新 fps、Canny/AI 分析更新率各自统计。记录帧延迟、结果年龄、错误/掉帧；运行时数据与构建资源/时序分开呈现。')

# 16
new('15 / 依赖驱动的实施计划')
table(['阶段 / 当前状态','具体交付','进入下一阶段的条件'],[['P0 主机底座 / 已完成','帧池、2PPC ROI、AXI 写回、结果发布；仿真与三版制品','9 项 full 通过；P&R 正裕量；源码/制品摘要一致'],['P1 外设工作点 / 待上板','实物核对 → 彩条 → DDR 校准 → 相机直通','颜色/方向/尺寸正确；真实帧率、稳定性与异常计数有记录'],['P2 真实帧闭环 / 待接入','RAW→RGB565、采集 DMA、DDR 仲裁、结果扫描与 CDC','真实 ROI、冻结/恢复、场消隐切换；无持有帧覆盖和显示欠载'],['P3 基础与高阶 / 分项实施','灰度/Sobel/中值/按键 → 彩色叠加/形状 → 完整 Canny/回放','同输入定点参考、同帧对齐、完整连通、每项资源与时延'],['P4 RISC-V + AI / 早期穿插评估','控制寄存器/固件；静态 INT8 → ROI 输入 → 按 profiling 加速','软件/硬件一致；arena 可容纳；显示不中断；实测端到端收益'],['P5 应用与交付 / 样本驱动','确定主应用；独立测试/消融；集成演示、报告与视频','误判可复现；长时运行；可从交付物重建和独立上电']],[.22,.42,.36])
par('P4 的最小 SoC/模型资源检查在 P1 稳定后穿插，不等全部高阶完成才评估容量；真实视频接入则以 P2 的帧/内存契约为前置。阶段按验收结果推进，不用到货日期代替任务完成条件。',SM)
h2('每次集成只增加一条可检查的链路')
bullet('输入与输出明确','指定测试图或操作、格式、尺寸、帧号和配置号；先静态帧，再相机帧，保留直通对照。')
bullet('验证与改动匹配','模块级定点/协议测试通过后做串接；结构变动检查 P&R。通过后只在新改动、新失败或明确疑点出现时重复。')
bullet('资源与状态可追溯','固定工具、IP、约束和模式；记录构建输入与 bit 摘要，保留回退点和必要日志。')
note('完成的定义','一个任务需有真实源码/配置、可重复输入或操作、可观察输出、对应验收记录。参考资料存在、RTL 仿真通过、P&R 通过、物理上板运行和应用指标达标分别记录。')

# 17
new('16 / 下一步接入任务与待决策')
table(['任务','输入 / 具体实现','接受条件'],[['T1 板卡/相机核对','PCB、丝印、FPC/转接板；确认所用 peri 与初始化','接口/供电/复位匹配；彩条与相机直通各自通过'],['T2 采集格式与 DMA','RAW 解包/去 Bayer → RGB565；SOF 申请 bank，完整 B 响应后发布','像素顺序/行长正确；无空闲时整帧丢弃且计数'],['T3 DDR 仲裁','采集写、渲染读、结果写、显示读；分析限额','混合访问带宽与最坏服务间隔满足预算，无长期饥饿'],['T4 扫描与跨域','结果描述符 → 扫描 DMA → 异步 FIFO → HDMI；vblank 握手','旧帧读请求排空后切 bank；无撕裂/欠载，几何字段原子更新'],['T5 参数与控制','先用最小参数入口，再接 RISC-V、按键和 UART','ROI/stride/尺寸合法；配置锁存与 ACK 一致；同帧结果可回查'],['T6 LCD 后接','JJX035FHD05-V9 DSI 初始化与转接板','核实手册电源脚标注差异；单屏显示通过，再评估双输出']],[.21,.47,.32])
h2('目前真正需要补齐的信息')
par('实物 PCB/相机/转接板版本与接线；相机模式和实际帧率；可获得的场景样本及成像条件；团队分工和可用工期。FPGA/相机型号基线、1080p60 目标及无触摸屏属性不再列成重复待选项。')
h2('工程约束与失败处理')
bullet('布局变更','当前源 bank 共用一套图像布局。源尺寸/stride 改变前排空任务并重置帧池；结果描述符携带独立尺寸，不直接当成连续 HDMI DE。')
bullet('异常归属','读写错误结果不发布；超时先告警，AXI 排空或协调复位前仍保持帧持有权。分析更新率可下调，但掉帧与旧结果年龄需显式统计。')
note('范围保持','下一步以 T1-T4 为主线，不同时引入新相机、新显示、多核或大模型。全部赛题功能仍保留在目标内，按上一页阶段逐项实现和接受。')

# 18
new('17 / 来源、版本与术语')
par('本版工程证据核对日期：2026-09-08。R1-R8 沿用 V1.0 已列资料与外部参考（原核查日期 2026-09-05）；本次不据其网页变化新增能力承诺。新增 R9 为当前本地验收记录。',SM)
refs=[
('R1','易灵思.pdf','用户参考资料；重点核对 PDF 第 12-17 页赛题四。页码按 PDF 顺序计。'),
('R2','Ti60F225_DemoBoard_v4完整资料包..zip','内含 TI60F225I3-V4 DEMO板软硬件设计说明-260813-1.pdf；本版核对 PDF 第 26 页 DDR、第 34 页按键表及目录。实物仍待确认。'),
('R3','1_3_EVSOC_tinyml用户手册_0416..pdf','TinyML User Guide Draft V2.0，2024-05-20；PDF 第 6-7 页为体系结构及 Pi V2/HyperRAM/DSI 示例。'),
]
for rid,title,desc in refs:
    par(f'<b>[{rid}] {escape(title)}</b><br/>{escape(desc)}',SM,gap=8)
online=[
('R4','Efinix MIPI CSI-2 RX Controller Core','https://www.efinixinc.com/support/ip/mipi-csi2-rx.php'),
('R5','Efinix TinyML Generator','https://github.com/Efinix-Inc/tinyml/blob/main/tools/tinyml_generator/README.md'),
('R6','Efinix TinyML FAQ：资源、profiling 与部署','https://github.com/Efinix-Inc/tinyml/blob/main/docs/faq.md'),
('R7','Efinix Titanium Ti60：器件资源','https://www.efinixinc.com/shop/ti60.php'),
('R8','OpenCV Canny：NMS 与滞后连接','https://docs.opencv.org/4.x/da/d22/tutorial_py_canny.html'),
]
for rid,title,url in online:
    par(f'<b>[{rid}] {escape(title)}</b><br/><link href="{url}" color="#087F8C">{url}</link>',SM,gap=8)
par('<b>[R9] 当前项目与验收证据</b><br/>vision_base/PROJECT.md；results/PREHARDWARE_REPORT.md；results/prehardware_acceptance.json；results/verification.full.json；artifacts/{camera,pattern,timing_probe}/manifest.json。以上均为 2026-09-08 本地核对结果。',SM)
table(['术语','含义'],[['CSI-2 / D-PHY','摄像头串行接口协议 / 物理层；不同于用于显示的 DSI'],['ROI / OSD / CDC','感兴趣区域 / 屏上叠加显示 / 跨时钟域'],['NMS / TFLM / CI','非极大值抑制 / TensorFlow Lite Micro / 自定义指令'],['WNS / TNS / P&R','最差负时序裕量 / 总负时序裕量 / 布局布线']],[.29,.71])
log.append({'page':page,'bottom':round(y,1)})
c.save()
(ROOT/'tmp'/'pdfs'/'v1_1/layout_check.json').write_text(json.dumps({'file':str(FILE),'pages':page,'layout':log},ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'file':str(FILE),'pages':page,'bytes':FILE.stat().st_size,'min_bottom':min(v['bottom'] for v in log)},ensure_ascii=False))
