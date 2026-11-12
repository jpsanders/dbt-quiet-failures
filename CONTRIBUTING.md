# Contributing

Issues and pull requests are welcome, especially another failure that gets past every other test.

```sh
git clone https://github.com/jpsanders/dbt-quiet-failures && cd dbt-quiet-failures
pip install dbt-duckdb
integration_tests/run.sh
```

A new check needs a seed that plants the fault, an assertion of the exact number of rows it returns, and a clean run
where it returns none. After editing `docs/MANUAL.md`, run `python3 scripts/build_man.py`.
