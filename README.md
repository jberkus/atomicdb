# Containerized PostgreSQL on Atomic Platforms

This repository is a demo area showing how high availability, scalable
PostgreSQL can be built out using Kubernetes and Docker (and run on
Atomic Host!).  These are not production solutions, but rather
intended to show off advances in Kubernetes and clustered PostgreSQL.

## patroni_petset

This directory demonstrates building a high-availability single-master
PostgreSQL cluster under Patroni, using Kubernetes StatefulSet (PetSet).

See its README for more information.
