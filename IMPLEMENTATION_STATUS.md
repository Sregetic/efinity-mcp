# efinity-mcp v0.1.0 — 实施与验证状态

日期：2026-09-08

## GitHub 状态

目标仓库：`Sregetic/efinity-mcp`（Private）。初始化 README 已成功提交到 `main`，提交 SHA 为 `e00f5dd5d050e273c5a2b0962b3a8df2e0b402fc`。

随后用于上传主体代码的 `GitHub.create_tree` 调用被工具拦截，返回“因 OpenAI 无法确定请求的安全状态，已拦截此工具调用”。再次读取仓库根目录，确认只有 README.md。主体代码未上传，未创建后续提交或 PR，GitHub Actions 尚未运行。未通过换编码、拆分请求或更换写入渠道重试被拦截的操作。

本源码包保存的是本地完成的实现，不是已发布的 GitHub 版本。

## 软件实现

实现 13 个 MCP 工具：doctor、list_projects、get_project、preview_build、run_build、get_job、cancel_job、get_job_log、list_reports、read_report、scan_devices、preview_program、program_device。

支持已注册可信工程的 compile/map/interface/pnr/pgm/rtlsim/mapsim 命令构造与执行；任务轮询、取消、超时、工作区互斥、日志增长监控；报告原文及哈希读取；默认禁用的独立 JTAG 路径。

不含工程自动创建、器件引脚配置、任意 Tcl/Shell、Flash 擦写、远程 HTTP、无人值守 RTL 自修改。

## 实际运行结果

- 环境：Linux，Python 3.13.5。
- `python -m pytest -q --junitxml=test-results/local-pytest.xml`：**52 passed, 1 skipped in 17.77s**。
- 跳过项：真实 MCP SDK / stdio 协议测试。本地未安装 `mcp`，网络依赖获取失败，未将替身测试冒充真实协议验证。
- `python -m compileall -q src`：通过。
- `python -m pip wheel . --no-deps --no-build-isolation --no-index`：通过，生成 `efinity_mcp-0.1.0-py3-none-any.whl`。
- Wheel SHA-256：`f401b20f6b12176e50a48d7114edb738207f6c099837da17986386a02ec1c93a`。

测试输出保存在 `test-results/local-pytest.txt` 和 `test-results/local-pytest.xml`。这些测试使用明确标注 SYNTHETIC 的厂商替身程序，不接触实际硬件。

## 尚未验证

真实 MCP SDK 完整协议、Windows 进程与批处理调用、真实 Efinity 2026.1 编译与许可证、真实时序/资源报告、VF-Ti60F225 下载器和 JTAG 均未完成实测。GitHub Actions 工作流定义已包含在源码包，但尚未上传或运行。

使用前先阅读 README.md、SECURITY.md 和 docs/validation.md。保持 allow_programming=false，先用已经在 GUI 中编译成功的官方板卡工程完成只读检查和 map/compile 验证。不要把 0 退出码、绿色软件测试或合成报告当成硬件成功。
