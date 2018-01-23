#! /bin/sh

export PATH=$PATH:~/.istio/istio-0.4.0/bin
export ISTIO_SAMPLES=~/.istio/istio-0.4.0/samples

oc login $(minishift ip):8443 -u admin -p admin --insecure-skip-tls-verify=true
oc new-project demo-istio
oc adm policy add-scc-to-user privileged -z default -n demo-istio

istioctl kube-inject -f $ISTIO_SAMPLES/helloworld/helloworld.yaml -o $ISTIO_SAMPLES/helloworld/helloworld-istio.yaml
oc create -f $ISTIO_SAMPLES/helloworld/helloworld-istio.yaml -n demo-istio

export HELLOWORLD_URL=$(oc get pod -l istio=ingress -o 'jsonpath={.items[0].status.hostIP}' -n istio-system):$(oc get svc istio-ingress -o 'jsonpath={.spec.ports[0].nodePort}' -n istio-system)

oc autoscale deployment helloworld-v1 --cpu-percent=50 --min=1 --max=10 -n demo-istio
oc autoscale deployment helloworld-v2 --cpu-percent=50 --min=1 --max=10 -n demo-istio

echo "Command to be replayed : curl http://$HELLOWORLD_URL/hello"
curl http://$HELLOWORLD_URL/hello
