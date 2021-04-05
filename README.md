# Rails PG Extras [![Gem Version](https://badge.fury.io/rb/rails-pg-extras.svg)](https://badge.fury.io/rb/rails-pg-extras) [![CircleCI](https://circleci.com/gh/pawurb/rails-pg-extras.svg?style=svg)](https://circleci.com/gh/pawurb/rails-pg-extras)

Rails port of [Heroku PG Extras](https://github.com/heroku/heroku-pg-extras) with several additions and improvements. The goal of this project is to provide powerful insights into the PostgreSQL database for Ruby on Rails apps that are not using the Heroku PostgreSQL plugin.

Included rake tasks and Ruby methods can be used to obtain information about a Postgres instance, that may be useful when analyzing performance issues. This includes information about locks, index usage, buffer cache hit ratios and vacuum statistics. Ruby API enables developers to easily integrate the tool into e.g. automatic monitoring tasks.

You can check out this blog post for detailed step by step tutorial on how to [optimize PostgreSQL using PG Extras library](https://pawelurbanek.com/postgresql-fix-performance).

Alternative versions:

- Core dependency - [Ruby](https://github.com/pawurb/ruby-pg-extras)

- [NodeJS](https://github.com/pawurb/node-postgres-extras)

- [Elixir](https://github.com/pawurb/ecto_psql_extras)

- [Python](https://github.com/pawurb/ecto_psql_extras)

- [Haskell](https://github.com/pawurb/haskell-pg-extras)

## Installation

In your Gemfile

```ruby
gem "rails-pg-extras"
```

Some of the queries (e.g., `calls` and `outliers`) require [pg_stat_statements](https://www.postgresql.org/docs/current/pgstatstatements.html) extension enabled.

You can check if it is enabled in your database by running:

```ruby
RailsPGExtras.extensions
```
You should see the similar line in the output:

```bash
| pg_stat_statements  | 1.7  | 1.7 | track execution statistics of all SQL statements executed |
```

## Usage

Each command can be used as a rake task, or a directly from the Ruby code.

```bash
rake pg_extras:cache_hit
```

```ruby
RailsPGExtras.cache_hit
```
```bash
+----------------+------------------------+
|        Index and table hit rate         |
+----------------+------------------------+
| name           | ratio                  |
+----------------+------------------------+
| index hit rate | 0.97796610169491525424 |
| table hit rate | 0.96724294813466787989 |
+----------------+------------------------+
```


By default the ASCII table is displayed, to change to format you need to specify the `in_format` parameter (`[:display_table, :hash, :array, :raw]` options are available):

```ruby
RailsPGExtras.cache_hit(in_format: :hash) =>

 [{"name"=>"index hit rate", "ratio"=>"0.97796610169491525424"}, {"name"=>"table hit rate", "ratio"=>"0.96724294813466787989"}]

RailsPGExtras.cache_hit(in_format: :array) =>

 [["index hit rate", "0.97796610169491525424"], ["table hit rate", "0.96724294813466787989"]]

RailsPGExtras.cache_hit(in_format: :raw) =>

 #<PG::Result:0x00007f75777f7328 status=PGRES_TUPLES_OK ntuples=2 nfields=2 cmd_tuples=2>
```

Some methods accept an optional `args` param allowing you to customize queries:

```ruby
RailsPGExtras.long_running_queries(args: { threshold: "200 milliseconds" })

```

## Available methods

### `cache_hit`

```ruby
RailsPGExtras.cache_hit

$ rake pg_extras:cache_hit

      name      |         ratio
----------------+------------------------
 index hit rate | 0.99957765013541945832
 table hit rate |                   1.00
(2 rows)
```

This command provides information on the efficiency of the buffer cache, for both index reads (`index hit rate`) as well as table reads (`table hit rate`). A low buffer cache hit ratio can be a sign that the Postgres instance is too small for the workload.

[More info](https://pawelurbanek.com/postgresql-fix-performance#cache-hit)

### `index_cache_hit`

```ruby

RailsPGExtras.index_cache_hit

$ rake pg_extras:index_cache_hit

| name                  | buffer_hits | block_reads | total_read | ratio             |
+-----------------------+-------------+-------------+------------+-------------------+
| teams                 | 187665      | 109         | 187774     | 0.999419514948821 |
| subscriptions         | 5160        | 6           | 5166       | 0.99883855981417  |
| plans                 | 5718        | 9           | 5727       | 0.998428496595076 |
(truncated results for brevity)
```

The same as `cache_hit` with each table's indexes cache hit info displayed separately.

[More info](https://pawelurbanek.com/postgresql-fix-performance#cache-hit)

### `table_cache_hit`

```ruby

RailsPGExtras.table_cache_hit

$ rake pg_extras:table_cache_hit

| name                  | buffer_hits | block_reads | total_read | ratio             |
+-----------------------+-------------+-------------+------------+-------------------+
| plans                 | 32123       | 2           | 32125      | 0.999937743190662 |
| subscriptions         | 95021       | 8           | 95029      | 0.999915815172211 |
| teams                 | 171637      | 200         | 171837     | 0.99883610631005  |
(truncated results for brevity)
```

The same as `cache_hit` with each table's cache hit info displayed seperately.

[More info](https://pawelurbanek.com/postgresql-fix-performance#cache-hit)

### `db_settings`

```ruby

RailsPGExtras.db_settings

$ rake pg_extras:db_settings

             name             | setting | unit |
------------------------------+---------+------+
 checkpoint_completion_target | 0.7     |      |
 default_statistics_target    | 100     |      |
 effective_cache_size         | 1350000 | 8kB  |
 effective_io_concurrency     | 1       |      |
(truncated results for brevity)

```

This method displays values for selected PostgreSQL settings. You can compare them with settings recommended by [PGTune](https://pgtune.leopard.in.ua/#/) and tweak values to improve performance.

[More info](https://pawelurbanek.com/postgresql-fix-performance#cache-hit)

### `index_usage`

```ruby
RailsPGExtras.index_usage

$ rake pg_extras:index_usage

       relname       | percent_of_times_index_used | rows_in_table
---------------------+-----------------------------+---------------
 events              |                          65 |       1217347
 app_infos           |                          74 |        314057
 app_infos_user_info |                           0 |        198848
 user_info           |                           5 |         94545
 delayed_jobs        |                          27 |             0
(5 rows)
```

This command provides information on the efficiency of indexes, represented as what percentage of total scans were index scans. A low percentage can indicate under indexing, or wrong data being indexed.

### `locks`

```ruby
RailsPGExtras.locks

$ rake pg_extras:locks

 procpid | relname | transactionid | granted |     query_snippet     | mode             |       age
---------+---------+---------------+---------+-----------------------+-------------------------------------
   31776 |         |               | t       | <IDLE> in transaction | ExclusiveLock    |  00:19:29.837898
   31776 |         |          1294 | t       | <IDLE> in transaction | RowExclusiveLock |  00:19:29.837898
   31912 |         |               | t       | select * from hello;  | ExclusiveLock    |  00:19:17.94259
    3443 |         |               | t       |                      +| ExclusiveLock    |  00:00:00
         |         |               |         |    select            +|                  |
         |         |               |         |      pg_stat_activi   |                  |
(4 rows)
```

This command displays queries that have taken out an exclusive lock on a relation. Exclusive locks typically prevent other operations on that relation from taking place, and can be a cause of "hung" queries that are waiting for a lock to be granted.

[More info](https://pawelurbanek.com/postgresql-fix-performance#deadlocks)

### `all_locks`

```ruby
RailsPGExtras.all_locks

$ rake pg_extras:all_locks
```

This command displays all the current locks, regardless of their type.

### `outliers`

```ruby
RailsPGExtras.outliers(args: { limit: 20 })

$ rake pg_extras:outliers

                   qry                   |    exec_time     | prop_exec_time |   ncalls    | sync_io_time
-----------------------------------------+------------------+----------------+-------------+--------------
 SELECT * FROM archivable_usage_events.. | 154:39:26.431466 | 72.2%          | 34,211,877  | 00:00:00
 COPY public.archivable_usage_events (.. | 50:38:33.198418  | 23.6%          | 13          | 13:34:21.00108
 COPY public.usage_events (id, reporte.. | 02:32:16.335233  | 1.2%           | 13          | 00:34:19.784318
 INSERT INTO usage_events (id, retaine.. | 01:42:59.436532  | 0.8%           | 12,328,187  | 00:00:00
 SELECT * FROM usage_events WHERE (alp.. | 01:18:10.754354  | 0.6%           | 102,114,301 | 00:00:00
 UPDATE usage_events SET reporter_id =.. | 00:52:35.683254  | 0.4%           | 23,786,348  | 00:00:00
(truncated results for brevity)
```

This command displays statements, obtained from `pg_stat_statements`, ordered by the amount of time to execute in aggregate. This includes the statement itself, the total execution time for that statement, the proportion of total execution time for all statements that statement has taken up, the number of times that statement has been called, and the amount of time that statement spent on synchronous I/O (reading/writing from the file system).

Typically, an efficient query will have an appropriate ratio of calls to total execution time, with as little time spent on I/O as possible. Queries that have a high total execution time but low call count should be investigated to improve their performance. Queries that have a high proportion of execution time being spent on synchronous I/O should also be investigated.

[More info](https://pawelurbanek.com/postgresql-fix-performance#missing-indexes)

### `calls`

```ruby
RailsPGExtras.calls(args: { limit: 10 })

$ rake pg_extras:calls

                   qry                   |    exec_time     | prop_exec_time |   ncalls    | sync_io_time
-----------------------------------------+------------------+----------------+-------------+--------------
 SELECT * FROM usage_events WHERE (alp.. | 01:18:11.073333  | 0.6%           | 102,120,780 | 00:00:00
 BEGIN                                   | 00:00:51.285988  | 0.0%           | 47,288,662  | 00:00:00
 COMMIT                                  | 00:00:52.31724   | 0.0%           | 47,288,615  | 00:00:00
 SELECT * FROM  archivable_usage_event.. | 154:39:26.431466 | 72.2%          | 34,211,877  | 00:00:00
 UPDATE usage_events SET reporter_id =.. | 00:52:35.986167  | 0.4%           | 23,788,388  | 00:00:00
(truncated results for brevity)
```

This command is much like `pg:outliers`, but ordered by the number of times a statement has been called.

[More info](https://pawelurbanek.com/postgresql-fix-performance#missing-indexes)

### `blocking`

```ruby
RailsPGExtras.blocking

$ rake pg_extras:blocking

 blocked_pid |    blocking_statement    | blocking_duration | blocking_pid |                                        blocked_statement                           | blocked_duration
-------------+--------------------------+-------------------+--------------+------------------------------------------------------------------------------------+------------------
         461 | select count(*) from app | 00:00:03.838314   |        15682 | UPDATE "app" SET "updated_at" = '2013-03-04 15:07:04.746688' WHERE "id" = 12823149 | 00:00:03.821826
(1 row)
```

This command displays statements that are currently holding locks that other statements are waiting to be released. This can be used in conjunction with `pg:locks` to determine which statements need to be terminated in order to resolve lock contention.

[More info](https://pawelurbanek.com/postgresql-fix-performance#deadlocks)

### `total_index_size`

```ruby
RailsPGExtras.total_index_size

$ rake pg_extras:total_index_size

  size
-------
 28194 MB
(1 row)
```

This command displays the total size of all indexes on the database, in MB. It is calculated by taking the number of pages (reported in `relpages`) and multiplying it by the page size (8192 bytes).

### `index_size`

```ruby
RailsPGExtras.index_size

$ rake pg_extras:index_size
                             name                              |  size
---------------------------------------------------------------+---------
 idx_activity_attemptable_and_type_lesson_enrollment           | 5196 MB
 index_enrollment_attemptables_by_attempt_and_last_in_group    | 4045 MB
 index_attempts_on_student_id                                  | 2611 MB
 enrollment_activity_attemptables_pkey                         | 2513 MB
 index_attempts_on_student_id_final_attemptable_type           | 2466 MB
 attempts_pkey                                                 | 2466 MB
 index_attempts_on_response_id                                 | 2404 MB
 index_attempts_on_enrollment_id                               | 1957 MB
 index_enrollment_attemptables_by_enrollment_activity_id       | 1789 MB
 enrollment_activities_pkey                                    |  458 MB
(truncated results for brevity)
```

This command displays the size of each each index in the database, in MB. It is calculated by taking the number of pages (reported in `relpages`) and multiplying it by the page size (8192 bytes).

### `table_size`

```ruby
RailsPGExtras.table_size

$ rake pg_extras:table_size

                             name                              |  size
---------------------------------------------------------------+---------
 learning_coaches                                              |  196 MB
 states                                                        |  145 MB
 grade_levels                                                  |  111 MB
 charities_customers                                           |   73 MB
 charities                                                     |   66 MB
(truncated results for brevity)
```

This command displays the size of each table and materialized view in the database, in MB. It is calculated by using the system administration function `pg_table_size()`, which includes the size of the main data fork, free space map, visibility map and TOAST data.

### `table_indexes_size`

```ruby
RailsPGExtras.table_indexes_size

$ rake pg_extras:table_indexes_size

                             table                             | indexes_size
---------------------------------------------------------------+--------------
 learning_coaches                                              |    153 MB
 states                                                        |    125 MB
 charities_customers                                           |     93 MB
 charities                                                     |     16 MB
 grade_levels                                                  |     11 MB
(truncated results for brevity)
```

This command displays the total size of indexes for each table and materialized view, in MB. It is calculated by using the system administration function `pg_indexes_size()`.

### `total_table_size`

```ruby
RailsPGExtras.total_table_size

$ rake pg_extras:total_table_size

                             name                              |  size
---------------------------------------------------------------+---------
 learning_coaches                                              |  349 MB
 states                                                        |  270 MB
 charities_customers                                           |  166 MB
 grade_levels                                                  |  122 MB
 charities                                                     |   82 MB
(truncated results for brevity)
```

This command displays the total size of each table and materialized view in the database, in MB. It is calculated by using the system administration function `pg_total_relation_size()`, which includes table size, total index size and TOAST data.

### `unused_indexes`

```ruby
RailsPGExtras.unused_indexes(args: { min_scans: 20 })

$ rake pg_extras:unused_indexes

          table      |                       index                | index_size | index_scans
---------------------+--------------------------------------------+------------+-------------
 public.grade_levels | index_placement_attempts_on_grade_level_id | 97 MB      |           0
 public.observations | observations_attrs_grade_resources         | 33 MB      |           0
 public.messages     | user_resource_id_idx                       | 12 MB      |           0
(3 rows)
```

This command displays indexes that have < 50 scans recorded against them, and are greater than 5 pages in size, ordered by size relative to the number of index scans. This command is generally useful for eliminating indexes that are unused, which can impact write performance, as well as read performance should they occupy space in memory.

[More info](https://pawelurbanek.com/postgresql-fix-performance#unused-indexes)

### `null_indexes`

```ruby

RailsPGExtras.null_indexes(args: { min_relation_size_mb: 10 })

$ rake pg_extras:null_indexes

   oid   |         index      | index_size | unique | indexed_column | null_frac | expected_saving
---------+--------------------+------------+--------+----------------+-----------+-----------------
  183764 | users_reset_token  | 1445 MB    | t      | reset_token    |   97.00%  | 1401 MB
   88732 | plan_cancelled_at  | 539 MB     | f      | cancelled_at   |    8.30%  | 44 MB
 9827345 | users_email        | 18 MB      | t      | email          |   28.67%  | 5160 kB

```

This command displays indexes that contain `NULL` values. A high ratio of `NULL` values means that using a partial index excluding them will be beneficial in case they are not used for searching.

[More info](https://pawelurbanek.com/postgresql-fix-performance#null-indexes)

### `seq_scans`

```ruby
RailsPGExtras.seq_scans

$ rake pg_extras:seq_scans

               name                |  count
-----------------------------------+----------
 learning_coaches                  | 44820063
 states                            | 36794975
 grade_levels                      | 13972293
 charities_customers               |  8615277
 charities                         |  4316276
 messages                          |  3922247
 contests_customers                |  2915972
 classroom_goals                   |  2142014
(truncated results for brevity)
```

This command displays the number of sequential scans recorded against all tables, descending by count of sequential scans. Tables that have very high numbers of sequential scans may be under-indexed, and it may be worth investigating queries that read from these tables.

[More info](https://pawelurbanek.com/postgresql-fix-performance#missing-indexes)

### `long_running_queries`

```ruby
RailsPGExtras.long_running_queries(args: { threshold: "200 milliseconds" })

$ rake pg_extras:long_running_queries

  pid  |    duration     |                                      query
-------+-----------------+---------------------------------------------------------------------------------------
 19578 | 02:29:11.200129 | EXPLAIN SELECT  "students".* FROM "students"  WHERE "students"."id" = 1450645 LIMIT 1
 19465 | 02:26:05.542653 | EXPLAIN SELECT  "students".* FROM "students"  WHERE "students"."id" = 1889881 LIMIT 1
 19632 | 02:24:46.962818 | EXPLAIN SELECT  "students".* FROM "students"  WHERE "students"."id" = 1581884 LIMIT 1
(truncated results for brevity)
```

This command displays currently running queries, that have been running for longer than 5 minutes, descending by duration. Very long running queries can be a source of multiple issues, such as preventing DDL statements completing or vacuum being unable to update `relfrozenxid`.

### `records_rank`

```ruby
RailsPGExtras.records_rank

$ rake pg_extras:records_rank

               name                | estimated_count
-----------------------------------+-----------------
 tastypie_apiaccess                |          568891
 notifications_event               |          381227
 core_todo                         |          178614
 core_comment                      |          123969
 notifications_notification        |          102101
 django_session                    |           68078
 (truncated results for brevity)
```

This command displays an estimated count of rows per table, descending by estimated count. The estimated count is derived from `n_live_tup`, which is updated by vacuum operations. Due to the way `n_live_tup` is populated, sparse vs. dense pages can result in estimations that are significantly out from the real count of rows.

### `bloat`

```ruby
RailsPGExtras.bloat

$ rake pg_extras:bloat

 type  | schemaname |           object_name         | bloat |   waste
-------+------------+-------------------------------+-------+----------
 table | public     | bloated_table                 |   1.1 | 98 MB
 table | public     | other_bloated_table           |   1.1 | 58 MB
 index | public     | bloated_table::bloated_index  |   3.7 | 34 MB
 table | public     | clean_table                   |   0.2 | 3808 kB
 table | public     | other_clean_table             |   0.3 | 1576 kB
 (truncated results for brevity)
```

This command displays an estimation of table "bloat" – space allocated to a relation that is full of dead tuples, that has yet to be reclaimed. Tables that have a high bloat ratio, typically 10 or greater, should be investigated to see if vacuuming is aggressive enough, and can be a sign of high table churn.

[More info](https://pawelurbanek.com/postgresql-fix-performance#bloat)

### `vacuum_stats`

```ruby
RailsPGExtras.vacuum_stats

$ rake pg_extras:vacuum_stats

 schema |         table         | last_vacuum | last_autovacuum  |    rowcount    | dead_rowcount  | autovacuum_threshold | expect_autovacuum
--------+-----------------------+-------------+------------------+----------------+----------------+----------------------+-------------------
 public | log_table             |             | 2013-04-26 17:37 |         18,030 |              0 |          3,656       |
 public | data_table            |             | 2013-04-26 13:09 |             79 |             28 |             66       |
 public | other_table           |             | 2013-04-26 11:41 |             41 |             47 |             58       |
 public | queue_table           |             | 2013-04-26 17:39 |             12 |          8,228 |             52       | yes
 (truncated results for brevity)
```

This command displays statistics related to vacuum operations for each table, including an estimation of dead rows, last autovacuum and the current autovacuum threshold. This command can be useful when determining if current vacuum thresholds require adjustments, and to determine when the table was last vacuumed.

### `kill_all`

```ruby

RailsPGExtras.kill_all

```

This commands kills all the currently active connections to the database. It can be useful as a last resort when your database is stuck in a deadlock.

### `buffercache_stats`

```ruby
RailsPGExtras.buffercache_stats(args: { limit: 10 })
```

This command shows the relations buffered in database share buffer, ordered by percentage taken. It also shows that how much of the whole relation is buffered.

### `buffercache_usage`

```ruby
RailsPGExtras.buffercache_usage(args: { limit: 20 })
```

This command calculates how many blocks from which table are currently cached.

### `extensions`

```ruby

RailsPGExtras.extensions

$ rake pg_extras:extensions

| pg_stat_statements | 1.7 | 1.7 | track execution statistics of all SQL statements executed
 (truncated results for brevity)

```

This command lists all the currently installed and available PostgreSQL extensions.

### mandelbrot

```ruby
RailsPGExtras.mandelbrot

$ rake pg_extras:mandelbrot
```

This command outputs the Mandelbrot set, calculated through SQL.

## Query sources

- [https://github.com/heroku/heroku-pg-extras](https://github.com/heroku/heroku-pg-extras)
- [https://hakibenita.com/postgresql-unused-index-size](https://hakibenita.com/postgresql-unused-index-size)
- [https://sites.google.com/site/itmyshare/database-tips-and-examples/postgres/useful-sqls-to-check-contents-of-postgresql-shared_buffer](https://sites.google.com/site/itmyshare/database-tips-and-examples/postgres/useful-sqls-to-check-contents-of-postgresql-shared_buffer)
