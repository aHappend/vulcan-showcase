# Streaming bilinear image scaler

[Vulcan](https://ahappend.github.io/vulcan/) |
[All designs](../../README.md) |
[MIT license](../../LICENSE)

A synthesizable, single-clock grayscale scaler with independent ready/valid
pixel streams, bounded two-row storage and explicit frame ownership.
It supports upscaling, downscaling, identity sizes and singleton dimensions
without buffering an entire source frame.

## Product features

- Five connected RTL modules for integration, frame/configuration control,
  row storage, coordinate/interpolation arithmetic and output reservation.
- Eight-bit pixels and one-pixel-wide interfaces. Maximum width and height
  are independently configurable from 1 to 32, with defaults of 16 and 12.
  This interface width is not a one-pixel-per-cycle throughput guarantee.
- Corner-aligned Q8 coordinates, floor-quantized mapping, edge clamping and
  one final round-half-up interpolation step. A singleton output axis samples
  the source origin; this is a defined fixed-point rule, not exact real-valued
  interpolation.
- Byte-strobed configuration registers, frame-boundary activation, counters,
  sticky errors and masked interrupts. Staged changes do not alter an active
  frame or a pixel already presented to the consumer.
- Stable stalled output payload, coordinates, frame ID and markers. Malformed
  input drains to a frame boundary or an explicit abort, preserving an already
  presented output until accepted. Reset is the explicit flush operation.

## Verified scope

Five separately compiled targets, including an unoverridden default, completed
**15 seeded runs** totaling **69,790 simulation cycles**. After the final reset,
these runs compared **252 complete valid frames and 8,520 pixels**, with
**16 or 17 complete frames in every run**. Malformed and aborted output prefixes
are recorded separately, not counted as completed valid frames.

The independent mathematical reference checked pixel values, raster coordinates,
frame IDs and boundary markers through the public interfaces. The finite runs
covered scaling direction, fractional rounding, singleton and non-power-of-two
shapes, clamping, staged configuration, stalls, malformed frames, abort/reset,
status and interrupt behavior.

Additional elaboration checks included nine pixel-compared smoke targets and
six named illegal-bound diagnostics. Generic default-top synthesis retained
connected arithmetic/control and **256 row-data storage bits**, with no inferred
latches. An isolated rounding defect was rejected by the ordinary checker with
a concrete **expected 64 versus observed 63** pixel mismatch.

The five files in [`rtl/`](rtl/) preserve the accepted implementation. Local
simulation-scheduling and verification-stimulus faults were corrected during
development; this is not a claim of defect-free first-attempt execution.

## Integration boundaries

Progress requires the declared bounded producer gaps and consumer readiness,
not permanent input or output stalls. A malformed source frame can leave an
irrevocable output prefix; it is not silently rolled back or treated as a valid
completed frame.

These results establish finite RTL simulation and generic synthesis, not
exhaustive verification, a full ISP, color processing, clock-domain crossing,
external-memory DMA, technology-mapped PPA, FPGA measurements, silicon validation
or physical signoff.
