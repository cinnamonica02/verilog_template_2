# Verilator runtime

This is the first host-side runtime for the 2x2 INT8 MXU. It drives the
Tiny Tapeout-compatible RTL directly and checks normal, signed, and saturating
matrix multiplications.

The host instruction stream currently uses:

```text
0x01 <byte>  LOAD_A
0x02 <byte>  LOAD_B
0x03         EXECUTE
0x04         READ_OUT
0x00         RESET_CASE
```

`reference.py` computes three 2x2 cases in pure Python, checks them, and
generates `runtime/program.bin` plus `runtime/expected.bin`. The C++ runtime
loads both files and drives the RTL; the RTL does not decode the instruction
bytes itself yet.

Custom 2x2 matrices can be generated without extra dependencies:

```sh
python runtime/reference.py custom.bin custom.expected \
  --a 127 127 -128 127 \
  --b 127 127 127 127
```

With Verilator installed, run from the repository root:

```sh
make -C runtime run
```

The Makefile builds the generated model under `runtime/obj_dir`, runs it, and
writes `runtime/mxu.vcd`. It also runs the Python reference generator first.

To run only the reference model:

```sh
python runtime/reference.py runtime/program.bin runtime/expected.bin
```
To build without running:

```sh
make -C runtime
```

Expected output:

```text
Reference OK: 3 cases, outputs=[[19, 22, 43, 50], [9, 22, 13, 50], [127, 127, 127, 127]]
MXU OK: 12 outputs across 3 cases
Waveform: runtime/mxu.vcd
```
