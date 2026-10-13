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
| [Memory fabric](projects/memory-arbiter/) | Multi-client bank arbitration, reserved response slots, ordered retirement, errors and interrupts | 27 seeded runs, eight endpoint checks, 6,624 measured transactions, generic synthesis |
| [Fixed-point stream processor](projects/stream-processor/) | Interleaved three-tap processing, frame-stable configuration, saturation/wrap, buffered backpressure | 27 seeded runs, 56,945 simulation cycles, 18,585 final-epoch valid retirements, generic synthesis |
| [Credit-aware deficit scheduler](projects/credit-scheduler/) | Byte-cost deficit round robin, outstanding credits, stable dispatch reservations, live configuration | 15 seeded runs, 145,884 simulation cycles, 5,544 final-epoch completions, generic synthesis |
| [Tagged completion and reorder](projects/tagged-completion-reorder/) | Shared generation-tagged issue, out-of-order completions, per-client ordered retirement, live status | Five RTL modules, 15 seeded runs, 15,658 final-epoch retirements, 320 legal parameter compilations |
| [Banked SECDED scratchpad](projects/banked-ecc-scratchpad/) | Error-protected bank storage, atomic byte writes, ordered client responses, background scrub | Seven RTL modules, 15 seeded runs, 19,526 final-epoch transactions, 128 legal parameter elaborations |
| [Streaming bilinear image scaler](projects/streaming-bilinear-image-scaler/) | Fixed-point grayscale scaling, two-row storage, frame-stable configuration, backpressure and error recovery | Five RTL modules, 15 seeded runs, 252 complete frames, 8,520 compared pixels, generic synthesis |

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
