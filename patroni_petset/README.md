# Patroni PetSet Implementation

This is a simplified, demo implementation of HA PostgreSQL using [Patroni](https://github.com/zalando/patroni/)
and [Kubernetes PetSet]().  It is not a production implementation; for an
example of a production implementation, see [Spilo](https://github.com/zalando/spilo/tree/master/postgres-appliance) and the
[Helm Chart for Spilo and Patroni](https://github.com/kubernetes/charts/tree/master/incubator/patroni).

## patroni-docker

This is a simple docker container build directory for creating a PostgreSQL
instance which uses Patroni for automated replication and HA.  It is the
base for the image used in the Kubernetes deployment.

Also included is a separate build just for creating a container with PostgreSQL
client tools.

## kubernetes

These are the PetSet kubernetes templates giving an example of how to deploy
a cluster based on Patroni.  Currently, these files deploy emphemeral
PostgreSQL, rather than with persistent volumes; look for updates for
and example with PVs.

First: create an etcd cluster using etcd.yaml or a similar profile.

```
kubectl create -f etcd.yaml
```

Second, create the secret for the PostgreSQL passwords.  You may want
to replace the actual password; the ones given in the file are "atomic" for all users.

```
kubectl create -f sec-patroni.yaml
```

Third, create the PostgreSQL PetSet.  Depending on your setup, you can
play with increasing the number of replicas:

```
kubectl create -f ps-patroni-ephemeral.yaml
```

Finally, create the write and load-balanced read services:

```
kubectl create -f svc-patroni-master.yaml
kubectl create -f svc-patroni-read.yaml
```

These services are currently internal-only using ClusterIP.  You can tinker
with the services to deploy them some other way.
