# frozen_string_literal: true

module RailsPGExtras
  def self.total_index_size_description
    "Total size of all indexes in MB"
  end

  def self.total_index_size_sql
    <<-EOS
SELECT pg_size_pretty(sum(c.relpages::bigint*8192)::bigint) AS size
FROM pg_class c
LEFT JOIN pg_namespace n ON (n.oid = c.relnamespace)
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
AND n.nspname !~ '^pg_toast'
AND c.relkind='i';
EOS
  end
end
