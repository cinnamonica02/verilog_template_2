"""Reference model and command-stream generator for the 2x2 MXU."""

from __future__ import annotations

import sys
from pathlib import Path

LOAD_A = 0x01
LOAD_B = 0x02
EXECUTE = 0x03
READ_OUT = 0x04


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


def main(output: str = "program.bin") -> None:
    a = [[1, 2], [3, 4]]
    b = [[5, 6], [7, 8]]
    expected = matmul_2x2(a, b)
    assert expected == [19, 22, 43, 50]

    path = Path(output)
    path.write_bytes(command_stream(a, b))
    print(f"Reference OK: {expected}")
    print(f"Program: {path}")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "program.bin")
