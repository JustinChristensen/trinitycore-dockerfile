#!/usr/bin/env bash

set -e

export TRINITYCORE_VERSION="${TRINITYCORE_VERSION:-10f6e3818578410246750c6fce53d189ad05bee4}"
export WORLD_DB_RELEASE="${WORLD_DB_RELEASE:-https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.19081/TDB_full_world_335.19081_2019_08_16.7z}"
export CLIENT_DIR="${CLIENT_DIR:-client}"

echo "Loading client Data directory..."
docker volume create trinitycore-data > /dev/null
docker run --rm -t -v "$(pwd)/$CLIENT_DIR:/client:cached" -v trinitycore-data:/data debian:buster-slim cp -rn /client/Data /data

echo "Building..."
docker build -t trinitycore-base --build-arg TRINITYCORE_VERSION base
docker build -t trinitycore-authserver authserver
docker build -t trinitycore-worldserver worldserver

exec docker-compose up
