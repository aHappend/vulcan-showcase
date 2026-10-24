<div align="center">
  <h1>流式 LZ4 数据块硬件解压引擎</h1>
  <p><strong>支持 Token 与扩展长度解析、重叠游程历史字典复制及异常压缩块恢复</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-18_Seeds_%C2%B7_85,275_Bytes-1d4ed8?style=flat-square" alt="Verification">
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

流式 LZ4 块解压硬件引擎，完整支持字面量拷贝、多字节扩展长度累加、滑动窗口历史字典回放（含 `offset < match_length` 重叠游程复制）与损坏块精确拦截。

| 维度 | 已验收工程交付物 |
| :--- | :--- |
| **可综合 RTL 模块 (`rtl/`)** | [`rtl/lz4_block_decoder.sv`](rtl/lz4_block_decoder.sv) |
| **回归验证与签核记录** | 18 轮随机种子回归 · 1,086 个压缩数据块 · 85,275 字节比特级精确解压 |
| **开源协议** | [MIT License](../../LICENSE) |

## 快速编译与语法检查

使用 Icarus Verilog (`iverilog -g2012`) 对 `rtl/` 下的可综合 SystemVerilog 源码执行编译检查：

```bash
iverilog -g2012 -t null rtl/*.sv
```

完整的英文接口时序、参数定义与微架构说明请参阅英文文档 [`README.md`](README.md)。

---
<p align="center"><sub>作者：<strong>Sufeng Guo</strong> · 微软亚洲研究院 (Microsoft Research Asia) · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>
