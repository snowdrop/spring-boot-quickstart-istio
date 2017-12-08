#
# Get from the Istio Pilot the Clusters registered
#
# Prereq :
# - httpie tool : https://httpie.org/
# - Minishift : https://docs.openshift.org/latest/minishift/getting-started/installing.html
# - Istio is installed under istio-system namespace
# - Pilot is exposed behind an OpenShift route : oc expose svc istio-pilot -n istio-system
#
# Info about Model to be used to build the request: https://github.com/istio/istio/blob/master/pilot/proxy/context.go
#
# Command syntax : ./scripts/pilotGetClusters.sh [service-name] [namespace]
#
# E.g : ./scripts/pilotGetClusters.sh greeting-service demo-istio
#

service=$1
namespace=$2

pilotURL=$(minishift openshift service istio-pilot --url)
podName=$(oc get pods -o jsonpath='{.items[*].metadata.name}' -l app=$service)
podIP=$(oc get pods -o jsonpath='{.items[*].metadata.name}' -l app=$service -o jsonpath='{.items[*].status.podIP}')

http -v $pilotURL/v1/clusters/$service/sidecar~$ip~$podName.$namespace~$namespace.svc.cluster.local