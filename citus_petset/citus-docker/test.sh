mkdir -p /pgdata/data
chown postgres:postgres /pgdata/data
chmod 700 /pgdata/data

/scripts/su-exec postgres /usr/bin/initdb -D /pgdata/data

/bin/cp -f /scripts/config/* /pgdata/data
chown -R postgres:postgres /pgdata/data

su - postgres
export POD_NAME="citus-0"
export POD_NAMESPACE="default"
export POD_GROUP="citus"
export SET_SIZE="2"

docker run -e POD_NAME="citus-0" \
 -e POD_NAMESPACE="default" \
 -e POD_GROUP="citus" \
  -e SET_SIZE="2" \
  jberkus/citus:0.4
