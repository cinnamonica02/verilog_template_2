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

The host path follows the full compiler architecture:

1. JAX Python program and graph extraction.
2. HLO/MLIR lowering for the supported operation subset.
3. TPU assembly and VLIW scheduling.
4. C++ instruction encoder and runtime.
5. Verilator-backed simulator adapter.
6. PJRT integration.

JAX provides the user-facing numerical program and graph extraction. It is not
required to run on a GPU; CPU execution is sufficient for reference results
and frontend development. CUDA and Triton are intentionally not dependencies:
the target is custom Verilog hardware rather than an NVIDIA GPU.

Each stage must preserve the same result as the reference model and RTL before
the next compiler layer is added.

## First vertical milestone

Given two small INT8 matrices:

1. The Python model computes the expected result.
2. The C++ instruction encoder creates a command stream.
3. The C++ runtime sends the stream to the RTL simulator.
4. The test compares RTL output with the model.
5. The test saves a waveform showing memory loads, computation, and completion.

This is the first hardware/compiler contract for the full architecture.

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

## Deferred layers

- Full transformer support until the MXU contract is stable.
- General HLO/MLIR coverage beyond the supported operation subset.
- Performance optimization before correctness and waveforms are established.
- Physical multi-tile deployment before the single-tile RTL contract is proven.

These are planned extensions, not requirements for the first working vertical
slice.

## Immediate implementation order

1. Preserve the passing Tiny Tapeout baseline and top-level interface.
2. Define the 2x2 INT8 MXU and instruction/memory contract.
3. Implement the functional MXU RTL and waveform tests.
4. Build the Verilator C++ harness and instruction runner.
5. Add the first VLIW instruction format for load and MXU execution.
6. Lower one JAX operation through HLO/MLIR into those instructions.
7. Add the PJRT runtime path.
