<div align="center">
  <h1>多客户端分体存储互连与保序退役网络</h1>
  <p><strong>支持多 Bank 冲突仲裁、预留响应槽背压防死锁与每客户端严格按序退役</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-27_Seeded_Runs_%C2%B7_6,624_Txns-1d4ed8?style=flat-square" alt="Verification">
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

面向多客户端并发访存的分体式片上存储互连网络，支持跨独立 SRAM Bank 的并行仲裁，并通过预留重排响应槽严格保证各客户端读写响应按序无死锁退役。

| 维度 | 已验收工程交付物 |
| :--- | :--- |
| **可综合 RTL 模块 (`rtl/`)** | [`rtl/memory_fabric.sv`](rtl/memory_fabric.sv)、[`rtl/mf_bank_decode.sv`](rtl/mf_bank_decode.sv)、[`rtl/mf_bank_issue.sv`](rtl/mf_bank_issue.sv)、[`rtl/mf_client_queue.sv`](rtl/mf_client_queue.sv)、[`rtl/mf_completion.sv`](rtl/mf_completion.sv)、[`rtl/mf_csr.sv`](rtl/mf_csr.sv)、[`rtl/mf_response_owner.sv`](rtl/mf_response_owner.sv)、[`rtl/mf_rr_arbiter.sv`](rtl/mf_rr_arbiter.sv) |
| **回归验证与签核记录** | 27 轮随机种子回归 · 6,624 笔实测访存事务 · 0 顺序或数据冲突 |
| **开源协议** | [MIT License](../../LICENSE) |

## 快速编译与语法检查

使用 Icarus Verilog (`iverilog -g2012`) 对 `rtl/` 下的可综合 SystemVerilog 源码执行编译检查：

```bash
iverilog -g2012 -t null rtl/*.sv
```

完整的英文接口时序、参数定义与微架构说明请参阅英文文档 [`README.md`](README.md)。

---
<p align="center"><sub>作者：<strong>Sufeng Guo</strong> · 微软亚洲研究院 (Microsoft Research Asia) · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>
