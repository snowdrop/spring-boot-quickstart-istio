#! /bin/sh

minikube delete
minikube start --memory 4000 --vm-driver xhyve

pushd $(mktemp -d)
echo "Git clone ansible project to install istio distro, project on openshift"
git clone git@github.com:snowdrop/istio-integration.git && cd istio-integration
ansible-playbook ansible/main.yml -e '{"cluster_flavour": "k8s","istio": {"release_tag_name": "0.4.0", "auth": true, "jaeger": true}}'
popd