-- oltp_read_write: oltp_read_only followed by oltp_write_only, one transaction
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
\set id random(1, :table_size)
UPDATE sbtest:t SET k = k + 1 WHERE id = :id;
\set id random(1, :table_size)
UPDATE sbtest:t SET c = sb_c_value() WHERE id = :id;
\set id random(1, :table_size)
\set k random(1, :table_size)
DELETE FROM sbtest:t WHERE id = :id;
INSERT INTO sbtest:t (id, k, c, pad) VALUES (:id, :k, sb_c_value(), sb_pad_value())
  ON CONFLICT DO NOTHING;
COMMIT;
