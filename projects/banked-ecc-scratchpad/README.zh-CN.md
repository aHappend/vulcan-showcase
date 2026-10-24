<div align="center">
  <h1>分体式 SECDED ECC 纠错片上暂存器子系统</h1>
  <p><strong>支持 39 位汉明纠一检二编码、原子字节掩码读改写与后台静默巡检纠错</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-7_RTL_Modules_%C2%B7_19,526_Txns-1d4ed8?style=flat-square" alt="Verification">
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

多 Bank 片上高可靠暂存器子系统，将每个 32 位数据字编码为 39 位 SECDED 纠一检二码字，支持原子字节写（Read-Modify-Write）、单比特错误透明纠正、双比特错误告警与后台自动巡检写回。

| 维度 | 已验收工程交付物 |
| :--- | :--- |
| **可综合 RTL 模块 (`rtl/`)** | [`rtl/banked_ecc_scratchpad.sv`](rtl/banked_ecc_scratchpad.sv)、[`rtl/scratchpad_bank.sv`](rtl/scratchpad_bank.sv)、[`rtl/scratchpad_csr.sv`](rtl/scratchpad_csr.sv)、[`rtl/scratchpad_frontend.sv`](rtl/scratchpad_frontend.sv)、[`rtl/scratchpad_maintenance.sv`](rtl/scratchpad_maintenance.sv)、[`rtl/secded_decode.sv`](rtl/secded_decode.sv)、[`rtl/secded_encode.sv`](rtl/secded_encode.sv) |
| **回归验证与签核记录** | 7 个可综合 RTL 模块 · 15 轮随机种子 · 19,526 笔 ECC 读写与后台巡检事务 |
| **开源协议** | [MIT License](../../LICENSE) |

## 快速编译与语法检查

使用 Icarus Verilog (`iverilog -g2012`) 对 `rtl/` 下的可综合 SystemVerilog 源码执行编译检查：

```bash
iverilog -g2012 -t null rtl/*.sv
```

完整的英文接口时序、参数定义与微架构说明请参阅英文文档 [`README.md`](README.md)。

---
<p align="center"><sub>作者：<strong>Sufeng Guo</strong> · 微软亚洲研究院 (Microsoft Research Asia) · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>
