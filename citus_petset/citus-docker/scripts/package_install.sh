#!/bin/bash

# setup dnf to pull PostgreSQL from yum.postgresql.org
#dnf -y -q install https://download.postgresql.org/pub/repos/yum/9.6/fedora/fedora-23-x86_64/pgdg-fedora96-9.6-3.noarch.rpm
rpm -i https://download.postgresql.org/pub/repos/yum/9.6/fedora/fedora-24-x86_64/pgdg-fedora96-9.6-3.noarch.rpm
# install citus repo
cp /scripts/config_file.repo /etc/yum.repos.d/citus-community.repo

# install some basics
dnf -y -q install readline-devel
dnf -y -q install hostname

# install postgresql and a bunch of accessories
dnf -y -q install postgresql96
dnf -y -q install postgresql96-server
dnf -y -q install postgresql96-contrib
dnf -y -q install postgresql96-devel postgresql96-libs
dnf -y -q install python3-psycopg2
dnf -y -q install citus_96

# set up SSL certs
dnf -y -q install openssl openssl-devel
sh /etc/ssl/certs/make-dummy-cert /etc/ssl/certs/postgres.cert
chown postgres:postgres /etc/ssl/certs/postgres.cert

# put binaries in postgres' path
ln -s /usr/pgsql-9.6/bin/pg_ctl /usr/bin/
ln -s /usr/pgsql-9.6/bin/pg_config /usr/bin/
ln -s /usr/pgsql-9.6/bin/pg_controldata /usr/bin/
ln -s /usr/pgsql-9.6/bin/initdb /usr/bin/
ln -s /usr/pgsql-9.6/bin/postgres /usr/bin/

#  install extensions
#dnf -y -q install postgresql-${PGVER}-postgis-2.1 postgresql-${PGVER}-postgis-2.1-scripts

# install python requirements
dnf -y -q install python3-pip
dnf -y -q install python3-devel
pip3 install -U requests

# install WAL-E
# pip install -U six
# pip install -U wal-e
# dnf -y -q install daemontools
# dnf -y -q install lzop pv

# clean up dnf cache to shrink image
dnf clean all
