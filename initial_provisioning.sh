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
readonly FR1X_BASEDIR=/etc/rad1x/
readonly FR1X_CADIR=ca
readonly FR1X_CA_RSA_KEYSIZE=4096
readonly FR1X_FILE_PROVISIONED=.provisioned_1x

# Server certificate for EAP-TLS, TTLS and PEAP
readonly CERT_CA_BASEDIR=
readonly CERT_SERVER_RSA_KEYSIZE=2048
readonly CERT_SERVER_VALIDITY_DAYS=730
readonly CERT_SERVER_SUBJECT="/OU=Example certificate/CN=freeradius"
readonly CERT_SERVER_CERTFILE=server.pem
readonly CERT_SERVER_KEYFILE=server.key
readonly CERT_SERVER_CAFILE=ca.pem

# freeradius specific files or folders
FRAD_CONFIG_EAP=/etc/raddb/mods-enabled/eap
FRAD_FILE_DH=/etc/raddb/dh
FRAD_DIR_CERT=/etc/raddb/certs


## Begin script
# Check if this is a fresh installation

if [ ! -f "$FR1X_BASEDIR/$FR1X_FILE_PROVISIONED"  ]; then
    echo "Fresh installation detected (absence of file $FR1X_BASEDIR/$FR1X_FILE_PROVISIONED)"
    echo "Start provisioning ..."
    if [ ! -d "$FR1X_BASEDIR" ]; then
      mkdir $FR1X_BASEDIR
    fi

    echo "Creating CA and SSL server certificate ..."

fi






#openssl req -new -newkey rsa:2048 -days 730 -x509 -keyout /etc/raddb/certs/server.key -out /etc/raddb/certs/server.pem -passout pass:privkey -subj "/OU=Example certificate/CN=freeradius"

