# frozen_string_literal: true

module RailsPGExtras
  def self.seq_scans_description
    "Count of sequential scans by table descending by order"
  end

  def self.seq_scans_sql
    <<-EOS
SELECT relname AS name,
       seq_scan as count
FROM
  pg_stat_user_tables
ORDER BY seq_scan DESC;
EOS
  end
end
