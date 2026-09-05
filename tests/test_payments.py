from paywise.payments import Payment, dollars


def test_payment_holds_amount_in_cents():
    p = Payment(vendor="Acme", amount_cents=dollars(6000))
    assert p.amount_cents == 600000
    assert p.approved_by is None
