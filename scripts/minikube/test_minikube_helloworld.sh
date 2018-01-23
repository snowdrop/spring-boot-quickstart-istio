#! /bin/sh

export PATH=$PATH:~/.istio/istio-0.4.0/bin
export ISTIO_SAMPLES=~/.istio/istio-0.4.0/samples

istioctl kube-inject -f $ISTIO_SAMPLES/helloworld/helloworld.yaml -o $ISTIO_SAMPLES/helloworld/helloworld-istio.yaml
kubectl create -f $ISTIO_SAMPLES/helloworld/helloworld-istio.yaml

export HELLOWORLD_URL=$(kubectl get po -l istio=ingress -o 'jsonpath={.items[0].status.hostIP}' -n istio-system):$(kubectl get svc istio-ingress -o 'jsonpath={.spec.ports[0].nodePort}' -n istio-system)

kubectl autoscale deployment helloworld-v1 --cpu-percent=50 --min=1 --max=10
kubectl autoscale deployment helloworld-v2 --cpu-percent=50 --min=1 --max=10

kubectl get hpa
echo "Command to be replayed : curl http://$HELLOWORLD_URL/hello"
curl http://$HELLOWORLD_URL/hello