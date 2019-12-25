# frozen_string_literal: true

module RailsPGExtras
  def self.table_indexes_size_description
    "Total size of all the indexes on each table, descending by size"
  end

  def self.table_indexes_size_sql
    <<-EOS
SELECT c.relname AS table,
  pg_size_pretty(pg_indexes_size(c.oid)) AS index_size
FROM pg_class c
LEFT JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
AND n.nspname !~ '^pg_toast'
AND c.relkind='r'
ORDER BY pg_indexes_size(c.oid) DESC;
EOS
  end
end
