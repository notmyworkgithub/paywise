import pytest
from paywise.payments import Payment, dollars
from paywise.processing import submit_payment, ApprovalRequiredError, PAYMENT_PATHWAYS


def test_submit_blocks_unapproved_large_payment():
    with pytest.raises(ApprovalRequiredError):
        submit_payment(Payment("Acme", dollars(9000)))


def test_submit_allows_approved_large_payment():
    assert submit_payment(Payment("Acme", dollars(9000), approved_by="mgr@corp"))


def test_submit_allows_small_payment():
    assert submit_payment(Payment("Acme", dollars(100)))


def test_every_payment_pathway_enforces_policy():
    # CONTROL: any registered way to create a payment must reject an unapproved $9k payment.
    unapproved_big = Payment("Acme", dollars(9000))
    for pathway in PAYMENT_PATHWAYS:
        with pytest.raises(ApprovalRequiredError):
            pathway(unapproved_big)
