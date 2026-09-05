from paywise.payments import Payment

APPROVAL_THRESHOLD_CENTS = 500000  # $5,000


def requires_approval(p: Payment) -> bool:
    return p.amount_cents > APPROVAL_THRESHOLD_CENTS


def is_authorized(p: Payment) -> bool:
    return (not requires_approval(p)) or bool(p.approved_by)
