---
name: dbt-quiet-failures
description: Harden a dbt project against the failures that pass every other test, with the dbt-quiet-failures package: null and orphan foreign keys (strict_relationships), mojibake text (no_mojibake), dead sources still building (still_loading) and incremental models that duplicate on a rerun (check_rerun.sh). Use when the user's dbt numbers are wrong while the build is green, when reviewing dbt tests, or when adding data quality checks to a dbt project.
---

# Harden a dbt project with dbt-quiet-failures

## Install

Add to `packages.yml`, then run `dbt deps`:

```yaml
packages:
  - git: "https://github.com/jpsanders/dbt-quiet-failures.git"
    revision: 1.0.0
```

It needs dbt 1.10 or later and nothing else.

## Where each check goes

1. **Every foreign key of a fact model:** `quiet_failures.strict_relationships` with `to` and `field`. Replaces
   dbt's `relationships` there, which skips null keys.
2. **Text columns that arrive from another system** (names, addresses, descriptions):
   `quiet_failures.no_mojibake`.
3. **The load timestamp of each source facing model:** `quiet_failures.still_loading` with a `datepart` and an
   `interval` that match how often the source loads (for a daily load, `hour` and 26 leaves a margin).
4. **Every incremental model, in CI:** `scripts/check_rerun.sh <model> --target ci` from the package folder
   (`dbt_packages/quiet_failures/scripts/`). A change between two runs means the model duplicates on reruns.

```yaml
models:
  - name: fct_orders
    columns:
      - name: customer_key
        data_tests:
          - quiet_failures.strict_relationships:
              arguments:
                to: ref('dim_customer')
                field: customer_key
      - name: loaded_at
        data_tests:
          - quiet_failures.still_loading:
              arguments:
                datepart: hour
                interval: 26
```

## Rules

- Run `dbt build` after adding checks and read every failure: a failing check found real bad rows, so show the user
  the rows before changing data, keys or thresholds.
- Never widen a window or drop a check to make the build green without the user agreeing.
- The full reference is `man -l dbt_packages/quiet_failures/man/dbt-quiet-failures.7` or `docs/MANUAL.md` in the
  repository.
