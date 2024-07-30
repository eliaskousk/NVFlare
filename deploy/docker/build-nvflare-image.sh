#!/usr/bin/env bash

set -x

docker build -t nvflare:latest -f ./Dockerfile-nvflare ../..
