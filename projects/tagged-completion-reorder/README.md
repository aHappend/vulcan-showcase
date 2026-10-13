# Tagged completion and reorder subsystem

[Vulcan](https://ahappend.github.io/vulcan/) |
[All designs](../../README.md) |
[MIT license](../../LICENSE)

A synthesizable multi-client subsystem that accepts requests, shares a bounded
tagged issue channel, handles out-of-order completions and retires results in
acceptance order for each client. Independent response backpressure does not
change an already presented request or result.

## Product features

- Five connected RTL module types: top-level integration, tag ownership and
  generation tracking, per-client reorder storage, issue reservation, and live
  control/status registers.
- One to four clients, reorder depths of one to five, and one to sixteen tags.
  The default is three clients, depth three and seven tags.
- Byte-strobed control/status access, occupancy and transaction counters,
  explicit access errors, sticky events, write-one-to-clear and interrupts.
- Unknown, duplicate and stale completion handling within a declared finite
  generation lifetime; reset flushes outstanding work.

## Verified scope

Five separate configurations, including an unoverridden default, completed
15 seeded runs. After the final reset, the runs correctly retired **15,658
requests**, with **313–443 per client per run**, and checked **19,718 CSR
responses**. Each tested client wrapped its reorder pointers at least 62 times;
each physical tag was reused at least 76 times with at least nine generation
rollovers.

The parameter checks compiled all **320 legal combinations**, exercised nine
endpoint/non-power-of-two smoke cases, and confirmed explicit rejection of six
illegal parameter values. These compile checks are not 320 full behavioral
regressions. A disposable result-bit defect was rejected by the independent
association checker. Generic synthesis retained the connected state-bearing
modules and passed structural/no-latch checks.

The source in [`rtl/`](rtl/) is the accepted five-file implementation. Local
transactor, synthesis-parser and illegal-parameter diagnostic faults were found
and corrected during development; these results do not claim defect-free
development.

## Integration boundaries

Generations are three bits wide. External users must respect the finite stale
completion horizon and the reset/drain contract: arbitrarily old completions
cannot be distinguished after generation reuse. Progress is conditional on
the specified readiness and completion assumptions, not guaranteed under
permanent backpressure.

These are scoped RTL simulation and generic synthesis results, not physical
signoff, technology-mapped PPA, FPGA measurements or silicon validation.
