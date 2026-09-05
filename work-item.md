# Add support for recurring vendor payments

We onboard vendors who bill the same amount monthly. Add the ability to create a recurring
payment that generates a payment each cycle.

## Acceptance criteria
- A function to create a recurring vendor payment (vendor, amount, cadence).
- Each generated payment MUST go through the existing approval policy: recurring payments over
  $5,000 require manager approval, same as one-time payments.
- Add the new pathway to `PAYMENT_PATHWAYS` and cover it in `tests/test_policy_invariants.py`.
- All existing tests must continue to pass.
