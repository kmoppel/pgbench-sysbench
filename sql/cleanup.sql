-- Equivalent of `sysbench oltp_* cleanup`: drops all sbtest* tables and helper functions.
-- Usage: psql -X -f sql/cleanup.sql
\set ON_ERROR_STOP on

SELECT format('DROP TABLE IF EXISTS %I.%I', schemaname, relname)
FROM pg_stat_user_tables
WHERE relname ~ '^sbtest[0-9]+$' \gexec

DROP FUNCTION IF EXISTS sb_oltp_read_only, sb_oltp_write_only, sb_oltp_read_write,
  sb_c_value, sb_pad_value, sb_rand_str, sb_load_chunk, sb_next_table, sb_bulk_insert;
DROP SEQUENCE IF EXISTS sb_load_seq, sb_bulk_seq;
