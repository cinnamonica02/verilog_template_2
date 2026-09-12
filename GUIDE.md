Building an open-source TPU with a full JAX/PJRT compiler pipeline targeting Verilog RTL is a massive shift in scale from a 1-tile Tiny Tapeout Wokwi/MAC layout.The tweet shows open-tpu, a project designed to compile JAX expressions into Very Long Instruction Word (VLIW) binaries that execute directly on custom hardware via PJRT.Architectural Layers of the Project+-------------------------------------------------------------+
|                     JAX Python Code                         |
|      (e.g., test_single_batched_transformer execution)      |
+-------------------------------------------------------------+
                              │
                              ▼
+-------------------------------------------------------------+
|                        HLO IR / MLIR                        |
|   (High-Level Optimizer IR lowering via StableHLO/MLIR)     |
+-------------------------------------------------------------+
                              │
                              ▼
+-------------------------------------------------------------+
|                    TPU Assembly & VLIW                      |
| (Instruction scheduling: MXU matmul, Vector unit, DMA)      |
+-------------------------------------------------------------+
                              │
                              ▼
+-------------------------------------------------------------+
|                    PJRT C++ / Python API                    |
|   (Memory allocation, binary loading, hardware trigger)     |
+-------------------------------------------------------------+
                              │
                              ▼
+-------------------------------------------------------------+
|                  Verilog RTL Core & Sim                     |
|  (Systolic Array / MXU, Vector Memory, DMA Engine, GTKWave) |
+-------------------------------------------------------------+
Key Components to BuildVerilog Hardware Units (RTL):Matrix Execution Unit (MXU): Systolic array designed for matrix multiplications ($Q \times K^T$, $A \times V$).Vector Execution Unit (XLU): Elementary functions like RMSNorm, Softmax scaling, and activation functions (ReLU/GeLU).DMA & Memory Controller: Manages movement between Host/HBM and Vector Memory (VMEM) / Weight Memory (WMEM).Compiler Frontend & Backend:JAX to HLO/MLIR: Hooking into JAX's @jax.jit tracing to extract HLO computation graphs.VLIW Instruction Scheduler: Bundles parallel execution slots (DMA loads, MXU computes, Vector ops) into wide instruction words.Runtime Driver (PJRT):Implements OpenXLA's PJRT C API to present your Verilog simulator (via Verilator/C++ harness) as a standard JAX execution device.Immediate Next StepTo run this architecture, you must move beyond Tiny Tapeout's single tile limit and build a Verilator-based simulation harness.Verification: Ensure you have verilator, gtkwave, and an MLIR/LLVM toolchain installed in your development environment to simulate the VCD waveforms visible in the screenshot.