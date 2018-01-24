#! /bin/sh

export GATEWAY_URL=$(oc get po -l istio=ingress -n istio-system -o 'jsonpath={.items[0].status.hostIP}'):$(oc get svc istio-ingress -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')
while [ $(curl --write-out %{http_code} --silent --output /dev/null http://${GATEWAY_URL}/productpage) != 200 ]
   do
     echo "Wait till we get http response 200 .... from http://${GATEWAY_URL}/productpage"
     sleep 30
  done
echo "SUCCESSFULLY TESTED : Service replied"

