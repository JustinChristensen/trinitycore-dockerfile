#!/usr/bin/env bash

for IMAGE in $(docker images -aq); do
    docker rmi -f $IMAGE
done
