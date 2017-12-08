# Instructions to install all in one

```bash
minishift stop
minishift delete --force  
minishift --profile demo config set image-caching true
minishift --profile demo config set memory 3GB
minishift --profile demo config set openshift-version v3.7.0
minishift --profile demo config set vm-driver xhyve
minishift --profile demo addon enable admin-user
minishift start --profile demo
oc login -u admin -p admin
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

## With Istio

```
pushd $(mktemp -d)
git clone git@github.com:snowdrop/istio-integration.git

# Install istio distro and platform
ansible-playbook istio-integration/ansible/main.yml -t install-istio

git clone git@github.com:snowdrop/spring-boot-quickstart-istio.git && cd spring-boot-quickstart-istio
oc new-project demo-istio
oc adm policy add-scc-to-user privileged -z default -n demo-istio

cd greeting-service
mvn clean package fabric8:deploy -Pistio-openshift -Dfabric8.resourceDir=src/main/istio

cd ../say-service
mvn clean package fabric8:deploy -Pistio-openshift -Dfabric8.resourceDir=src/main/istio
sleep 30s
oc expose svc istio-ingress -n istio-system

export SAY_URL=$(minishift openshift service istio-ingress -n istio-system --url)/say
http -v $SAY_URL

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


