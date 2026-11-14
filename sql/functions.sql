-- Server-side helpers and PL/pgSQL transaction bodies mirroring oltp_common.lua.
-- Each function call is one transaction, so the per-transaction query counts
-- (--point_selects, --index_updates, ...) are run in a single round trip.

-- Random string of n groups of 11 digits separated by dashes
CREATE OR REPLACE FUNCTION sb_rand_str(n int) RETURNS text
LANGUAGE sql VOLATILE AS $$
  SELECT string_agg(lpad(floor(random() * 1e11)::bigint::text, 11, '0'), '-')
  FROM generate_series(1, n)
$$;

-- 10 groups, 119 characters
CREATE OR REPLACE FUNCTION sb_c_value() RETURNS text
LANGUAGE sql VOLATILE AS 'SELECT sb_rand_str(10)';

-- 5 groups, 59 characters
CREATE OR REPLACE FUNCTION sb_pad_value() RETURNS text
LANGUAGE sql VOLATILE AS 'SELECT sb_rand_str(5)';

-- Hands out tables round-robin to concurrent loader transactions
CREATE SEQUENCE IF NOT EXISTS sb_load_seq;
-- Row values for bulk_insert, shared by all workers
CREATE SEQUENCE IF NOT EXISTS sb_bulk_seq;

-- Next sbtestN table (round-robin over all existing ones via sb_load_seq)
CREATE OR REPLACE FUNCTION sb_next_table() RETURNS text
LANGUAGE sql VOLATILE AS $$
  SELECT (array_agg(format('%I.%I', schemaname, relname) ORDER BY relname))
           [1 + (nextval('sb_load_seq') - 1) % count(*)]
  FROM pg_stat_user_tables WHERE relname ~ '^sbtest[0-9]+$'
$$;

-- Data load: inserts 100000 rows into the next sbtest table;
-- k is random in [1, 100000]
CREATE OR REPLACE FUNCTION sb_load_chunk() RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  EXECUTE format('INSERT INTO %s (k, c, pad)
    SELECT 1 + floor(random() * 100000)::int, sb_c_value(), sb_pad_value()
    FROM generate_series(1, 100000)', sb_next_table());
END
$$;

-- bulk_insert: inserts (v, v) rows, v from sb_bulk_seq, into the next sbtest table
CREATE OR REPLACE FUNCTION sb_bulk_insert(batch int) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  EXECUTE format('INSERT INTO %s SELECT v, v FROM
    (SELECT nextval(''sb_bulk_seq'') v FROM generate_series(1, %s)) s',
    sb_next_table(), batch);
END
$$;

-- Read part of oltp_read_only / oltp_read_write
CREATE OR REPLACE FUNCTION sb_oltp_read_only(
  tables int, table_size int, range_size int DEFAULT 100,
  point_selects int DEFAULT 10, simple_ranges int DEFAULT 1,
  sum_ranges int DEFAULT 1, order_ranges int DEFAULT 1,
  distinct_ranges int DEFAULT 1) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
  tbl text := 'sbtest' || (1 + floor(random() * tables))::int;
  id int;
BEGIN
  FOR i IN 1..point_selects LOOP
    id := 1 + floor(random() * table_size);
    EXECUTE format('SELECT c FROM %s WHERE id = $1', tbl) USING id;
  END LOOP;

  FOR i IN 1..simple_ranges LOOP
    id := 1 + floor(random() * table_size);
    EXECUTE format('SELECT c FROM %s WHERE id BETWEEN $1 AND $2', tbl)
      USING id, id + range_size - 1;
  END LOOP;

  FOR i IN 1..sum_ranges LOOP
    id := 1 + floor(random() * table_size);
    EXECUTE format('SELECT SUM(k) FROM %s WHERE id BETWEEN $1 AND $2', tbl)
      USING id, id + range_size - 1;
  END LOOP;

  FOR i IN 1..order_ranges LOOP
    id := 1 + floor(random() * table_size);
    EXECUTE format('SELECT c FROM %s WHERE id BETWEEN $1 AND $2 ORDER BY c', tbl)
      USING id, id + range_size - 1;
  END LOOP;

  FOR i IN 1..distinct_ranges LOOP
    id := 1 + floor(random() * table_size);
    EXECUTE format('SELECT DISTINCT c FROM %s WHERE id BETWEEN $1 AND $2 ORDER BY c', tbl)
      USING id, id + range_size - 1;
  END LOOP;
END
$$;

-- Write part of oltp_write_only / oltp_read_write
CREATE OR REPLACE FUNCTION sb_oltp_write_only(
  tables int, table_size int, index_updates int DEFAULT 1,
  non_index_updates int DEFAULT 1, delete_inserts int DEFAULT 1) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
  tbl text := 'sbtest' || (1 + floor(random() * tables))::int;
  id int;
BEGIN
  FOR i IN 1..index_updates LOOP
    id := 1 + floor(random() * table_size);
    EXECUTE format('UPDATE %s SET k = k + 1 WHERE id = $1', tbl) USING id;
  END LOOP;

  FOR i IN 1..non_index_updates LOOP
    id := 1 + floor(random() * table_size);
    EXECUTE format('UPDATE %s SET c = $1 WHERE id = $2', tbl)
      USING sb_c_value(), id;
  END LOOP;

  FOR i IN 1..delete_inserts LOOP
    id := 1 + floor(random() * table_size);
    EXECUTE format('DELETE FROM %s WHERE id = $1', tbl) USING id;
    EXECUTE format('INSERT INTO %s (id, k, c, pad) VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING', tbl)
      USING id, 1 + floor(random() * table_size)::int, sb_c_value(), sb_pad_value();
  END LOOP;
END
$$;

-- Full oltp_read_write transaction (reads, then writes) in one transaction
CREATE OR REPLACE FUNCTION sb_oltp_read_write(
  tables int, table_size int, range_size int DEFAULT 100,
  point_selects int DEFAULT 10, simple_ranges int DEFAULT 1,
  sum_ranges int DEFAULT 1, order_ranges int DEFAULT 1,
  distinct_ranges int DEFAULT 1, index_updates int DEFAULT 1,
  non_index_updates int DEFAULT 1, delete_inserts int DEFAULT 1) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
  PERFORM sb_oltp_read_only(tables, table_size, range_size, point_selects,
    simple_ranges, sum_ranges, order_ranges, distinct_ranges);
  PERFORM sb_oltp_write_only(tables, table_size, index_updates,
    non_index_updates, delete_inserts);
END
$$;
