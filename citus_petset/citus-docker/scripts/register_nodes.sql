create or replace function register_nodes(
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
    RAISE NOTICE '%',node_uri;
    PERFORM master_add_node(node_uri, 5432);
  END LOOP;
RETURN TRUE;
END;
$f$;
