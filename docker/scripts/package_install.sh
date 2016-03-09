#!/bin/bash

# setup dnf to pull PostgreSQL from yum.postgresql.org
#dnf -y -q install https://download.postgresql.org/pub/repos/yum/9.5/fedora/fedora-23-x86_64/pgdg-fedora95-9.5-3.noarch.rpm
rpm -i /scripts/pgdg-fedora95-9.5-3.noarch.rpm

# install some basics
dnf -y -q install readline-devel
dnf -y -q install hostname

# install postgresql and a bunch of accessories
dnf -y -q install postgresql95
dnf -y -q install postgresql95-server
dnf -y -q install postgresql95-contrib
dnf -y -q install postgresql95-devel postgresql95-libs
dnf -y -q install python-psycopg2

# set up SSL certs
dnf -y -q install openssl openssl-devel
sh /etc/ssl/certs/make-dummy-cert /etc/ssl/certs/patroni.cert
chown postgres:postgres /etc/ssl/certs/patroni.cert

# put pg_ctl in postgres' path
ln -s /usr/pgsql-9.5/bin/pg_ctl /usr/bin/
ln -s /usr/pgsql-9.5/bin/pg_config /usr/bin/
ln -s /usr/pgsql-9.5/bin/pg_controldata /usr/bin/

#  install extensions
#dnf -y -q install postgresql-${PGVER}-postgis-2.1 postgresql-${PGVER}-postgis-2.1-scripts

# install python requirements
dnf -y -q install python-pip
dnf -y -q install python-devel

# install WAL-E
# pip install -U six
# pip install -U requests
# pip install -U wal-e
# dnf -y -q install daemontools
# dnf -y -q install lzop pv

# install patroni dependancies
dnf -y -q install python-y -qaml
pip install -U setuptools
pip install -r /scripts/requirements-py2.txt

# install patroni.  commented out for testing
cd /patroni
python setup.py install
