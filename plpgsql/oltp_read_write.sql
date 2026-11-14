-- PL/pgSQL variant: whole read-write transaction in one round trip.
SELECT sb_oltp_read_write(:tables, :table_size, :range_size);
