# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer


@cocotb.test()
async def test_project(dut):
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    async def run_matrix(a, b, expected):
        for value in a + b:
            dut.ui_in.value = value & 0xFF
            await ClockCycles(dut.clk, 1)
            await Timer(1, unit="ns")

        await ClockCycles(dut.clk, 8)
        await Timer(1, unit="ns")

        for value in expected:
            assert dut.uo_out.value == value & 0xFF
            await ClockCycles(dut.clk, 1)
            await Timer(1, unit="ns")

    await run_matrix(
        [1, 2, 3, 4],
        [5, 6, 7, 8],
        [19, 22, 43, 50],
    )

    await run_matrix(
        [127, 127, 127, 127],
        [127, 127, 127, 127],
        [127, 127, 127, 127],
    )
