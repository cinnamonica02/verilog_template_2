#include "Vtt_um_bjarke_micro_mac.h"
#include "verilated.h"

#include <array>
#include <cstdint>
#include <iostream>
#include <memory>

namespace {

using Byte = std::uint8_t;

Byte encode(std::int8_t value) {
    return static_cast<Byte>(value);
}

std::int8_t decode(Byte value) {
    return static_cast<std::int8_t>(value);
}

void tick(Vtt_um_bjarke_micro_mac& dut) {
    dut.clk = 0;
    dut.eval();
    dut.clk = 1;
    dut.eval();
    dut.clk = 0;
    dut.eval();
}

void reset(Vtt_um_bjarke_micro_mac& dut) {
    dut.rst_n = 0;
    for (int i = 0; i < 2; ++i) {
        tick(dut);
    }
    dut.rst_n = 1;
}

std::array<std::int8_t, 4> run_matrix(
    Vtt_um_bjarke_micro_mac& dut,
    const std::array<std::int8_t, 8>& input) {
    for (const auto value : input) {
        dut.ui_in = encode(value);
        tick(dut);
    }

    dut.ui_in = 0;
    for (int i = 0; i < 8; ++i) {
        tick(dut);
    }

    std::array<std::int8_t, 4> output{};
    for (auto& value : output) {
        value = decode(static_cast<Byte>(dut.uo_out));
        tick(dut);
    }
    return output;
}

}  // namespace

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto dut = std::make_unique<Vtt_um_bjarke_micro_mac>();
    dut->clk = 0;
    dut->ui_in = 0;
    dut->ena = 1;
    dut->uio_in = 0;
    reset(*dut);

    const std::array<std::int8_t, 8> input = {1, 2, 3, 4, 5, 6, 7, 8};
    const std::array<std::int8_t, 4> expected = {19, 22, 43, 50};
    const auto actual = run_matrix(*dut, input);

    if (actual != expected) {
        std::cerr << "MXU mismatch: [" << static_cast<int>(actual[0]) << ", "
                  << static_cast<int>(actual[1]) << ", "
                  << static_cast<int>(actual[2]) << ", "
                  << static_cast<int>(actual[3]) << "]\n";
        return 1;
    }

    std::cout << "MXU OK: [19, 22, 43, 50]\n";
    return 0;
}
