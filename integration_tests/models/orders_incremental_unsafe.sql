-- No unique key: every rerun appends the same rows again. check_rerun.sh must catch it.
{{ config(materialized='incremental') }}

select order_id, customer_id, amount
from {{ ref('orders_clean') }}
