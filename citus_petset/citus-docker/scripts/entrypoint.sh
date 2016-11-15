#!/bin/bash

#set some derived variables

DOCKER_IP=${POD_IP}
HNAME=${POD_NAME}
LOOKUP="${POD_NAME}.${POD_GROUP}"
NODE=${HNAME//[^a-z0-9]/_}

#!/bin/bash

set -e

# check if we have a pgdata dir
if ! [ -e /pgdata/data/postgresql.conf ]; then
  #create postgresql directories and set permissions
  mkdir -p /pgdata/data
  mkdir -p /mnt/stats/pgsql-stats/
  chown -R postgres:postgres /pgdata/data
  chmod -R 700 /pgdata/data
  chown -R postgres:postgres /mnt/stats/pgsql-stats
  chmod -R 700 /mnt/stats/pgsql-stats
  # initdb
  /scripts/su-exec postgres /usr/bin/initdb -D /pgdata/data -E UTF8
  # copy config files
  /bin/cp -f /scripts/config/* /pgdata/data/
  chown -R postgres:postgres /pgdata/data/
fi

# run postgres daemon
/scripts/su-exec postgres /scripts/entrypoint.py
