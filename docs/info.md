## How it works

This project implements a four-tap signed INT8 multiply-accumulate engine.
One signed INT8 sample is supplied on `ui_in` on each enabled rising edge of
`clk`. Four consecutive samples are multiplied by the fixed weights
`[12, -45, 88, -20]` and accumulated. The result is saturated to signed INT8
and presented on `uo_out` after the fourth sample. Reset clears the accumulator
and starts a new four-sample frame. The bidirectional pins are unused.

## How to test

The RTL test uses cocotb and Icarus Verilog. From the repository root, install
the Python environment and run the test with:

```sh
uv sync
uv run make -C test -B
```

The test covers a normal signed MAC calculation and positive and negative
saturation. The waveform is written to `test/tb.fst`.

## External hardware

None.
