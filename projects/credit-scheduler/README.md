# Credit-aware deficit scheduler

A synthesizable SystemVerilog scheduler for multiple independently buffered
request queues. Byte-cost deficit round robin shares dispatch service while
per-queue outstanding limits prevent issuing more work than a consumer can hold.

**Highlights:** accumulating capped deficits, multiple sends per eligible visit,
an irrevocable backpressured dispatch reservation, completion-credit returns,
live byte-strobed configuration, counters, sticky errors and interrupts.

| Parameter | Default | Supported range |
| --- | --- | --- |
| `QUEUES` | 3 | 1-4 |
| `DEPTH` | 2 | 1-8 |

Each queue accepts an eight-bit nonzero cost and an opaque 16-bit tag. The shared
dispatch channel preserves the selected queue, cost and tag while stalled.
Live configuration changes cannot withdraw an already presented dispatch.
Completions return one outstanding credit to the corresponding queue; they do
not carry tags or implement out-of-order result matching.

## Results

The accepted implementation is **one RTL module**, with **360 physical lines**
and **348 nonblank, non-comment lines**. Its independent public-interface
regression passed **15 configuration/seed runs**, covering **145,884 simulation
cycles**, **1,238,873 public-signal comparisons** and **15,083 CSR responses**.
The final reset epochs completed **5,544 transactions**, with **164-172 per
queue per run**, after all accepted work drained.

The mandatory matrix exercised `(QUEUES, DEPTH)` values `(1,1)`, `(1,3)`,
`(3,1)`, `(3,3)` and a separately compiled unoverridden `(3,2)` default,
each with seeds 13, 37 and 79. Additional endpoint checks covered `(4,8)` and
`(2,5)`; four illegal-parameter cases produced the expected nonzero exits.

Checks covered real multi-send deficit service, costly-head accumulation,
credit exhaustion and returns, queue wraps, stable stalled dispatch, live
configuration precedence, rejected ingress, erroneous completions, CSR
backpressure, byte strobes, write-one-to-clear event priority, interrupts and
reset. A disposable single-bit tag defect produced an exact output mismatch
and nonzero checker exit; production RTL was not overwritten.

Default-top Yosys 0.33 generic synthesis completed with **5,291 generic cells**,
zero structural-check problems and no inferred latches. Ten register-array
lowering warnings were retained and examined. Generic cells are not
technology-mapped area, timing closure or power measurements. The tested matrix
does not exhaust all legal parameter combinations; billion-event counter wraps,
formal exhaustiveness, board operation and physical signoff are not claimed.

## Integrate

Instantiate [`credit_scheduler`](rtl/credit_scheduler.sv) with one clock and
synchronous active-high reset.

| Interface | Purpose |
| --- | --- |
| `in_*` | Per-queue ready/valid cost and tag ingress, with explicit rejection |
| `dispatch_*` | One shared ready/valid dispatch reservation |
| `completion_*` | Per-queue completion credits and invalid-return indication |
| `csr_req_*`, `csr_rsp_*` | Custom 32-bit byte-strobed configuration/status access |
| `irq` | Masked sticky error indication |

Producers hold valid and payload until handshake. Reset discards buffered and
outstanding work, clears the dispatch reservation and restores configuration.
The CSR interface is **not AXI or APB** and allows one pending response. A new
event takes priority over clearing its sticky bit on the same edge. Progress
depends on downstream readiness, sufficient configured credits and valid
completion returns; permanent backpressure cannot have an unconditional bound.

---

[Vulcan website](https://ahappend.github.io/vulcan/) · [All designs](../../README.md)
