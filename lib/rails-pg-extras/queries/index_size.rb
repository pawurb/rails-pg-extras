# frozen_string_literal: true

module RailsPGExtras
  def self.index_size_description
    "The size of indexes, descending by size"
  end

  def self.index_size_sql
    <<-EOS
SELECT c.relname AS name,
  pg_size_pretty(sum(c.relpages::bigint*8192)::bigint) AS size
FROM pg_class c
LEFT JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
AND n.nspname !~ '^pg_toast'
AND c.relkind='i'
GROUP BY c.relname
ORDER BY sum(c.relpages) DESC;
EOS
  end
end
