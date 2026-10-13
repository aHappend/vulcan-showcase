# Streaming LZ4 block decoder

A bounded, single-clock SystemVerilog decoder for raw LZ4 blocks, with byte-wide
ready/valid input and output. It handles literal and match-length extensions,
little-endian offsets, overlapping copies, backpressure and recoverable errors.
It is not a frame decoder or compressor and does not use a cross-block dictionary.

[Vulcan website](https://ahappend.github.io/vulcan/) · [Design gallery](../../)

## Interface and integration

The synthesizable top is [`lz4_block_decoder`](rtl/lz4_block_decoder.sv).

| Interface | Contract |
| --- | --- |
| `clk`, `rst`, `abort` | One clock; synchronous active-high reset and abort. Reset has priority. |
| `cmd_*` | One outstanding command with exact compressed and decompressed byte counts. |
| `s_*` | Byte input with `s_last` on the declared final compressed byte. |
| `m_*` | Byte output with first/last markers; a presented byte and its markers remain stable while stalled. |
| `status_*` | One held terminal result, with error code and actual consumed/emitted counts. |
| `busy` | Asserted from command acceptance through terminal-status retirement. |

`MAX_COMPRESSED_BYTES`, `MAX_DECOMPRESSED_BYTES` and `HISTORY_BYTES` independently
support values from 1 through 4096. Defaults are 512, 1024 and 1024 respectively.
History holds the current block's committed output; newly committed bytes can
feed overlapping matches. A new block cannot read the previous block's history.
The complete decoded block must fit both output and history limits.

Malformed fields, invalid offsets, length overflow, limit violations and official
end-rule violations produce explicit errors. An ordinary error retains the
already transferred output prefix. The producer must discard the unsent input
suffix before submitting a new command. Consumers should use terminal status,
not the output last marker alone, to determine success.

Reset cancels the current transaction without a terminal response. Active abort
cancels pending, untransferred output and returns an aborted status with pre-edge
transfer counts. Integration must respect the declared input/output lengths,
ready/valid ownership and status retirement before starting another block.

## Accepted results

The scoped implementation completed independent engineering acceptance:

| Measurement | Result |
| --- | --- |
| Configuration and seed coverage | Six configurations at seeds 17, 43 and 89; 18 runs, including a separately compiled default without overrides |
| Successful block comparisons | 1,086 valid blocks; 41,340 compressed bytes and 85,275 decoded bytes |
| Independent upstream cross-check | Every valid block compared byte-for-byte with liblz4 1.9.4 |
| Illegal parameters | Nine named, nonzero-exit range diagnostics |
| Default generic synthesis | 8,192 history bits, 187 connected non-history sequential bits, 305 cells, no inferred latches |
| Defect sensitivity | A swapped-offset defect was rejected by the ordinary checker with a concrete terminal-status mismatch |

Negative and canceled transactions are separate from the valid-block totals.
The smallest configuration supports empty decoded blocks only; its valid decoded
byte count is zero, not evidence of nonempty decoding. Verification also covers
malformed input, ordered errors, reset/abort, stalls, overlapping copies, history
isolation and successful following blocks within the tested bounds.

The format authority is `lz4/lz4` release `v1.10.0`,
[`doc/lz4_Block_format.md`](https://github.com/lz4/lz4/blob/v1.10.0/doc/lz4_Block_format.md).
Results describe directed/seeded RTL simulation and memory-preserving generic
synthesis, not exhaustive formal proof, physical timing, area/power signoff,
silicon measurements or a one-byte-per-cycle throughput guarantee.

## License

The published implementation and this product description use the repository's
[MIT License](../../LICENSE).
