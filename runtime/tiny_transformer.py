"""Compile a tiny 2-token attention block into 2x2 MXU commands."""

from __future__ import annotations

import math
import sys

from reference import build_files, matmul_2x2


def matrix(values: list[int]) -> list[list[int]]:
    return [values[:2], values[2:]]


def transpose(values: list[list[int]]) -> list[list[int]]:
    return [[values[0][0], values[1][0]], [values[0][1], values[1][1]]]


def softmax_rows(values: list[list[int]]) -> list[list[float]]:
    result = []
    for row in values:
        peak = max(row)
        exponents = [math.exp(value / math.sqrt(2) - peak / math.sqrt(2)) for value in row]
        total = sum(exponents)
        result.append([value / total for value in exponents])
    return result


def quantize_attention(values: list[list[float]], scale: int = 32) -> list[list[int]]:
    return [[round(value * scale) for value in row] for row in values]


def main(program: str = "transformer.bin", expected: str = "transformer.expected") -> None:
    tokens = matrix([1, 2, 3, 4])
    wq = matrix([1, 0, 0, 1])
    wk = matrix([1, 1, 0, 1])
    wv = matrix([1, 0, 1, 1])
    wo = matrix([1, 1, 0, 1])

    q = matrix(matmul_2x2(tokens, wq))
    k = matrix(matmul_2x2(tokens, wk))
    v = matrix(matmul_2x2(tokens, wv))
    scores = matrix(matmul_2x2(q, transpose(k)))
    attention = quantize_attention(softmax_rows(scores))
    context_scaled = matrix(matmul_2x2(attention, v))
    context = [[round(value / 32) for value in row] for row in context_scaled]

    cases = [
        (tokens, wq),
        (tokens, wk),
        (tokens, wv),
        (q, transpose(k)),
        (attention, v),
        (context, wo),
    ]
    outputs = build_files(cases, program, expected)
    print(f"TinyTransformer reference OK: {len(outputs)} tiled MXU operations")
    print(f"Attention weights (scale=32): {attention}")
    print(f"Final output: {outputs[-1]}")
    print(f"Program: {program}")
    print(f"Expected: {expected}")


if __name__ == "__main__":
    main(
        sys.argv[1] if len(sys.argv) > 1 else "transformer.bin",
        sys.argv[2] if len(sys.argv) > 2 else "transformer.expected",
    )
