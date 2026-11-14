-- bulk_insert: each transaction inserts :batch rows (v, v) in one multi-row INSERT,
-- v from the global sequence sb_bulk_seq. The target table is the next sbtestN
-- round-robin (sb_load_seq), so any -c works. Needs -D batch=N and
-- psql -v tables=N -f sql/prepare_bulk_insert.sql
SELECT sb_bulk_insert(:batch);
