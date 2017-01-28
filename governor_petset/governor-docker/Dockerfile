# This dockerfile is meant to help with setup and testing of
# governor nodes.  It is designed to use kubernetes to support
# multiple nodes

FROM fedora:24

ENV LANG=C.UTF8

ADD ./scripts/ /scripts/

RUN /scripts/package_install.sh

EXPOSE 5000 5432 1234 1244

ENTRYPOINT ["/bin/bash", "/scripts/entrypoint.sh"]
