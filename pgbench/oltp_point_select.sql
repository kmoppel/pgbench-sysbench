-- oltp_point_select: 10 point SELECTs on one table per event (autocommit)
-- Required: -M simple -D tables=N -D table_size=N
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
