#!/usr/bin/env bash
# Run a model twice and fail if the second run changed it.
#
#   scripts/check_rerun.sh <model> [extra dbt flags, for example --target ci]
#
# A safe incremental model repairs on a rerun. An unsafe one appends the same
# rows again, and nothing else in dbt notices. This compares the row count and
# the count of distinct rows after each run, using quiet_failures.fingerprint.
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: $0 <model> [dbt flags]" >&2
  exit 2
fi
model="$1"
shift

fingerprint() {
  dbt run-operation quiet_failures.fingerprint --args "{model: ${model}}" "$@" \
    | grep -o '{"relation".*}' | tail -n 1
}

dbt run --select "${model}" "$@" > /dev/null
first="$(fingerprint "$@")"
dbt run --select "${model}" "$@" > /dev/null
second="$(fingerprint "$@")"

echo "after run 1: ${first}"
echo "after run 2: ${second}"
if [ -z "${first}" ] || [ "${first}" != "${second}" ]; then
  echo "FAIL: rerunning ${model} changed it"
  exit 1
fi
echo "OK: rerunning ${model} left it unchanged"
