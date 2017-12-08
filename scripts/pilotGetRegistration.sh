#
# Get from the Istio Pilot the Registration
#
# Prereq :
# - httpie tool : https://httpie.org/
# - Minishift : https://docs.openshift.org/latest/minishift/getting-started/installing.html
# - Istio is installed under istio-system namespace
# - Pilot is exposed behind an OpenShift route : oc expose svc istio-pilot -n istio-system
#
# Info about Model to be used to build the request: https://github.com/istio/istio/blob/master/pilot/proxy/context.go
#
# Command syntax : ./scripts/pilotGetRegistration.sh
#
# E.g : ./scripts/pilotGetRegistration.sh
#

pilotURL=$(minishift openshift service istio-pilot --url)

http -v $pilotURL/v1/registration