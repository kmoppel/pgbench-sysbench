-- Step 2 of `sysbench oltp_* prepare`: parallel data load.
-- Each transaction inserts 100000 rows into the next sbtestN table (round-robin),
-- so run: pgbench -n -c <clients> -t <txns per client> -f pgbench/init_data.sql
-- Rows per table = 100000 * clients * txns / tables; k is random in [1, 100000].
SELECT sb_load_chunk();
