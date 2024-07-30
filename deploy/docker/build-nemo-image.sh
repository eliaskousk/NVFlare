#!/usr/bin/env bash

set -x

docker build -t nemo:latest -f ./Dockerfile-nemo ../..
