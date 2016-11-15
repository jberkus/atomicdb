#!/bin/bash

# setup dnf to pull PostgreSQL from yum.postgresql.org
#dnf -y -q install https://download.postgresql.org/pub/repos/yum/9.5/fedora/fedora-23-x86_64/pgdg-fedora95-9.5-3.noarch.rpm
rpm -i /scripts/pgdg-fedora95-9.5-3.noarch.rpm

# install some basics
dnf -y -q install readline-devel
dnf -y -q install hostname

# install postgresql client
dnf -y -q install postgresql95

# install some other useful stuff
dnf -y -q install tmux curl
