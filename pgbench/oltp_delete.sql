-- oltp_delete (autocommit)
\set t random(1, :tables)
\set id random(1, :table_size)
DELETE FROM sbtest:t WHERE id = :id;
