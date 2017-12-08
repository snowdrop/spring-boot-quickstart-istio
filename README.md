Table of Contents
=================

   * [Instructions to play with Say and Greeting Spring Boot Microservices](#instructions-to-play-with-say-and-greeting-spring-boot-microservices)
      * [Locally](#locally)
      * [Deploy the 2 Microservices on OpenShift](#deploy-the-2-microservices-on-openshift)
      * [Istio and Say plus Greeting Microservices](#istio-and-say-plus-greeting-microservices)
         * [Instructions](#instructions)
   * [Troubleshoot](#troubleshoot)

# Instructions to play with Say and Greeting Spring Boot Microservices 

This Quickstart contains 2 Spring Boot applications where the REST `Say` service calls the REST `Greeting` service. 
The project can be used locally and launched using Spring Boot Maven plugin or deployed on OpenShift.

To support multiple environments, 2 maven profiles have been defined and will be used to pass the endpoint of the greeting service
within the `application.yaml` file. The `development` profile is used when the application is launched locally using Spring Boot Maven plugin
while the `Openshift` profile will be used when the `Say` application is running on OpenShift. 

## Locally

- Greeting Service
```bash
cd greeting-service
mvn clean compile && mvn spring-boot:run
```

- Say Service
```bash
cd say-service
mvn compile spring-boot:run
```

- Call the service
```bash
http http://localhost:8090/say
HTTP/1.1 200 
Content-Type: application/json;charset=UTF-8
Date: Thu, 23 Nov 2017 05:42:31 GMT
Transfer-Encoding: chunked

{
    "content": "Hello, World!",
    "id": 1
}
```

## Deploy the 2 Microservices on OpenShift

- Start a Minishift VM on MacOS using Xhyve hypervisor
```bash
minishift --profile istio-demo config set image-caching true
minishift --profile istio-demo config set memory 3GB
minishift --profile istio-demo config set openshift-version v3.7.0
minishift --profile istio-demo config set vm-driver xhyve
minishift --profile istio-demo addon enable admin-user
minishift start --profile istio-demo
```

- Log to Openshift and create a `demo` project
```bash
oc login $(minishift ip):8443 -u admin -p admin
oc new-project demo
```

- Deploy the 2 Services
```bash
cd greeting-service
mvn clean fabric8:deploy -Popenshift

cd say-service
mvn clean fabric8:deploy -Popenshift
```
- Call the `Say` service
```bash
SAY_SERVICE=$(minishift openshift service --url say-service)
http $SAY_SERVICE/say
```

## Istio and Say plus Greeting Microservices

The following instructions will let you to install 2 Spring Boot applications, top of the Istio Site mesh where the `Say Service` is calling the
 `Greeting service` to get as response `Hello World`.

When, an external HTTP client will consume the service using either `curl` or `httpie` tools, then the HTTP request will be propagated as such :

_HTTP Client -> issue http request to call the `http://say-service/say` endpoint exposed by the Istio Ingress Proxy -> Route and address of the Say Service is resolved 
-> request forwarded to the Envoy Proxy -> Pass HTTP Request to Say Service running within the pod -> Call the `http://greeting-service/greeting` service running within another pod -> Populate response which is returned_

To allow to inject the Envoy Proxy and initialize correctly the pod to route all the internal traffic
to ththe Envoyis Proxy, we will use the Fabric8 Maven Plugin using a new Enricher module called `istio-enricher`.

Remarks: 

- This code has been tested against Istio 0.2.12. 
- Due to a [bug](https://github.com/istio/istio/issues/2031) discovered with istio 0.3.0, we don't recommend to install it till it is resolved.
- By adopting this enricher, then it is not longer required to use istioctl client !

### Instructions 

Follow these instructions to play with Istio and the `Say` service

1. Install the istio binary distribution locally according to these [instructions](https://github.com/snowdrop/istio-integration/blob/master/README-ANSIBLE.md#download-and-install-istio-distribution) using Ansible 2.4
  . The distro of istio contains the `istioctl` client but also the yaml resources files to be used to install it on OpenShift
2.  Next, deploy the istio platform on Minishift using this [ansible playbook](https://github.com/snowdrop/istio-integration/blob/master/README-ANSIBLE.md#deploy-istio-on-openshift) 

3. Get the Fabric8 Maven `istio-enricher` enricher and compile it locally
```bash
git clone git@github.com:snowdrop/fmp-istio-enricher.git
cd fmp-istio-enricher
mvn install
```

4. Create a new Openshift namespace `demo-istio`. Add to the `default` serviceaccount user, used to authenticate the pod with Openshift, the `privileged` security constraint.

```bash
oc new-project demo-istio
oc adm policy add-scc-to-user privileged -z default -n demo-istio
```

5. Deploy the Greeting service 
```bash
cd greeting-service
mvn clean package fabric8:deploy -Pistio-openshift -Dfabric8.resourceDir=src/main/istio
```

6. Install the Say service
```bash
cd say-service
mvn clean package fabric8:deploy -Pistio-openshift -Dfabric8.resourceDir=src/main/istio
```

7. Access the `Say` service using the Istio Ingress/Proxy

In order to access the service, it is required first to expose the Istio Ingress proxy behind a route that Openshift can route from your localhost machine.
Then, execute this command
```bash
oc expose svc istio-ingress -n istio-system
```

Next, you will be able to access the service using the address of the service exposed by the Ingress Proxy

```bash
export SAY_URL=$(minishift openshift service istio-ingress -n istio-system --url)/say
curl $SAY_URL

or 

http -v $SAY_URL
GET /say HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Host: istio-ingress-istio-system.192.168.64.26.nip.io
User-Agent: HTTPie/0.9.9



HTTP/1.1 200 OK
Cache-control: private
Set-Cookie: 144852ee66f5cb84d6e58f9bcce52825=d8dd521a887ff43f55e011dcd3d9caec; path=/; HttpOnly
content-type: application/json;charset=UTF-8
date: Wed, 06 Dec 2017 12:51:38 GMT
server: envoy
transfer-encoding: chunked
x-envoy-upstream-service-time: 63

{
    "content": "Hello, World!",
    "id": 6
}

```

Enjoy this first **Istio** and **Spring Boot** Developer Experience !!

# Troubleshoot

Let's ask the local envoy proxy what it knows about its listeners, routes, clusters, and info (remember it got : this from xDS from Pilot?)

```bash
oc get pods
NAME                           READY     STATUS      RESTARTS   AGE
greeting-service-3-2scr7       2/2       Running     0          49m
say-service-3-lrkh8            2/2       Running     0          49m

oc rsh -c istio-proxy say-service-3-lrkh8

(proxy)$ curl localhost:15000
(proxy)$ curl localhost:15000/listeners
(proxy)$ curl localhost:15000/clusters
(proxy)$ curl localhost:15000/server_info
(proxy)$ curl localhost:15000/stats
(proxy)$ curl localhost:15000/routes
```

You can also execute the curl request without doing a rsh and using the `oc exec` command

```bash
podName=$(oc get pods -o jsonpath='{.items[*].metadata.name}' -l app=say-service)
oc exec $podName -c spring-boot curl http://localhost:15000/routes
oc exec $podName -c spring-boot curl http://localhost:15000/clusters
oc exec $podName -c spring-boot curl http://localhost:15000/listeners
```

If the routes about the services are well added within the Envoy Routes Discovery repository, then you should be able to see this entry when you issue
the command `curl http://localhost:15000/routes | grep [service-name]` where `[service-name]` corresponds to one of the service installed  

```bash
oc exec $podName -c spring-boot curl http://localhost:15000/routes | grep greeting-service
...
```

The pretty printed json format returned for a service contains for a name, the virtual hosts associated. The virtual host definition will let
Envoy to understand how traffic can pass. So, as you can see, you have a virtual domain defined for the `greeting-service`.
Envoy will catch any request that arrives to it with HOST header equal `greeting-service:8080` and will direct it to the 
`out.63122066cf2af786d555e101d51237c3d5e00da4` according to the prefix whic is `/` 

Remark : since istio 0.3, the cluster route name corresponds to a human readible containing also the protocol
Example : `cluster: out.greeting-service.demo-istio.svc.cluster.local|http.`

```json
 
"route_table_dump"
{
  "name": "8080",
  "virtual_hosts": [
    {
      "name": "greeting-service.demo-istio.svc.cluster.local|http",
      "domains": [
        "greeting-service:8080",
        "greeting-service",
        "greeting-service.demo-istio:8080",
        "greeting-service.demo-istio",
        "greeting-service.demo-istio.svc:8080",
        "greeting-service.demo-istio.svc",
        "greeting-service.demo-istio.svc.cluster:8080",
        "greeting-service.demo-istio.svc.cluster",
        "greeting-service.demo-istio.svc.cluster.local:8080",
        "greeting-service.demo-istio.svc.cluster.local",
        "172.30.2.64:8080",
        "172.30.2.64"
      ],
      "routes": [
        {
          "match": {
            "prefix": "/"
          },
          "route": {
            "cluster": "out.63122066cf2af786d555e101d51237c3d5e00da4"
          }
        }
      ]
    }
    ...
  ]
```

To verify that the route is well registered and match the pod of service, then you will query the clusters info
and filter the result according to its cluster id

```bash
oc exec $podName -c spring-boot curl http://localhost:15000/clusters | grep 63122066cf2af786d555e101d51237c3d5e00da4
```

Then you should be able to verify the podIP address used

```
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::cx_active::1
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::cx_connect_fail::0
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::cx_total::1
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::rq_active::0
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::rq_timeout::0
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::rq_total::1
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::health_flags::healthy
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::weight::1
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::zone::
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::canary::false
out.63122066cf2af786d555e101d51237c3d5e00da4::172.17.0.13:8080::success_rate::-1
```

With the ip address of the pod, then you can verify first that it beloings to our service
and next issue a curl request to question the HTTP Endpoint

1. Get the Pod IP Address
```bash
oc get pods -o jsonpath='{.items[*].status.podIP}' -l app=say-service
172.17.0.14                                               
```

2. Issue a curl HTTP Query
```bash
podName=$(oc get pods -o jsonpath='{.items[*].matedate.name}' -l app=say-service)
oc exec $podName -c spring-boot curl http://localhost:8080/say                
{"id":2,"content":"Hello, World!"}                    
```

## /routes endpoint is not there

/routes should be there when you `curl http://localhost:15000/routes` the admin endpoint of the proxy.

According to the [Envoy RDS doc](https://www.envoyproxy.io/docs/envoy/latest/operations/admin.html#get--routes?route_config_name=-name-)
"This endpoint is only available if envoy has HTTP routes configured via RDS."

So, if the /routes endpointis missing, then that means that Envoy proxy for some reason is not configured with RDS (it should be).

To check envoy's configuration, run:

```bash
oc exec -it <your pod> -c istio-proxy -- ls /etc/istio/proxy
```

The output will be, for example: envoy-rev0.json
And then cat this envoy configuration:

```bash
oc exec -it <your pod> -c istio-proxy -- cat /etc/istio/proxy/envoy-rev0.json
```

You should check if there is RDS cluster defined:

```
 "cluster_manager": {
    "clusters": [
      {
        "name": "rds",
        "connect_timeout_ms": 10000,
        "type": "strict_dns",
        "lb_type": "round_robin",
        "hosts": [
          {

            "url": "tcp://istio-pilot.istio-system:15003"

          }
        ]
      },
```





