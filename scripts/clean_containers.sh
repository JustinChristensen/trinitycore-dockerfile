#!/usr/bin/env bash

for CONT in $(docker ps -aq); do
    docker rm -f $CONT
done
