# Changelog

Versions follow [semantic versioning](https://semver.org). Tags carry the bare version, such as `1.0.0`.

## 1.0.0 (2026-11-12)

- The checks and their behaviour are unchanged from 0.1.0; this release marks them stable.
- A full reference as a man page, `man/dbt-quiet-failures.7`, from `docs/MANUAL.md`; CI fails when it is stale.
- A Claude Code plugin with a skill that adds the checks to a dbt project, AGENTS.md, llms.txt, a code of conduct,
  issue forms and Dependabot for the workflow actions.
- CI on Python 3.14 with dbt 1.10 and the latest dbt; the job names say which dbt they run.
- The first release is tagged `0.1.0` now, without the v.

## 0.1.0 (2026-09-24)

The first version: strict_relationships, no_mojibake, still_loading, the fingerprint macro and check_rerun.sh, with
an integration suite on DuckDB.
