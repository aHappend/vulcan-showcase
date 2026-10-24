<div align="center">
  <h1>存储转发多端口片上数据包路由器</h1>
  <p><strong>支持可配置路由表、输入端口缓冲队列、整包无损仲裁与错包安全丢弃</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-17_Configs_%C2%B7_110,088_Cycles-1d4ed8?style=flat-square" alt="Verification">
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

可综合存储转发式片上数据包路由器，支持在线配置路由表、输入端独立缓冲队列、多端口并发争用下的整包原子仲裁以及异常帧自动隔离丢弃。

| 维度 | 已验收工程交付物 |
| :--- | :--- |
| **可综合 RTL 模块 (`rtl/`)** | [`rtl/packet_arbiter.sv`](rtl/packet_arbiter.sv)、[`rtl/packet_csr.sv`](rtl/packet_csr.sv)、[`rtl/packet_descriptors.sv`](rtl/packet_descriptors.sv)、[`rtl/packet_ingress.sv`](rtl/packet_ingress.sv)、[`rtl/packet_output.sv`](rtl/packet_output.sv)、[`rtl/packet_routes.sv`](rtl/packet_routes.sv)、[`rtl/packet_switch.sv`](rtl/packet_switch.sv) |
| **回归验证与签核记录** | 17 组配置 · 51 轮随机种子回归 · 110,088 仿真周期 · 整包零损毁 |
| **开源协议** | [MIT License](../../LICENSE) |

## 快速编译与语法检查

使用 Icarus Verilog (`iverilog -g2012`) 对 `rtl/` 下的可综合 SystemVerilog 源码执行编译检查：

```bash
iverilog -g2012 -t null rtl/*.sv
```

完整的英文接口时序、参数定义与微架构说明请参阅英文文档 [`README.md`](README.md)。

---
<p align="center"><sub>作者：<strong>Sufeng Guo</strong> · 微软亚洲研究院 (Microsoft Research Asia) · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>
