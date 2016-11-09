#!/bin/bash

#create postgresql directories and set permissions
mkdir -p /pgdata/data
mkdir -p /mnt/stats/pgsql-stats/
chown -R postgres:postgres /pgdata/data
chmod -R 700 /pgdata/data
chown -R postgres:postgres /mnt/stats/pgsql-stats
chmod -R 700 /mnt/stats/pgsql-stats

# create patroni configuration directory
mkdir -p /etc/patroni
chown -R postgres:postgres /etc/patroni

# create wal-e configuration
# mkdir /etc/wal-e.d/

#mv /setup/patroni /patroni
#chown -R postgres:postgres /patroni
#chmod +x /patroni/*.py

#mkdir /scripts
#cp /setup/scripts/* /scripts/
