#!/usr/bin/env bash

set -e

export TRINITYCORE_VERSION='10f6e3818578410246750c6fce53d189ad05bee4'
export WORLD_DB_RELEASE='https://github.com/TrinityCore/TrinityCore/releases/download/TDB335.19081/TDB_full_world_335.19081_2019_08_16.7z'

docker build -t trinitycore-base --build-arg TRINITYCORE_VERSION base
docker-compose build --parallel
exec docker-compose up
