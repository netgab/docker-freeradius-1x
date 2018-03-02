
# docker-freeradius-1x

## Dislaimer
Im still in the development and documentation phase of the container.

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
To run the docker container "ready-to-use" with the demoCA and SSL server certificates
```
docker run -d -e "DOCKER_ENV_CA_PRIVKEY_PASS=myPassPhrase" \
-p 1812:1812/udp -p 1813:1813/udp -v /etc/raddb freeradius-1x
```
The environment variable DOCKER_ENV_CA_PRIVKEY_PASS sets the private key passphrase for the CA:
Please change "myPassPhrase" to another secret only known to you!


To run the docker container without a prebuild demo CA without SSL server certificates 
```
docker run -d -p 1812:1812/udp -p 1813:1813/udp -v /etc/raddb freeradius-1x
```
The absence of the environment variable DOCKER_ENV_CA_PRIVKEY_PASS indicates that you don't want a demo CA.
Please put your own SSL server certificate, private key and CA chain into the /etc/raddb/certs directory.
* SSL server certificate: /etc/raddb/server.pem
* SSL server private key: /etc/raddb/server.key
* CA certificate chain: /etc/raddb/ca.pem

If your private key is protected by a passphrase please adjust the file /etc/raddb/mods-available/eap
The parameter "private_key_password" must be uncommented and the private key must be set.
```
[...]
tls-config tls-common {
  [...]
  private_key_password = whatever
  [...]
```

## DemoCA
The demoCA is based on openSSL and is stored in /etc/rad1x/CA.
If the demoCA should be used in production (not really recommended), the CA directory must be exposed as well

Example:
```
docker run -d -e "DOCKER_ENV_CA_PRIVKEY_PASS=myPassPhrase" \
-p 1812:1812/udp -p 1813:1813/udp \
-v /etc/raddb -v /etc/rad1x/CA freeradius-1x
```

The CA has the following docker run -d -e "DOCKER_ENV_CA_PRIVKEY_PASS=myPassPhrase" \
-p 1812:1812/udp -p 1813:1813/udp \
-v /etc/raddb -v /etc/rad1x/CA freeradius-1x

### CA preconfiguration 
* CA
  * Private key size (RSA): 4096 Bit
  * Private key passphrase: Set via environmental variable DOCKER_ENV_CA_PRIVKEY_PASS
  * Validity: 3650 days (10 years)
* freeradius server certificate
  * Private key size (RSA): 4096 Bit
  * Hash algorithm: SHA256
  * Validity: 730 days (2 years)
