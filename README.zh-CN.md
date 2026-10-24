<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="brand/logo-dark.svg">
    <img src="brand/logo.svg" width="420" alt="Vulcan">
  </picture>
  <h1>Vulcan 芯片工坊总览 · 硬件重铸，智造未来</h1>
  <p><strong>100 MHz+ 可综合开源芯片家族矩阵 · Intel Arria 10 GX PCIe Gen3x8 板级在环签核 · IEEE/ACM 学术级双轨报告</strong></p>
  <p>
    <img src="https://img.shields.io/badge/已验证芯片-17_颗专用芯片_%2B_10_核_IP-0f766e?style=flat-square" alt="Chips">
    <img src="https://img.shields.io/badge/Quartus_17.1_STA-100_MHz%2B_时序基线-0f766e?style=flat-square" alt="STA">
    <img src="https://img.shields.io/badge/Intel_Arria_10_GX_HIL-100%25_实测通过-1d4ed8?style=flat-square" alt="HIL">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="https://ahappend.github.io/vulcan/">项目主页</a> ·
    <a href="https://github.com/aHappend/anvil-q">Anvil-Q (大模型)</a> ·
    <a href="https://github.com/aHappend/anvil-e">Anvil-E (多模态向量)</a> ·
    <a href="https://github.com/aHappend/billet-t">Billet-T (频谱变换)</a> ·
    <a href="https://github.com/aHappend/billet-f">Billet-F (数字滤波)</a> ·
    <a href="https://github.com/aHappend/rivet-a">Rivet-A (认证加密)</a> ·
    <a href="https://github.com/aHappend/rivet-h">Rivet-H (杂凑认证)</a> ·
    <a href="README.md"><strong>English</strong></a>
  </p>
</div>

---

**Vulcan** 是面向可综合数字芯片的自主硬件工程系统，将权威开源模型与协议规范全自动转化为 `100 MHz+` 可综合 SystemVerilog RTL、自检仿真与故障注入验证套件、Intel Arria 10 GX PCIe Gen3x8 物理板级在环（HIL）签核及中英文严格分离的 IEEE/ACM 学术论文级双轨报告。

## Vulcan 七大工坊芯片家族矩阵

| 芯片家族 | 工坊意象 | 领域定位与开源仓库 |
| :--- | :--- | :--- |
| **Anvil（铁砧）** *(当前核心重心)* | 承担核心计算任务的工坊重器 | AI 与大模型计算系列 — [**Anvil-Q**（开源量化大模型推理）](https://github.com/aHappend/anvil-q) · [**Anvil-E**（多模态向量表征）](https://github.com/aHappend/anvil-e) |
| **Billet（金属坯料）** | 基础材料经加工组合构建计算系统 | 数字信号处理系列 — [**Billet-T**（FFT/IFFT 与功率谱）](https://github.com/aHappend/billet-t) · [**Billet-F**（FIR 与级联 SOS-IIR 滤波）](https://github.com/aHappend/billet-f) |
| **Rivet（铆钉）** | 小而关键、牢固可靠的安全基石 | 密码、校验与数据完整性系列 — [**Rivet-A**（AES-GCM 与多上下文 DMA）](https://github.com/aHappend/rivet-a) · [**Rivet-H**（SHA-256/512 与 HMAC）](https://github.com/aHappend/rivet-h) |
| **Swage（型锻模）** | 将输入加工成形的精密模具 | 图像处理与 ISP 系列 — **Swage-S**（双线性图像缩放、3×3 空间卷积滤波、Bayer 去马赛克、色彩空间转换） |
| **Bellows（风箱）** | 收缩展开、连续高吞吐的数据流 | 压缩、解压与流式数据处理系列 — **Bellows-L**（流式 LZ4 解压/哈希压缩、多通道 XXH32/CRC32 DMA） |
| **Crucible（坩埚）** | 多种材料融合成形的渲染容器 | 图形处理与渲染系列（几何变换、纹理采样与光照融合管线） |
| **Furnace（工业炉）** | 整合多计算环节的系统级设备 | 大型异构 SoC 与完整多引擎计算系统系列 |

## 17 颗已签核芯片 `100 MHz+` 实测指标与双轨学术报告总表

| 系列 | 芯片代号 | 架构与数值规格 | Quartus 17.1 STA (`10.0 ns`) | Intel Arria 10 GX 资源占用 | PCIe Gen3x8 板级 HIL | 学术白皮书与开发者工程报告 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **ANVIL-Q** | [**Anvil-Q1**](https://github.com/aHappend/anvil-q/blob/main/anvil-q1/) | `Qwen/Qwen2.5-0.5B-Instruct-AWQ` · 24 层 `896d` 14:2 GQA · W4A16 G128 混合精度推理核 | `108.48 MHz` (`WNS +0.782 ns`) | `21,890 ALMs (5.12%) · 219 DSPs (14.43%) · 384 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/anvil-q/blob/main/anvil-q1/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/anvil-q/blob/main/anvil-q1/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/anvil-q/blob/main/anvil-q1/REPORT.pdf) |
| **ANVIL-Q** | [**Anvil-Q2**](https://github.com/aHappend/anvil-q/blob/main/anvil-q2/) | `Qwen/Qwen2.5-1.5B-Instruct-AWQ` · 28 层 `1536d` 12:2 GQA · 1/2/4-Bank 并行与 Q16/INT8 KV-Cache 压缩 | `101.39 MHz` (`WNS +0.137 ns`) | `34,200 ALMs (8.01%) · 384 DSPs (25.30%) · 512 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/anvil-q/blob/main/anvil-q2/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/anvil-q/blob/main/anvil-q2/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/anvil-q/blob/main/anvil-q2/REPORT.pdf) |
| **ANVIL-E** | [**Anvil-E1**](https://github.com/aHappend/anvil-e/blob/main/anvil-e1/) | `google/embeddinggemma-2` 纯文本版 · 24 层 5:1 混合注意力 · PLE 与 768D Matryoshka L2 归一化 | `107.31 MHz` (`WNS +0.681 ns`) | `18,420 ALMs (4.31%) · 128 DSPs (8.43%) · 192 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e1/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e1/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e1/REPORT.pdf) |
| **ANVIL-E** | [**Anvil-E2**](https://github.com/aHappend/anvil-e/blob/main/anvil-e2/) | `google/embeddinggemma-2` 视觉+文本双模态 · 16 层 ViT + 3x3 池化 + 24 层主干 | `111.45 MHz` (`WNS +1.027 ns`) | `23,550 ALMs (5.51%) · 192 DSPs (12.65%) · 312 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e2/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e2/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e2/REPORT.pdf) |
| **ANVIL-E** | [**Anvil-E3**](https://github.com/aHappend/anvil-e/blob/main/anvil-e3/) | `google/embeddinggemma-2` 音频+视觉+文本三模态 · 12 层 Conformer + 16 层 ViT + 24 层主干 | `111.63 MHz` (`WNS +1.042 ns`) | `26,480 ALMs (6.20%) · 224 DSPs (14.76%) · 360 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e3/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e3/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e3/REPORT.pdf) |
| **BILLET-T** | [**BILLET-T1**](https://github.com/aHappend/billet-t/blob/main/billet-t1/) | 256 点定点基 2 复数 FFT 引擎 · 双缓冲乒乓存储与位反转重排 | `128.29 MHz` (`WNS +2.205 ns`) | `4,120 ALMs (0.96%) · 16 DSPs (1.05%) · 16 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t1/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t1/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t1/REPORT.pdf) |
| **BILLET-T** | [**BILLET-T2**](https://github.com/aHappend/billet-t/blob/main/billet-t2/) | 运行时可配置 64/128/256/512 点正逆 FFT/IFFT 引擎 · 动态级联与 `1/N` 缩放饱和 | `141.42 MHz` (`WNS +2.929 ns`) | `5,480 ALMs (1.28%) · 24 DSPs (1.58%) · 24 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t2/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t2/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t2/REPORT.pdf) |
| **BILLET-T** | [**BILLET-T3**](https://github.com/aHappend/billet-t/blob/main/billet-t3/) | 4 通道 Hann 加窗、50% 帧重叠滑动 STFT 与功率谱密度（`|X[k]|^2`）引擎 | `141.42 MHz` (`WNS +2.929 ns`) | `7,860 ALMs (1.84%) · 32 DSPs (2.11%) · 36 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t3/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t3/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t3/REPORT.pdf) |
| **BILLET-F** | [**BILLET-F1**](https://github.com/aHappend/billet-f/blob/main/billet-f1/) | 可编程 1/8/16/32/64 阶有符号 16 位 FIR 滤波器 · 原子系数切换与全精度舍入饱和 | `170.01 MHz` (`WNS +4.118 ns`) | `3,240 ALMs (0.76%) · 32 DSPs (2.11%) · 8 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f1/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f1/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f1/REPORT.pdf) |
| **BILLET-F** | [**BILLET-F2**](https://github.com/aHappend/billet-f/blob/main/billet-f2/) | 4 通道交织 FIR 滤波器 · 双缓冲乒乓系数库与 1/2/4 并行乘加通道 | `162.31 MHz` (`WNS +3.839 ns`) | `6,180 ALMs (1.45%) · 64 DSPs (4.22%) · 20 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f2/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f2/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f2/REPORT.pdf) |
| **BILLET-F** | [**BILLET-F3**](https://github.com/aHappend/billet-f/blob/main/billet-f3/) | 级联二阶节 (SOS) IIR 递归滤波器与可配置 FIR/IIR 多级滤波链引擎 | `118.40 MHz` (`WNS +1.554 ns`) | `8,920 ALMs (2.09%) · 80 DSPs (5.27%) · 28 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f3/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f3/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f3/REPORT.pdf) |
| **RIVET-A** | [**RIVET-A1**](https://github.com/aHappend/rivet-a/blob/main/rivet-a1/) | FIPS-197 AES-128 加解密核心 · 在线轮密钥扩展与保序流式握手接口 | `458.93 MHz` (`WNS +7.821 ns`) | `2,150 ALMs (0.50%) · 0 DSPs · 4 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a1/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a1/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a1/REPORT.pdf) |
| **RIVET-A** | [**RIVET-A2**](https://github.com/aHappend/rivet-a/blob/main/rivet-a2/) | NIST SP 800-38D AES-128/256-GCM 认证加解密与 `GF(2^128)` GHASH 鉴别标签引擎 | `440.33 MHz` (`WNS +7.729 ns`) | `4,680 ALMs (1.10%) · 0 DSPs · 8 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a2/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a2/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a2/REPORT.pdf) |
| **RIVET-A** | [**RIVET-A3**](https://github.com/aHappend/rivet-a/blob/main/rivet-a3/) | 4 密钥槽、4 上下文优先级调度 AES-GCM 与描述符驱动 Scatter-Gather DMA 子系统 | `185.60 MHz` (`WNS +4.612 ns`) | `8,340 ALMs (1.95%) · 0 DSPs · 24 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a3/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a3/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a3/REPORT.pdf) |
| **RIVET-H** | [**RIVET-H1**](https://github.com/aHappend/rivet-h/blob/main/rivet-h1/) | FIPS 180-4 流式 SHA-256 引擎 · 完整字节计数与自动单/双块边界填充 | `251.51 MHz` (`WNS +6.024 ns`) | `2,480 ALMs (0.58%) · 0 DSPs · 4 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h1/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h1/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h1/REPORT.pdf) |
| **RIVET-H** | [**RIVET-H2**](https://github.com/aHappend/rivet-h/blob/main/rivet-h2/) | RFC 2104 / 4231 HMAC-SHA-256 引擎 · 超长密钥哈希归一化与流式上下文保存/恢复 | `251.51 MHz` (`WNS +6.024 ns`) | `4,320 ALMs (1.01%) · 0 DSPs · 12 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h2/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h2/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h2/REPORT.pdf) |
| **RIVET-H** | [**RIVET-H3**](https://github.com/aHappend/rivet-h/blob/main/rivet-h3/) | 4 通道带标签并发 SHA-256 / SHA-512（80 轮 64 位）与 HMAC 多上下文消息认证引擎 | `196.93 MHz` (`WNS +4.922 ns`) | `8,150 ALMs (1.91%) · 0 DSPs · 24 M20K` | **通过 (3/3)** | [**中文白皮书 PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h3/SHOWCASE_REPORT.zh-CN.pdf) · [**英文白皮书 PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h3/SHOWCASE_REPORT.pdf) · [**工程报告 PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h3/REPORT.pdf) |

## 基础数据通路与互连 IP 库 (`projects/`)

| IP 核名称 | 架构特性 | 验证规模 |
| :--- | :--- | :--- |
| [**Ready/valid FIFO**](projects/ready-valid-fifo/) | 参数化深度缓冲、反压控制、单周期同时读写 | 13 组配置、39 轮随机种子、82,645 仿真周期 |
| [**Multi-channel DMA**](projects/multichannel-dma/) | 描述符队列、轮询仲裁、32 位缓冲传输与中断状态 | 7 个 RTL 模块、9 组回归配置、Yosys 综合通过 |
| [**Packet router**](projects/packet-router/) | 存储转发队列、可配置路由表、整包无损仲裁 | 17 组配置、51 轮随机种子、110,088 仿真周期 |
| [**Memory fabric**](projects/memory-arbiter/) | 多客户端多 Bank 仲裁、预留响应槽、保序退役 | 27 轮随机种子、6,624 笔实测事务 |
| [**Fixed-point stream processor**](projects/stream-processor/) | 交织三抽头定点流水处理、饱和/截断与反压 | 27 轮随机种子、56,945 周期、18,585 笔有效退役 |
| [**Credit-aware deficit scheduler**](projects/credit-scheduler/) | 字节代价赤字轮询 (DRR)、信用流控与在线重配 | 15 轮随机种子、145,884 周期、5,544 笔完成 |
| [**Tagged completion and reorder**](projects/tagged-completion-reorder/) | 代际标签发射、乱序完成重排、按客户端保序退役 | 5 个 RTL 模块、15 轮随机种子、320 组参数编译 |
| [**Banked SECDED scratchpad**](projects/banked-ecc-scratchpad/) | SECDED ECC 纠一检二多 Bank 存储、原子字节写与后台巡检 | 7 个 RTL 模块、15 轮随机种子、19,526 笔事务 |
| [**Streaming bilinear image scaler**](projects/streaming-bilinear-image-scaler/) | 定点二维双线性图像缩放、双行缓冲与反压恢复 | 5 个 RTL 模块、15 轮随机种子、252 帧完整图像 |
| [**Streaming LZ4 block decoder**](projects/streaming-lz4-block-decoder/) | 流式 LZ4 块解压、重叠游程历史复制与错包恢复 | 18 轮随机种子、1,086 数据块、85,275 解压字节 |

---
<p align="center"><sub>作者：<strong>Sufeng Guo</strong> · 微软亚洲研究院 (Microsoft Research Asia) · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="LICENSE">MIT License</a></sub></p>
