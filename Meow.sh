#!/usr/bin/env bash
set -Eeuo pipefail

REGION="us-east4"
INSTANCE="lab-setup"
REMOTE_SCRIPT="/tmp/arc112-run.sh"

log() { printf '\n\033[1;36m[%s]\033[0m %s\n' "$(date +%H:%M:%S)" "$*"; }

PROJECT_ID="$(gcloud config get-value project 2>/dev/null || true)"
if [[ -z "${PROJECT_ID}" || "${PROJECT_ID}" == "(unset)" ]]; then
  PROJECT_ID="$(gcloud projects list --format='value(projectId)' --filter='projectId~^qwiklabs-gcp-' --limit=1)"
fi
if [[ -z "${PROJECT_ID}" ]]; then
  echo "ERROR: Lab project nahi mila. Cloud Shell me lab student account se login karein." >&2
  exit 1
fi

gcloud config set project "${PROJECT_ID}" >/dev/null

ZONE="$(gcloud compute instances list --filter="name=('${INSTANCE}')" --format='value(zone.basename())' | head -n1)"
if [[ -z "${ZONE}" ]]; then
  echo "ERROR: '${INSTANCE}' VM nahi mili. Lab start karke Cloud Shell se dobara run karein." >&2
  exit 1
fi

log "Project: ${PROJECT_ID} | VM: ${INSTANCE} | Zone: ${ZONE} | App Engine region: ${REGION}"

cat > /tmp/arc112-remote.sh <<'REMOTE'
#!/usr/bin/env bash
set -Eeuo pipefail
REGION="us-east4"
WORKDIR="${HOME}/python-docs-samples"
APPDIR="${WORKDIR}/appengine/standard_python3/hello_world"
log() { printf '\n[VM %s] %s\n' "$(date +%H:%M:%S)" "$*"; }

log "Python Hello World repository clone/check"
if [[ ! -d "${APPDIR}" ]]; then
  git clone --depth=1 --filter=blob:none --sparse \
    https://github.com/GoogleCloudPlatform/python-docs-samples.git "${WORKDIR}"
  git -C "${WORKDIR}" sparse-checkout set appengine/standard_python3/hello_world
fi
cd "${APPDIR}"

# Keep the lab project within its instance quota requirement.
sed -i '/^automatic_scaling:/,$d' app.yaml || true
cat >> app.yaml <<'EOF'
automatic_scaling:
  max_instances: 1
EOF

log "First deployment: default Hello World"
gcloud app deploy app.yaml --quiet

URL="$(gcloud app browse --no-launch-browser 2>/dev/null | awk '/https?:\/\// {print $NF; exit}')"
if [[ -z "${URL}" ]]; then URL="https://${GOOGLE_CLOUD_PROJECT}.appspot.com"; fi
STATUS1="$(curl -L -s -o /tmp/arc112-before.txt -w '%{http_code}' "${URL}" || true)"
printf '\nFirst deployment URL: %s\nHTTP status: %s\n' "${URL}" "${STATUS1}"

log "Greeting ko Hello, Cruel World! me update kar raha hoon"
python3 - <<'PY'
from pathlib import Path
p = Path('main.py')
if not p.exists():
    raise SystemExit('ERROR: Expected Python main.py nahi mila')
s = p.read_text()
replacements = [
    ('Hello, World!', 'Hello, Cruel World!'),
    ('Hello World!', 'Hello, Cruel World!'),
    ('Hello world!', 'Hello, Cruel World!'),
    ('Hello World', 'Hello, Cruel World!'),
]
for old, new in replacements:
    s = s.replace(old, new)
p.write_text(s)
if 'Cruel World' not in s:
    raise SystemExit('ERROR: Greeting update apply nahi hua')
PY

log "Second deployment: updated greeting"
gcloud app deploy app.yaml --quiet
STATUS2="$(curl -L -s -o /tmp/arc112-after.txt -w '%{http_code}' "${URL}" || true)"
printf '\nFinal deployment URL: %s\nHTTP status: %s\n' "${URL}" "${STATUS2}"
printf 'Final response preview:\n'
sed -n '1,5p' /tmp/arc112-after.txt || true
REMOTE

chmod +x /tmp/arc112-remote.sh
ENCODED="$(base64 -w0 /tmp/arc112-remote.sh)"
log "IAP tunnel ke through ${INSTANCE} VM par remote deployment workflow chala raha hoon"
SSH_COMMAND="echo ${ENCODED} | base64 -d > ${REMOTE_SCRIPT} && chmod +x ${REMOTE_SCRIPT} && ${REMOTE_SCRIPT}"
SSH_OK=0
for ATTEMPT in 1 2 3 4; do
  if gcloud compute ssh "${INSTANCE}" --zone="${ZONE}" \
      --tunnel-through-iap --quiet --command="${SSH_COMMAND}"; then
    SSH_OK=1
    break
  fi
  log "SSH attempt ${ATTEMPT} fail hua; 15 seconds baad retry kar raha hoon"
  sleep 15
done
if [[ "${SSH_OK}" != "1" ]]; then
  echo "ERROR: lab-setup VM par SSH establish nahi hua. Console me VM row ka SSH button ek baar open karke script dobara run karein." >&2
  exit 1
fi

cat <<'NOTE'

ARC112 ke download, first deployment aur updated deployment tasks complete ho gaye. Skills Boost page par 30-60 seconds wait karke dono objectives par "Check my progress" click karein.
NOTE
