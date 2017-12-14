# Instructions to install minishift, istio, microservices

  * [Create a Minishift vm](#create-a-minishift-vm)
  * [Install Istio and Spring Boot Microservices](#install-istio)
  * [Install Spring Boot Microservices on OpenShift](#without-istio)

## Create a Minishift vm

Prequisite is that minishift is installed on your [laptop](https://docs.openshift.org/latest/minishift/getting-started/installing.html).
If minishift is not installed on your machine, you can use the following ansible [playbook to install it](https://github.com/snowdrop/istio-integration/blob/master/README-ANSIBLE.md#install-minishift-optional)

Execute these commands within a terminal to create a profile using Xhyve drive to install into boot2docker vm Openshift 3.7 
To use istio 0.3.0, simply change the `ISTIO_VERSION` variable

```bash
export ISTIO_VERSION="0-2-12"
minishift stop
minishift delete --force  
minishift --profile istio-$ISTIO_VERSION config set image-caching true
minishift --profile istio-$ISTIO_VERSION config set memory 3GB
minishift --profile istio-$ISTIO_VERSION config set openshift-version v3.7.0
minishift --profile istio-$ISTIO_VERSION config set vm-driver xhyve
minishift --profile istio-$ISTIO_VERSION addon enable admin-user
minishift start --profile istio-$ISTIO_VERSION
oc login -u admin -p admin
```

## Install Istio

Next, to install istio and the 2 Spring Boot microservices, execute the following instructions within a terminal.

Prerequesite: 
- Ansible 2.4 must be installed on your laptop
- minishift is installed and a vm created as defined previously

Remarks : 

- To switch from the istio version 0.2.12 to 0.3.0, then use the `sed -i.bk s//g` instructions

```bash
pushd $(mktemp -d)
echo "Git clone ansible project to install istio distro, project on openshift"
git clone git@github.com:snowdrop/istio-integration.git
sed -i.bk 's/release_tag_name: \"0.2.12\"/release_tag_name: \"0.3.0\"/g' istio-integration/ansible/etc/config.yaml (OPTIONAL)

ansible-playbook istio-integration/ansible/main.yml -t install-distro
ansible-playbook istio-integration/ansible/main.yml -t install-istio

echo "Sleep at least 5min to be sure that all the docker images of istio will be downloaded and istio will be deployed"
sleep 5m
git clone git@github.com:snowdrop/spring-boot-quickstart-istio.git && cd spring-boot-quickstart-istio
sed -i.bk 's/istioVersion: \"0.2.12\"/istioVersion: \"0.3.0\"/g' greeting-service/src/main/istio/profiles.yml (OPTIONAL)
sed -i.bk 's/istioVersion: \"0.2.12\"/istioVersion: \"0.3.0\"/g' say-service/src/main/istio/profiles.yml (OPTIONAL)

oc new-project demo-istio
oc adm policy add-scc-to-user privileged -z default -n demo-istio

mvn clean package fabric8:deploy -Pistio-openshift -Dfabric8.resourceDir=src/main/istio

sleep 30s
oc expose svc istio-ingress -n istio-system

export SAY_URL=$(minishift openshift service istio-ingress -n istio-system --url)/say
http -v $SAY_URL
popd
```

## Without istio

```bash
pushd $(mktemp -d)
git clone git@github.com:snowdrop/spring-boot-quickstart-istio.git && cd spring-boot-quickstart-istio
oc new-project demo
cd greeting-service
mvn clean package fabric8:deploy -Popenshift
cd ../say-service
mvn clean package fabric8:deploy -Popenshift
sleep 15s
oc get svc/say-service -o yaml
oc rsh $(oc get pods -o jsonpath='{.items[*].metadata.name}' -l app=say-service)
curl http://localhost:8080/say
curl http://$HOSTNAME:8080/say
podIP=$(grep `hostname` /etc/hosts | awk '{print $1}')
echo $podIP
curl $podIP:8080/say
# curl http://say-service.demo.svc.cluster.local:8080/say
curl http://greeting-service.demo.svc.cluster.local:8080/greeting
popd
```




