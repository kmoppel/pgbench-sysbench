-- oltp_read_only (default counts: 10 point, 1 simple/sum/order/distinct range)
-- Required: -M simple -D tables=N -D table_size=N -D range_size=N
BEGIN;
\set t random(1, :tables)
\set id random(1, :table_size)
SELECT c FROM sbtest:t WHERE id = :id;
\set id random(1, :table_size)
SELECT c FROM sbtest:t WHERE id = :id;
\set id random(1, :table_size)
SELECT c FROM sbtest:t WHERE id = :id;
\set id random(1, :table_size)
SELECT c FROM sbtest:t WHERE id = :id;
\set id random(1, :table_size)
SELECT c FROM sbtest:t WHERE id = :id;
\set id random(1, :table_size)
SELECT c FROM sbtest:t WHERE id = :id;
\set id random(1, :table_size)
SELECT c FROM sbtest:t WHERE id = :id;
\set id random(1, :table_size)
SELECT c FROM sbtest:t WHERE id = :id;
\set id random(1, :table_size)
SELECT c FROM sbtest:t WHERE id = :id;
\set id random(1, :table_size)
SELECT c FROM sbtest:t WHERE id = :id;
\set id random(1, :table_size)
\set id2 :id + :range_size - 1
SELECT c FROM sbtest:t WHERE id BETWEEN :id AND :id2;
\set id random(1, :table_size)
\set id2 :id + :range_size - 1
SELECT SUM(k) FROM sbtest:t WHERE id BETWEEN :id AND :id2;
\set id random(1, :table_size)
\set id2 :id + :range_size - 1
SELECT c FROM sbtest:t WHERE id BETWEEN :id AND :id2 ORDER BY c;
\set id random(1, :table_size)
\set id2 :id + :range_size - 1
SELECT DISTINCT c FROM sbtest:t WHERE id BETWEEN :id AND :id2 ORDER BY c;
COMMIT;
