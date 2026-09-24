#!/usr/bin/env bash
# Prove every check fails on the planted fault and passes on clean data.
# Needs dbt-duckdb. Run from anywhere: integration_tests/run.sh
set -euo pipefail
cd "$(dirname "$0")"
export DBT_PROFILES_DIR=.

rm -f target/integration.duckdb
dbt deps
dbt seed --full-refresh
dbt build --exclude orders_incremental_safe orders_incremental_unsafe

../scripts/check_rerun.sh orders_incremental_safe

if ../scripts/check_rerun.sh orders_incremental_unsafe; then
  echo "FAIL: check_rerun.sh passed a model that duplicates on rerun"
  exit 1
fi
echo "OK: check_rerun.sh caught the duplicating model"
echo "All integration checks passed."
