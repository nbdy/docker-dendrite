#!/bin/bash

DOCKER_IMAGE="matrixdotorg/dendrite-monolith:latest"

source .env

if [ ! -d config ]; then
  echo "Creating config directory"
  mkdir config
fi

if [ ! -f config/matrix_key.pem ]; then
  echo "Generating private key since it does not exist"
  docker run --rm --entrypoint="/usr/bin/generate-keys" -v $(pwd)/config:/mnt $DOCKER_IMAGE \
    -private-key /mnt/matrix_key.pem
fi

if [ ! -f config/dendrite.yaml ]; then
  echo "Generating config since it does not exist"
  docker run --rm --entrypoint="/bin/sh" -v $(pwd)/config:/mnt $DOCKER_IMAGE \
    -c "/usr/bin/generate-config \
          -dir /var/dendrite \
          -db postgres:///$POSTGRES_USER:$POSTGRES_PASSWORD@dendritedb/$dendrite?sslmode=disable \
          -server $DOMAIN > /mnt/dendrite.yaml"
fi

echo "Setup done"
