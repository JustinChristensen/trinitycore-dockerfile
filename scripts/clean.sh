#!/usr/bin/env bash

docker system prune &&
./clean_containers.sh &&
./clean_images.sh
