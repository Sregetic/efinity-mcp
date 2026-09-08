# 官方接口依据与兼容范围

核对日期：2026-09-08。这里记录的是文档依据，不是本机运行证据。

## Efinity

- [Efinity Command-Line Interface User Guide v1.1](https://www.efinixinc.com/support/docsdl.php?pn=UG-EFN-CLI&s=ef)，PDF 第 4–7 页：环境初始化、`efx_run.py` 的工程位置参数、`--flow` 和 `--output_dir`。本文档封面为 May 2026；官网索引月份可能与封面不同。
- [Efinity Programmer User Guide v4.3](https://www.efinixinc.com/docs/efinity-pgm-v4.3.pdf)，PDF 第 22–27 页：`ftdi_program.py`、`--list_usb`、`-m jtag`、`--url`、`--aurl` 与 JTAG 的 `.bit` 输入要求。
- [官方文档索引](https://www.efinixinc.com/support/docs.php?p=e)：版本发生变化时，以安装版本的官方帮助重新核对。

Windows 官方还提供 `efx_run.bat`；本适配器在加载 `setup.bat` 后，直接用配置的厂商 Python 可执行文件调用公开文档所列 `scripts/efx_run.py`，避免依赖用户级 `.py` 文件关联。Linux 同样先加载 `setup.sh`。厂商 Python 自动查找路径只是兼容候选，不表示所有安装包布局相同；可在本地 TOML 中明确覆盖。

公开构建流不接受 `program`，也不接收自由格式 `--map_opts` / `--pnr_opts` / Tcl 字符串。`compile` 与 `pgm` 仅用于构建产物。JTAG 使用单独接口且不接受 Flash 操作；实际目标必须填写带序列号的 FTDI URL，不使用默认首个设备。第三方板下载器是否兼容此入口仍需现场验证。

## MCP 与客户端

- [官方 Python SDK v1 文档](https://py.sdk.modelcontextprotocol.io/v1/)。本版选择 `mcp>=1.28,<2` 的维护分支接口，明确禁止无意升级至破坏兼容性的 v2；这不是声称 v1 是最新主线。
- [官方 Codex MCP 配置入口](https://developers.openai.com/codex/mcp/)：本地 stdio 配置使用 `command` 和 `args`。客户端更新后应重新核对配置，不开启自动审批或扩大沙箱权限。

## 不做未经证实的接口承诺

v0.1.0 不使用未公开的内部脚本，不猜测 `.peri.xml` 或器件封装/引脚定义，不把 FPGA 内软核工具链当作 MCP 运行时，不推断 HTTP 硬件服务安全配置。Python API 工程创建、真实报告结构化解析、远程硬件调试将在实际环境验证后另行实现。
