## Base image
FROM alpine

## Dockerfile author
MAINTAINER Johannes Luther <joe@netgab.net> 

## Install packages
RUN apk update && apk upgrade && \
  apk add --update --no-cache \
  freeradius freeradius-eap openssl bash

## Additional packages (devel only)
RUN  apk add --update --no-cache \
  nano

## Create files and directories
RUN mkdir -p /etc/rad1x/scripts

## Mapping volumes
#VOLUME \
#    /opt/db/ \
#    /etc/freeradius/certs

EXPOSE \
    1812/udp \
    1813

COPY *.sh /etc/rad1x/scripts/
COPY config /etc/rad1x/config/

ENTRYPOINT ["/bin/bash", "/etc/rad1x/scripts/initial_provisioning.sh"]

CMD ["radiusd","-Xx","-f"]

