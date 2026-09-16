#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$HOME/python-docs-samples/appengine/standard_python3/hello_world"
if [[ -d "$HOME/python-docs-samples/.git" ]]; then
  echo 'Existing python-docs-samples checkout found; reusing it.'
else
  git clone --depth=1 https://github.com/GoogleCloudPlatform/python-docs-samples.git "$HOME/python-docs-samples"
fi
[[ -f "$ROOT/app.yaml" && -f "$ROOT/main.py" ]] || { echo "Python sample not found at $ROOT" >&2; exit 1; }
cd "$ROOT"
# Keep the source at the official current Python 3 standard runtime.
sed -i 's/^runtime: python.*/runtime: python312/' app.yaml
printf 'Sample directory: %s\n' "$PWD"
grep '^runtime:' app.yaml
echo 'Step 1 complete. Run step 2 from this same SSH terminal.'
