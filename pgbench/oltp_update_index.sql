-- oltp_update_index (autocommit)
\set t random(1, :tables)
\set id random(1, :table_size)
UPDATE sbtest:t SET k = k + 1 WHERE id = :id;
