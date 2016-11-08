#!/bin/bash

# run mkauth

/etc/pgbouncer/mkauth.py /etc/pgbouncer/userlist.txt \
 "host=${POSTGRESQL_SERVICE_HOST} port=${POSTGRESQL_SERVICE_PORT} \
 user=admin password=admin dbname=postgres"

 chmod 744 /etc/pgbouncer/userlist.txt

# define pgbouncer config

cat > /etc/pgbouncer/pgbouncer.ini <<__EOF__
[databases]
* = host=${POSTGRESQL_SERVICE_HOST} port=${POSTGRESQL_SERVICE_PORT}

[pgbouncer]
logfile = /tmp/pgbouncer.log
pidfile = /tmp/pgbouncer.pid
listen_address = *
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
server_reset_query = DISCARD ALL
max_client_conn = 50
default_pool_size = 5
log_connections = 0
log_disconnections = 0
__EOF__

cat /etc/pgbouncer/pgbouncer.ini

# start pgbouncer
pgbouncer -u pgbouncer /etc/pgbouncer/pgbouncer.ini
