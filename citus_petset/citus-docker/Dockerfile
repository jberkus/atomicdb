# This dockerfile is meant to help with setup and testing of
# citusdb clusters.  It is designed to use kubernetes to support
# multiple nodes

FROM fedora:24

ADD ./scripts/ /scripts/

RUN /scripts/package_install.sh

EXPOSE 5432

CMD ["/bin/bash", "/scripts/entrypoint.sh"]
