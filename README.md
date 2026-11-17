# Vulcan Silicon Showcase — Public chip-family and reusable-IP catalog

[English](README.md) · [简体中文](README.zh-CN.md) · [Repository guide / 文件导航](REPOSITORY_GUIDE.md)

Documentation updated: 2026-11-17. This page describes a repository snapshot, not a live job dashboard.

## Overview

**Vulcan Silicon Showcase** publishes chip RTL, technical reports and verification artifacts. A navigation hub for public chip repositories and ten reusable IP examples. It is not a fleet-wide hardware signoff certificate.

The chip project is public; Vulcan itself remains private and closed-source. Future public releases must be limited to chip technology and public reproducibility materials, excluding Vulcan internal architecture and operating materials. This refresh organizes documentation only; it is not a comprehensive disclosure audit of historical material and does not claim that the existing repository tree has undergone such clearance.

## Scope and evidence

Use the [exact-directory result index](REPOSITORY_GUIDE.md). Functional simulation, synthesis, standalone/virtual-pin timing, board-bridge probing, workload readback and system-software execution are different evidence scopes. A pass at one scope does not establish another. Existing historical results are retained; this documentation refresh neither upgrades nor invalidates them.

Read timing, utilization and performance values from their specific records and applicability conditions; results from differently located copies are not merged. This page makes no fleet-wide claim of physical-board completion, full-model inference, physical Linux boot or measured power/energy efficiency.

## Repository guide

The [repository guide](REPOSITORY_GUIDE.md) lists existing source, constraints, tests, reports and result paths. Hyphenated, underscored and `chips/` directories can be different publication copies; none is silently designated authoritative, moved or deleted.

Start reproduction from the selected chip’s public specification, test instructions and scripts. Tool, input and board requirements belong to that directory. Chip experiments were not rerun as part of this documentation update.

## Reusable Datapath & Interconnect IP Gallery (`projects/`)

| IP Core | Highlights | Verification Summary |
| --- | --- | --- |
| [**Ready/valid FIFO**](projects/ready-valid-fifo/) | Parameterized buffering, backpressure, simultaneous enqueue/dequeue | 13 configs, 39 seeded runs, 82,645 cycles |
| [**Multi-channel DMA**](projects/multichannel-dma/) | Queued descriptors, round-robin scheduling, buffered 32-bit transfers | 7 RTL modules, 9 configs, Yosys synthesis |
| [**Packet router**](projects/packet-router/) | Store-and-forward queues, configurable routing, whole-packet arbitration | 17 configs, 51 seeded runs, 110,088 cycles |
| [**Memory fabric**](projects/memory-arbiter/) | Multi-client bank arbitration, reserved response slots, ordered retirement | 27 seeded runs, 6,624 measured transactions |
| [**Fixed-point stream processor**](projects/stream-processor/) | Interleaved 3-tap processing, saturation/wrap, buffered backpressure | 27 seeded runs, 56,945 cycles, 18,585 retirements |
| [**Credit-aware deficit scheduler**](projects/credit-scheduler/) | Byte-cost deficit round robin, outstanding credits, live configuration | 15 seeded runs, 145,884 cycles, 5,544 completions |
| [**Tagged completion and reorder**](projects/tagged-completion-reorder/) | Generation-tagged issue, out-of-order completion, ordered retirement | 5 RTL modules, 15 seeded runs, 320 compilations |
| [**Banked SECDED scratchpad**](projects/banked-ecc-scratchpad/) | SECDED ECC bank storage, atomic byte writes, background scrub | 7 RTL modules, 15 seeded runs, 19,526 transactions |
| [**Streaming bilinear image scaler**](projects/streaming-bilinear-image-scaler/) | Fixed-point 2D scaling, dual-row line buffer, backpressure recovery | 5 RTL modules, 15 seeded runs, 252 frames |
| [**Streaming LZ4 block decoder**](projects/streaming-lz4-block-decoder/) | Bounded byte-stream LZ4 decoding, overlapping RLE history copy | 18 seeded runs, 1,086 blocks, 85,275 decoded bytes |

---

Counts in this gallery are historical summaries from the linked project publications, not fresh measurements or board acceptance. The [repository guide](REPOSITORY_GUIDE.md) lists the ten example directories and their reports.

## Related projects

- AI / embeddings: [Anvil-Q](https://github.com/aHappend/anvil-q), [Anvil-E](https://github.com/aHappend/anvil-e), [Anvil-QN](https://github.com/aHappend/anvil-qn), [Anvil-EN](https://github.com/aHappend/anvil-en), [Anvil-D](https://github.com/aHappend/anvil-d).
- Systems: [Hammer-V](https://github.com/aHappend/hammer-v), [Furnace-X](https://github.com/aHappend/furnace-x).
- DSP / vision: [Billet-F](https://github.com/aHappend/billet-f), [Billet-T](https://github.com/aHappend/billet-t), [Swage-S](https://github.com/aHappend/swage-s).
- Data / security / graphics: [Bellows-L](https://github.com/aHappend/bellows-l), [Bellows-N](https://github.com/aHappend/bellows-n), [Rivet-A](https://github.com/aHappend/rivet-a), [Rivet-H](https://github.com/aHappend/rivet-h), [Crucible-G](https://github.com/aHappend/crucible-g), [SABLE](https://github.com/aHappend/sable).
- [Public fleet catalog](https://github.com/aHappend/vulcan-showcase). Related independent research: [ACE-2](https://github.com/aHappend/ace-2), [ACE-3](https://github.com/aHappend/ace-3); these retain their own provenance and acceptance boundaries.
- DSpark is a research direction, not a published chip delivery in this repository; no implementation or repository link is asserted here.
