# Factory demo — Runbook (~15–20 min)

**Status: PRE-BAKE DONE (2026-09-04).** The Factory run below is real and captured. Remaining
human items: screen-record the reveal beats (see Fallbacks), and capture the Factory App
governance surfaces (Task A6 step 4).

**The honest line (say it):** "The coding itself is comparable to any good agent — what you're
watching is the **governed pathway**: the control, the gate, the audit trail."

## What actually happened (observed, not hoped)
- Auth smoke test: `droid exec "list the files in this repo" --output-format json` → success in ~5s.
- Real run: `droid exec -f work-item.md --output-format json --auto low -m claude-haiku-4-5-20251001`
  - **64 seconds, 14 turns, ~36k Factory credits.** Full JSON log: `../recordings/factory-run.log`.
  - Gotcha hit live: short model aliases are rejected — use the full dated id
    (`claude-haiku-4-5-20251001`). `droid` prints the valid model list on error.
- **Outcome: Factory implemented it CORRECTLY.** `create_recurring_payment()` routes every
  generated payment through `submit_payment()`, registered a wrapper in `PAYMENT_PATHWAYS`, and
  added three recurring-payment tests of its own.
- Verification: `uv run pytest -v` → **11/11 PASSED**, including the control
  (`test_every_payment_pathway_enforces_policy`) against the new pathway. Output captured in
  `../recordings/factory-run-pytest.txt`.
- Changes live on branch **`factory/recurring-payments`** (commit `03243c0`); `main` still holds
  the pre-Factory state, so the diff can be shown live: `git diff main factory/recurring-payments`.

**Narration (the "enforced" beat, since there was no catch):** "The ticket *told* the agent the
rule, the codebase *enforced* it, and the control test proves every pathway — including the one
the agent just invented — rejects an unapproved $9,000 payment. Nothing merges without this gate
plus a human sign-off. If the agent had skipped the pathway, this same test is what would have
caught it."

## Pre-flight (verified live 2026-09-04)
```bash
# droid 0.212.1 already installed (brew install --cask droid)
# key lives in /Users/t/_repos/wrk/.env (FACTORY_API_KEY=...)
cd ai-demos/factory-demo
set -a && source ../../.env && set +a
droid exec "list the files in this repo" --output-format json   # 5s smoke test
```

## Live beats (matches deck slide 8 cue box)
1. Show `work-item.md` — a normal ticket. (~1 min)
2. Reveal the pre-baked run: `../recordings/factory-run.log` (or re-run live — 64s is short
   enough to kick off, then narrate over it). (~4 min)
3. **The control:** `git checkout factory/recurring-payments && uv run pytest -v` → 11/11, walk
   `test_every_payment_pathway_enforces_policy`. Show the diff vs main. (~3 min)
4. Factory App (app.factory.ai): session record for run `36f3de15…`, autonomy settings, Droid
   Shield — "secret scanning at the commit gate runs on this $20 tier; audit/SIEM/policy
   enforcement is the enterprise tier — that's the surface I'm narrating." (~4 min)
5. Takeaway slide (deck 9). (~1 min)

## Timings (to confirm in dress rehearsal)
Run: ~1 min · pytest: instant · total segment budget 15–20 min holds with ~5 min of Q&A slack.

## Fallbacks (capture during rehearsal)
- `../recordings/factory-run.log` — real JSON log (exists ✅)
- `../recordings/factory-run-pytest.txt` — real pytest output (exists ✅)
- `../recordings/factory-run.mov` — screen recording of beats 2–3 (**TODO: record in rehearsal**)
- `../recordings/factory-audit-trail.mov` — App governance surfaces (**TODO: human, A6 step 4**)
- Trigger: any live command that stalls >15s or errors once. Do not debug on stage.
