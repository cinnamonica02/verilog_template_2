# Open TPU on Tiny Tapeout

## Goal

Build a small open TPU prototype that can execute a JAX computation through a
host-side compiler/runtime and a Verilog RTL accelerator. JAX is the frontend;
C++ owns the compiler backend, simulator runtime, and instruction execution.
The target demo is a small transformer layer, matching the workflow shown in
`image.png`:

```text
JAX program -> HLO/MLIR -> TPU instructions -> PJRT runtime -> RTL simulator
                                                           -> result/waveform
```

Tiny Tapeout is the hardware target and verification flow. The compiler,
runtime, and simulator driver remain host-side software.

## Repository boundary

```text
src/                    Tiny Tapeout-compatible RTL
test/                   Cocotb RTL tests
compiler/               JAX/HLO lowering and instruction generation
runtime/                Simulator and future PJRT integration
model/                  Small Python reference model
docs/                   Project documentation
```

The existing `src/project.v` remains the top-level entry point until the RTL
interface is deliberately replaced. New software layers must be testable
without requiring ASIC hardening.

## Hardware architecture

The RTL accelerator will grow in this order:

1. INT8 multiply-accumulate unit.
2. Small systolic Matrix Execution Unit (MXU).
3. Vector Execution Unit for elementwise operations such as ReLU.
4. Local vector/weight memories with simple DMA-style load and store commands.
5. Instruction decoder and execution control.

The first useful hardware contract is a matrix multiply command over fixed-size
INT8 tiles, with an INT32 accumulator and a defined output saturation rule.

## Host architecture

The host path will grow in this order:

1. Python reference model for the hardware contract.
2. C++ instruction encoder and simulator runtime.
3. Verilator-backed C++ adapter.
4. JAX tracing/lowering for the supported operation subset.
5. VLIW scheduling for memory, MXU, and vector operations.
6. PJRT integration.

JAX provides the user-facing numerical program and graph extraction. It is not
required to run on a GPU; CPU execution is sufficient for reference results
and frontend development. CUDA and Triton are intentionally not dependencies:
the target is custom Verilog hardware rather than an NVIDIA GPU.

The initial C++ compiler may accept only one operation. It must produce the
same result as the reference model and RTL before adding more operations.

## First vertical milestone

Given two small INT8 matrices:

1. The Python model computes the expected result.
2. The C++ instruction encoder creates a command stream.
3. The C++ runtime sends the stream to the RTL simulator.
4. The test compares RTL output with the model.
5. The test saves a waveform showing memory loads, computation, and completion.

This milestone is complete before adding JAX or PJRT.

## Tiny Tapeout constraints

- Keep the public top-level ports compatible with the Tiny Tapeout template.
- Keep `info.yaml`, `src/project.v`, and `test/Makefile` consistent.
- Treat the current one-tile design as the first hardware prototype, not as the
  final capacity of the TPU architecture.
- Run RTL tests before local hardening; run gate-level tests after hardening.
- Do not assume host software can fit on the chip.

## Verification rules

Every hardware feature gets one reference-model check and one RTL test.
Priority cases are:

- reset and enable behavior;
- signed INT8 inputs;
- accumulator width and saturation;
- command ordering and completion;
- matrix dimensions and memory bounds.

The reference model is the executable specification until a formal or more
complete verification flow is justified.

## Explicit non-goals for the first milestone

- Full transformer support.
- General HLO/MLIR compilation.
- Performance optimization.
- Physical multi-tile deployment.
- Full PJRT compliance.

These are planned extensions, not requirements for the first working vertical
slice.

## Immediate implementation order

1. Repair the existing Tiny Tapeout testbench/module-name mismatch.
2. Specify and test the current MAC behavior.
3. Add the Python reference model.
4. Replace the fixed MAC interface with the smallest matrix-command interface.
5. Add the C++ simulator adapter and instruction test.
6. Add JAX tracing for that one supported matrix operation.
7. Add PJRT only after direct JAX-to-simulator execution works.
