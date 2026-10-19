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
  · <a href="#accelerator-families">Accelerators</a>
  · <a href="#reusable-rtl-families-and-systems">RTL families</a>
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
| [Streaming LZ4 block decoder](projects/streaming-lz4-block-decoder/) | Bounded byte-stream decoding, overlapping history copies, backpressure, ordered errors and block recovery | 18 seeded runs, 1,086 valid blocks, 85,275 compared decoded bytes, generic synthesis |

These designs completed their scoped RTL engineering acceptance. The source
files here are the accepted implementations, ready to explore and integrate.
Results describe simulation and, where stated, generic synthesis; they do not
claim silicon measurements or physical signoff.

## Delivery packages for new projects

Future additions will include a design delivery package, not just RTL:

- Accepted RTL, interface/architecture documentation and integration instructions.
- A public technical report (`REPORT.pdf`) and its source, with English-name
  attribution and no personal contact details.
- Reproducible verification sources, configuration/seed matrices, tool versions
  and commands, plus the simulation/synthesis evidence supporting the report.
- A project-relative evidence index: each published result must link to an
  included public artifact. Missing evidence and scope limits remain explicit.

Public reports are separate editions when private references need removal.
Technical results, thresholds and material limitations must not change during
publication; the public edition is reviewed after editing and rendering.
Closed framework code, prompts, provider sessions, credentials, private
experience capsules and internal operating records are not part of the package.
Evidence selection must preserve material failures and repairs, not present a
misleading success-only record. Redistribution rights must permit publication.

This standard applies to future additions. Existing entries remain selected
RTL releases; their reports and evidence are not being retroactively repackaged.

## Accelerator families

Beyond the ten component releases above, Vulcan supports the **ANVIL** AI
accelerator family. Publication state below is scoped to October 19, 2026.

| Family | Focus | Public delivery boundary |
| --- | --- | --- |
| **ANVIL — [E](https://github.com/aHappend/anvil-e) / [Q](https://github.com/aHappend/anvil-q)** | Text/vision embedding and quantized causal-inference RTL | E1/E2 and Q1 have published engineering packages and reports; E3/Q2 remain in development. Official-weight comparisons use bounded remapped slices, not complete target-model acceptance. Q1 converts binary16 storage to Q16.16 execution, not IEEE FP16 arithmetic. |

## Reusable RTL families and systems

RIVET and BILLET are grouped by family rather than listed as individual chips.
Generations, reports and verification details belong in their own repositories;
these are separate from the ten component releases.

| Family / system | Product lines | Public delivery boundary |
| --- | --- | --- |
| **RIVET** | [A — AES/GCM, key/context management and DMA](https://github.com/aHappend/rivet-a) · [H — SHA/HMAC and saved contexts](https://github.com/aHappend/rivet-h) | Generations 1–3 published in both lines, with scoped RTL/report packages |
| **BILLET** | [T — FFT/IFFT and spectral analysis](https://github.com/aHappend/billet-t) · [F — FIR/IIR filtering](https://github.com/aHappend/billet-f) | Generations 1–3 published in both lines; arithmetic, coefficient and configuration limits remain generation-specific |
| **[SABLE](https://github.com/aHappend/sable)** | Reliable-message transport protocol system | Published RTL/report package, with bounded protocol and simulation scope |

Publication does not imply fabricated silicon, physical signoff, full-model
validation or cryptographic certification. See each package's evidence and
limitations before reuse.

## Explore

- **[Project website](https://ahappend.github.io/vulcan/)** — meet Vulcan.
- **[ANVIL E](https://github.com/aHappend/anvil-e) / [Q](https://github.com/aHappend/anvil-q)** — accelerator-family packages, reports and current acceptance boundaries.
- **[RIVET & BILLET](#reusable-rtl-families-and-systems)** — grouped crypto/DSP RTL families and the SABLE protocol system.
- **[RTL projects](projects/)** — browse the released designs and their interfaces.
- **[Visual identity](brand/)** — original logos, marks and application icon.

New accepted designs will join this collection as they are released.

## License

Published code, documentation and artwork are provided under the [MIT License](LICENSE).
