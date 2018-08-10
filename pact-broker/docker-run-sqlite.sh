#!/usr/bin/env bash

containerName="pactbroker"

docker run \
  --name ${containerName} \
  -e PACT_BROKER_DATABASE_ADAPTER=sqlite \
  -e PACT_BROKER_DATABASE_NAME=pactbroker.sqlite \
  -p 80:80 \
  -d dius/pact-broker
