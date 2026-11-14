-- Step 3 of `sysbench oltp_* prepare`: secondary index and statistics, after loading.
-- Usage: psql -X -v tables=4 -f sql/02_indexes.sql sbtest
-- Optional: -v create_secondary=0 to skip the k_N indexes
\if :{?create_secondary} \else \set create_secondary 1 \endif

\set ON_ERROR_STOP on
\set QUIET on

SELECT format('CREATE INDEX k_%s ON sbtest%s(k)', g, g)
FROM generate_series(1, :tables) g
WHERE :create_secondary = 1 \gexec

SELECT format('VACUUM ANALYZE sbtest%s', g)
FROM generate_series(1, :tables) g \gexec
