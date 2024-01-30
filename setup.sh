#!/bin/bash

DOCKER_IMAGE="matrixdotorg/dendrite-monolith:latest"

source .env

if [ ! -d config ]; then mkdir config; fi

if [ ! -f config/matrix_key.pem ]; then
  docker run --rm --entrypoint="/usr/bin/generate-keys" -v $(pwd)/config:/mnt $DOCKER_IMAGE \
    -private-key /mnt/matrix_key.pem
fi

if [ ! -f config/dendrite.yaml ]; then
  docker run --rm --entrypoint="/bin/sh" -v $(pwd)/config:/mnt $DOCKER_IMAGE \
    -c "/usr/bin/generate-config \
          -dir /var/dendrite \
          -db postgres:///$POSTGRES_USER:$POSTGRES_PASSWORD@dendritedb/$dendrite?sslmode=disable \
          -server $DOMAIN > /mnt/dendrite.yaml"
fi
