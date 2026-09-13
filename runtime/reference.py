"""Reference model and command-stream generator for the 2x2 MXU."""

from __future__ import annotations

import sys
from pathlib import Path

LOAD_A = 0x01
LOAD_B = 0x02
EXECUTE = 0x03
READ_OUT = 0x04
RESET = 0x00


def saturate_int8(value: int) -> int:
    return max(-128, min(127, value))


def matmul_2x2(a: list[list[int]], b: list[list[int]]) -> list[int]:
    values = [
        a[0][0] * b[0][0] + a[0][1] * b[1][0],
        a[0][0] * b[0][1] + a[0][1] * b[1][1],
        a[1][0] * b[0][0] + a[1][1] * b[1][0],
        a[1][0] * b[0][1] + a[1][1] * b[1][1],
    ]
    return [saturate_int8(value) for value in values]


def command_stream(a: list[list[int]], b: list[list[int]]) -> bytes:
    data = bytearray()
    for value in sum(a, []):
        data.extend((LOAD_A, value & 0xFF))
    for value in sum(b, []):
        data.extend((LOAD_B, value & 0xFF))
    data.extend((EXECUTE, READ_OUT, READ_OUT, READ_OUT, READ_OUT))
    return bytes(data)


CASES = [
    ([[1, 2], [3, 4]], [[5, 6], [7, 8]]),
    ([[-1, 2], [-3, 4]], [[5, -6], [7, 8]]),
    ([[127, 127], [127, 127]], [[127, 127], [127, 127]]),
]


def build_files(program: str, expected_file: str) -> list[list[int]]:
    program_data = bytearray()
    expected: list[list[int]] = []
    for index, (a, b) in enumerate(CASES):
        if index:
            program_data.append(RESET)
        result = matmul_2x2(a, b)
        program_data.extend(command_stream(a, b))
        expected.append(result)

    with Path(program).open("wb") as file:
        file.write(program_data)
    with Path(expected_file).open("wb") as file:
        file.write(bytes(value & 0xFF for result in expected for value in result))
    return expected


def main(output: str = "program.bin", expected_file: str = "expected.bin") -> None:
    expected = build_files(output, expected_file)
    assert expected == [[19, 22, 43, 50], [9, 22, 13, 50], [127, 127, 127, 127]]

    print(f"Reference OK: {len(expected)} cases, outputs={expected}")
    print(f"Program: {output}")
    print(f"Expected: {expected_file}")


if __name__ == "__main__":
    main(
        sys.argv[1] if len(sys.argv) > 1 else "program.bin",
        sys.argv[2] if len(sys.argv) > 2 else "expected.bin",
    )
