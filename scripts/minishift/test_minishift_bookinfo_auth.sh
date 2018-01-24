#! /bin/sh

AUTH_POLICY=$(oc get configmap istio -o yaml -n istio-system | grep authPolicy | head -1)

echo "The auth policy should be 'MUTUAL_TLS'. The result is\n ${AUTH_POLICY}"

#Loop while the app is being started
while ! oc get pods -l app=productpage -n bookinfo | grep Running > /dev/null; do sleep 10; done
while ! oc get pods -l app=details -n bookinfo  | grep Running > /dev/null; do sleep 10; done

POD_NAME=$(oc get pods -l app=productpage -n bookinfo -o 'jsonpath={.items[0].metadata.name}')

echo "\nThe istio-proxy container should contain the following: cert-chain.pem   key.pem   root-cert.pem"
oc exec ${POD_NAME} -n bookinfo -c istio-proxy -- ls /etc/certs/

echo "\nExecuting an HTTP request to the details service should result in a 200 status code"
oc exec ${POD_NAME} -n bookinfo -c istio-proxy -- curl https://details:9080/details/0  -o /dev/null -s -w '%{http_code}\n' --key /etc/certs/key.pem --cert /etc/certs/cert-chain.pem --cacert /etc/certs/root-cert.pem -k

