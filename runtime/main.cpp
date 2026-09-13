#include "Vtt_um_bjarke_micro_mac.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include <array>
#include <cstdint>
#include <iostream>
#include <memory>
#include <vector>

namespace {

using Byte = std::uint8_t;

enum class Opcode { LoadA, LoadB, Execute, ReadOut };

struct Command {
    Opcode opcode;
    std::int8_t value = 0;
};

Byte encode(std::int8_t value) {
    return static_cast<Byte>(value);
}

std::int8_t decode(Byte value) {
    return static_cast<std::int8_t>(value);
}

void tick(Vtt_um_bjarke_micro_mac& dut, VerilatedVcdC& trace, vluint64_t& time) {
    dut.clk = 0;
    dut.eval();
    trace.dump(time++);
    dut.clk = 1;
    dut.eval();
    trace.dump(time++);
    dut.clk = 0;
    dut.eval();
    trace.dump(time++);
}

void reset(Vtt_um_bjarke_micro_mac& dut, VerilatedVcdC& trace, vluint64_t& time) {
    dut.rst_n = 0;
    for (int i = 0; i < 2; ++i) {
        tick(dut, trace, time);
    }
    dut.rst_n = 1;
}

std::array<std::int8_t, 4> run_program(
    Vtt_um_bjarke_micro_mac& dut,
    VerilatedVcdC& trace,
    vluint64_t& time,
    const std::vector<Command>& program) {
    std::array<std::int8_t, 4> output{};
    std::size_t output_index = 0;

    for (const auto command : program) {
        switch (command.opcode) {
            case Opcode::LoadA:
            case Opcode::LoadB:
                dut.ui_in = encode(command.value);
                tick(dut, trace, time);
                break;
            case Opcode::Execute:
                dut.ui_in = 0;
                for (int i = 0; i < 8; ++i) {
                    tick(dut, trace, time);
                }
                break;
            case Opcode::ReadOut:
                if (output_index >= output.size()) {
                    std::cerr << "too many READ_OUT commands\n";
                    return {};
                }
                output[output_index++] = decode(static_cast<Byte>(dut.uo_out));
                tick(dut, trace, time);
                break;
        }
    }
    return output;
}

std::vector<Command> matrix_program() {
    return {
        {Opcode::LoadA, 1}, {Opcode::LoadA, 2},
        {Opcode::LoadA, 3}, {Opcode::LoadA, 4},
        {Opcode::LoadB, 5}, {Opcode::LoadB, 6},
        {Opcode::LoadB, 7}, {Opcode::LoadB, 8},
        {Opcode::Execute},
        {Opcode::ReadOut}, {Opcode::ReadOut},
        {Opcode::ReadOut}, {Opcode::ReadOut},
    };
}

}  // namespace

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    auto dut = std::make_unique<Vtt_um_bjarke_micro_mac>();
    VerilatedVcdC trace;
    dut->trace(&trace, 99);
    trace.open("mxu.vcd");

    dut->clk = 0;
    dut->ui_in = 0;
    dut->ena = 1;
    dut->uio_in = 0;
    vluint64_t time = 0;
    reset(*dut, trace, time);

    const auto actual = run_program(*dut, trace, time, matrix_program());
    const std::array<std::int8_t, 4> expected = {19, 22, 43, 50};
    trace.close();

    if (actual != expected) {
        std::cerr << "MXU mismatch: [" << static_cast<int>(actual[0]) << ", "
                  << static_cast<int>(actual[1]) << ", "
                  << static_cast<int>(actual[2]) << ", "
                  << static_cast<int>(actual[3]) << "]\n";
        return 1;
    }

    std::cout << "MXU OK: [19, 22, 43, 50]\n";
    std::cout << "Waveform: runtime/mxu.vcd\n";
    return 0;
}
