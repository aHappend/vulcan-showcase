<div align="center">
  <h1>多通道轮询描述符 DMA 传输引擎</h1>
  <p><strong>支持描述符队列、多通道公平轮询仲裁、32 位缓冲突发传输与中断状态管理</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-7_RTL_Modules_%C2%B7_Yosys_Verified-1d4ed8?style=flat-square" alt="Verification">
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

可综合多通道直接内存访问（DMA）引擎，集成每通道独立描述符队列、工作保持型轮询调度器、32 位内部数据缓冲及完成/异常中断状态寄存器。

| 维度 | 已验收工程交付物 |
| :--- | :--- |
| **可综合 RTL 模块 (`rtl/`)** | [`rtl/dma_data_fifo.sv`](rtl/dma_data_fifo.sv)、[`rtl/dma_descriptor_queue.sv`](rtl/dma_descriptor_queue.sv)、[`rtl/dma_read_engine.sv`](rtl/dma_read_engine.sv)、[`rtl/dma_registers.sv`](rtl/dma_registers.sv)、[`rtl/dma_scheduler.sv`](rtl/dma_scheduler.sv)、[`rtl/dma_write_engine.sv`](rtl/dma_write_engine.sv)、[`rtl/mc_dma.sv`](rtl/mc_dma.sv) |
| **回归验证与签核记录** | 7 个可综合 RTL 模块 · 9 组回归测试配置 · Yosys 综合与零锁存器验证通过 |
| **开源协议** | [MIT License](../../LICENSE) |

## 快速编译与语法检查

使用 Icarus Verilog (`iverilog -g2012`) 对 `rtl/` 下的可综合 SystemVerilog 源码执行编译检查：

```bash
iverilog -g2012 -t null rtl/*.sv
```

完整的英文接口时序、参数定义与微架构说明请参阅英文文档 [`README.md`](README.md)。

---
<p align="center"><sub>作者：<strong>Sufeng Guo</strong> · 微软亚洲研究院 (Microsoft Research Asia) · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>
