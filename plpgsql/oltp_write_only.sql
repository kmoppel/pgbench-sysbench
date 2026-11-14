-- PL/pgSQL variant: whole write-only transaction in one round trip.
SELECT sb_oltp_write_only(:tables, :table_size);
