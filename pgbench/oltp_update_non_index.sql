-- oltp_update_non_index (autocommit)
\set t random(1, :tables)
\set id random(1, :table_size)
UPDATE sbtest:t SET c = sb_c_value() WHERE id = :id;
