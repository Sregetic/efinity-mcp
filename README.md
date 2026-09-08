# efinity-mcp

面向 Efinix Efinity 的本地 MCP 适配器。目标是让支持本地 stdio MCP 的客户端调用已有 FPGA 工程的构建流程、读取原始日志与报告，并在明确授权后进行 JTAG 配置。

**v0.1.0 是待真机验收的首版，不是 Efinix 官方产品。** 软件测试使用合成的替身程序，不代表已经在 Efinity 2026.1 或 VF-Ti60F225 上完成综合、时序收敛或烧录。该仓库不包含 Efinity 安装包、许可证、厂商 IP、板卡工程或真实位流。

## 已实现的范围

| 能力 | v0.1.0 行为 |
|---|---|
| MCP 服务 | 官方 Python SDK v1，stdio；不监听网络端口 |
| 环境检查 | 检查安装目录、setup 脚本、厂商 Python、flow/programmer 脚本是否存在 |
| 工程注册 | 由本地 TOML 显式登记工程 ID、XML 和输出目录，逐工程授权执行 |
| 构建/仿真 | `compile`、`map`、`interface`、`pnr`、`pgm`、`rtlsim`、`mapsim` |
| 长任务 | 即时返回 job ID，轮询、取消、超时、日志增长监控、工作区互斥 |
| 日志与报告 | 有界日志尾部；原始报告按行读取；记录文件哈希与本次变化 |
| 设备枚举 | 通过厂商 `--list_usb` 获取 USB 信息，结果在 job 日志中 |
| JTAG | 默认关闭；指定序列号、预览 SHA-256、明确确认后提交；使用已确认文件快照 |

**特别注意：`pgm` 是生成位流，不是烧录。** 普通构建接口拒绝 `program`，JTAG 接口只接受 `.bit`，不自动把 `.hex` 当成 JTAG 输入，也不提供 Flash 擦写模式。命令依据见 [官方接口来源](docs/vendor-interfaces.md)。

## 快速开始：Windows

先安装独立的 **Python 3.11 或更高版本**，用于本服务；Efinity 自带 Python 只用于厂商脚本，不在其中安装 MCP 依赖。以下路径只是示例。

```powershell
git clone https://github.com/Sregetic/efinity-mcp.git
cd efinity-mcp
py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -e ".[dev]"
Copy-Item examples\efinity-mcp.windows.toml efinity-mcp.local.toml
```

使用你实际安装的 Python 版本替换 `-3.12`。编辑 `efinity-mcp.local.toml`，填写 Efinity 安装路径和**已在 GUI 中验证的官方/板卡示例工程**。然后运行：

```powershell
.\.venv\Scripts\python.exe -m efinity_mcp --config efinity-mcp.local.toml --doctor
```

`toolchain_available: true` 仅代表必要文件存在，**不代表许可证、工程、下载器或板卡通过验收**。自动寻找厂商 Python 失败时，按 doctor 提示在 `[efinity]` 中设置真实 `python.exe` 路径。不要把 MCP 虚拟环境解释器误填成厂商解释器。

服务启动命令：

```powershell
.\.venv\Scripts\python.exe -m efinity_mcp --config efinity-mcp.local.toml
```

该命令进入 stdio 服务，等待 MCP 客户端，不显示图形窗口。实际使用时应由客户端启动它；配置样例见 [examples/codex.toml](examples/codex.toml)。

Linux 参见 [examples/efinity-mcp.linux.toml](examples/efinity-mcp.linux.toml)。安装方式是 `python3 -m venv .venv` 后通过 `.venv/bin/python -m pip install -e .` 安装。厂商进程启动前会单独加载 Efinity 的 `bin/setup.sh`；Windows 则加载 `bin/setup.bat`，不会修改系统级环境变量。

## 推荐的首轮操作

先用 `doctor`、`list_projects`、`get_project`、`preview_build` 做只读检查。确认官方示例、工程 XML、引脚和约束可信后，由操作人在本地把该工程的 `trusted` 改成 `true`，重启 MCP 服务。

然后调用 `run_build(project_id="edge", flow="map")`，记录返回的 ID，使用 `get_job` 轮询并用 `get_job_log` 查看日志。基础综合成功后才运行 `compile`。最后调用 `list_reports(project_id="edge", job_id="...")` 和 `read_report` 读取本次生成/变更的文件。

不要同时在 GUI 和 MCP 中构建同一个输出目录，也不要在构建中途修改 RTL 或约束。分阶段 `pnr` / `pgm` 依赖已有前序产物，本服务不伪造或自动推断这些依赖。

## 正确解释结果

`status="succeeded"` 表示厂商**进程退出码为 0**，不表示 RTL 功能正确、时序完全约束、所有时钟满足要求、引脚电压安全或硬件运行正确。v0.1.0 不在未获得真实报告样本的情况下猜测 WNS/LUT 表格格式；`timing_pass` 保持 `null`，以原始报告为准。

每次任务记录命令、时间、退出码、工程 XML 哈希、产物哈希。`job_id` 过滤只列出本次新建/变化的产物；文件后来被改动会标记 `changed_since_job`。这不是完整工程快照，源代码版本仍应由 Git 管理。扫描有上限，截断与跳过计数会显式返回。

## 安全边界

配置中 `trusted=false`、`allow_programming=false` 为默认值。没有任意 Shell/Tcl、任意文件写入、自动重试烧录、自动选第一个下载器或远程 HTTP 服务。MCP 参数不能修改信任配置。

**这不是沙箱。** 已授权 Efinity 工程中的 Tcl、脚本、仿真代码等可能以当前用户权限运行，外部引用也不由本适配器完全审计。只运行自己或老师已审核的工程，使用普通用户账户。MCP 客户端应保留工具审批，不要把设备控制授予陌生客户端。详细边界见 [SECURITY.md](SECURITY.md)。

仅把代码上传 GitHub 不会让本对话直接获得你电脑上的 Efinity：需要在安装 Efinity 的电脑上安装本服务，并在本地 MCP 客户端中配置。远程连接和身份认证不属于此版范围。

## 开发与测试

```bash
python -m pip install -e ".[dev]"
python -m pytest -q
python -m compileall -q src
python -m build
```

CI 在 Linux/Windows 上安装真实 MCP SDK，并强制执行 stdio 握手、工具发现及调用测试。其 Efinity 后端仍是 `tests/conftest.py` 中明确标注的替身，不下载商业 EDA，也不接触 FPGA。没有安装 SDK 的离线环境会跳过协议测试；CI 设置 `EFINITY_REQUIRE_MCP=1`，不允许因缺依赖而跳过。

首轮真机验收、已知限制和下一阶段工作见 [docs/validation.md](docs/validation.md) 和 [docs/roadmap.md](docs/roadmap.md)。

## 许可证

适配器原创代码采用 MIT License。Efinity、厂商库及第三方依赖仍受各自许可证约束。
