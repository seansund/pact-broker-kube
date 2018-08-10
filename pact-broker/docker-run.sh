#!/usr/bin/env bash

containerName="pactbroker"

docker run --name ${containerName} --link pactbroker-db:postgres -e PACT_BROKER_DATABASE_HOST=postgres -e PACT_BROKER_DATABASE_USERNAME=pactbrokeruser -e PACT_BROKER_DATABASE_PASSWORD=TheUserPassword -e PACT_BROKER_DATABASE_NAME=pactbroker -d -p 80:80 dius/pact-broker
