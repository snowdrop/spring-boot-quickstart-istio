#!/bin/bash

# Command usage
# ./manage_images.sh [COMMAND]
#
# Available Commands:
# export     Export Docker images to minishift cache
# import     Import Docker images to minishift cache

docker_images=(
  istio/istio-ca:0.4.0
  istio/grafana:0.4.0
  istio/pilot:0.4.0
  istio/proxy_debug:0.4.0
  istio/proxy_init:0.4.0
  istio/mixer:0.4.0
  istio/servicegraph:0.4.0
  istio/examples-bookinfo-ratings-v1:0.2.8
  istio/examples-bookinfo-reviews-v2:0.2.8
  istio/examples-bookinfo-reviews-v1:0.2.8
  istio/examples-bookinfo-reviews-v3:0.2.8
  istio/examples-bookinfo-details-v1:0.2.8
  istio/examples-bookinfo-productpage-v1:0.2.8
  prom/statsd-exporter:v0.5.0
  prom/prometheus:v2.0.0
  alpine:latest
  jaegertracing/all-in-one:latest
)
IMAGES=$(printf "%s " "${docker_images[@]}")

minishift image $1 $IMAGES