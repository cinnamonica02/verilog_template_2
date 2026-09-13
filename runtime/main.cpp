#include "Vtt_um_bjarke_micro_mac.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "instructions.h"

#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <iterator>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

using Byte = std::uint8_t;

Byte encode(std::int8_t value) {
    return static_cast<Byte>(value);
}

std::int8_t decode(Byte value) {
    return static_cast<std::int8_t>(value);
}

std::vector<Byte> load_program(const char* filename) {
    std::ifstream file(filename, std::ios::binary);
    if (!file) {
        throw std::runtime_error(std::string("cannot open program: ") + filename);
    }
    return std::vector<Byte>(
        std::istreambuf_iterator<char>(file), std::istreambuf_iterator<char>());
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
    const std::vector<Byte>& program) {
    std::array<std::int8_t, 4> output{};
    std::size_t pc = 0;
    std::size_t output_index = 0;

    while (pc < program.size()) {
        const Byte opcode = program[pc++];
        switch (opcode) {
            case instruction::LOAD_A:
            case instruction::LOAD_B:
                if (pc >= program.size()) {
                    std::cerr << "truncated load instruction\n";
                    return {};
                }
                dut.ui_in = program[pc++];
                tick(dut, trace, time);
                break;
            case instruction::EXECUTE:
                dut.ui_in = 0;
                for (int i = 0; i < 8; ++i) {
                    tick(dut, trace, time);
                }
                break;
            case instruction::READ_OUT:
                if (output_index >= output.size()) {
                    std::cerr << "too many READ_OUT instructions\n";
                    return {};
                }
                output[output_index++] = decode(static_cast<Byte>(dut.uo_out));
                tick(dut, trace, time);
                break;
            default:
                std::cerr << "unknown opcode 0x" << std::hex
                          << static_cast<int>(opcode) << std::dec << "\n";
                return {};
        }
    }

    if (output_index != output.size()) {
        std::cerr << "program returned " << output_index
                  << " outputs, expected " << output.size() << "\n";
        return {};
    }
    return output;
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

    const char* program_file = argc > 1 ? argv[1] : "program.bin";
    const auto actual = run_program(*dut, trace, time, load_program(program_file));
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
    std::cout << "Waveform: mxu.vcd\n";
    return 0;
}
