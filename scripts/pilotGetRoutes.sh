
#
# Prereq : install httpie tool
# Pilot is exposed behind an OpenShift route -> oc expose istio-pilot -n istio-system
# Model : https://github.com/istio/istio/blob/master/pilot/proxy/context.go
# syntax : ./scripts/pilotGetRoutes.sh [service-name] [port] [namespace]
#

service=$1
port=$2
namespace=$3

pilotURL=$(minishift openshift service istio-pilot --url)
podName=$(oc get pods -o jsonpath='{.items[*].metadata.name}' -l app=$service)
podIP=$(oc get pods -o jsonpath='{.items[*].metadata.name}' -l app=$service -o jsonpath='{.items[*].status.podIP}')

http -v $pilotURL/v1/routes/$port/$service/sidecar~$ip~$podName.$namespace~$namespace.svc.cluster.local