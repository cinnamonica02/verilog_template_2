# TinyTransformer MXU Demo

This demo shows the complete local flow:

```text
Python transformer graph
  -> 2x2 INT8 command streams
  -> Verilator compilation
  -> Tiny Tapeout RTL execution
  -> verified outputs and VCD waveform
```

## Run locally

The easiest local environment is VS Code with the repository opened through WSL.
Install the tools once:

```bash
sudo apt update
sudo apt install -y make g++ python3 verilator
```

From the repository root, run:

```bash
make -C runtime transformer
```

Expected output includes:

```text
TinyTransformer reference OK: 6 tiled MXU operations
Attention weights (scale=32): [[0, 32], [0, 32]]
Final output: [4, 8, 4, 8]
MXU OK: 24 outputs across 6 cases
Waveform: mxu.vcd
```

The generated waveform is `runtime/mxu.vcd`.

## Inspect the waveform

Open [Surfer](https://app.surfer-project.org/) and drag in `runtime/mxu.vcd`.
Display these signals:

- `clk`
- `rst_n`
- `ui_in[7:0]`
- `uo_out[7:0]`

The normal matrix test eventually produces:

```text
0x13  0x16  0x2b  0x32
19    22    43    50
```

The waveform shows the streamed input bytes and the clocked output bytes from
the actual Tiny Tapeout RTL.

## Inspect the layout

Download the GDS artifact from a green GitHub Actions run and open
[Tiny Explorer](https://znah.net/tiny_explorer/). Load the local GDS/OASIS file,
then record the full tile, cell/layer views, and a zoomed-in core view.

Tiny Explorer is for the final physical layout. Surfer is for RTL simulation
waveforms.

## Record the demo

Use Windows Game Bar with `Win+Alt+R`, or use OBS for a longer recording.

Recommended sequence:

1. Show `runtime/tiny_transformer.py` in VS Code.
2. Run `make -C runtime transformer` in the integrated WSL terminal.
3. Show the successful reference and RTL output checks.
4. Open `runtime/mxu.vcd` in Surfer and show the input/output timing.
5. Open the GDS file in Tiny Explorer and show the 3D layout.

GitHub Actions runs the same Makefile command in a clean Linux environment.
Use the local recording for the presentation and the CI run as reproducibility
evidence.
