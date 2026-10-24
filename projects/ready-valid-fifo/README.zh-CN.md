<div align="center">
  <h1>Ready/Valid 参数化流式弹性 FIFO</h1>
  <p><strong>支持满容量同时读写、背压流控与任意非二次幂深度的单时钟可综合缓冲器</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-13_Configs_%C2%B7_82,645_Cycles-1d4ed8?style=flat-square" alt="Verification">
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

面向流式数据通路的单时钟参数化弹性 FIFO，支持标准 `ready/valid` 背压握手、满容量状态下同周期同时入队与出队、精确占用量输出以及非 2 次幂深度配置。

| 维度 | 已验收工程交付物 |
| :--- | :--- |
| **可综合 RTL 模块 (`rtl/`)** | [`rtl/rv_fifo.sv`](rtl/rv_fifo.sv) |
| **回归验证与签核记录** | 13 组参数配置 · 39 轮随机种子回归 · 82,645 仿真周期 · 0 误差 |
| **开源协议** | [MIT License](../../LICENSE) |

## 快速编译与语法检查

使用 Icarus Verilog (`iverilog -g2012`) 对 `rtl/` 下的可综合 SystemVerilog 源码执行编译检查：

```bash
iverilog -g2012 -t null rtl/*.sv
```

完整的英文接口时序、参数定义与微架构说明请参阅英文文档 [`README.md`](README.md)。

---
<p align="center"><sub>作者：<strong>Sufeng Guo</strong> · 微软亚洲研究院 (Microsoft Research Asia) · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>
