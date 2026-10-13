# Buffered fixed-point stream processor

A synthesizable SystemVerilog subsystem for interleaved, framed signal streams:
three signed taps, independent channel histories, frame-stable configuration,
and ordered, backpressured output.

**Highlights:** signed 16-bit samples and coefficients, exact 36-bit accumulation,
32-bit bias, arithmetic right shift, selectable saturation or wrap, clipping
flags, buffered ingress/egress, byte-strobed configuration and status registers,
explicit protocol errors, counters and interrupts.

| Parameter | Default | Supported range |
| --- | --- | --- |
| `CHANNELS` | 2 | 1-4 |
| `INPUT_DEPTH` | 2 | 1-8 |
| `OUTPUT_DEPTH` | 2 | 1-8 |

Each accepted sample carries a channel, an opaque eight-bit tag, and start/end
frame markers. A start-of-frame handshake captures that channel's pre-edge
shadow configuration and clears its two-sample history. Configuration writes
during a frame affect the next frame, not samples already accepted into queues.
History contains original inputs, never transformed outputs.

## Results

The accepted implementation contains **six RTL modules** and **519 nonblank,
non-comment RTL lines**. Its independent public-interface regression passed
**27 configuration/seed runs**: eight explicit parameter combinations and a
separately compiled default, each with seeds 11, 29 and 73. The mandatory runs
covered **56,945 simulation cycles** and **18,585 valid transformed retirements
after the final reset**, with 260-502 such retirements per channel per run.
Two endpoint smoke runs and six illegal-parameter rejection cases also passed.

Checks covered all three taps, interleaved histories, signed extrema, positive
and negative clipping, saturation and wrap, floor shifts, frame snapshots,
same-edge configuration precedence, queue wraps, stable stalled payloads,
reset epochs, malformed framing, byte strobes, errors and interrupts.
A disposable arithmetic corruption was detected as a specific output mismatch
with a nonzero checker exit; the accepted RTL was unchanged.

The observed minimum latency was **three cycles**. Under continuous valid/ready
traffic, a 200-cycle observation window retired 200 beats when both queue depths
were at least two, or 100 when either depth was one. These are scoped RTL-cycle
measurements, not a measured clock frequency or a universal latency guarantee.

Default-top Yosys generic synthesis completed with **11,122 generic cells**,
zero structural-check problems and no inferred latch cells. Four expected
counter-array lowering warnings were retained. These results are not exhaustive
formal proof, technology-mapped area, timing closure, power estimates, board
tests or silicon measurements. The tested matrix is a subset of supported
parameter combinations.

## Integrate

Instantiate [`stream_processor`](rtl/stream_processor.sv) with all six files in
[`rtl/`](rtl/), one clock, and synchronous active-high reset.

| Interface | Purpose |
| --- | --- |
| `in_*`, `out_*` | Ordered ready/valid samples and frame metadata |
| `csr_req_*`, `csr_rsp_*` | Custom 32-bit configuration/status access |
| `irq` | Masked sticky protocol, clipping and CSR-error indication |

Producers hold valid and payload until handshake. Queues use conservative
pre-edge occupancy: a full queue cannot accept a replacement on the same edge
that it pops, and an empty queue has no bypass. Reset flushes all queued work,
frame state, histories, configuration, counters and pending CSR responses.

Nested start markers flag an error and begin a new frame. Orphan or invalid
channel beats return zero data with an explicit error; their metadata and
global order are preserved. The CSR interface is **not AXI or APB**, allows one
pending response, rejects invalid accesses without changing targeted fields,
and gives new events priority over simultaneous write-one-to-clear operations.

---

[Vulcan website](https://ahappend.github.io/vulcan/) · [All designs](../../README.md)
