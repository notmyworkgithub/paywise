# Factory demo — Runbook (~15–20 min)

**Status: SKELETON — Task A6 (pre-bake) has NOT run yet.** 🛑 It needs `FACTORY_API_KEY`
(PART 0 item 1: Factory Pro, $20/mo) and spends money. After the pre-bake, replace every
`TODO(A6)` with what *actually* happened — this runbook must reflect the observed run, not hopes.

**The honest line (say it):** "The coding itself is comparable to any good agent — what you're
watching is the **governed pathway**: the control, the gate, the audit trail."

## Pre-flight (verified against Factory docs 2026-09-04)
```bash
# install (once): ALREADY DONE on this machine — droid 0.212.1 via `brew install --cask droid`
export FACTORY_API_KEY=fk-...                      # from app.factory.ai/settings/api-keys
cd ai-demos/factory-demo
# smoke test (cheap):
droid exec "list the files in this repo" --output-format json
```

## The run (pre-baked in Task A6; re-run live only if rehearsed timing allows)
```bash
git checkout -b factory/recurring-payments
droid exec -f work-item.md --output-format json --auto low \
  2>&1 | tee ../recordings/factory-run.log
# then the control:
uv run pytest -v
```
- `--auto low` = safe file edits only; read-only is the default without it.
- Use `--reasoning-effort` (long form) if tuning; `-r` means resume in interactive mode.
- Exit code is 0/nonzero — CI-gradable.
- TODO(A6): model chosen, wall-clock time, cost observed.

## Live beats (matches deck slide 8 cue box)
1. Show `work-item.md` — a normal ticket. (~1 min)
2. Reveal the pre-baked run: `factory-run.log` + the diff/PR Factory produced. (~4 min)
3. **The control:** run `uv run pytest -v` on Factory's branch. (~3 min)
   - TODO(A6): which outcome happened —
     - Invariant test FAILED → "the control caught an ungoverned pathway." (+ self-correction if captured)
     - All PASSED → "the policy was enforced; nothing merges without the gate + human sign-off."
4. Factory App: audit trail / session record / autonomy settings; Droid Shield note — baseline
   secret-scanning at the commit gate is on this ($20) tier; deeper policy/SIEM surfaces are
   enterprise — narrate them from the settings screens. (~4 min)
5. Takeaway slide (deck 9). (~1 min)

## Timings
TODO(A6): fill from rehearsal.

## Fallback
- `recordings/factory-run.mov` — the run + pytest control moment.
- `recordings/factory-audit-trail.mov` — the App governance surfaces.
- Trigger: any live command that stalls >15s or errors once. Do not debug on stage.
