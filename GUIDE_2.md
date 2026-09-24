Skip to content
ta10g22
TinyInfer
Repository navigation
Code
Issues
Pull requests
Actions
Projects
Security and quality
Insights
ta10g22
TinyInfer
Public
Go to file
t
T
ta10g22
ta10g22
added ruslts for baseline and compiler optmized inference on large_ml…
7433b2f
 · 
2 weeks ago
Name		
Benchmarks
added ruslts for baseline and compiler optmized inference on large_ml…
2 weeks ago
Headers
added ruslts for baseline and compiler optmized inference on large_ml…
2 weeks ago
Models
added ruslts for baseline and compiler optmized inference on large_ml…
2 weeks ago
Scripts
added ruslts for baseline and compiler optmized inference on large_ml…
2 weeks ago
Source
added ruslts for baseline and compiler optmized inference on large_ml…
2 weeks ago
docs
added ruslts for baseline and compiler optmized inference on large_ml…
2 weeks ago
Readme.md
Models Written in ML frameworks like Tensorflow, pytorch and jax will…
2 months ago
Tinyinfer
added ruslts for baseline and compiler optmized inference on large_ml…
2 weeks ago
makefile
added ruslts for baseline and compiler optmized inference on large_ml…
2 weeks ago
requirements.txt
created script give me metadata of models after exported into ONNX fo…
2 months ago
Repository files navigation
README
TinyInfer
TinyInfer is a small C++ machine learning inference runtime built from scratch.

The goal of this project is to understand and demonstrate how trained neural networks are executed outside of Python frameworks like PyTorch.

Project summary
Most beginner machine learning projects focus on training a model and reporting accuracy.

TinyInfer focuses on what happens after training:

Train model in PyTorch
        ↓
Export model as ONNX
        ↓
Load ONNX graph and weights in C++
        ↓
Run inference
        ↓
Validate output against PyTorch
        ↓
Optimise the runtime
        ↓
Benchmark performance
Why I am building this
The purpose of TinyInfer is to build the layer underneath a machine learning framework.

Instead of only using:

model(input)
this project explores what that call actually requires internally.

Which makes the project relevant to ML systems, AI infrastructure, inference engineering, and hardware-aware software engineering.

Engineering focus
TinyInfer is designed around three engineering goals:

1. Correctness
2. Performance
3. Runtime and graph optimisation
Planned features
Version 1: Basic C++ inference runtime
 Tensor class
 ONNX model loading
 Read model graph metadata from ONNX
 Linear layer
 ReLU activation
 Softmax
 Forward pass for a small neural network
 MNIST or small classifier inference
 PyTorch output comparison
 Unit tests for core operations
Version 2: Performance kernels
A kernel is a performance-critical function that implements one operation, such as matrix multiplication.

 Naive matrix multiplication
 Cache-blocked matrix multiplication
 Multithreaded matrix multiplication
 Benchmark suite
 Runtime comparison between implementations
 Performance tables and graphs
Version 3: Graph optimisation
 Simple computation graph representation
 Graph execution engine
 Operator fusion
 Dead node elimination
 Constant folding
 Benchmark before and after graph optimisation.
About
No description, website, or topics provided.
Resources
Readme
Activity
Stars
1 star
Watchers
0 watching
Forks
0 forks
Report repository
Releases
No releases published
Packages
No packages published
Contributors
1
 (1)
@ta10g22
ta10g22Tochi
Languages
C++
61%
Python
33.3%
Makefile
5.7%
Footer
© 2026 GitHub, Inc.
Footer navigation



---

## Project roadmap: from Tiny Tapeout to a mini-transformer

The long-term goal is to compile and execute a small neural network or
transformer layer, while showing both the software execution log and the RTL
waveform. The project is intentionally split into two hardware scales.

### Tiny Tapeout vertical slice

The current 1×1 design proves the complete path:

```text
Python graph/reference
        ↓
2×2 matrix command stream
        ↓
C++ Verilator runtime
        ↓
Tiny Tapeout MXU RTL
        ↓
Verified output and waveform
```

The Tiny Tapeout milestone should remain small: a dependency-free Python
reference, a command-stream generator, and a tiny compiled MLP or sequence of
2×2 linear layers. Weights and activations are streamed by the host because
the current tile has no substantial local memory.

### ChipFoundry or FPGA prototype

The full mini-transformer target belongs in a larger prototype with a spatial
systolic array, SRAM for weights and activations, DMA or memory interfaces, and
an instruction/control processor. That design can be developed first in
Verilator or on an FPGA, then moved to a larger ChipFoundry/OpenFrame project.

JAX may eventually be added as an optional frontend, but JAX, PJRT, CUDA, and
GPU hardware are not required for the current Tiny Tapeout path. The immediate
goal is a reproducible CPU-only compiler/runtime demonstration; the larger
transformer architecture is a later hardware phase.


Multiply and accumulate matrix multiplier ASIC with design for test infrastructure
This ASIC is silicon proven: A0 works

A0

ASIC design for a 2x2 systolic matrix multiplier on GF180 supporting multiply and accumulate operations on int8 data alongside a design for test infrastructure to help debug both usage and diagnose design issues in silicon.

This MAC accelerator operates at up to 50 MHz and is capable of reaching up to 100 MMAC/s or 200 MIOPS/s.

Documentation on using this accelerator can be found : here

Bringup logs and instructions can be found: here

ASIC implementation final render

ASIC
This accelerator was designed for the GF180nm node using the gf180mcuD PDK. It occupies 1,127.83 µm² of die area and has a target typical operating voltage of 3.3V at 25°C.

This design features two clock trees, one for the MAC and another for the JTAG TAP. The MAC clock targets a 50 MHz operating frequency, and the JTAG 2 MHz.

There are currently no known manufacturability issues.

Current status: Silicon proven, taped-out as part of the tiny-tapeout gf-0p2 shuttle, bring-up finished and A0 works.

MAC
This design features 4 MAC units performing a fused multiply-accumulat operation (FMA) on 8-bit signed integers.

This entire operation is computed in a single cycle at 50 MHz and a single rounding operation to fit into the 8-bit signed integer range is performed on the final operation's results.

Frequency
The 50 MHz speed was chosen according to the maximum estimated reliable IO switching frequency. Going above this would not have resulted in any additional speedup given the IO data transfer and on-chip storage bottlenecks.

Multiplication
Each unit implements a Booth radix-4 multiplier. This multiplier design was chosen for its low logic depth and reasonable area cost. Additionally, since we are performing a signed multiplication, we can remove a level in the Wallace tree we are using for the partial product additions given we only have 4 partial products, unlike the 5 needed for unsigned operations.

Data access
This design stores a single 8-bit signed weight internally per MAC unit. The remainder of the input data must be circulated through the input parallel port on every use, making IO this design's biggest bottleneck for this first generation.

This tradeoff was made because weights exhibit higher temporal and spatial locality than input data. In typical usage, each MAC unit will reuse the same weight value multiple times across different computations, and these weights often remain constant across multiple input matrices.

DFT
This design embeds a JTAG for debugging the accelerator's usage by probing into internal registers and helping identify PCB issues using a boundary scan.

This JTAG TAP was designed to operate at 2 MHz, has idcode 0x1beef0d7.

Its instruction register length is 3, and implements the following instructions:

Instruction	Opcode	Description
EXTEST	0x0	Boundary scan
IDCODE	0x1	Reads JTAG TAP identifier
SAMPLE_PRELOAD	0x2	Boundary scan
USER_REG	0x3	Probe internal registers
BYPASS	0x7	Set the TAP in bypass mode
All four standard instructions EXTEST, IDCODE, SAMPLE_PRELOAD, BYPASS conform to the standard behavior.

USER_REG
The USER_REG state was designed to probe into the data currently used by each of the 4 MAC units. The data to be read is specified by loading its address in the data register during a previous DR_SHIFT stage. As such, two sequences of DR_SHIFTS might be necessary:

Load the address of the next data
Read the data off TDO
The address and data are both 8 bits wide, though only the bottom 4 bits of the address are used.

Address format
The address uses the following format:

[ unused 7:4 ][ mac unit 3:2 ][ register id 1:0 ] 
Register id mapping for each MAC unit gives us the current:

Register ID	Description
0x0	Weight (multiplier)
0x1	Multiplicand (circulated data)
0x2	Summand (circulated data)
0x3	MAC operation overflow bits, used in rounding to the maximum representation range of the int8_t, discarded before the next MAC unit (internal MAC unit data)
Important considerations for usage
When using the USER_REG custom JTAG TAP instruction, the MAC logic is expected to be temporarily halted, as in no weight or data update operations and no matrix compute is expected to be ongoing. To this effect, there is no CDC protection when transferring data between the JTAG clock domain and the MAC domain. If the MAC isn't halted, the resulting metastability risks corrupting the sampled data.

This also applies when doing a boundary scan.

Quickstart
For quickly getting started, use the utilities provided in jtag/openocd.cfg.

Given this default config assumes you are using a jlink, and this might not be the adapter you are using, you may need to update the adapter by including your probe's config file:

source [find interface/jlink.cfg]
Usage
Run using :

openocd -f jtag/openocd.cfg
Expected output:

Open On-Chip Debugger 0.12.0+dev-02171-g11dc2a288 (2025-11-23-19:25)
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
Info : J-Link V10 compiled Jan 30 2023 11:28:07
Info : Hardware version: 10.10
Info : VTarget = 3.380 V
Info : clock speed 2000 kHz
Info : JTAG tap: tpu.tap tap/device found: 0x1beef0d7 (mfg: 0x06b (Transwitch), part: 0xbeef, ver: 0x1)
Warn : gdb services need one or more targets defined
idcode : 1beef0d7
read internal register 0:0 : 0x00 - weight
read internal register 0:1 : 0x00 - multiplicand ( input data )
read internal register 0:2 : 0x00 - summand ( input data )
...
License
This project is licensed under the Apache License 2.0, see the LICENSE file for details.

Credits
Thanks to the Tiny Tapeout project, its contributors, and all the community working on open source silicon tools for making this possible

Future improvements
This design was the first iteration for a systolic MAC accelerator designed from scratch in under 2 weeks. Here are a few paths I have identified for future improvements:

Explore floating-point arithmetic
Integrate on-chip SRAM to reduce input data bottleneck
More directed MAC unit physical layout, with particular attention given to adder tree implementations; experiment with full adder cells
Add support for detecting manufacturing faults in silicon and integrate an ATPG flow into future workflows
About
GF180 ASIC tapeout of a 2x2 MAC with DFT infrastructure

essenceia.github.io/projects/two_weeks_until_tapeout/
Topics
Resources
Readme
Apache-2.0 license
Activity
Stars
74 stars
Watchers
0 watching
Forks
2 forks
Report repository
Releases
1tag
Packages
No packages published
Contributors
1
 (1)
@Essenceia
EssenceiaJulia Desmazes
Languages
Verilog
59.6%
Python
16.3%
Tcl
10.6%
C
8.3%
Makefile
4.5%
CMake
0.7%
Footer
© 20


---

