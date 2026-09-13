#pragma once

#include <cstdint>
#include <vector>

namespace instruction {

enum Opcode : std::uint8_t {
    RESET = 0x00,
    LOAD_A = 0x01,
    LOAD_B = 0x02,
    EXECUTE = 0x03,
    READ_OUT = 0x04,
};

inline std::vector<std::uint8_t> matrix_program() {
    return {
        LOAD_A, 1, LOAD_A, 2, LOAD_A, 3, LOAD_A, 4,
        LOAD_B, 5, LOAD_B, 6, LOAD_B, 7, LOAD_B, 8,
        EXECUTE,
        READ_OUT, READ_OUT, READ_OUT, READ_OUT,
    };
}

}  // namespace instruction
