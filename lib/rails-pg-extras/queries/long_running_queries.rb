# frozen_string_literal: true

module RailsPGExtras
  def self.long_running_queries_description
    "All queries longer than five minutes by descending duration"
  end

  def self.long_running_queries_sql
    <<-EOS
SELECT
  pid,
  now() - pg_stat_activity.query_start AS duration,
  query AS query
FROM
  pg_stat_activity
WHERE
  pg_stat_activity.query <> ''::text
  AND state <> 'idle'
  AND now() - pg_stat_activity.query_start > interval '5 minutes'
ORDER BY
  now() - pg_stat_activity.query_start DESC;
EOS
  end
end
