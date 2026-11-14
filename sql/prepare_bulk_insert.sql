-- Equivalent of `sysbench bulk_insert prepare`: empty (id, k) tables plus helper functions.
-- Usage: psql -v tables=N -f sql/prepare_bulk_insert.sql
\set ON_ERROR_STOP on
\i sql/functions.sql
SELECT format('CREATE TABLE IF NOT EXISTS sbtest%s (
  id INTEGER NOT NULL,
  k INTEGER DEFAULT 0 NOT NULL,
  PRIMARY KEY (id))', g)
FROM generate_series(1, :tables) g \gexec
