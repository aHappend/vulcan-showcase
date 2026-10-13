# Banked SECDED scratchpad

[Vulcan](https://ahappend.github.io/vulcan/) |
[All designs](../../README.md) |
[MIT license](../../LICENSE)

A synthesizable, single-clock scratchpad combining independent memory banks,
ordered client responses, atomic byte writes and background error scrubbing.
Each 32-bit data word is stored as a 39-bit single-error-correcting,
double-error-detecting codeword.

## Product features

- Seven connected RTL module types: integration, client ownership and
  arbitration, atomic bank storage, maintenance and scrub control, live
  control/status registers, and separate SECDED encoding and decoding.
- One to four clients, one to four banks and one to eight rows per bank,
  including non-power-of-two sizes. Defaults are three clients, two banks
  and five rows per bank: ten data words.
- Two reserved transactions per client. Different banks can finish out of
  order while each client's responses remain in acceptance order and stable
  under backpressure.
- Partial writes correct the old word before merging bytes. An uncorrectable
  base rejects the partial write without changing storage; full writes can
  replace it. Reads correct returned data without repairing storage.
- Acknowledged maintenance XOR transactions, background stored-word repair,
  byte-strobed registers, counters, sticky status, write-one-to-clear and
  masked interrupts.

## Verified scope

Five separately compiled targets, including an unoverridden default, completed
**15 seeded runs** totaling **96,238 simulation cycles**. After the final reset,
the runs correctly compared **19,526 completed client transactions**, with
**229-1,867 per client per run**. Every tested client exceeded the declared
180-transaction, 24-read and 24-write minimums.

The default tests exercised all **39 individual codeword bit faults** and
**741 distinct double-bit pairs** per run on a known-written word. Every
mandatory run checked uncorrectable scrub progress, error reporting and
storage preservation, including the single-word configuration. An acknowledged
XOR undo followed by a clean read of the original data checked preservation
independently of an error-shaped response.

Parameter checks covered **128 legal elaborations**, 12 explicit endpoint and
non-power-of-two smoke targets plus a separately unoverridden default, and
nine explicit illegal-value diagnostics. These are not 128 full behavioral
regressions. Generic synthesis retained connected state-bearing modules,
195 storage bits per default bank and zero latches. A disposable result-bit
defect was rejected by the ordinary public-interface checker.

The seven files in [`rtl/`](rtl/) preserve the accepted implementation.
Local RTL, smoke-test and verification faults were corrected during development;
independent review also found and required repair of missing single-word scrub
coverage before acceptance. This is not a claim of defect-free development.

## Integration boundaries

Reset is synchronous and initializes actual storage to encoded zero, canceling
pending work. Bank services serialize client, maintenance and scrub operations
to avoid stale repair commits. Progress bounds require the declared service
eligibility and readiness assumptions, not permanent backpressure.

SECDED guarantees are limited to the stated single-bit and double-bit fault
domain. These results do not establish exhaustive system correctness, CDC
support, SRAM-macro timing, technology-mapped PPA, FPGA measurements, silicon
validation or physical signoff.
