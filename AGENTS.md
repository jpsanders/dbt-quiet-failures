# AGENTS.md

Instructions for AI coding agents working on dbt-quiet-failures itself. To use the package in a dbt project, read
`skills/dbt-quiet-failures/SKILL.md`.

## Commands

```sh
pip install dbt-duckdb           # once, on a Python the dbt version supports (3.14 for the latest)
integration_tests/run.sh         # every check on its fault and on clean data; CI runs the same
python3 scripts/build_man.py     # rebuild man/dbt-quiet-failures.7 after editing docs/MANUAL.md
```

## Layout

```text
macros/tests/          the three data tests
macros/fingerprint.sql the macro check_rerun.sh compares
scripts/check_rerun.sh run a model twice and fail if it changed
integration_tests/     a dbt project with seeds that plant each fault, and run.sh
docs/MANUAL.md         the one source for the man page
```

## Rules

- A new check comes with a seed that contains the fault and an assertion of the exact number of rows it returns, and
  it must return none on clean data. A check that cannot fail proves nothing.
- Use dbt's cross database macros, so the package stays adapter neutral, and add no package dependencies.
- Tags carry the bare version, `1.2.0`, never `v1.2.0`; `dbt_project.yml` carries the same version.
