# paywise

A minimal vendor-payment service used for a live demo.

**Business rule:** Any payment over $5,000 requires manager approval. All payments must go
through `submit_payment()`. Any new payment pathway MUST enforce this policy and be covered
by `tests/test_policy_invariants.py`.

## Running the tests

```bash
uv run pytest -v
```
