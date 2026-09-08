# efinity-mcp 当前实施状态

## v0.1.1：Windows 启动修复与本机接入

主体代码已经导入 GitHub，不再是只有 README 的仓库。原始 v0.1.0 ZIP、中文旧状态文件和 manifest 保留为历史快照。

本轮实现：

- 修复 Windows `cmd.exe` 含空格路径引号错误；保留 Linux 参数列表、失败传播和既有硬件门控。
- 失败任务返回退出码及获取日志的提示。
- 新增本地 CLI：`--init-config`、`--print-codex-config`、`--check-mcp`。不覆盖配置，不隐式启用 trusted 或烧录，不自动修改 Codex 配置。
- 增加真实 MCP stdio 构建成功/失败、轮询、日志和报告读取测试；新增 Windows setup 失败中止测试。

本轮本地 Linux 测试：68 项通过；真实 MCP 模块因本地无法安装 SDK 而跳过。GitHub CI 安装真实 SDK 并设置 `EFINITY_REQUIRE_MCP=1`，不得跳过协议测试。以本次提交对应的 Actions 结果为最终软件验证记录。

## 原始 CI 发现

v0.1.0 导入提交的 [CI 运行](https://github.com/Sregetic/efinity-mcp/actions/runs/34199351733)：Linux Python 3.11/3.12 通过；Windows Python 3.12 有 16 项失败，集中在厂商子进程启动路径。这是本轮修复依据，而不是已完成 Windows 验收的证据。

## 仍需用户电脑验证

真实 Efinity 安装、许可证、厂商 Python 路径、示例工程 map/compile、实际报告、VF-Ti60F225 下载器/JTAG 尚未实测。CI 的 Efinity 后端是 SYNTHETIC 替身；真实 MCP SDK、Windows 操作系统和子进程链路则由 CI 实际运行。

下一项外部依赖是 Efinity 安装目录和一个已经能在 GUI 中编译的工程 XML。先完成只读检查与 map/compile；保持 `allow_programming=false`。
