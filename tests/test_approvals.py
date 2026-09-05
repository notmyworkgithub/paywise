from paywise.payments import Payment, dollars
from paywise.approvals import requires_approval, is_authorized, APPROVAL_THRESHOLD_CENTS


def test_over_threshold_requires_approval():
    assert requires_approval(Payment("Acme", dollars(5000.01)))


def test_at_or_under_threshold_does_not():
    assert not requires_approval(Payment("Acme", APPROVAL_THRESHOLD_CENTS))


def test_authorized_only_when_approved_if_required():
    assert not is_authorized(Payment("Acme", dollars(9000)))
    assert is_authorized(Payment("Acme", dollars(9000), approved_by="mgr@corp"))
    assert is_authorized(Payment("Acme", dollars(100)))  # small, no approval needed
