#! /bin/sh

ISTIO_PROFILE_DIR="$HOME/.minishift/profiles/istio"
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

if [ ! -d "$ISTIO_PROFILE_DIR" ]; then
  echo "### Istio profile doesn't exist. Let's create it .... $ISTIO_PROFILE_DIR ####"
  minishift profile set istio
  minishift --profile istio config set memory 4GB
  minishift --profile istio config set openshift-version v3.7.1
  minishift --profile istio config set vm-driver xhyve
  minishift --profile istio addon enable admin-user
fi

minishift delete --profile istio -f

minishift config set image-caching true
minishift image cache-config add $IMAGES
minishift start --profile istio

# echo "Log to OpenShift and install istio"
# oc login $(minishift ip):8443 -u admin -p admin
#
# pushd $(mktemp -d)
# echo "Git clone ansible project to install istio distro, project on openshift"
# git clone git@github.com:snowdrop/istio-integration.git && cd istio-integration
# ansible-playbook ansible/main.yml -e '{"cluster_flavour": "ocp","istio": {"release_tag_name": "0.4.0", "auth": false, "jaeger": true, "bookinfo": true}}'
# popd