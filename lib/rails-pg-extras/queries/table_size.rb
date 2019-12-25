# frozen_string_literal: true

module RailsPGExtras
  def self.table_size_description
    "Size of the tables (excluding indexes), descending by size"
  end

  def self.table_size_sql
    <<-EOS
SELECT c.relname AS name,
  pg_size_pretty(pg_table_size(c.oid)) AS size
FROM pg_class c
LEFT JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
AND n.nspname !~ '^pg_toast'
AND c.relkind='r'
ORDER BY pg_table_size(c.oid) DESC;
EOS
  end
end
