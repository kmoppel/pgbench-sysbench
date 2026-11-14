-- Step 1 of `sysbench oltp_* prepare`: helper functions and empty tables.
-- Usage: psql -X -v tables=4 -f sql/00_schema.sql
-- Optional: -v unlogged=1 for UNLOGGED tables
-- Next: load data with pgbench/init_data.sql, then run sql/02_indexes.sql

\if :{?unlogged} \else \set unlogged 0 \endif

\set ON_ERROR_STOP on
\set QUIET on

\i sql/functions.sql

SELECT format('CREATE %s TABLE sbtest%s(
  id SERIAL,
  k INTEGER DEFAULT 0 NOT NULL,
  c CHAR(120) DEFAULT '''' NOT NULL,
  pad CHAR(60) DEFAULT '''' NOT NULL,
  PRIMARY KEY (id))',
  CASE WHEN :unlogged = 1 THEN 'UNLOGGED' ELSE '' END, g)
FROM generate_series(1, :tables) g \gexec
