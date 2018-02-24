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

## Mapping volumes
#VOLUME \
#    /opt/db/ \
#    /etc/freeradius/certs

EXPOSE \
    1812/udp \
    1813

CMD ["radiusd","-xx","-f"]
