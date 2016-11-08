# This dockerfile is meant to help with setup and testing of
# patroni nodes.  it supplies psql, which is not available on
# the Atomic Host

FROM fedora:23

ADD ./scripts/ /scripts/

RUN /scripts/psql_install.sh

CMD ["/bin/bash"]
USER root
