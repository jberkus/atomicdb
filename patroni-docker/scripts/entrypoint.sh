#!/bin/bash

#set some derived variables

DOCKER_IP=${POD_IP}
HNAME=${POD_NAME}
LOOKUP="${POD_NAME}.${POD_GROUP}"
NODE=${HNAME//[^a-z0-9]/_}

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

#create patroni config
cat > /etc/patroni/patroni.yml <<__EOF__
bootstrap:
  dcs:
    loop_wait: 5
    maximum_lag_on_failover: 104857600
    postgresql:
      parameters:
        hot_standby: 'on'
        log_destination: 'stderr'
        logging_collector: 'off'
        max_connections: 100
        max_replication_slots: 12
        max_wal_senders: 12
        wal_keep_segments: 8
        wal_level: hot_standby
        wal_log_hints: 'on'
      use_pg_rewind: false
      use_slots: true
    retry_timeout: 5
    ttl: 15
  initdb:
  - encoding: UTF8
  - locale: C.utf8
  pg_hba:
  - host replication standby 0.0.0.0/0 md5
  - host    all all 0.0.0.0/0 md5
  users:
    admin:
      options:
      - createrole
      - createdb
      password: ${ADMINPASS}
etcd:
  host: ${ETCD_HOST}:2379
  scope: ${CLUSTERNAME}
  ttl: 15
postgresql:
  authentication:
    replication:
      password: ${REPLICATIONPASS}
      username: standby
    superuser:
      password: ${SUPERPASS}
      username: postgres
  callbacks:
    on_restart: /scripts/callback_role.py
    on_role_change: /scripts/callback_role.py
    on_start: /scripts/callback_role.py
    on_stop: /scripts/callback_role.py
  connect_address: ${LOOKUP}:5432
  create_replica_method:
  - basebackup
  data_dir: /pgdata/data
  listen: 0.0.0.0:5432
  name: ${NODE}
  scope: ${CLUSTERNAME}
restapi:
  connect_address: ${LOOKUP}:8008
  listen: 0.0.0.0:8008
scope: ${CLUSTERNAME}
__EOF__

cat /etc/patroni/patroni.yml

/scripts/su-exec postgres python /patroni/patroni.py /etc/patroni/patroni.yml
