{#
    Failure 2: a rerun duplicates instead of repairing.

    An incremental model without a reliable unique key appends the same rows
    again when it reruns, and nothing fails. The only proof of a safe rerun
    is to run it twice and compare.

    `fingerprint` logs a relation's row count and its count of distinct
    rows, as one JSON line. `scripts/check_rerun.sh` runs a model, takes a
    fingerprint, runs it again and fails if the fingerprint moved.

        dbt run-operation quiet_failures.fingerprint --args '{model: fct_orders}'
#}

{% macro fingerprint(model) %}

    {%- set relation = ref(model) -%}
    {%- set columns = adapter.get_columns_in_relation(relation) -%}
    {#- Every column as text, nulls made visible, with a separator so ("a", "bc") and ("ab", "c") differ. -#}
    {%- set parts = [] -%}
    {%- for column in columns -%}
        {%- do parts.append("coalesce(cast(" ~ column.quoted ~ " as " ~ dbt.type_string() ~ "), '<null>')") -%}
        {%- do parts.append("'|'") -%}
    {%- endfor -%}
    {%- set row_expression = dbt.concat(parts) -%}

    {%- set query -%}
        select
            count(*) as row_count,
            count(distinct {{ row_expression }}) as distinct_rows
        from {{ relation }}
    {%- endset -%}

    {%- set result = run_query(query) -%}
    {%- if execute -%}
        {%- set row = result.rows[0] -%}
        {{ log('{"relation": "' ~ relation.schema ~ '.' ~ relation.identifier ~ '", "rows": ' ~ row[0] ~ ', "distinct_rows": ' ~ row[1] ~ '}', info=true) }}
    {%- endif -%}

{% endmacro %}
