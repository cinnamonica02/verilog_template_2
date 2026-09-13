# Verilator runtime

This is the first host-side runtime for the 2x2 INT8 MXU. It drives the
Tiny Tapeout-compatible RTL directly and checks one matrix multiplication.

With Verilator installed, run from the repository root:

```sh
make -C runtime run
```

The Makefile builds the generated model under `runtime/obj_dir` and runs it.
To build without running:

```sh
make -C runtime
```

Expected output:

```text
MXU OK: [19, 22, 43, 50]
```
