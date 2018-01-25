#! /bin/sh

ISTIO_VERSION=${1:-0.4.0}

ISTIO_PROFILE_DIR="$HOME/.minishift/profiles/istio"
docker_images=(
  istio/istio-ca:$ISTIO_VERSION
  istio/grafana:$ISTIO_VERSION
  istio/pilot:$ISTIO_VERSION
  istio/proxy_debug:$ISTIO_VERSION
  istio/proxy_init:$ISTIO_VERSION
  istio/mixer:$ISTIO_VERSION
  istio/servicegraph:$ISTIO_VERSION
  istio/examples-bookinfo-ratings-v1:0.2.8
  istio/examples-bookinfo-ratings-v2:0.2.8
  istio/examples-bookinfo-reviews-v1:0.2.8
  istio/examples-bookinfo-reviews-v2:0.2.8
  istio/examples-bookinfo-reviews-v3:0.2.8
  istio/examples-bookinfo-details-v1:0.2.8
  istio/examples-bookinfo-productpage-v1:0.2.8
  istio/examples-helloworld-v1:latest
  istio/examples-helloworld-v2:latest
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

# Delete the VM which has been provisioned according to istio profile
minishift delete --profile istio -f

# Enable config cache and set list of images to be part of the cache
minishift config set image-caching true
minishift image cache-config add $IMAGES
minishift start --profile istio

# Export images from Docker registry to store them locally under this directory ~/.minishift/cache/images/blobs
#minishift image export

echo "Log to OpenShift and install istio"
oc login $(minishift ip):8443 -u admin -p admin
pushd $(mktemp -d)
echo "Git clone ansible project to install istio distro on your laptop, project on openshift"
git clone https://github.com/istio/istio.git && cd istio/install
ansible-playbook ansible/main.yml -e '{"cluster_flavour": "ocp","istio": {"release_tag_name": "$ISTIO_VERSION", "auth": true, "jaeger": true, "bookinfo": true}}'
popd