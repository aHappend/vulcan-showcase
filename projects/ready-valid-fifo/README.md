# Ready/valid FIFO

A compact, parameterized SystemVerilog buffer for streaming datapaths.

**Highlights:** one clock, synchronous active-high reset, ready/valid
backpressure, simultaneous enqueue/dequeue at full capacity, explicit occupancy
and support for non-power-of-two depths.

| Parameter | Default |
| --- | --- |
| `DATA_WIDTH` | 8 bits |
| `DEPTH` | 4 entries |

The input handshake is `in_valid && in_ready`; the output handshake is
`out_valid && out_ready`. Payload order is preserved. There is no empty-state
combinational bypass. Reset clears occupancy and deasserts both handshakes;
storage contents need not be initialized.

## Results

The accepted design contains **52 nonblank, non-comment RTL lines**.
Recorded regression covers **13 configurations, 39 seeded runs and 82,645
cycles**, including reset, stalls, wraparound and simultaneous transfers.

## Use

The complete implementation is [`rtl/rv_fifo.sv`](rtl/rv_fifo.sv).
Instantiate `rv_fifo` with positive `DATA_WIDTH` and `DEPTH`.

Compile from this directory with Icarus Verilog:

```bash
iverilog -g2012 -s rv_fifo -t null rtl/rv_fifo.sv
```

This command checks compilation; it does not rerun the reported regression.

---

**中文简介：** 面向流式数据通路的单时钟参数化 FIFO，支持背压、同时入队出队、
占用量输出与非二次幂深度。已完成 13 种配置、39 组种子的仿真验收。

[Vulcan website](https://ahappend.github.io/vulcan/) · [All designs](../../README.md)
