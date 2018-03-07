#!/bin/bash

LABEL_DEVEL="development"

# Rebuild image
docker build --tag freeradius-1x:latest .

# Start container with new image in interactive shell
docker run -e "DOCKER_ENV_CA_PRIVKEY_PASS=myPassPhrase" --label $LABEL_DEVEL -ti freeradius-1x /bin/bash

# Delete all freeradius-1x containers with the "development" tag
docker ps -q -a -f label=$LABEL_DEVEL | xargs docker rm
