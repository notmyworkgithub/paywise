#!/usr/bin/env bash
# Launch PayWise with a Python that will still work after agents edit the code.
# `python3` on this Mac is Apple's 3.9, which rejects modern syntax like `str | None`.
for p in /opt/homebrew/bin/python3 "$HOME/.local/bin/python3.11" python3; do
  if command -v "$p" >/dev/null 2>&1; then PY="$p"; break; fi
done
echo "using $("$PY" --version 2>&1) at $PY"
exec "$PY" "$(dirname "$0")/app.py"
