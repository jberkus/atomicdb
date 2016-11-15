#!/bin/bash

#set some derived variables

DOCKER_IP=${POD_IP}
HNAME=${POD_NAME}
LOOKUP="${POD_NAME}.${POD_GROUP}"
NODE=${HNAME//[^a-z0-9]/_}

if [[ ${POD_NAME} == *-0 ]]; then
  ISBOOTSTRAP="true"
else
  ISBOOTSTRAP="false"
fi

#create postgresql directories and set permissions
mkdir -p /pgdata/data
mkdir -p /mnt/stats/pgsql-stats/
chown -R postgres:postgres /pgdata/data
chmod -R 700 /pgdata/data
chown -R postgres:postgres /mnt/stats/pgsql-stats
chmod -R 700 /mnt/stats/pgsql-stats

# create governor configuration directory
mkdir -p /etc/governor
chown -R postgres:postgres /etc/governor

#create governor config
cat > /governor/governor.yml <<__EOF__
loop_wait: 1000 #milliseconds
data_dir: "/pgdata/data"
api_port: 5000
haproxy_status:
        listen: 127.0.0.1:2345
fsm:
  raft_port: 1234
  cluster_config_port: 1244
  bootstrap_peers:
    - http://${POD_GROUP}-0:1244
  #TODO: Alter canoe to allow set-list of bootstrap peers
  is_bootstrap: ${ISBOOTSTRAP}
  # cluster_id: 1234
  leader_ttl: 3000 #milliseconds
  member_ttl: 3000 #milliseconds
postgresql:
  name: ${LOOKUP}
  listen: 0.0.0.0:5432
  maximum_lag_on_failover: 104857600 # 100 megabyte in bytes
  replication:
    username: replication
    password: rep-pass
    network:  10.0.0.0/8
  parameters:
    max_wal_senders: 5
    wal_keep_segments: 8
max_replication_slots: 5
__EOF__

cat /governor/governor.yml

/scripts/su-exec postgres /governor/governor /governor/governor.yml
