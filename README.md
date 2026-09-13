![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout 2×2 INT8 Matrix multiply

This project is a small open matrix execution unit  built for
[Tiny Tapeout](https://tinytapeout.com/). It loads two 2×2 signed INT8 matrices, multiply
them, and stream four saturated INT8 results back out.

The design is intentionally small and reproducible. The RTL fits the Tiny
Tapeout interface, the tests run with cocotb and Icarus Verilog, and a
Verilator/C++ runtime produces a waveform showing the command stream and
hardware result.

