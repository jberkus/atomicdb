#!/bin/bash

# setup dnf to pull PostgreSQL from yum.postgresql.org
#dnf -y -q install https://download.postgresql.org/pub/repos/yum/9.5/fedora/fedora-23-x86_64/pgdg-fedora95-9.5-3.noarch.rpm
# using cached version for now because rpm server being slow
rpm -i /rpm/pgdg-fedora95-9.5-3.noarch.rpm

# install pgbouncer and a bunch of accessories
dnf -y -q install postgresql95
dnf -y -q install pgbouncer
dnf -y -q install python python-psycopg2
