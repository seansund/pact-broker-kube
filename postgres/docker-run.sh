#!/usr/bin/env bash

imageName="pactbroker-db"
containerName="pactbroker-db"
localSqlVolume="/private/var/lib/postgresql/data"

imageDir=$(dirname "$0")
cd ${imageDir}

docker build -t ${imageName} .

docker run --name ${containerName} -v ${localSqlVolume}:/var/lib/postgresql/data -d ${imageName}
