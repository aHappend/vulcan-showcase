<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="brand/logo-dark.svg">
    <img src="brand/logo.svg" width="420" alt="Vulcan">
  </picture>
  <h1>Vulcan Silicon Showcase · Hardware, Forged Anew</h1>
  <p><strong>Synthesizable 100 MHz+ Open Silicon Families · Intel Arria 10 GX PCIe Gen3x8 HIL · IEEE/ACM Dual-Track Reports</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Verified_Accelerators-17_Chips_%2B_10_IPs-0f766e?style=flat-square" alt="Chips">
    <img src="https://img.shields.io/badge/Quartus_17.1_STA-100_MHz%2B_Baseline-0f766e?style=flat-square" alt="STA">
    <img src="https://img.shields.io/badge/Intel_Arria_10_GX_HIL-100%25_Passed-1d4ed8?style=flat-square" alt="HIL">
    <img src="https://img.shields.io/badge/Author-Sufeng_Guo_(MSRA)-334155?style=flat-square" alt="Author">
    <img src="https://img.shields.io/badge/License-MIT-64748b?style=flat-square" alt="License">
  </p>
  <p>
    <a href="https://ahappend.github.io/vulcan/">Website</a> ·
    <a href="https://github.com/aHappend/anvil-q">Anvil-Q (LLM)</a> ·
    <a href="https://github.com/aHappend/anvil-e">Anvil-E (Embedding)</a> ·
    <a href="https://github.com/aHappend/billet-t">Billet-T (FFT/DSP)</a> ·
    <a href="https://github.com/aHappend/billet-f">Billet-F (FIR/IIR)</a> ·
    <a href="https://github.com/aHappend/rivet-a">Rivet-A (AES-GCM)</a> ·
    <a href="https://github.com/aHappend/rivet-h">Rivet-H (SHA/HMAC)</a> ·
    <a href="README.zh-CN.md"><strong>中文文档</strong></a>
  </p>
</div>

---

**Vulcan** is an autonomous hardware engineering system that turns authoritative model and protocol specifications into synthesizable `100 MHz+` SystemVerilog RTL, self-checking verification suites, Intel Arria 10 GX PCIe Gen3x8 hardware-in-the-loop (HIL) validation, and IEEE/ACM-grade dual-track PDF publications.

## Vulcan Seven-Family Workshop Silicon Matrix

| Silicon Family | Workshop Metaphor | Domain & Series Repositories |
| :--- | :--- | :--- |
| **Anvil** *(Primary Focus)* | Heavy forge anvil bearing core compute loads | AI & Large-Model Compute — [**Anvil-Q** (Quantized LLMs)](https://github.com/aHappend/anvil-q) · [**Anvil-E** (Multimodal Embeddings)](https://github.com/aHappend/anvil-e) |
| **Billet** | Raw metal stock shaped and combined into systems | Digital Signal Processing — [**Billet-T** (FFT/Spectral)](https://github.com/aHappend/billet-t) · [**Billet-F** (FIR/SOS-IIR Filters)](https://github.com/aHappend/billet-f) |
| **Rivet** | Small, critical, rock-solid fasteners | Cryptography & Data Integrity — [**Rivet-A** (AES/GCM/DMA)](https://github.com/aHappend/rivet-a) · [**Rivet-H** (SHA-256/512/HMAC)](https://github.com/aHappend/rivet-h) |
| **Swage** | Die-forming tool shaping inputs into target forms | Image Processing & ISP — **Swage-S** (2D Scaler, 3×3 Spatial Filter, Bayer Demosaic, CSC) |
| **Bellows** | Expanding/contracting continuous airflow | Streaming Data Compression — **Bellows-L** (LZ4 Decompressor, Hash-Table Compressor, XXH32 DMA) |
| **Crucible** | Vessel fusing diverse materials into form | Graphics Processing & Rendering (Geometry, Texture & Lighting Fusion) |
| **Furnace** | Industrial furnace integrating multiple stages | Heterogeneous SoCs & Complete Multi-Engine Compute Subsystems |

## Complete 17-Chip `100 MHz+` Silicon Signoff & Dual-Track Report Index

| Series | Accelerator | Architecture & Numerical Scope | Quartus 17.1 STA (`10.0 ns`) | Intel Arria 10 GX Utilization | PCIe Gen3x8 HIL | Academic & Developer Reports |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **ANVIL-Q** | [**Anvil-Q1**](https://github.com/aHappend/anvil-q/blob/main/anvil-q1/) | `Qwen/Qwen2.5-0.5B-Instruct-AWQ` · 24L `896d` 14:2 GQA · W4A16 Group-128 GEMV | `108.48 MHz` (`WNS +0.782 ns`) | `21,890 ALMs (5.12%) · 219 DSPs (14.43%) · 384 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/anvil-q/blob/main/anvil-q1/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/anvil-q/blob/main/anvil-q1/REPORT.pdf) |
| **ANVIL-Q** | [**Anvil-Q2**](https://github.com/aHappend/anvil-q/blob/main/anvil-q2/) | `Qwen/Qwen2.5-1.5B-Instruct-AWQ` · 28L `1536d` 12:2 GQA · 1/2/4-Bank AWQ + Q16/INT8 KV-Cache | `101.39 MHz` (`WNS +0.137 ns`) | `34,200 ALMs (8.01%) · 384 DSPs (25.30%) · 512 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/anvil-q/blob/main/anvil-q2/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/anvil-q/blob/main/anvil-q2/REPORT.pdf) |
| **ANVIL-E** | [**Anvil-E1**](https://github.com/aHappend/anvil-e/blob/main/anvil-e1/) | `google/embeddinggemma-2` Text-Only · 24L 5:1 Hybrid GQA · PLE + Matryoshka 768D L2 Norm | `107.31 MHz` (`WNS +0.681 ns`) | `18,420 ALMs (4.31%) · 128 DSPs (8.43%) · 192 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e1/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e1/REPORT.pdf) |
| **ANVIL-E** | [**Anvil-E2**](https://github.com/aHappend/anvil-e/blob/main/anvil-e2/) | `google/embeddinggemma-2` Vision+Text · 16L ViT + 3x3 Pooler + 24L Hybrid Backbone | `111.45 MHz` (`WNS +1.027 ns`) | `23,550 ALMs (5.51%) · 192 DSPs (12.65%) · 312 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e2/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e2/REPORT.pdf) |
| **ANVIL-E** | [**Anvil-E3**](https://github.com/aHappend/anvil-e/blob/main/anvil-e3/) | `google/embeddinggemma-2` Audio+Vision+Text Trimodal · 12L Conformer + 16L ViT + 24L Backbone | `111.63 MHz` (`WNS +1.042 ns`) | `26,480 ALMs (6.20%) · 224 DSPs (14.76%) · 360 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e3/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/anvil-e/blob/main/anvil-e3/REPORT.pdf) |
| **BILLET-T** | [**BILLET-T1**](https://github.com/aHappend/billet-t/blob/main/billet-t1/) | 256-Point Fixed-Point Radix-2 Complex FFT · Double-Buffered Ping-Pong Memory & Bit-Reversal | `128.29 MHz` (`WNS +2.205 ns`) | `4,120 ALMs (0.96%) · 16 DSPs (1.05%) · 16 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t1/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t1/REPORT.pdf) |
| **BILLET-T** | [**BILLET-T2**](https://github.com/aHappend/billet-t/blob/main/billet-t2/) | Runtime-Configurable 64/128/256/512-Point FFT/IFFT · Stage-by-Stage Schedule & `1/N` Scaling | `141.42 MHz` (`WNS +2.929 ns`) | `5,480 ALMs (1.28%) · 24 DSPs (1.58%) · 24 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t2/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t2/REPORT.pdf) |
| **BILLET-T** | [**BILLET-T3**](https://github.com/aHappend/billet-t/blob/main/billet-t3/) | 4-Channel Windowed 50%-Overlap STFT & Power-Spectrum (`|X[k]|^2`) Engine | `141.42 MHz` (`WNS +2.929 ns`) | `7,860 ALMs (1.84%) · 32 DSPs (2.11%) · 36 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t3/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/billet-t/blob/main/billet-t3/REPORT.pdf) |
| **BILLET-F** | [**BILLET-F1**](https://github.com/aHappend/billet-f/blob/main/billet-f1/) | Programmable 1/8/16/32/64-Tap Signed 16-Bit FIR · Atomic Coefficient Commit & Saturation | `170.01 MHz` (`WNS +4.118 ns`) | `3,240 ALMs (0.76%) · 32 DSPs (2.11%) · 8 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f1/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f1/REPORT.pdf) |
| **BILLET-F** | [**BILLET-F2**](https://github.com/aHappend/billet-f/blob/main/billet-f2/) | 4-Channel Interleaved FIR · Double-Buffered Coefficient Banks & 1/2/4 Parallel MAC Lanes | `162.31 MHz` (`WNS +3.839 ns`) | `6,180 ALMs (1.45%) · 64 DSPs (4.22%) · 20 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f2/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f2/REPORT.pdf) |
| **BILLET-F** | [**BILLET-F3**](https://github.com/aHappend/billet-f/blob/main/billet-f3/) | Cascaded Biquad SOS IIR + Configurable Multistage FIR->IIR / IIR->FIR Filter Chain | `118.40 MHz` (`WNS +1.554 ns`) | `8,920 ALMs (2.09%) · 80 DSPs (5.27%) · 28 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f3/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/billet-f/blob/main/billet-f3/REPORT.pdf) |
| **RIVET-A** | [**RIVET-A1**](https://github.com/aHappend/rivet-a/blob/main/rivet-a1/) | FIPS-197 AES-128 Encryption/Decryption · On-the-Fly Key Schedule & Tag-Preserving Handshake | `458.93 MHz` (`WNS +7.821 ns`) | `2,150 ALMs (0.50%) · 0 DSPs · 4 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a1/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a1/REPORT.pdf) |
| **RIVET-A** | [**RIVET-A2**](https://github.com/aHappend/rivet-a/blob/main/rivet-a2/) | NIST SP 800-38D AES-128/256-GCM Authenticated Encryption & `GF(2^128)` GHASH Tag Engine | `440.33 MHz` (`WNS +7.729 ns`) | `4,680 ALMs (1.10%) · 0 DSPs · 8 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a2/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a2/REPORT.pdf) |
| **RIVET-A** | [**RIVET-A3**](https://github.com/aHappend/rivet-a/blob/main/rivet-a3/) | 4-Key-Slot, 4-Context Priority-Scheduled AES-GCM & Descriptor-Driven Scatter-Gather DMA | `185.60 MHz` (`WNS +4.612 ns`) | `8,340 ALMs (1.95%) · 0 DSPs · 24 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a3/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/rivet-a/blob/main/rivet-a3/REPORT.pdf) |
| **RIVET-H** | [**RIVET-H1**](https://github.com/aHappend/rivet-h/blob/main/rivet-h1/) | FIPS 180-4 Streaming SHA-256 · Full Message-Length Accounting & Automatic 1/2-Block Padding | `251.51 MHz` (`WNS +6.024 ns`) | `2,480 ALMs (0.58%) · 0 DSPs · 4 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h1/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h1/REPORT.pdf) |
| **RIVET-H** | [**RIVET-H2**](https://github.com/aHappend/rivet-h/blob/main/rivet-h2/) | RFC 2104 / 4231 HMAC-SHA-256 · Long-Key Normalization & Mid-Stream Context Save/Restore | `251.51 MHz` (`WNS +6.024 ns`) | `4,320 ALMs (1.01%) · 0 DSPs · 12 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h2/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h2/REPORT.pdf) |
| **RIVET-H** | [**RIVET-H3**](https://github.com/aHappend/rivet-h/blob/main/rivet-h3/) | 4-Channel Tagged SHA-256 / SHA-512 (80-Round 64-Bit) & HMAC Multi-Context Authenticator | `196.93 MHz` (`WNS +4.922 ns`) | `8,150 ALMs (1.91%) · 0 DSPs · 24 M20K` | **PASSED (3/3)** | [**Whitepaper PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h3/SHOWCASE_REPORT.pdf) · [**Engineering PDF**](https://github.com/aHappend/rivet-h/blob/main/rivet-h3/REPORT.pdf) |

## Reusable Datapath & Interconnect IP Gallery (`projects/`)

| IP Core | Highlights | Verification Summary |
| :--- | :--- | :--- |
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
<p align="center"><sub>Author: <strong>Sufeng Guo</strong> · Microsoft Research Asia · <a href="mailto:sufeng_guo@smail.nju.edu.cn">sufeng_guo@smail.nju.edu.cn</a> · <a href="LICENSE">MIT License</a></sub></p>
