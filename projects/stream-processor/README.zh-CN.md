<div align="center">
  <h1>多流交织定点数字信号流处理器</h1>
  <p><strong>支持每通道独立三抽头滤波状态隔离、饱和/截断算术模式与背压弹性缓冲</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeds_%C2%B7_18,585_Retirements-1d4ed8?style=flat-square" alt="Verification">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="../../README.zh-CN.md">返回 Vulcan 作品集主页</a> ·
    <a href="rtl/">RTL 源码</a> ·
    <a href="README.md"><strong>English</strong></a>
  </p>
</div>

---

## 架构与工程总览

支持多通道交织输入的定点流处理器，内置通道级独立三抽头历史状态寄存器、可配置有符号饱和或回绕算术单元及零丢包背压输出缓冲。

| 维度 | 已验收工程交付物 |
| :--- | :--- |
| **可综合 RTL 模块 (`rtl/`)** | [`rtl/sp_arithmetic.sv`](rtl/sp_arithmetic.sv)、[`rtl/sp_csr.sv`](rtl/sp_csr.sv)、[`rtl/sp_frame_tracker.sv`](rtl/sp_frame_tracker.sv)、[`rtl/sp_quantizer.sv`](rtl/sp_quantizer.sv)、[`rtl/sp_queue.sv`](rtl/sp_queue.sv)、[`rtl/stream_processor.sv`](rtl/stream_processor.sv) |
| **回归验证与签核记录** | 27 轮随机种子回归 · 56,945 仿真周期 · 18,585 笔精确输出退役 |
| **开源协议** | [MIT License](../../LICENSE) |

## 快速编译与语法检查

使用 Icarus Verilog (`iverilog -g2012`) 对 `rtl/` 下的可综合 SystemVerilog 源码执行编译检查：

```bash
iverilog -g2012 -t null rtl/*.sv
```

完整的英文接口时序、参数定义与微架构说明请参阅英文文档 [`README.md`](README.md)。

---
<p align="center"><sub>作者：<strong>Sufeng Guo</strong> · 微软亚洲研究院 (Microsoft Research Asia) · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>
