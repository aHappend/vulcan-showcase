# Vulcan Silicon Showcase — 公开芯片家族与可复用 IP 目录

[English](README.md) · [简体中文](README.zh-CN.md) · [Repository guide / 文件导航](REPOSITORY_GUIDE.md)

文档更新：2026-11-17。本页对应仓库快照，不是实时作业看板。

## 概览

**Vulcan Silicon Showcase**：公开芯片家族与可复用 IP 目录。下方保留芯片技术与报告入口；具体实现范围以所链接目录、规范、测试和结果原件为准。

芯片项目公开；Vulcan 本身保持私有、闭源。今后公开发布仅限芯片技术与公开复现资料，不得包含 Vulcan 内部架构或运作资料。本次更新仅整理文档，并非对全部历史材料进行全面披露审查，也不声称既有仓库树已完成此类清查。

## 范围与证据

按实际目录核对[公开结果索引](REPOSITORY_GUIDE.md)。功能仿真、综合、独立 IP／虚拟引脚时序、板卡桥接探测、工作负载数值读回和系统软件执行是不同层级；一种通过不能替代另一种。现有历史结果保留，不因本次文档更新自动升级或作废。

时钟、资源与性能指标必须读取对应目录的原始记录和适用条件；同名副本不合并为一个数值。此处不宣称全系完成上板、完整模型推理、Linux 实机启动或功耗／能效测量。

## 文件导航

[文件与证据导航](REPOSITORY_GUIDE.md)列出真实存在的源码、约束、测试、报告及结果路径。连字符、下划线和 `chips/` 目录可能是不同发布副本，不自动指定某份为权威，也不移动或删除原件。

公开复现从对应芯片的规范、测试说明和脚本开始；所需工具、输入和板卡条件以该目录为准。文档更新没有重新执行芯片实验。

## 基础数据通路与互连 IP 库 (`projects/`)

| IP 核名称 | 架构特性 | 验证规模 |
| --- | --- | --- |
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

本表数量为所链接项目的历史发表摘要，不是新测量或板卡验收。[文件导航](REPOSITORY_GUIDE.md)列出十个示例目录及报告。

## 关联项目

- AI / embeddings: [Anvil-Q](https://github.com/aHappend/anvil-q), [Anvil-E](https://github.com/aHappend/anvil-e), [Anvil-QN](https://github.com/aHappend/anvil-qn), [Anvil-EN](https://github.com/aHappend/anvil-en), [Anvil-D](https://github.com/aHappend/anvil-d).
- Systems: [Hammer-V](https://github.com/aHappend/hammer-v), [Furnace-X](https://github.com/aHappend/furnace-x).
- DSP / vision: [Billet-F](https://github.com/aHappend/billet-f), [Billet-T](https://github.com/aHappend/billet-t), [Swage-S](https://github.com/aHappend/swage-s).
- Data / security / graphics: [Bellows-L](https://github.com/aHappend/bellows-l), [Bellows-N](https://github.com/aHappend/bellows-n), [Rivet-A](https://github.com/aHappend/rivet-a), [Rivet-H](https://github.com/aHappend/rivet-h), [Crucible-G](https://github.com/aHappend/crucible-g), [SABLE](https://github.com/aHappend/sable).
- [Public fleet catalog](https://github.com/aHappend/vulcan-showcase). Related independent research: [ACE-2](https://github.com/aHappend/ace-2), [ACE-3](https://github.com/aHappend/ace-3); these retain their own provenance and acceptance boundaries.
- DSpark 是研究方向，不代表本仓库已交付对应芯片；此处不虚构实现或仓库链接。
