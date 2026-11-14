-- oltp_insert (autocommit); id comes from the SERIAL default
\set t random(1, :tables)
\set k random(1, :table_size)
INSERT INTO sbtest:t (k, c, pad) VALUES (:k, sb_c_value(), sb_pad_value());
