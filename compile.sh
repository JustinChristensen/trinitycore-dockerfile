#!/usr/bin/env bash
exec docker build "$@" -t trinitycore-compile compile
