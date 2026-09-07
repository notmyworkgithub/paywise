#!/usr/bin/env bash
# Factory demo driver — guided run of show for the assurance talk.
#
# Every beat prints: what to SAY, the command it is about to run, what the
# room should be LOOKING at, and the line to land before you move on.
# Nothing here is destructive: the "break the control" beat runs in a
# disposable copy under /tmp and is deleted straight after.
#
#   ./demo.sh          full run
#   ./demo.sh 4        start at beat 4
#   ./demo.sh --check  pre-flight only

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$REPO/.venv/bin/python"
SCRATCH="/tmp/paywise-break-$$"

# The run made on THIS account, 2026-09-06. Replace if you re-bake.
SESSION_ID="68bcd192-ef60-44cc-9996-81190c3c3c18"
SESSION_DIR="$HOME/.factory/sessions/-private-tmp-claude-502--Users-Shared-ai-demos-cdcfc3e9-74ab-471a-8930-33fe2d6fe3da-scratchpad-paywise-demo"

b=$'\033[1m'; d=$'\033[2m'; r=$'\033[31m'; g=$'\033[32m'
y=$'\033[33m'; c=$'\033[36m'; m=$'\033[35m'; x=$'\033[0m'

beat()  { printf '\n%s%s\n  BEAT %s · %s\n%s%s\n' "$b$c" "══════════════════════════════════════════════════════════════" "$1" "$2" "══════════════════════════════════════════════════════════════" "$x"; }
say()   { printf '\n%s  SAY  %s%s%s\n' "$b$y" "$x$y" "$1" "$x"; }
look()  { printf '\n%s  LOOK AT  %s%s%s\n' "$b$m" "$x$m" "$1" "$x"; }
note()  { printf '%s     · %s%s\n' "$d" "$1" "$x"; }
land()  { printf '\n%s  ⟶  LAND THIS:%s %s\n' "$b$y" "$x" "$1"; }
pause() { printf '\n%s  [Enter]%s' "$d" "$x"; read -r _; }
run()   { printf '\n%s  $ %s%s\n\n' "$b" "$1" "$x"; eval "$1"; }

cleanup() { rm -rf "$SCRATCH"; }
trap cleanup EXIT

preflight() {
  printf '\n%sPRE-FLIGHT%s\n' "$b" "$x"
  local ok=0
  if [ -x "$PY" ]; then printf '  %s✓%s venv python (do NOT type `uv` on this account)\n' "$g" "$x"
  else printf '  %s✗%s venv python missing at %s\n' "$r" "$x" "$PY"; ok=1; fi
  if command -v droid >/dev/null 2>&1; then printf '  %s✓%s droid %s\n' "$g" "$x" "$(droid --version 2>/dev/null | head -1)"
  else printf '  %s✗%s droid not on PATH\n' "$r" "$x"; ok=1; fi
  if git -C "$REPO" log --oneline -1 >/dev/null 2>&1; then printf '  %s✓%s git can read the repo\n' "$g" "$x"
  else printf '  %s✗%s git refuses this repo. Run:\n      git config --global --add safe.directory %s\n' "$r" "$x" "$REPO"; ok=1; fi
  if git -C "$REPO" rev-parse --verify -q factory/recurring-payments >/dev/null; then printf '  %s✓%s branch factory/recurring-payments\n' "$g" "$x"
  else printf '  %s✗%s branch factory/recurring-payments missing\n' "$r" "$x"; ok=1; fi
  if [ -f "$SESSION_DIR/$SESSION_ID.jsonl" ]; then printf '  %s✓%s local session record for beat 5\n' "$g" "$x"
  else printf '  %s!%s no local session record — beat 5 falls back to narration\n' "$y" "$x"; fi
  printf '  %s·%s branch now: %s | clean tree: %s\n' "$d" "$x" \
     "$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null)" \
     "$([ -z "$(git -C "$REPO" status --porcelain 2>/dev/null)" ] && echo yes || echo NO)"
  [ $ok -eq 0 ] && printf '\n  %sReady.%s\n' "$g" "$x" || printf '\n  %sFix the above before you go on.%s\n' "$r" "$x"
  return $ok
}

[ "${1:-}" = "--check" ] && { preflight; exit $?; }
START="${1:-1}"

clear
printf '%s\n  FACTORY — RUN OF SHOW%s\n  %s%s%s\n' "$b" "$x" "$d" "$REPO" "$x"
preflight || { printf '\n%sAborting.%s\n' "$r" "$x"; exit 1; }
printf '\n  %sBudget ~15 min. Beat 3 is the one that lands. Do not rush it.%s\n' "$d" "$x"
pause

# ── 1 ───────────────────────────────────────────────────────────────────────
if [ "$START" -le 1 ]; then
beat 1 "The ticket"
say "\"Before I show you an agent, I want to show you what I gave it.\""
run "cat '$REPO/work-item.md'"
look "the MUST line in the acceptance criteria"
note "Nothing here is prompt-engineered. A junior engineer gets this ticket on a Tuesday."
note "The ticket STATES the rule. It cannot ENFORCE anything. Hold that thought."
land "\"I did not ask the agent to be careful. I wrote a requirement.\""
pause
fi

# ── 2 ───────────────────────────────────────────────────────────────────────
if [ "$START" -le 2 ]; then
beat 2 "The control"
say "\"This is the thing in the codebase that does the enforcing.\""
run "sed -n '/^def test_every_payment_pathway/,\$p' '$REPO/tests/test_policy_invariants.py'"
look "the loop — it iterates a REGISTRY, not a hand-written list"
note "It does not test the new feature. It does not know the feature exists."
note "It asserts: every route to money refuses an unapproved \$9,000 payment."
land "\"This is a segregation-of-duties rule that runs on every commit.\""
pause
fi

# ── 3 ───────────────────────────────────────────────────────────────────────
if [ "$START" -le 3 ]; then
beat 3 "Break it  ← the money beat"
say "\"Let me be the rushed developer. Or the careless agent. Same thing.\""
rm -rf "$SCRATCH"; cp -R "$REPO" "$SCRATCH" 2>/dev/null
cat >> "$SCRATCH/src/paywise/processing.py" <<'PYEOF'


def quick_pay(p: Payment) -> str:
    """Convenience helper added by a hurried developer (or agent)."""
    return f"PAY-{abs(hash((p.vendor, p.amount_cents))) % 10_000_000:07d}"


PAYMENT_PATHWAYS.append(quick_pay)
PYEOF
run "tail -8 '$SCRATCH/src/paywise/processing.py'"
look "ten lines: it creates a payment and never calls is_authorized()"
note "This is a disposable copy in /tmp. Your real repo is untouched."
pause
say "\"Nobody has written a test for that function. It is sixty seconds old.\""
run "cd '$SCRATCH' && '$PY' -m pytest -q 2>&1 | tail -12"
look "DID NOT RAISE ApprovalRequiredError — and WHICH test caught it"
land "\"The build went red the moment a new route to money appeared that did not ask permission. I did not have to notice it. That is the difference between review and control.\""
rm -rf "$SCRATCH"
pause
fi

# ── 4 ───────────────────────────────────────────────────────────────────────
if [ "$START" -le 4 ]; then
beat 4 "Now let the agent try"
say "\"I handed that ticket to Factory. Eighty seconds, no supervision, low autonomy.\""
run "git -C '$REPO' diff main factory/recurring-payments --stat -- src tests"
look "it touched the source AND registered itself in PAYMENT_PATHWAYS"
note "It also ADDED three of its own tests. It did not weaken the control."
pause
say "\"Here is the pathway it invented, and where it registered it.\""
run "git -C '$REPO' diff main factory/recurring-payments -- src/paywise/processing.py | head -45"
look "it routes through submit_payment() — the ONE place that calls is_authorized()"
pause
say "\"So the same gate that just caught me now judges the agent.\""
# Run the branch in a disposable copy — never switch the live repo on stage.
rm -rf "$SCRATCH"; cp -R "$REPO" "$SCRATCH" 2>/dev/null
git -C "$SCRATCH" checkout -q -f factory/recurring-payments 2>/dev/null
run "cd '$SCRATCH' && '$PY' -m pytest -q 2>&1 | tail -5"
look "11 passed — including the control, against a pathway that did not exist this morning"
rm -rf "$SCRATCH"
land "\"I do not have to trust the agent. I have to trust the gate.\""
pause
fi

# ── 5 ───────────────────────────────────────────────────────────────────────
if [ "$START" -le 5 ]; then
beat 5 "The receipt"
say "\"Everything you just watched left a record that is not on my laptop.\""
if [ -f "$SESSION_DIR/$SESSION_ID.jsonl" ]; then
  printf '\n  %sWhat the record actually captured:%s\n\n' "$b" "$x"
  "$PY" - "$SESSION_DIR/$SESSION_ID.jsonl" "$SESSION_DIR/$SESSION_ID.settings.json" <<'PYEOF'
import json, sys, collections
ev = collections.Counter(); tools = collections.Counter()
for line in open(sys.argv[1]):
    try: d = json.loads(line)
    except Exception: continue
    ev[d.get("type", "?")] += 1
    msg = d.get("message") or {}
    body = msg.get("content")
    if isinstance(body, list):
        for blk in body:
            if isinstance(blk, dict) and blk.get("type") == "tool_use":
                tools[blk.get("name")] += 1
s = json.load(open(sys.argv[2]))
u = s.get("tokenUsage", {})
print(f"    model            {s.get('model')}")
print(f"    autonomy         {s.get('autonomyMode')}   (admin-capped at the org tier)")
print(f"    tool execution   {s.get('toolExecutionMode')}   subagents allowed: {s.get('allowSubagentsInScripts')}")
print(f"    provider         {s.get('providerLock')} / {s.get('apiProviderLock')}")
print(f"    active time      {round(s.get('assistantActiveTimeMs',0)/1000,1)}s")
print(f"    cost             {u.get('factoryCredits')} Factory credits")
print(f"    events logged    {sum(ev.values())}")
print(f"    actions taken    " + "  ".join(f"{k}×{v}" for k, v in sorted(tools.items())))
PYEOF
  look "every file it read, every edit it made, every command it ran — enumerated"
  note "This is the local copy. The same record syncs to app.factory.ai as a shareable session URL."
else
  note "No local record found — narrate this beat from the deck instead."
fi
pause
say "\"In the Factory app that same run is a page I can send to a reviewer.\""
printf '\n  %sIn the browser (app.factory.ai), walk these in order:%s\n' "$b" "$x"
note "1. Sessions list  → find the run. If it is EMPTY, you are on a different login than the run."
note "2. Open the run   → the transcript: the ticket in, the reasoning, every tool call"
note "3. The diff       → review it inline, leave a comment, approve"
note "4. Share          → copy the session URL. THIS is the artifact you hand an auditor."
note "5. Settings       → autonomy level. Show that it is a setting, not a vibe."
printf '\n  %s⚠ Rehearse this once. A blank sessions list on stage is the worst-case slide.%s\n' "$r" "$x"
pause
fi

# ── 6 ───────────────────────────────────────────────────────────────────────
if [ "$START" -le 6 ]; then
beat 6 "Honesty — say this out loud"
printf '\n  %sSHOW (real on your $20 Pro tier)%s\n' "$b$g" "$x"
note "session record + transcript · shareable URL · diff review + approve"
note "terminal output · autonomy toggle · Droid Shield secret-block at commit"
printf '\n  %sNARRATE (Business/Enterprise — do not pretend to show)%s\n' "$b$y" "$x"
note "org-wide audit log · SIEM export · deny-lists / model + network policy · SSO + SCIM"
printf '\n  %sNEVER SAY%s\n' "$b$r" "$x"
note "\"Factory codes better than Claude Code\" — it does not, and they will know"
note "\"SOC 2 Type II\" — it is Type I.  \"ISO 42001 certified\" — say ADOPTING"
note "\"Droid Shield strips vulnerabilities\" on this tier — it is secret scanning"
land "\"That is the surface I am narrating rather than showing.\""
pause
fi

printf '\n%s  Factory segment complete.%s\n' "$b$g" "$x"
printf '  %sHandoff line: \"Same question, different mechanism.\" → Buzz.%s\n' "$d" "$x"
printf '  %sIf anything stalls >15s: stop, play recordings/factory-run.mov, keep narrating.%s\n\n' "$d" "$x"
