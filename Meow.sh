#!/usr/bin/env bash
set -Eeuo pipefail

REGION="us-east4"
INSTANCE="lab-setup"
REMOTE_HOME="/tmp/arc112-home"
LOCAL_APP="/tmp/arc112-app"

log() { printf '\n\033[1;36m[%s]\033[0m %s\n' "$(date +%H:%M:%S)" "$*"; }

PROJECT_ID="$(gcloud config get-value project 2>/dev/null || true)"
if [[ -z "${PROJECT_ID}" || "${PROJECT_ID}" == "(unset)" ]]; then
  PROJECT_ID="$(gcloud projects list --format='value(projectId)' --filter='projectId~^qwiklabs-gcp-' --limit=1)"
fi
[[ -n "${PROJECT_ID}" ]] || { echo "ERROR: Lab project nahi mila." >&2; exit 1; }
gcloud config set project "${PROJECT_ID}" >/dev/null
ZONE="$(gcloud compute instances list --filter="name=('${INSTANCE}')" --format='value(zone.basename())' | head -n1)"
[[ -n "${ZONE}" ]] || { echo "ERROR: lab-setup VM nahi mili." >&2; exit 1; }

log "Project: ${PROJECT_ID} | VM: ${INSTANCE} | Zone: ${ZONE} | App Engine region: ${REGION}"

run_remote() {
  local script="$1"
  local encoded
  encoded="$(printf '%s' "$script" | base64 -w0)"
  gcloud compute ssh "${INSTANCE}" --zone="${ZONE}" --tunnel-through-iap --quiet \
    --command="echo ${encoded} | base64 -d | bash"
}

REMOTE_PREP='set -Eeuo pipefail
WORKDIR="$HOME/python-docs-samples"
APPDIR="$WORKDIR/appengine/standard_python3/hello_world"
if [[ ! -d "$APPDIR" ]]; then
  git clone --depth=1 --filter=blob:none --sparse https://github.com/GoogleCloudPlatform/python-docs-samples.git "$WORKDIR"
  git -C "$WORKDIR" sparse-checkout set appengine/standard_python3/hello_world
fi
cd "$APPDIR"
sed -i "/^automatic_scaling:/,$d" app.yaml || true
cat >> app.yaml <<"EOF"
automatic_scaling:
  max_instances: 1
EOF
printf "VM_APP_READY=%s\\n" "$APPDIR"'

log "IAP ke through VM par Hello World app download/configure kar raha hoon"
run_remote "${REMOTE_PREP}"

rm -rf "${LOCAL_APP}"
mkdir -p "${LOCAL_APP}"
log "VM se app Cloud Shell me copy kar raha hoon"
gcloud compute scp --recurse --tunnel-through-iap --quiet \
  "${INSTANCE}:python-docs-samples/appengine/standard_python3/hello_world/." \
  "${LOCAL_APP}/" --zone="${ZONE}"
cd "${LOCAL_APP}"

if ! gcloud app describe >/dev/null 2>&1; then
  log "Cloud Shell student account se App Engine us-east4 initialize kar raha hoon"
  gcloud app create --region="${REGION}" --quiet
fi

log "Cloud Shell student account se first deployment kar raha hoon"
gcloud app deploy app.yaml --quiet
URL="$(gcloud app browse --no-launch-browser 2>/dev/null | awk '/https?:\/\// {print $NF; exit}')"
[[ -n "${URL}" ]] || URL="https://${PROJECT_ID}.appspot.com"
STATUS1="$(curl -L -s -o /tmp/arc112-before.txt -w '%{http_code}' "${URL}" || true)"
printf '\nFirst deployment URL: %s\nHTTP status: %s\n' "${URL}" "${STATUS1}"

log "VM par greeting update kar raha hoon"
REMOTE_UPDATE='set -Eeuo pipefail
cd "$HOME/python-docs-samples/appengine/standard_python3/hello_world"
python3 - <<"PY"
from pathlib import Path
p=Path("main.py")
s=p.read_text()
for old in ("Hello, World!", "Hello World!", "Hello world!", "Hello World"):
    s=s.replace(old, "Hello, Cruel World!")
p.write_text(s)
assert "Cruel World" in s
PY'
run_remote "${REMOTE_UPDATE}"

rm -rf "${LOCAL_APP}"
mkdir -p "${LOCAL_APP}"
log "Updated app VM se Cloud Shell me copy kar raha hoon"
gcloud compute scp --recurse --tunnel-through-iap --quiet \
  "${INSTANCE}:python-docs-samples/appengine/standard_python3/hello_world/." \
  "${LOCAL_APP}/" --zone="${ZONE}"
cd "${LOCAL_APP}"

log "Cloud Shell student account se updated deployment kar raha hoon"
gcloud app deploy app.yaml --quiet
STATUS2="$(curl -L -s -o /tmp/arc112-after.txt -w '%{http_code}' "${URL}" || true)"
printf '\nFinal deployment URL: %s\nHTTP status: %s\n' "${URL}" "${STATUS2}"
sed -n '1,5p' /tmp/arc112-after.txt || true
printf '\nARC112 deployments complete. 30-60 seconds wait karke Check my progress click karein.\n'
