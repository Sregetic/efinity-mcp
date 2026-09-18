局部仿真证据；bank_switch.v 是资料包原始模块，未作修改。

复现（在本目录中运行）：
```powershell
& C:/iverilog/bin/iverilog.exe -g2012 -s tb -o probe.vvp tb_bank_switch.sv bank_switch.v
& C:/iverilog/bin/vvp.exe probe.vvp
```

日志 result.txt 表示成功复现接口反例，而非断言设计正确。实际板上发生频率尚未测量。
