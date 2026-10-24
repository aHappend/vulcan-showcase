<div align="center">
  <h1>流式二维双线性定点图像缩放加速器</h1>
  <p><strong>支持双行乒乓行缓冲、Q8.8 定点亚像素插值与无损背压流控</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Language-SystemVerilog_2012-0f766e?style=flat-square" alt="SV2012">
    <img src="https://img.shields.io/badge/Verification-5_RTL_Modules_%C2%B7_252_Frames-1d4ed8?style=flat-square" alt="Verification">
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

可综合流式二维双线性图像缩放硬件核，集成双行行缓冲（Line Buffer）、Q8.8 定点亚像素权重插值、任意输入/输出分辨率比例配置及全流水背压恢复。

| 维度 | 已验收工程交付物 |
| :--- | :--- |
| **可综合 RTL 模块 (`rtl/`)** | [`rtl/scaler_coordinates.sv`](rtl/scaler_coordinates.sv)、[`rtl/scaler_frame_control.sv`](rtl/scaler_frame_control.sv)、[`rtl/scaler_output.sv`](rtl/scaler_output.sv)、[`rtl/scaler_rows.sv`](rtl/scaler_rows.sv)、[`rtl/streaming_bilinear_scaler.sv`](rtl/streaming_bilinear_scaler.sv) |
| **回归验证与签核记录** | 5 个可综合 RTL 模块 · 15 轮随机种子 · 252 帧完整二维图像逐像素精确缩放 |
| **开源协议** | [MIT License](../../LICENSE) |

## 快速编译与语法检查

使用 Icarus Verilog (`iverilog -g2012`) 对 `rtl/` 下的可综合 SystemVerilog 源码执行编译检查：

```bash
iverilog -g2012 -t null rtl/*.sv
```

完整的英文接口时序、参数定义与微架构说明请参阅英文文档 [`README.md`](README.md)。

---
<p align="center"><sub>作者：<strong>Sufeng Guo</strong> · 微软亚洲研究院 (Microsoft Research Asia) · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="../../LICENSE">MIT License</a></sub></p>
