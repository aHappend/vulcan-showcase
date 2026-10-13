# Store-and-forward packet router

A configurable SystemVerilog switch with independent ingress queues and
whole-packet arbitration for each output.

**Highlights:** first-beat route capture, concurrent independent outputs,
backpressure, round-robin packet grants, byte-strobed configuration registers,
drop accounting and masked sticky interrupts.

| Parameter | Default | Supported range |
| --- | --- | --- |
| `INPUTS` / `OUTPUTS` | 3 / 3 | 1–16 each |
| `PACKET_SLOTS` | 2 per input | 1–16 |
| `MAX_WORDS` | 16 | 1–256 |

Packets contain 32-bit words. A four-bit tag selects one of sixteen configurable
routes on the first accepted beat; subsequent route changes do not redirect a
packet already in progress. Disabled routes, invalid destinations and oversized
packets are drained and dropped without exposing partial packets.

## Results

The accepted implementation contains **seven production RTL modules** and
**681 nonblank, non-comment RTL lines**. Its Icarus regression passed **51
configuration/seed runs**, covering sixteen parameter combinations and a
separately compiled default. Those runs totalled **110,088 simulation cycles**
and **3,060 seeded packet deliveries**, in addition to directed traffic.

Coverage includes routing updates, queue wrap/fullness, contention, concurrent
outputs, reset, stalls, CSR errors, counters, interrupts and bounded-readiness
fairness. A disposable output-data corruption was detected by the independent
interface checks. Default Yosys generic synthesis completed with zero check
problems and no inferred latches, producing **13,491 generic cells**. Six unique
counter-array conversion warnings were retained.

These are scoped simulation and generic-synthesis results, not exhaustive
formal proof, technology-mapped area, timing closure or silicon measurements.
The tested matrix is a subset of the supported parameter ranges.

## Integrate

Instantiate [`packet_switch`](rtl/packet_switch.sv) with all seven files in
[`rtl/`](rtl/). Use one clock and synchronous active-high reset.

| Interface | Purpose |
| --- | --- |
| `in_valid`, `in_ready`, `in_data`, `in_tag`, `in_last` | Flattened per-input packet lanes |
| `out_valid`, `out_ready`, `out_data`, `out_last` | Flattened per-output packet lanes |
| `csr_req_*`, `csr_rsp_*` | Custom 32-bit configuration requests and responses |
| `irq` | Masked sticky error indication |

Sources hold valid and payload until handshake. Outputs preserve packet order
within each input, never interleave packets, and retain payload while stalled.
Head-of-line blocking is intentional. Reset flushes partial and queued packets,
disables every route and clears counters, errors and interrupt masks. An absent
`last` does not fabricate a packet boundary.

The CSR interface is not AXI or APB. It permits one pending response, uses byte
addresses and byte strobes, and reports invalid accesses explicitly.

| Byte address | Register |
| --- | --- |
| `0x0000` / `0x0004` | Identification / version |
| `0x0008`–`0x0018` | Input/output counts, queue depth, maximum packet length and features |
| `0x0020` / `0x0024` / `0x0028` | W1C error status / interrupt mask / masked pending status |
| `0x0100 + 4*tag` | Route: destination in bits 7:0, enable in bit 8 |
| `0x0200 + 0x20*input` | Input counters, occupancy, descriptor count and state |
| `0x0500 + 0x10*output` | Transmitted packet/beat counters and busy state |

New errors dominate a same-edge W1C acknowledgement. Counters wrap modulo
2^32; the regression checks the oracle's rollover arithmetic, not a full
2^32-event hardware rollover.

Compile from this directory:

```bash
iverilog -g2012 -s packet_switch -t null rtl/*.sv
```

This checks compilation only; it does not rerun the reported regression.

---

**中文简介：** 可配置存储转发分组交换子系统，包含独立输入队列、逐包轮询仲裁、
并行输出、背压、路由配置、丢包计数和中断。已完成 17 种配置、51 组种子运行、
110,088 个仿真周期及默认配置通用综合；不代表物理签核。

[Vulcan website](https://ahappend.github.io/vulcan/) · [All designs](../../README.md)
