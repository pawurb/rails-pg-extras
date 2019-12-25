# frozen_string_literal: true

module RailsPGExtras
  def self.unused_indexes_description
    "Unused and almost unused indexes"
  end
  # Ordered by their size relative to the number of index scans.
  # Exclude indexes of very small tables (less than 5 pages),
  # where the planner will almost invariably select a sequential scan,
  # but may not in the future as the table grows

  def self.unused_indexes_sql
    <<-EOS
SELECT
  schemaname || '.' || relname AS table,
  indexrelname AS index,
  pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size,
  idx_scan as index_scans
FROM pg_stat_user_indexes ui
JOIN pg_index i ON ui.indexrelid = i.indexrelid
WHERE NOT indisunique AND idx_scan < 50 AND pg_relation_size(relid) > 5 * 8192
ORDER BY pg_relation_size(i.indexrelid) / nullif(idx_scan, 0) DESC NULLS FIRST,
pg_relation_size(i.indexrelid) DESC;
EOS
  end
end
