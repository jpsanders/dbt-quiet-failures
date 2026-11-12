# dbt-quiet-failures

## NAME

dbt-quiet-failures - four dbt checks for the failures that pass every other test

## SYNOPSIS

```
packages:
  - git: "https://github.com/jpsanders/dbt-quiet-failures.git"
    revision: 1.0.0

quiet_failures.strict_relationships   a data test: to, field
quiet_failures.no_mojibake            a data test: patterns (optional)
quiet_failures.still_loading          a data test: datepart, interval
quiet_failures.fingerprint            a macro: model
scripts/check_rerun.sh MODEL [DBT FLAGS...]
```

## DESCRIPTION

The pipeline ran green and the numbers are still wrong. Each check in this package targets one way that happens, and
each is proven in CI against a fixture that contains the failure and against clean data where it must find nothing.

It needs dbt 1.10 or later and no other packages. The checks use dbt's cross database macros; CI runs them on DuckDB
with dbt 1.10 and the latest dbt.

## INSTALL

Add the package to `packages.yml` with the release tag as the revision, then run `dbt deps`. The tests are called
with the `quiet_failures.` prefix.

## CHECKS

### strict_relationships

dbt's `relationships` test skips rows whose key is null, so a fact row passes, then vanishes from every inner join
downstream, and the revenue comes out quietly short. `strict_relationships` fails on a null key, an empty key and a
key with no match in the parent. A deliberate unknown member, such as -1, passes when the dimension carries it.

```
columns:
  - name: customer_key
    data_tests:
      - quiet_failures.strict_relationships:
          arguments:
            to: ref('dim_customer')
            field: customer_key
```

### no_mojibake

UTF-8 read as Latin-1 or Windows-1252 turns "José" into "JosÃ©". `no_mojibake` fails on those byte pair signatures and
on the Unicode replacement character. A lone "Ã" is not enough, so uppercase Portuguese such as "SÃO PAULO" passes.
Pass `patterns` to replace the default list.

```
columns:
  - name: customer_name
    data_tests:
      - quiet_failures.no_mojibake
```

### still_loading

A source is switched off, its table stops updating, and every model on top of it keeps running green on old data.
`still_loading` fails when the newest value in the column is older than the window you set. Unlike
`dbt source freshness`, it runs inside `dbt build`.

```
columns:
  - name: loaded_at
    data_tests:
      - quiet_failures.still_loading:
          arguments:
            datepart: hour
            interval: 24
```

### check_rerun.sh and fingerprint

An incremental model without a reliable unique key appends the same rows again when it reruns, and nothing fails.
`scripts/check_rerun.sh` runs the model twice and compares the row count and the count of distinct rows after each run,
using the `fingerprint` macro, and exits 1 if either moved.

```
scripts/check_rerun.sh fct_orders --target ci
dbt run-operation quiet_failures.fingerprint --args '{model: fct_orders}'
```

## PROOF

`integration_tests/run.sh` seeds a fixture for each failure and asserts the exact rows each check returns: 2 bad keys,
2 garbled names, 1 dead source, and a rerun that doubles 3 rows to 6. Every check also runs on clean data, where it
must find nothing.

## EXIT STATUS

The data tests fail the way any dbt test fails: `dbt build` and `dbt test` exit non zero. `check_rerun.sh` exits 0
when the rerun left the model unchanged, 1 when it changed it, 2 on bad arguments.

## FOR AGENTS

To harden a dbt project: add `strict_relationships` to every foreign key in a fact model, `no_mojibake` to text
columns that come from another system, and `still_loading` to the load timestamp of each source model; then run
`check_rerun.sh` on every incremental model in CI. Read `dbt build` output for the failing test and the rows it
returned before changing data or thresholds.

## SEE ALSO

https://github.com/jpsanders/dbt-quiet-failures

## AUTHOR

James Phillip Sanders, https://jamesphillipsanders.com
