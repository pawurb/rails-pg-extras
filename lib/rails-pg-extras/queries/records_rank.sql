/* All tables and the number of rows in each ordered by number of rows descending */

SELECT
  relname AS name,
  n_live_tup AS estimated_count
FROM
  pg_stat_user_tables
ORDER BY
  n_live_tup DESC;
