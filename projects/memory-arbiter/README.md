# Ordered multi-client memory fabric

A synthesizable SystemVerilog subsystem that shares one or two external memory
banks among independent clients while preserving each client's response order.

**Highlights:** round-robin bank arbitration, queued requests, reserved completion
slots, stable stalled requests, cross-bank completion reordering, byte-strobed
writes, explicit errors, configuration/status registers and interrupts.

| Parameter | Default | Supported range |
| --- | --- | --- |
| `CLIENTS` | 3 | 1-8 |
| `BANKS` | 2 | 1 or 2 |
| `SLOTS` | 2 per client | 1-8 |

Requests carry an opaque eight-bit tag, a 16-bit byte address, 32-bit data and
four write strobes. Tags may repeat. For two banks, address bit 2 selects the
bank; unaligned requests instead receive an ordered local error.

## Results

The accepted implementation contains **eight RTL modules** and **624 nonblank,
non-comment RTL lines**. Its independent public-interface regression passed
**27 configuration/seed runs**: eight parameter combinations and an independently
compiled default, each with seeds 17, 41 and 97. The measured post-reset epochs
completed **96 transactions per client**, half reads and half writes, for
**6,624 transactions**. The mandatory runs covered **60,651 simulation cycles**,
including additional directed traffic. Eight endpoint smoke runs also passed.

Checks covered repeated tags, exact byte-write readback, full-slot backpressure,
concurrent banks, actual out-of-order bank completion with ordered client
retirement, errors, reset epochs, CSR snapshots, interrupts and error-dominant
W1C. Fairness was checked as a bound on available-bank grants, not an
unconditional latency promise. A disposable response-tag corruption was detected
as a transaction mismatch with a nonzero checker exit.

Default-top Yosys generic synthesis completed with **6,075 generic cells**, zero
structural-check problems and no remaining inferred latches. Six unique
memory-to-register lowering warnings were retained. These are scoped simulation
and generic-synthesis results, not exhaustive formal proof, technology-mapped
area, timing closure, power estimates, board tests or silicon measurements.
The tested matrix is a subset of the supported parameter ranges.

## Integrate

Instantiate [`memory_fabric`](rtl/memory_fabric.sv) with all eight files in
[`rtl/`](rtl/), using one clock and synchronous active-high reset.

| Interface | Purpose |
| --- | --- |
| `c_req_*`, `c_rsp_*` | Packed per-client request and ordered response channels |
| `b_req_*`, `b_rsp_*` | Independent external bank request and response channels |
| `csr_req_*`, `csr_rsp_*` | Custom 32-bit configuration/status interface |
| `irq` | Masked sticky error indication |

Producers hold valid and payload until handshake. Each bank accepts at most one
request awaiting response, and its responder must return exactly one response,
no earlier than the following clock edge. Completion storage is reserved at
client admission, so client backpressure does not block a contracted bank
response. Requests may experience documented per-client head-of-line blocking.
There is no fabricated timeout completion.

Reset flushes all outstanding transaction state and must also flush the external
responder; already committed external memory writes may remain. Writes and error
responses return zero data. The CSR interface is **not AXI or APB** and permits
one pending response. Invalid accesses return explicit errors.

Compile from this directory:

```bash
iverilog -g2012 -s memory_fabric -t null rtl/*.sv
```

This checks compilation only; it does not rerun the reported regression.

---

**中文简介：** 多客户端存储仲裁与响应路由子系统，支持请求排队、轮询仲裁、
跨存储体乱序完成与客户端顺序返回、字节写使能、错误和中断。已完成 27 组必需
配置/种子运行、8 组端点检查和默认配置通用综合；不代表物理签核。

[Vulcan website](https://ahappend.github.io/vulcan/) · [All designs](../../README.md)
