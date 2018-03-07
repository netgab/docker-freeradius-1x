#!/usr/bin/env bash

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# debugging
#set -x

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # the full path of the directory where the script resides
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"     # full path including script name
__base="$(basename ${__file} .sh)"

function onExit() {
  echo "$(date) - exiting $__base"
  echo $?
}
trap onExit EXIT

## Basic variables and settings
# General variables
readonly FR1X_BASEDIR=/etc/rad1x
readonly FR1X_CONFDIR=$FR1X_BASEDIR/config
readonly FR1X_FILE_PROVISIONED=$FR1X_BASEDIR/.provisioned_1x

readonly FR1X_CADIR=$FR1X_BASEDIR/CA
readonly FR1X_CANAME="radius1X_demoCA"
readonly FR1X_CA_SUBJECT="CN=1X 802.1X Demo CA"
readonly FR1X_CA_OPENSSLCNF=$FR1X_CONFDIR/openssl/openssl.cnf
readonly FR1X_CA_RSA_KEYSIZE=4096
readonly FR1X_CA_VALIDITY_DAYS=3650     # 10 years
readonly FR1X_CA_PRIVKEY=$FR1X_CADIR/private/$FR1X_CANAME.key
readonly FR1X_CA_CERT=$FR1X_CADIR/$FR1X_CANAME.pem

# Environment variable names
readonly FR1X_ENV_CA_PRIVKEY_PASS=DOCKER_ENV_CA_PRIVKEY_PASS

# freeradius specific files or folders
readonly FRAD_BASEDIR=/etc/raddb
readonly FRAD_CONFIG_EAP=$FRAD_BASEDIR/mods-enabled/eap
readonly FRAD_DIR_CERT=$FRAD_BASEDIR/certs

# Server certificate for EAP-TLS, TTLS and PEAP
readonly CERT_SERVER_RSA_KEYSIZE=4096
readonly CERT_SERVER_HASH_SIGN=sha256
readonly CERT_SERVER_VALIDITY_DAYS=730
readonly CERT_SERVER_SUBJECT="/OU=Example certificate/CN=freeradius"
readonly CERT_SERVER_CERTFILE=$FRAD_DIR_CERT/server.pem
readonly CERT_SERVER_KEYFILE=$FRAD_DIR_CERT/server.key
readonly CERT_SERVER_CAFILE=$FRAD_DIR_CERT/ca.pem
readonly FRAD_FILE_DH=$FRAD_DIR_CERT/dh
#readonly FRAD_DH_KEYSIZE=4096
readonly FRAD_DH_KEYSIZE=1024

## Begin script
# Check if this is a fresh installation

if [ ! -f $FR1X_FILE_PROVISIONED ]; then
    echo "Fresh installation detected (absence of file $FR1X_FILE_PROVISIONED)"
    echo "Start provisioning ..."
    if [ ! -d "$FR1X_BASEDIR" ]; then
      mkdir $FR1X_BASEDIR
    fi


    # Checking if environmental variable for CA creation is set
    # If not, skip the CA creation process
    if  [ ! -v ${DOCKER_ENV_CA_PRIVKEY_PASS:-} ]; then
      echo "Creating CA in $FR1X_CADIR ..."
      if [ ! -d "$FR1X_CADIR" ]; then
        mkdir $FR1X_CADIR
      fi
      mkdir $FR1X_CADIR/certs $FR1X_CADIR/private $FR1X_CADIR/crl $FR1X_CADIR/newcerts
      # Create index file and initial serial number
      touch $FR1X_CADIR/index.txt
      echo '100001' >$FR1X_CADIR/serial
      # Create CRL file and initial serial number
      touch $FR1X_CADIR/crlnumber
      echo '100001' >$FR1X_CADIR/serial

      # Create CA certificate
      openssl req -config $FR1X_CA_OPENSSLCNF -new -passout env:$FR1X_ENV_CA_PRIVKEY_PASS -newkey rsa:$FR1X_CA_RSA_KEYSIZE -x509 \
        -keyout $FR1X_CA_PRIVKEY -out $FR1X_CA_CERT -days $FR1X_CA_VALIDITY_DAYS \
        -subj "/$FR1X_CA_SUBJECT" -extensions v3_ca

      # Create freeradius server certificate CSR
      echo "Creating SSL server certificate in $FRAD_DIR_CERT ..."
      openssl req -config $FR1X_CA_OPENSSLCNF -nodes -newkey rsa:$CERT_SERVER_RSA_KEYSIZE \
        -keyout $CERT_SERVER_KEYFILE -out /tmp/server.csr -subj "$CERT_SERVER_SUBJECT"

      # Sign CSR
      openssl ca -batch -config $FR1X_CA_OPENSSLCNF -policy policy_anything \
        -passin env:$FR1X_ENV_CA_PRIVKEY_PASS \
        -out $CERT_SERVER_CERTFILE -in /tmp/server.csr -days $CERT_SERVER_VALIDITY_DAYS \
        -extensions rad1x_ssl_server

      # Copy CA cert to freeradius cert folder
      cp $FR1X_CA_CERT $CERT_SERVER_CAFILE
    else
      echo "no CA private key passphrase set (environmental variable $FR1X_ENV_CA_PRIVKEY_PASS) ... skipping demo CA creation"
    fi

    # Create Diffie-Hellman nonce file
    echo "Creating Diffie-Hellman nonce file. CAUTION: This may take a while ..."
    openssl dhparam -check -text -5 $FRAD_DH_KEYSIZE -out $FRAD_FILE_DH

    # Copy config files in rad1x config directory
    #echo "Copy config files in rad1x config directory to freeradius config"
    #echo "[DEBUG] cp -r $FR1X_CONFDIR/freeradius/ $FRAD_BASEDIR"
    #cp -r $FR1X_CONFDIR/freeradius/* $FRAD_BASEDIR

    # Set the provisioned flag
    touch $FR1X_FILE_PROVISIONED
fi

exec "$@"
