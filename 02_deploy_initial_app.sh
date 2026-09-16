#!/usr/bin/env bash
set -Eeuo pipefail
REGION="${REGION:-us-west1}"
ROOT="$HOME/python-docs-samples/appengine/standard_python3/hello_world"
[[ -f "$ROOT/app.yaml" ]] || { echo 'Run step 1 first.' >&2; exit 1; }
gcloud config set project "$GOOGLE_CLOUD_PROJECT" >/dev/null
gcloud config set compute/region "$REGION" >/dev/null
gcloud services enable appengine.googleapis.com
if ! grep -q '^automatic_scaling:' "$ROOT/app.yaml"; then
  cat >> "$ROOT/app.yaml" <<'EOF'
automatic_scaling:
  max_instances: 1
EOF
fi
if ! gcloud app describe >/dev/null 2>&1; then
  gcloud app create --region="$REGION"
fi
cd "$ROOT"
gcloud app deploy app.yaml --quiet
URL="$(gcloud app describe --format='value(defaultHostname)')"
echo "Step 2 complete. Open: https://$URL"
echo 'Expected initial greeting: Hello World!'
