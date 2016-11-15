#!/bin/bash

# setup dnf to pull PostgreSQL from yum.postgresql.org
#dnf -y -q install https://download.postgresql.org/pub/repos/yum/9.5/fedora/fedora-23-x86_64/pgdg-fedora95-9.5-3.noarch.rpm
rpm -i https://download.postgresql.org/pub/repos/yum/9.5/fedora/fedora-24-x86_64/pgdg-fedora95-9.5-4.noarch.rpm

# install some basics
dnf -y -q install readline-devel
dnf -y -q install hostname

# install postgresql and a bunch of accessories
dnf -y -q install postgresql95
dnf -y -q install postgresql95-server
dnf -y -q install postgresql95-contrib
dnf -y -q install postgresql95-devel postgresql95-libs

# set up SSL certs
dnf -y -q install openssl openssl-devel
sh /etc/ssl/certs/make-dummy-cert /etc/ssl/certs/postgres.cert
chown postgres:postgres /etc/ssl/certs/postgres.cert

# put pg_ctl in postgres' path
ln -s /usr/pgsql-9.5/bin/pg_ctl /usr/bin/
ln -s /usr/pgsql-9.5/bin/pg_config /usr/bin/
ln -s /usr/pgsql-9.5/bin/pg_controldata /usr/bin/

#  install extensions
#dnf -y -q install postgresql-${PGVER}-postgis-2.1 postgresql-${PGVER}-postgis-2.1-scripts

# install go deps
dnf -y install go wget git

# download Governor
cd /
git clone https://github.com/compose/governor.git
cd /governor/
git checkout golang-custom-raft

# build governor
go build

# clean up dnf cache
dnf clean dbcache
