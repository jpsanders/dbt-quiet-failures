{#
    Failure 1: the fact table joins on a null.

    dbt's built in `relationships` test skips rows whose key is null, so a
    fact row with a missing key passes it, then vanishes from every inner
    join downstream. Surrogate keys make it worse: dbt_utils'
    generate_surrogate_key hashes a row of nulls into an ordinary looking
    value, so `not_null` passes too.

    This test returns every child row whose key is null, empty, or has no
    match in the parent. A deliberate "unknown" member (a key of -1, say)
    passes, as long as the parent carries that row.
#}

{% test strict_relationships(model, column_name, to, field) %}

with child as (

    select {{ column_name }} as child_key
    from {{ model }}

),

parent as (

    select distinct {{ field }} as parent_key
    from {{ to }}

)

select child.child_key
from child
left join parent
    on child.child_key = parent.parent_key
where child.child_key is null
   or trim(cast(child.child_key as {{ dbt.type_string() }})) = ''
   or parent.parent_key is null

{% endtest %}
