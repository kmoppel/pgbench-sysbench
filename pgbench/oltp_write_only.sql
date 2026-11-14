-- oltp_write_only (1 index update, 1 non-index update, 1 DELETE/INSERT)
-- Required: -M simple -D tables=N -D table_size=N
-- sb_c_value()/sb_pad_value() come from sql/functions.sql
BEGIN;
\set t random(1, :tables)
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
