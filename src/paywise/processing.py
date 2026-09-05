from typing import Callable

from paywise.payments import Payment
from paywise.approvals import is_authorized


class ApprovalRequiredError(Exception):
    pass


def submit_payment(p: Payment) -> str:
    if not is_authorized(p):
        raise ApprovalRequiredError(f"{p.vendor} ${p.amount_cents/100:.2f} needs manager approval")
    return f"PAY-{abs(hash((p.vendor, p.amount_cents))) % 10_000_000:07d}"


# Registry of every public way to create/submit a payment. New pathways MUST be added here.
PAYMENT_PATHWAYS: list[Callable[[Payment], str]] = [submit_payment]
