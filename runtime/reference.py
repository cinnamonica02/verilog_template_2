"""Reference model and command-stream generator for the 2x2 MXU."""

from __future__ import annotations

import argparse
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


def build_files(
    cases: list[tuple[list[list[int]], list[list[int]]]],
    program: str,
    expected_file: str,
) -> list[list[int]]:
    program_data = bytearray()
    expected: list[list[int]] = []
    for index, (a, b) in enumerate(cases):
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


def parse_matrix(values: list[int]) -> list[list[int]]:
    if len(values) != 4 or any(value < -128 or value > 127 for value in values):
        raise ValueError("each matrix needs four signed INT8 values (-128..127)")
    return [values[:2], values[2:]]


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate a 2x2 MXU command stream")
    parser.add_argument("output", nargs="?", default="program.bin")
    parser.add_argument("expected", nargs="?", default="expected.bin")
    parser.add_argument("--a", nargs=4, type=int, metavar="A", help="four row-major INT8 values")
    parser.add_argument("--b", nargs=4, type=int, metavar="B", help="four row-major INT8 values")
    args = parser.parse_args()

    if (args.a is None) != (args.b is None):
        parser.error("--a and --b must be provided together")

    cases = CASES
    if args.a is not None and args.b is not None:
        try:
            cases = [(parse_matrix(args.a), parse_matrix(args.b))]
        except ValueError as error:
            parser.error(str(error))

    expected = build_files(cases, args.output, args.expected)

    if args.a is None:
        assert expected == [[19, 22, 43, 50], [9, 22, 13, 50], [127, 127, 127, 127]]

    print(f"Reference OK: {len(expected)} cases, outputs={expected}")
    print(f"Program: {args.output}")
    print(f"Expected: {args.expected}")


if __name__ == "__main__":
    main()
