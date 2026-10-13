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
  · <a href="README.md">English</a>
  · <a href="brand/">品牌素材</a>
</p>

Vulcan 让 AI 参与硬件开发，将设计目标转化为可使用的 RTL 成果。
这里展示精选硬件作品、产品亮点和 Vulcan 的视觉形象。

## 精选作品

| 项目 | 产品亮点 | 已取得的结果 |
| --- | --- | --- |
| [Ready/valid FIFO](projects/ready-valid-fifo/) | 参数化缓存、背压、同时入队出队、非二次幂深度 | 13 种配置、39 组种子、82,645 个仿真周期 |
| [多通道 DMA](projects/multichannel-dma/) | 描述符队列、轮询仲裁、32 位缓存传输、状态与中断 | 7 个 RTL 模块、9 种回归配置、通用综合 |
| [分组路由器](projects/packet-router/) | 存储转发队列、可配置路由、并行输出、逐包仲裁 | 17 种配置、51 组种子、110,088 个仿真周期、通用综合 |
| [存储仲裁子系统](projects/memory-arbiter/) | 多客户端存储体仲裁、预留响应槽、顺序返回、错误与中断 | 27 组种子运行、8 组端点检查、6,624 笔测量事务、通用综合 |
| [定点流处理器](projects/stream-processor/) | 多通道三抽头运算、帧内配置快照、饱和/回绕、缓存背压 | 27 组种子运行、56,945 个仿真周期、末次复位后 18,585 笔有效结果、通用综合 |

这些设计均已完成相应范围的 RTL 工程验收，公开源码保留已验收实现。
所列结果来自仿真及明确注明的通用综合，不代表芯片实测或物理签核。

## 探索更多

- **[Vulcan 官网](https://ahappend.github.io/vulcan/)**：了解产品。
- **[开源设计](projects/)**：浏览 RTL 与接口介绍。
- **[视觉素材](brand/)**：原版 Logo、品牌图标与应用图标。

后续完成验收的设计将持续加入成果集。

## 许可

公开的代码、文档与视觉素材采用 [MIT License](LICENSE)。
