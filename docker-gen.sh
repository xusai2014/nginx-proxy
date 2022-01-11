#!/usr/bin/env bash

docker build -t nginx-proxy .
docker tag nginx-proxy:latest xusai2014/nginx-proxy
docker push xusai2014/nginx-proxy
