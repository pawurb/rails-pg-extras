# frozen_string_literal: true

module RailsPGExtras
  def self.index_size
    connection.execute(index_size_query)
  end

  private

  def self.index_size_query
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

  private_class_method :index_size_query
end
