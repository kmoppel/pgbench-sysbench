# sysbench-pgbench

The sysbench `oltp_*` and `bulk_insert` workloads (`src/lua/oltp_common.lua`,
`bulk_insert.lua`) re-implemented for PostgreSQL as plain SQL, pgbench scripts
and PL/pgSQL. Needs only `psql` and `pgbench` to run.

# Running

```
cd sysbench-pgbench
createdb sbtest

# 1) Schema + helper functions
psql -X -v tables=4 -f sql/00_schema.sql sbtest

# 2) Parallel data load with pgbench: every transaction inserts 100k rows into the next table
#    round-robin via a sequence, so 4 clients x -t 10 = 40 txns = 4M rows = 1M rows per table
pgbench -n -c 4 -j 4 -t 10 -f pgbench/init_data.sql sbtest

# 3) Secondary indexes (k_N) + VACUUM ANALYZE
psql -X -v tables=4 -f sql/02_indexes.sql sbtest

# oltp_read_write, 16 clients for 60s (-M simple is required: table names are substituted textually)
pgbench -n -M simple -c 16 -j 4 -T 60 -P 10 -D tables=4 -D table_size=1000000 -D range_size=100 \
  -f pgbench/oltp_read_write.sql sbtest

# Weighted mix, like sysbench's separate runs combined
pgbench -n -M simple -c 16 -T 60 -D tables=4 -D table_size=1000000 -D range_size=100 \
  -f pgbench/oltp_read_only.sql@80 -f pgbench/oltp_write_only.sql@20 sbtest

# One round trip per transaction via PL/pgSQL, works with -M prepared too
pgbench -n -M prepared -c 16 -T 60 -D tables=4 -D table_size=1000000 -D range_size=100 \
  -f plpgsql/oltp_read_write.sql sbtest

# bulk_insert: 8 tables, each transaction inserts 1000 rows into the next table round-robin.
# Uses the same sbtestN names, so run it in a separate database
createdb sbbulk
psql -X -v tables=8 -f sql/prepare_bulk_insert.sql sbbulk
pgbench -n -c 8 -j 8 -T 30 -D batch=1000 -f pgbench/bulk_insert.sql sbbulk

# Cleanup: drops all sbtestN tables and the helper functions
psql -X -f sql/cleanup.sql sbtest
psql -X -f sql/cleanup.sql sbbulk
```

Connection settings come from the usual libpq `PG*` variables or the
`-h/-p/-U` options.

| Path | Content |
|------|---------|
| `sql/00_schema.sql` | helper functions and empty tables (same columns as sysbench, `SERIAL` id); `-v unlogged=1` for unlogged tables |
| `pgbench/init_data.sql` | parallel data load, 100000 rows per transaction (`sb_load_chunk()`) |
| `sql/02_indexes.sql` | secondary index (`-v create_secondary=0` to skip) and `VACUUM ANALYZE` |
| `sql/functions.sql` | random `c`/`pad` generators and the PL/pgSQL transaction bodies `sb_oltp_read_only/write_only/read_write` (per-transaction query counts are function arguments) |
| `pgbench/*.sql` | pgbench scripts: `oltp_{point_select,read_only,write_only,read_write,update_index,update_non_index,delete,insert}`, `bulk_insert` |
| `plpgsql/*.sql` | one-round-trip variants calling the functions: `oltp_{read_only,write_only,read_write}` |
| `sql/prepare_bulk_insert.sql` | empty `sbtest<N>(id, k)` tables for bulk_insert |
| `sql/cleanup.sql` | drops tables and functions |

Differences from sysbench:
- Query counts in `pgbench/*.sql` are fixed at the sysbench defaults (10 point selects, 1 of each range query, 1 index/non-index update, 1 delete+insert); edit the scripts or use the PL/pgSQL scripts (change the function arguments) to alter them.
- Ids are uniformly random (no sysbench `--rand-type=special`).
- One table is picked per transaction (not per query group). It is substituted textually, so the pgbench scripts need `-M simple`.
- The DELETE/INSERT pair uses `ON CONFLICT DO NOTHING` to avoid duplicate-key aborts when concurrent clients hit the same id.
- PL/pgSQL scripts use dynamic `EXECUTE` (no cached plans).
- bulk_insert commits each batch as it goes, not one big batch at the end.
