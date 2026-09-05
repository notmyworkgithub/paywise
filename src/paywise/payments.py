from dataclasses import dataclass


def dollars(x: float) -> int:
    return round(x * 100)


@dataclass
class Payment:
    vendor: str
    amount_cents: int
    approved_by: str | None = None
