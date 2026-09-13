# Verilator runtime

This is the first host-side runtime for the 2x2 INT8 MXU. It drives the
Tiny Tapeout-compatible RTL directly and checks one matrix multiplication.

The host instruction stream currently uses:

```text
0x01 <byte>  LOAD_A
0x02 <byte>  LOAD_B
0x03         EXECUTE
0x04         READ_OUT
```

The runtime interprets these instructions for now; the RTL does not decode
them yet.

With Verilator installed, run from the repository root:

```sh
make -C runtime run
```

The Makefile builds the generated model under `runtime/obj_dir`, runs it, and
writes `runtime/mxu.vcd`.
To build without running:

```sh
make -C runtime
```

Expected output:

```text
MXU OK: [19, 22, 43, 50]
Waveform: runtime/mxu.vcd
```
