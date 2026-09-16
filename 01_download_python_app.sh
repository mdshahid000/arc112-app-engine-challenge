#!/usr/bin/env bash
set -Eeuo pipefail
# IMPORTANT: Run this command inside the SSH terminal for the lab-setup VM.
cd "$HOME"
if [[ ! -d "$HOME/python-docs-samples/.git" ]]; then
  git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
else
  echo 'python-docs-samples already exists; keeping the lab download.'
fi
cd "$HOME/python-docs-samples/appengine/standard_python3/hello_world"
[[ -f app.yaml && -f main.py ]] || { echo 'Expected Python Hello World files are missing.' >&2; exit 1; }
pwd
ls -la
echo 'Task 1 download complete. Now click Check my progress for Download the Hello World app.'
