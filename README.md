# docker-freeradius-1x

## Introduction
docker-freeradius-1x is a freeradius server based on Alpine Linux.
The primary use case is 802.1X using EAP-TLS and PEAP.
The docker image is initially provisioned (first time only) with:
* A demo CA for 802.1X EAP-TLS and PEAP
  * Only one hierarchy
  * CA based on openssl
  * CA basedir in container /etc/rad1x/CA
* Hardened freeradius config:
  * Tuned "eap" config file (mods-available) to support EAP-TLS and PEAP only
  * Tunel "sites-available / default" config file to support EAP-TLS and PEAP only
 



