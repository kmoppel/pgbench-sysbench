-- PL/pgSQL variant: whole read-only transaction in one round trip.
-- Per-transaction query counts default to the sysbench ones (see sql/functions.sql).
SELECT sb_oltp_read_only(:tables, :table_size, :range_size);
