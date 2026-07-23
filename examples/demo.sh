#!/usr/bin/env bash
# demo.sh - a short simulation of a night run using the whole kit.
#
# It runs a few bounded iterations under the runaway guard, narrates them with
# nightlog, runs a verification gate (one passing check, one failing), then prints
# the morning brief. It writes only into a throwaway .nightshift-demo dir and cleans
# up after itself, so it is safe to run anywhere.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
bin="$root/bin"
export NIGHTSHIFT_DIR="$root/.nightshift-demo"
rm -rf "$NIGHTSHIFT_DIR"

echo "== bounded work under the runaway guard (cap: 3 iterations) =="
i=0
while "$bin/runaway-guard" --max-iters 3 --max-minutes 60; do
  i=$(( i + 1 ))
  echo "  iteration $i: doing one unit of work"
  "$bin/nightlog" done "processed batch $i"
done

echo
echo "== record a cost marker and a note =="
"$bin/nightlog" cost "approx 1.2M tokens across the run"
"$bin/nightlog" note "one flaky check retried and passed"

echo
echo "== verification gate (one pass, one deliberate fail) =="
"$bin/verify-gate" "true" "false" || echo "  (gate correctly reported a failure and returned nonzero)"

echo
echo "== morning brief =="
echo
"$bin/morning-brief"

rm -rf "$NIGHTSHIFT_DIR"
