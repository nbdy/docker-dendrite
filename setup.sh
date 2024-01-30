#!/bin/bash

DOCKER_IMAGE="matrixdotorg/dendrite-monolith:latest"
CONFIG_DIR="dendrite_config"

source .env

if [ ! -d $CONFIG_DIR ]; then
  echo "Creating directory '$CONFIG_DIR'"
  mkdir $CONFIG_DIR
fi

if [ ! -f $CONFIG_DIR/matrix_key.pem ]; then
  echo "Generating private key since it does not exist"
  docker run --rm --entrypoint="/usr/bin/generate-keys" -v $(pwd)/$CONFIG_DIR:/mnt $DOCKER_IMAGE \
    -private-key /mnt/matrix_key.pem
fi

if [ ! -f $CONFIG_DIR/dendrite.yaml ]; then
  echo "Generating $CONFIG_DIR since it does not exist"
  docker run --rm --entrypoint="/bin/sh" -v $(pwd)/$CONFIG_DIR:/mnt $DOCKER_IMAGE \
    -c "/usr/bin/generate-$CONFIG_DIR \
          -dir /var/dendrite \
          -db postgres:///$POSTGRES_USER:$POSTGRES_PASSWORD@dendritedb/$dendrite?sslmode=disable \
          -server $DOMAIN > /mnt/dendrite.yaml"
fi

echo "Setup done"
