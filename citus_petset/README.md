# CitusDB StatefulSet Implementation

This is a simplified, demo implementation of CitusDB clustered database
deployment using [Kubernetes PetSet/StatefulSet]().  
It is not a production implementation at this time.  Rather, this is a demo
and a prototype for developing a production [Helm chart]() for
CitusDB

## citus-docker

This is a simple docker container build directory for creating a PostgreSQL
instance which creates a PostgreSQL instance with Citus installed.  It is the
base for the image used in the Kubernetes deployment.

This image will not work without Kubernetes.

## kubernetes

These are the PetSet kubernetes templates giving an example of how to deploy
a Citus cluster based on Patroni.  Currently, these files deploy emphemeral
PostgreSQL, rather than with persistent volumes due to an outstanding
bug with PetSet and PVs on AWS; look for updates for
and example with PVs.

First, install the secrets.  You'll probably want to change the passwords
in the secrets file; the current password for all users is "atomic".  The
passwords in the file are base64-encoded strings.

```
kubectl apply -f sec-citus.yaml
```

Next, create the Citus PetSet.  Depending on your setup, you can
play with increasing the number of replicas.  Note that the number
of replicas needs to be set in two places, both after "replicas"
and for the variable SET_SIZE.  If you are planning on having redundant
shards, you will want to make sure that the number of replicas is
appropriately divisible, keeping in mind that one replica is the
query node and does not store data.

Other requirements if you're modifying the file:

* POD_GROUP must be set to the same name as the ServiceName for the StatefulSet
* you cannot change the names of database users (you could add more though)
* you cannot change the port of the PetSet Service
* ETCD_HOST and POD_IP are there for future use and are not currently used
  by the demo container.

```
kubectl create -f ps-citus.yaml
```

Third, create the query service:

```
kubectl create -f svc-citus.yaml
```

These services are currently internal-only using ClusterIP.  You can tinker
with the services to deploy them some other way.

At this point, you should be able to connect to the citus database from
within the cluster at the address `citusdb.default`, for example:

```
psql -h citusdb.default -U admin citusdb
```

This setup is based on the idea that "citus-0" is the query node, and that
all other nodes are shards.  This is actually an HA configuration, as Kubernetes
will automatically replace citus-0 if it fails.

Once connected, you can create distributed table and query it:

```
```

## missing pieces

A number of additional steps would need to be required to make this a production
deployment.  Among the ones which will be included in this prototype and
the eventual Helm chart for Citus are:

* ssl-only connections
* persistent volume support (waiting on these bugs: )
* auto-termination on loss of connection to the kube-master
* support for shard replicas (waiting on additional StatefulSet features)
* backup service(s)
* add-database-to-all-nodes service
* dynamic templating of postgresql.conf and pg_hba.conf (waiting on new
  StatefulSet ConfigMap features)

There are also issues which will be entirely up to your administration and
setup, such as:

* Vault or other secure secrets setup for passwords
* Backing PV storage setup
* connection pooling, if required
