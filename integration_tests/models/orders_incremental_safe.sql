-- Keyed incremental: a rerun replaces rows instead of adding them.
{{ config(materialized='incremental', unique_key='order_id', incremental_strategy='delete+insert') }}

select order_id, customer_id, amount
from {{ ref('orders_clean') }}
