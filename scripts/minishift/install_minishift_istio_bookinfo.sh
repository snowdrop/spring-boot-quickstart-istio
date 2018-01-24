#! /bin/sh

ISTIO_PROFILE_DIR="$HOME/.minishift/profiles/istio"

if [ ! -d "$ISTIO_PROFILE_DIR" ]; then
  echo "### Istio profile doesn't exist. Let's create it .... $ISTIO_PROFILE_DIR ####"
  minishift profile set istio
  minishift --profile istio config set image-caching true
  minishift --profile istio config set memory 4GB
  minishift --profile istio config set openshift-version v3.7.1
  minishift --profile istio config set vm-driver xhyve
  minishift --profile istio addon enable admin-user
fi

minishift start --profile istio

echo "Log to OpenShift and install istio"
oc login $(minishift ip):8443 -u admin -p admin

pushd $(mktemp -d)
echo "Git clone ansible project to install istio distro, project on openshift"
git clone git@github.com:snowdrop/istio-integration.git && cd istio-integration
ansible-playbook ansible/main.yml -e '{"cluster_flavour": "ocp","istio": {"release_tag_name": "0.4.0", "auth": false, "jaeger": true, "bookinfo": true}}'
popd