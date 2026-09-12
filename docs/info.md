## How it works

This project implements a 2x2 signed INT8 matrix multiplication engine. On
enabled rising edges of `clk`, `ui_in` receives four row-major values for matrix
`A`, followed by four row-major values for matrix `B`. One execute cycle later,
the four row-major values of `C = A x B` are presented on `uo_out`, one per
clock. Results are saturated to signed INT8. Reset starts a new matrix
operation, and the bidirectional pins are unused.

## How to test

The RTL test uses cocotb and Icarus Verilog. From the repository root, install
the Python environment and run the test with:

```sh
uv sync
uv run make -C test -B
```

The test covers a normal 2x2 matrix multiplication and positive saturation. The
waveform is written to `test/tb.fst`.

## External hardware

None.
