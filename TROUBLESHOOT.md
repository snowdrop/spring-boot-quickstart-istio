# Troubleshoot

   * [How to question the Envoy Proxy](#how-to-question-the-envoy-proxy)
   * [Tell me if my route is well registered under RDS](#tell-me-if-my-route-is-well-registered-under-rds)
   * [Is my route part of en Envoy Cluster ?](#is-my-route-part-of-en-envoy-cluster-)
   * [Envoy /routes endpoint is not there ?](#envoy-routes-endpoint-is-not-there-)

## How to question the Envoy Proxy

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

## Tell me if my route is well registered under RDS

If the routes about the services are well added within the Envoy Routes Discovery repository, then you should be able to see an entry when you issue
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

## Is my route part of en Envoy Cluster ?

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
podName=$(oc get pods -o jsonpath='{.items[*].metadata.name}' -l app=say-service)
oc exec $podName -c spring-boot curl http://localhost:8080/say                
{"id":2,"content":"Hello, World!"}                    
```

## Envoy /routes endpoint is not there ?

/routes should be there when you `curl http://localhost:15000/routes` the admin endpoint of the proxy.

According to the [Envoy RDS doc](https://www.envoyproxy.io/docs/envoy/latest/operations/admin.html#get--routes?route_config_name=-name-)
"This endpoint is only available if envoy has HTTP routes configured via RDS."

So, if the /routes endpointis missing, then that means that Envoy proxy for some reason is not configured with RDS (it should be).

To check envoy's configuration, run:

```bash
podName=$(oc get pods -o jsonpath='{.items[*].metadata.name}' -l app=say-service)
oc exec -it $podName -c istio-proxy -- ls /etc/istio/proxy
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





