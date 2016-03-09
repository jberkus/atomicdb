#!/bin/bash

# if in a pod, set IP to the pod IP, otherwise
# set it to the hostname
if [ -z "${POD_IP}"]
then
  echo "no pods\n"
  DOCKER_IP=$(hostname --ip-address)
  HNAME=$(hostname)
  echo "$DOCKER_IP $NODE"
else
  DOCKER_IP=$($POD_IP)
  HNAME=$($POD_NAME)
fi

NODE=${HNAME//[^a-z0-9]/_}

# create patroni config
cat > /etc/patroni/patroni.yml <<__EOF__

scope: &scope ${CLUSTER}
ttl: &ttl 30
loop_wait: &loop_wait 10
restapi:
  listen: ${DOCKER_IP}:8001
  connect_address: ${DOCKER_IP}:8001
  auth: '${APIUSER}:${APIPASS}'
  certfile: /etc/ssl/certs/patroni.cert
  keyfile: /etc/ssl/certs/patroni.cert
etcd:
  scope: *scope
  ttl: *ttl
  host: ${ETCD}:2379
tags:
  nofailover: False
  noloadbalance: False
  clonefrom: False
postgresql:
  name: ${NODE}
  scope: *scope
  listen: 0.0.0.0:5432
  connect_address: ${DOCKER_IP}:5432
  data_dir: /pgdata/data
  maximum_lag_on_failover: 104857600 # 100 megabyte in bytes
  use_slots: True
  pgpass: /tmp/pgpass0
  initdb:
  - encoding: UTF8
  - data-checksums
  create_replica_methods:
    - basebackup
  pg_hba:
  - local all all  trust
  - host all all 0.0.0.0/0 md5
  - hostssl all all 0.0.0.0/0 md5
  replication:
    username: ${ADMINUSER}
    password: ${ADMINPASS}
    network:  ${DOCKER_IP}/16
  pg_rewind:
    username: ${ADMINUSER}
    password: ${ADMINPASS}
  superuser:
    username: ${ADMINUSER}
    password: ${ADMINPASS}
  admin:
    username: ${ADMINUSER}
    password: ${ADMINPASS}
  parameters:
    archive_mode: "off"
    archive_command: mkdir -p ../wal_archive && cp %p ../wal_archive/%f
    wal_level: hot_standby
    max_wal_senders: 10
    hot_standby: "on"
__EOF__

# do 9.3 compatibility which removes replication slots
if [ "${PGVERSION}" = "9.3" ]
then
    cat >> /etc/patroni/patroni.yml <<__EOF__
    wal_keep_segments: 10
__EOF__
else
    cat >> /etc/patroni/patroni.yml <<__EOF__
    max_replication_slots: 7
    wal_keep_segments: 5
__EOF__
fi

cat /etc/patroni/patroni.yml

exec python /patroni/patroni.py /etc/patroni/patroni.yml
