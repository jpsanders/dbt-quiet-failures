-- A source that loaded an hour ago.
select {{ dbt.dateadd('hour', -1, dbt.current_timestamp()) }} as loaded_at
