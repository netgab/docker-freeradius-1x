
# docker-freeradius-1x

## Introduction
docker-freeradius-1x is a freeradius server based on Alpine Linux.
The primary use case is 802.1X using EAP-TLS and PEAP.
The docker image is initially provisioned (first time only) with:
* A demo CA for 802.1X EAP-TLS and PEAP (optional)
  * Only one hierarchy
  * CA based on openssl
  * CA basedir in container /etc/rad1x/CA
* Hardened freeradius config:
  * Tuned "eap" config file (mods-available) to support EAP-TLS and PEAP only
  * Tunel "sites-available / default" config file to support EAP-TLS and PEAP only

## Quick start
To run the docker container "ready-to-use" with the demoCA and server certificates
```
docker run -d -e "DOCKER_ENV_CA_PRIVKEY_PASS=myPassPhrase" -p 1812:1812/udp -p 1813:1813/udp -v /etc/raddb freeradius-1x
```
The environment variable DOCKER_ENV_CA_PRIVKEY_PASS sets the private key passphrase for the CA:
Please change "myPassPhrase" to another secret only known to you!

 



