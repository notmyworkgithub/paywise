#!/usr/bin/env bash
# Launch PayWise.
#
# PYTHONPATH=src mirrors what pytest already does (pythonpath = ["src"] in
# pyproject.toml). Without it, the moment app.py imports the paywise policy
# package the app stops starting. Do not remove this.
#
# Interpreter order matters too: Apple's /usr/bin/python3 is 3.9 and rejects
# modern syntax, so it is last.
here="$(cd "$(dirname "$0")" && pwd)"
for p in "$here/.venv/bin/python" /opt/homebrew/bin/python3 python3; do
  if [ -x "$p" ] || command -v "$p" >/dev/null 2>&1; then PY="$p"; break; fi
done
echo "using $("$PY" --version 2>&1) at $PY"
cd "$here" && PYTHONPATH="$here/src${PYTHONPATH:+:$PYTHONPATH}" exec "$PY" app.py
