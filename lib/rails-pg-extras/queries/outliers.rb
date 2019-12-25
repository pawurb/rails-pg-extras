# frozen_string_literal: true

module RailsPGExtras
  def self.outliers_description
    "10 queries that have longest execution time in aggregate"
  end

  def self.outliers_sql
    <<-EOS
SELECT interval '1 millisecond' * total_time AS total_exec_time,
to_char((total_time/sum(total_time) OVER()) * 100, 'FM90D0') || '%'  AS prop_exec_time,
to_char(calls, 'FM999G999G999G990') AS ncalls,
interval '1 millisecond' * (blk_read_time + blk_write_time) AS sync_io_time,
query AS query
FROM pg_stat_statements WHERE userid = (SELECT usesysid FROM pg_user WHERE usename = current_user LIMIT 1)
ORDER BY total_time DESC
LIMIT 10
EOS
  end
end
