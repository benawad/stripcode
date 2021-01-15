#!/bin/bash

VERSION=`cat version.txt`
NEW_VERSION=`expr $VERSION + 1`
echo $NEW_VERSION > version.txt

docker build -t benawad/stripcode:$NEW_VERSION .
docker save benawad/stripcode:$NEW_VERSION | bzip2 | ssh stripcode "bunzip2 | docker load"
ssh stripcode "docker tag benawad/stripcode:$(echo $NEW_VERSION) dokku/api:latest && dokku tags:deploy api latest"