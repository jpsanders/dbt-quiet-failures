{#
    Failure 4: a dead source keeps building.

    A system is switched off, its table stops updating, and every model on
    top of it keeps running green against yesterday's data, then last
    month's. `dbt source freshness` catches this, but it is a separate
    command that `dbt build` does not run, so it only helps where someone
    has scheduled it.

    This test fails when the newest value in `column_name` is older than
    `interval` units of `datepart`. Put it on the source or on the first
    model built from it. dbt_utils.recency does the same job; this one ships
    with the other three so the package needs no dependencies.
#}

{% test still_loading(model, column_name, datepart, interval) %}

with newest as (

    select max({{ column_name }}) as newest_value
    from {{ model }}

)

select newest_value
from newest
where newest_value is null
   or newest_value < {{ dbt.dateadd(datepart, -1 * interval, dbt.current_timestamp()) }}

{% endtest %}
