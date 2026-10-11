#!/bin/sh
set -eu

test -n "${OFFLOADR_VENV}"
test -x "${OFFLOADR_VENV}/bin/python"

"${OFFLOADR_VENV}/bin/python" launch.py --uv --skip-install \
    --skip-torch-cuda-test --cpu --ui-debug-mode \
    --model-ref /tmp/forge-build-models > /tmp/forge-warmup.log 2>&1 &
pid="$!"
trap 'kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true' EXIT

ready=0
for _ in $(seq 1 180); do
    if grep -Eq "Running on local URL|Startup time:|Application startup complete" /tmp/forge-warmup.log; then
        ready=1
        break
    fi
    if ! kill -0 "$pid" 2>/dev/null; then
        cat /tmp/forge-warmup.log
        wait "$pid"
        exit 1
    fi
    sleep 1
done
cat /tmp/forge-warmup.log
test "$ready" = 1

# Confirm the server answers before preserving its generated startup artifacts.
"${OFFLOADR_VENV}/bin/python" -c 'import urllib.request; assert urllib.request.urlopen("http://127.0.0.1:7860/", timeout=30).status == 200'
kill "$pid" 2>/dev/null || true
wait "$pid" 2>/dev/null || true
trap - EXIT
