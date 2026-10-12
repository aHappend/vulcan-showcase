# Buffered multi-channel DMA

A configurable SystemVerilog subsystem for queued memory-to-memory transfers.

**Highlights:** independent channel configuration, captured descriptor queues,
round-robin scheduling, buffered read/write overlap, explicit error handling,
response-based counters and interrupt control.

| Parameter | Default | Supported range |
| --- | --- | --- |
| `CHANNELS` | 4 | 1–16 |
| `DESC_DEPTH` | 2 queued descriptors per channel | 1–16 |
| `DATA_DEPTH` | 4 buffered words | 1–16 |

Transfers contain **1–256 aligned 32-bit words**, with independently fixed or
incrementing source and destination addresses. One descriptor is active at a
time; its read and write engines can overlap.

## Results

The accepted implementation contains **seven production RTL modules** and
**945 nonblank, non-comment RTL lines**. It passed nine regression
configurations and Yosys generic synthesis of the default configuration.
The regression includes transfer correctness, backpressure, arbitration,
configuration errors, reset, counters, interrupts and injected response errors.
The tested matrix is a subset of the supported parameter ranges.

## Integrate

Instantiate [`mc_dma`](rtl/mc_dma.sv) with all seven files in [`rtl/`](rtl/).
The subsystem uses one clock and synchronous active-high reset.

| Interface | Purpose |
| --- | --- |
| `cfg_req_*`, `cfg_rsp_*` | 32-bit configuration requests and responses |
| `rd_req_*`, `rd_rsp_*` | Read requests and ordered responses |
| `wr_req_*`, `wr_rsp_*` | Full-word write requests and ordered responses |
| `irq` | Masked channel completion/error interrupt |

These are custom ready/valid interfaces, not AXI or APB. A memory responder
must return exactly one ordered response per accepted request, no earlier than
the following cycle, and preserve response payloads under backpressure.
Reset must also discard outstanding transactions in the connected responder.

### Configuration

Global registers are `ID` at `0x0000`, `CAPABILITIES` at `0x0004`,
`IRQ_MASK` at `0x0008`, `IRQ_PENDING` at `0x000c` and `MAX_WORDS` at `0x0010`.
Channel `c` starts at `0x0100 + 0x40*c`:

| Offset | Register |
| --- | --- |
| `0x00` | Source address |
| `0x04` | Destination address |
| `0x08` | Word count |
| `0x0c` | Control: source increment, destination increment, interrupt enable |
| `0x10` | Start: write bit 0 with byte-zero strobe enabled |
| `0x14` | Status |
| `0x18` / `0x1c` / `0x20` | Completed descriptors / successful words / failed descriptors |
| `0x24` / `0x28` / `0x2c` | Interrupt status / acknowledgement / error causes |

Check the configuration response to confirm descriptor admission. Interrupts
are initially masked. Transfers are not atomic: an error can leave partial
writes, and overlapping ranges have no `memmove` guarantee. Burst transfers,
partial-word DMA writes and multiple concurrently active descriptors are not
implemented.

Compile from this directory with Icarus Verilog:

```bash
iverilog -g2012 -s mc_dma -t null rtl/*.sv
```

This command checks compilation; it does not rerun the reported regression.
Generic synthesis is not a timing, area, FPGA-deployment or silicon qualification.

---

**中文简介：** 多通道存储器搬运子系统，集成描述符队列、轮询仲裁、读写缓存、
配置寄存器、计数器与中断。默认 4 通道，支持 1–256 个 32 位整字搬运；
已完成九种配置的仿真回归和默认配置的通用综合。

[Vulcan website](https://ahappend.github.io/vulcan/) · [All designs](../../README.md)
