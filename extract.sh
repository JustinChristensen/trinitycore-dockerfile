#!/usr/bin/env bash

exec docker build -f extract/Dockerfile -t trinitycore-extract "$@" .

