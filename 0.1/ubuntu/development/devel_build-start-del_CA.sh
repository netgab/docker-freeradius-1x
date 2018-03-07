#!/bin/bash

LABEL_DEVEL="development"
TAG="netgab/freeradius-1x:0.1-ubuntu"

# Rebuild image
docker build --tag $TAG .

# Start container with new image in interactive shell
docker run -e "DOCKER_ENV_CA_PRIVKEY_PASS=myPassPhrase" --label $LABEL_DEVEL -ti $TAG /bin/bash

# Delete all freeradius-1x containers with the "development" tag
docker ps -q -a -f label=$LABEL_DEVEL | xargs docker rm
