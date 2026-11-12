# Security

Please report security problems privately, through GitHub's
[private vulnerability reporting](https://github.com/jpsanders/dbt-quiet-failures/security/advisories/new), not in a
public issue.

The package is SQL and one shell script. The tests only read the models they are attached to.
`check_rerun.sh` runs `dbt run` on the model you name, twice, with the flags you pass, so point it at a CI or
development target, not production.
