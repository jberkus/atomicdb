# This dockerfile is meant to help with setup and testing of
# patroni nodes.  It is designed to use kubernetes to support
# multiple nodes

FROM fedora:24

ADD ./scripts/ /scripts/
ADD ./patroni/ /patroni/

RUN /scripts/package_install.sh

EXPOSE 8008 5432

ENTRYPOINT ["/bin/bash", "/scripts/entrypoint.sh"]
