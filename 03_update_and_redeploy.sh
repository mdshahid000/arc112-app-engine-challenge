#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$HOME/python-docs-samples/appengine/standard_python3/hello_world"
[[ -f "$ROOT/main.py" ]] || { echo 'Run step 1 first.' >&2; exit 1; }
cd "$ROOT"
python3 - <<'PY'
from pathlib import Path
p=Path('main.py')
s=p.read_text()
s=s.replace('Hello World!', 'Goodbye world!').replace('Hello, World!', 'Goodbye world!')
p.write_text(s)
PY
gcloud app deploy app.yaml --quiet
URL="$(gcloud app describe --format='value(defaultHostname)')"
echo "Step 3 complete. Open: https://$URL"
echo 'Expected updated greeting: Goodbye world!'
