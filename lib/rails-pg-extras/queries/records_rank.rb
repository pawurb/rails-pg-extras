# frozen_string_literal: true

module RailsPGExtras
  def self.records_rank_description
    "All tables and the number of rows in each ordered by number of rows descending"
  end

  def self.records_rank_sql
    <<-EOS
SELECT
  relname AS name,
  n_live_tup AS estimated_count
FROM
  pg_stat_user_tables
ORDER BY
  n_live_tup DESC;
EOS
  end
end
