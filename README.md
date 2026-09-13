![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout 2×2 INT8 MXU

This project is a small open matrix execution unit (MXU) built for
[Tiny Tapeout](https://tinytapeout.com/). It demonstrates the first useful
hardware slice of an open TPU: load two 2×2 signed INT8 matrices, multiply
them, and stream four saturated INT8 results back out.

The design is intentionally small and reproducible. The RTL fits the Tiny
Tapeout interface, the tests run with cocotb and Icarus Verilog, and a
Verilator/C++ runtime produces a waveform showing the command stream and
hardware result.

## Current architecture

```text
Python reference model
        ↓ command stream
C++ Verilator runtime
        ↓ Tiny Tapeout interface
2×2 INT8 MXU RTL
        ↓
mxu.vcd + verified output
```

The current runtime uses these host-side commands:

```text
0x01 <byte>  LOAD_A
0x02 <byte>  LOAD_B
0x03         EXECUTE
0x04         READ_OUT
```

The RTL itself receives matrix bytes through `ui_in` and returns results on
`uo_out`. The bidirectional pins are currently unused. The reference model
and RTL agree on this example:

```text
A = [[1, 2], [3, 4]]
B = [[5, 6], [7, 8]]
C = [[19, 22], [43, 50]]
```

## Run the RTL test

Using [uv](https://docs.astral.sh/uv/):

```sh
uv sync
uv run make -C test -B
```

This runs the cocotb testbench and writes `test/tb.fst`.

## Run the Verilator runtime

With Verilator and GNU Make installed:

```sh
make -C runtime run
```

The Makefile first runs `runtime/reference.py`, which checks the matrix result
and generates `runtime/program.bin`. The C++ runtime then executes that stream
against the RTL and writes `runtime/mxu.vcd`.

Expected output:

```text
Reference OK: [19, 22, 43, 50]
MXU OK: [19, 22, 43, 50]
Waveform: mxu.vcd
```

Open the VCD with [Surfer](https://app.surfer-project.org/) or GTKWave. Add
`clk`, `ui_in[7:0]`, and `uo_out[7:0]` to the waveform view.

## Project scope

The current goal is correctness, reproducible simulation, and a clear
hardware/software boundary. The following remain future work:

- larger or spatially pipelined systolic arrays;
- a richer instruction decoder and local memories;
- optional JAX lowering and compiler integration;
- PJRT integration and transformer-scale workloads.

JAX, CUDA, Triton, and PJRT are not required for the current design or tests.
The reference path runs on a CPU and has no GPU dependency.

## Repository layout

```text
src/                  Tiny Tapeout-compatible RTL
test/                 Cocotb/Icarus verification
runtime/reference.py  Python reference model and command generator
runtime/main.cpp      Verilator C++ runtime
runtime/Makefile      Runtime build and execution flow
docs/                 Tiny Tapeout project documentation
DESIGN.md             Longer architecture plan
```

## Tiny Tapeout resources

- [Tiny Tapeout documentation](https://tinytapeout.com/)
- [Project documentation](docs/info.md)
- [Tiny Tapeout FAQ](https://tinytapeout.com/faq/)
- [Local hardening guide](https://www.tinytapeout.com/guides/local-hardening/)
