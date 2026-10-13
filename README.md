<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="brand/logo-dark.svg">
    <img src="brand/logo.svg" width="480" alt="Vulcan">
  </picture>
</p>

<h1 align="center">Hardware, forged anew.</h1>

<p align="center">
  Open RTL designs. Real engineering results.
  <br>
  <a href="https://ahappend.github.io/vulcan/">Visit the website</a>
  · <a href="README.zh-CN.md">中文</a>
  · <a href="brand/">Brand assets</a>
</p>

Vulcan brings AI-assisted hardware development to concrete, reusable designs.
This gallery presents selected RTL deliverables, product highlights and the
Vulcan visual identity.

## Featured designs

| Design | Highlights | Results |
| --- | --- | --- |
| [Ready/valid FIFO](projects/ready-valid-fifo/) | Parameterized buffering, backpressure, simultaneous enqueue/dequeue, arbitrary positive depths | 13 configurations, 39 seeded runs, 82,645 simulation cycles |
| [Multi-channel DMA](projects/multichannel-dma/) | Queued descriptors, round-robin scheduling, buffered 32-bit transfers, status and interrupts | Seven RTL modules, nine regression configurations, generic synthesis |
| [Packet router](projects/packet-router/) | Store-and-forward queues, configurable routing, concurrent outputs, whole-packet arbitration | 17 configurations, 51 seeded runs, 110,088 simulation cycles, generic synthesis |

These designs completed their scoped RTL engineering acceptance. The source
files here are the accepted implementations, ready to explore and integrate.
Results describe simulation and, where stated, generic synthesis; they do not
claim silicon measurements or physical signoff.

## Explore

- **[Project website](https://ahappend.github.io/vulcan/)** — meet Vulcan.
- **[RTL projects](projects/)** — browse the released designs and their interfaces.
- **[Visual identity](brand/)** — original logos, marks and application icon.

New accepted designs will join this collection as they are released.

## License

Published code, documentation and artwork are provided under the [MIT License](LICENSE).
