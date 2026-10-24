<div align="center">
  <h1>带代际标签的乱序完成重排与保序退役单元</h1>
  <p><strong>支持动态标签分配、乱序完成捕获、代际隔离与按客户端保序退役</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-5_RTL_Modules_%C2%B7_320_Builds-1d4ed8?style=flat-square" alt="Verification">
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

面向分离事务（Split-Transaction）总线的乱序重排缓冲器，通过代际标签（Generation-Tagged）机制捕获乱序后端响应并严格按请求顺序退役。

| 维度 | 已验收工程交付物 |
| :--- | :--- |
| **可综合 RTL 模块 (`rtl/`)** | [`rtl/client_reorder.sv`](rtl/client_reorder.sv)、[`rtl/control_status.sv`](rtl/control_status.sv)、[`rtl/issue_reserver.sv`](rtl/issue_reserver.sv)、[`rtl/tag_owner_pool.sv`](rtl/tag_owner_pool.sv)、[`rtl/tagged_completion_reorder.sv`](rtl/tagged_completion_reorder.sv) |
| **回归验证与签核记录** | 5 个可综合 RTL 模块 · 15 轮随机种子回归 · 320 组参数矩阵编译通过 |
| **开源协议** | [MIT License](../../LICENSE) |

## 快速编译与语法检查

使用 Icarus Verilog (`iverilog -g2012`) 对 `rtl/` 下的可综合 SystemVerilog 源码执行编译检查：

```bash
iverilog -g2012 -t null rtl/*.sv
```

完整的英文接口时序、参数定义与微架构说明请参阅英文文档 [`README.md`](README.md)。

---
<p align="center"><sub>作者：<strong>Sufeng Guo</strong> · 微软亚洲研究院 (Microsoft Research Asia) · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>
