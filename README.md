Table of Contents
=================

   * [Instructions to play with Say and Greeting Spring Boot Microservices](#instructions-to-play-with-say-and-greeting-spring-boot-microservices)
      * [Locally](#locally)
      * [Deploy the 2 Microservices on OpenShift](#deploy-the-2-microservices-on-openshift)
      * [Istio and Say plus Greeting Microservices](#istio-and-say-plus-greeting-microservices)
         * [Instructions](#instructions)

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
minishift --profile istio-demo config set openshift-version v3.7.0-rc.0
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

The following instructions will let you to install 2 Spring Boot applications where the first is part of the Istio Site mesh `this is the Say Service` while the second
that we call `Greeting service` is deployed as a standalone microservice.

When, an external HTTP client will consume the service using either `curl` or `httpie` tools, then the following actions will take place :

_HTTP Client -> issue http request to call the `http://say-service/say` endpoint exposed by the Istio Ingress Proxy -> Route and address of the Say Service is resolved 
-> request forwarded to the Envoy Proxy -> Pass HTTP Request to Say Service running within the pod -> Call the `http://greeting-service/greeting` service running within another pod -> Populate response which is returned_

To allow to inject the Envoy Proxy and initialize correctly the pod to route all the internal traffic
to this Proxy, we will use the Fabric8 Maven Plugin using a new Enricher module called `istio-enricher`.

Remarks: 

- This code has been tested against Istio 0.2.12. 
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

4. Create a new Openshift namespace `demo-istio` and add the default serviceaccount, used to authenticate the pod with Openshift, with these security constraints (anyuid/privileged) required
  to let the Istio Proxy to be launched with any UID.
```bash
oc new-project demo-istio
oc adm policy add-scc-to-user anyuid -z default -n demo-istio
oc adm policy add-scc-to-user privileged -z default -n demo-istio
```

5. Deploy the Greeting service 
```bash
cd greeting-service
mvn clean package fabric8:deploy -Popenshift
```

6. Install the Say service part of the Service Mesh
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

