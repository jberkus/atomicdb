create or replace function citus_register_nodes(
  num_nodes INT,
  app_name TEXT,
  base_url TEXT
)
RETURNS BOOLEAN
LANGUAGE PLPGSQL
AS $f$
DECLARE node_uri TEXT;
  node_loop INT;
BEGIN
  FOR node_loop IN 1 .. num_nodes - 1 LOOP
    node_uri := format('%s-%s.%s.%s', app_name, node_loop, app_name, base_url);
    SELECT node_name FROM master_get_active_worker_nodes()
    WHERE node_name = node_uri;
    IF NOT FOUND THEN
      PERFORM master_add_node(node_uri, 5432);
    END IF;
  END LOOP;
RETURN TRUE;
END;
$f$;

create or replace function citus_register_node(
  shard_name TEXT
)
RETURNS BOOLEAN
LANGUAGE PLPGSQL
AS $f$
BEGIN
  SELECT node_name FROM master_get_active_worker_nodes()
  WHERE node_name = shard_name;
  IF NOT FOUND THEN
    PERFORM master_add_node(shard_name, 5432);
  END IF;
RETURN TRUE;
END;
$f$;
