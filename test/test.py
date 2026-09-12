# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, ReadOnly


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    async def run_frame(samples, expected):
        for sample in samples:
            dut.ui_in.value = sample & 0xFF
            await ClockCycles(dut.clk, 1)
            await ReadOnly()
        assert dut.uo_out.value == expected & 0xFF

    dut._log.info("Test four-sample signed MAC")
    await run_frame([1, 2, 3, 4], 106)  # 1*12 + 2*(-45) + 3*88 + 4*(-20)

    dut._log.info("Test positive saturation")
    await run_frame([127, 127, 127, 127], 127)

    dut._log.info("Test negative saturation")
    await run_frame([-128, -128, -128, -128], -128)
