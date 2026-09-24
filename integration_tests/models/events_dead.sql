-- A source whose system was switched off ten days ago.
select {{ dbt.dateadd('day', -10, dbt.current_timestamp()) }} as loaded_at
