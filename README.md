# Containerized PostgreSQL on Atomic Platforms

This repository is a demo area showing how high availability, scalable
PostgreSQL can be built out using Kubernetes and Docker (and run on
Atomic Host!).  These are not production solutions, but rather
intended to show off advances in Kubernetes and clustered PostgreSQL.

## patroni_petset

This directory demonstrates building a high-availability single-master
PostgreSQL cluster under Patroni, using Kubernetes StatefulSet (PetSet).

See its README for more information.

## citus_petset

This directory contains a prototype of a CitusDB sharded database cluster under
Kubernetes StatefulSet(PetSet).  See its README for more details.

## governor-petset

This directory contains a prototype of the new Go-based Governor PostgreSQL
cluster under Kubernetes.  It is a WIP, and doesn't yet work.

## LICENSING

The general repository is under the MIT License.  However, the
cluster examples incorporate code from other projects, which may be
differently licensed.  Please check the individual directories
if you have specific licensing needs.
