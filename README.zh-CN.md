<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="brand/logo-dark.svg">
    <img src="brand/logo.svg" width="480" alt="Vulcan">
  </picture>
</p>

<h1 align="center">把想法，锻造成硬件。</h1>

<p align="center">
  开源 RTL 设计，展示真实工程成果。
  <br>
  <a href="https://ahappend.github.io/vulcan/">访问官网</a>
  · <a href="#加速器家族">加速器家族</a>
  · <a href="#可复用-rtl-家族与系统">RTL 家族</a>
  · <a href="README.md">English</a>
  · <a href="brand/">品牌素材</a>
</p>

Vulcan 是独立的硬件工程项目，不属于 Argus AI Team。
它让 AI 参与硬件开发，将设计目标转化为可使用的 RTL 成果。
这里展示精选硬件作品、产品亮点和 Vulcan 的视觉形象。

## 精选作品

| 项目 | 产品亮点 | 已取得的结果 |
| --- | --- | --- |
| [Ready/valid FIFO](projects/ready-valid-fifo/) | 参数化缓存、背压、同时入队出队、非二次幂深度 | 13 种配置、39 组种子、82,645 个仿真周期 |
| [多通道 DMA](projects/multichannel-dma/) | 描述符队列、轮询仲裁、32 位缓存传输、状态与中断 | 7 个 RTL 模块、9 种回归配置、通用综合 |
| [分组路由器](projects/packet-router/) | 存储转发队列、可配置路由、并行输出、逐包仲裁 | 17 种配置、51 组种子、110,088 个仿真周期、通用综合 |
| [存储仲裁子系统](projects/memory-arbiter/) | 多客户端存储体仲裁、预留响应槽、顺序返回、错误与中断 | 27 组种子运行、8 组端点检查、6,624 笔测量事务、通用综合 |
| [定点流处理器](projects/stream-processor/) | 多通道三抽头运算、帧内配置快照、饱和/回绕、缓存背压 | 27 组种子运行、56,945 个仿真周期、末次复位后 18,585 笔有效结果、通用综合 |
| [信用约束赤字调度器](projects/credit-scheduler/) | 按字节成本累计赤字轮询、在途信用、不可撤销派发预留、实时配置 | 15 组种子运行、145,884 个仿真周期、末次复位后 5,544 笔完成事务、通用综合 |
| [带标签完成与重排子系统](projects/tagged-completion-reorder/) | 代际标签共享派发、乱序完成、客户端内顺序退休、实时状态 | 5 个 RTL 模块、15 组种子运行、末次复位后 15,658 笔退休事务、320 种合法参数编译 |
| [多存储体 SECDED 片上存储](projects/banked-ecc-scratchpad/) | 纠错存储、原子字节写、客户端顺序响应、后台巡检修复 | 7 个 RTL 模块、15 组种子运行、末次复位后 19,526 笔事务、128 种合法参数展开 |
| [流式双线性图像缩放器](projects/streaming-bilinear-image-scaler/) | 定点灰度缩放、双行缓存、帧内配置快照、背压与错误恢复 | 5 个 RTL 模块、15 组种子运行、252 个完整帧、8,520 个逐项比较像素、通用综合 |
| [流式 LZ4 块解压器](projects/streaming-lz4-block-decoder/) | 有界字节流解压、历史重叠复制、背压、有序错误与块间恢复 | 18 组种子运行、1,086 个有效块、85,275 个逐字节比较的解压字节、通用综合 |

这些设计均已完成相应范围的 RTL 工程验收，公开源码保留已验收实现。
所列结果来自仿真及明确注明的通用综合，不代表芯片实测或物理签核。

## 新项目的设计交付包

后续新增项目将提供设计交付包，而不只有 RTL：

- 已验收 RTL、接口与架构文档，以及集成说明。
- 公开技术报告（`REPORT.pdf`）及其源文件；只保留英文姓名署名，不含个人联系方式。
- 可复现的验证源码、参数与种子矩阵、工具版本和命令，以及支撑报告的仿真、综合证据。
- 使用项目相对路径的证据索引：公开结果必须指向包内实际提供的文件，缺失证据与范围限制明确列出。

涉及私有引用时，报告制作单独的公开版本。发布处理不得改变技术结果、验收阈值或
实质性限制；公开版在编辑与渲染后重新审查。闭源框架代码、提示词、后端会话、凭据、
私有经验胶囊和内部操作记录不属于公开交付包。证据选择必须保留重要失败与修复事实，
不能制造只有成功的误导性记录；第三方材料还须具备允许再分发的许可。

此标准仅用于后续新增项目。现有条目仍是精选 RTL 发布，不回头补做报告与证据打包。

## 加速器家族

除上述十个基础 IP 外，Vulcan 以 **ANVIL（铁砧）** AI 与大模型计算家族作为七大工坊芯片家族矩阵（`ANVIL`、`RIVET`、`BILLET`、`SWAGE`、`BELLOWS`、`CRUCIBLE`、`FURNACE`）的首要重心，并默认执行 `100 MHz+` 静态时序基线。

| 家族 | 方向 | 公开交付边界 |
| --- | --- | --- |
| **ANVIL — [Q](https://github.com/aHappend/anvil-q) / [E](https://github.com/aHappend/anvil-e)** | 量化因果大模型推理（`Q1` `108.48 MHz`、`Q2` `101.39 MHz`）与多模态嵌入（`E1` `107.31 MHz`、`E2` `111.45 MHz`、`E3` `111.63 MHz`）RTL | 全部五颗芯片（`Q1`、`Q2`、`E1`、`E2`、`E3`）均已发布 `100 MHz+` RTL 交付包、IEEE/ACM 学术论文级双轨单语报告（`SHOWCASE_REPORT.pdf` / `SHOWCASE_REPORT.zh-CN.pdf` / `REPORT.pdf`）、Quartus 17.1 TimeQuest STA 签核与 Intel Arria 10 GX PCIe Gen3x8 物理板级 HIL 实测证据。 |

## 可复用 RTL 家族与系统

RIVET、BILLET、SWAGE、BELLOWS、CRUCIBLE 与 FURNACE 与 ANVIL 共同构成七大工坊芯片家族矩阵。
各代实现、报告与验证细节保留在对应仓库；它们与上述十个基础 IP 分开。

| 家族 / 系统 | 产品线 | 公开交付边界 |
| --- | --- | --- |
| **RIVET（铆钉）** | [A — AES/GCM、密钥/上下文管理与 DMA](https://github.com/aHappend/rivet-a) · [H — SHA/HMAC 与可保存哈希上下文](https://github.com/aHappend/rivet-h) | 两条产品线均已发布第 1–3 代，提供限定范围的 RTL/报告交付包 |
| **BILLET（金属坯料）** | [T — FFT/IFFT 与频谱分析](https://github.com/aHappend/billet-t) · [F — FIR/IIR 滤波](https://github.com/aHappend/billet-f) | 两条产品线均已发布第 1–3 代；运算、系数及配置限制按各代分别声明 |
| **SWAGE（型锻模） / BELLOWS（风箱）** | 图像处理与 ISP（`Swage`）· 压缩、解压与流式数据处理（`Bellows`） | 首个核心已发布于 [`projects/streaming-bilinear-image-scaler/`](projects/streaming-bilinear-image-scaler/) 与 [`projects/streaming-lz4-block-decoder/`](projects/streaming-lz4-block-decoder/)；独立芯片系列按 `100 MHz+` 基线持续推进 |
| **CRUCIBLE（坩埚） / FURNACE（工业炉）** | 图形处理与渲染（`Crucible`）· 大型异构 SoC 与完整计算系统（`Furnace`） | 后续规划芯片系列，随核心 IP 与 `Anvil` 系列迭代推进 |
| **[SABLE](https://github.com/aHappend/sable)** | 可靠消息传输协议系统 | 已发布 RTL/报告交付包，保留协议及仿真的限定范围 |

公开发布不等于流片、物理签核、完整模型验证或密码安全认证。
复用前请阅读对应交付包的证据与限制。

## 探索更多

- **[Vulcan 官网](https://ahappend.github.io/vulcan/)**：了解产品。
- **[ANVIL E](https://github.com/aHappend/anvil-e) / [Q](https://github.com/aHappend/anvil-q)**：查看加速器家族交付包、报告与当前验收边界。
- **[RIVET 与 BILLET](#可复用-rtl-家族与系统)**：集中浏览密码/DSP RTL 家族及 SABLE 协议系统。
- **[开源设计](projects/)**：浏览 RTL 与接口介绍。
- **[视觉素材](brand/)**：原版 Logo、品牌图标与应用图标。

后续完成验收的设计将持续加入成果集。

## 许可

公开的代码、文档与视觉素材采用 [MIT License](LICENSE)。
