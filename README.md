# Instructions to play with Quickstart 

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

## Deploy Services on OpenShift

- Start a Minishift VM on MacOS using Xhyve hypervisor
```bash
minishift --profile istio-demo config set image-caching true
minishift --profile istio-demo config set memory #GB
minishift --profile istio-demo config set memory 3GB
minishift --profile istio-demo config set openshift-version v3.7.0-rc.0
minishift --profile istio-demo config set vm-driver xhyve
minishift --profile istio-demo addon enable admin-user
minishift start --profile istio-demo
```

- Log to openshift and creatde a ``demo`` project
```bash
oc login $(minishift ip):8443 -u admin -p admin
oc new-project demo
```

- Deploy the 2 Services
```bash
cd greeting-service
mvn fabric8:deploy -Popenshift

cd say-service
mvn fabric8:deploy -Popenshift
```
- Call the `Say` service
```bash
SAY_SERVICE=$(minishift openshift service --url say-service)
http $SAY_SERVICE/say
```

## Istio and Hello World

- Install istio using ansible script

- Test the `HelloWorld` example provided by istio distro. So, move to the istio distro folder
```bash
cd /Users/dabou/Code/istio/installation/istio-0.2.12/samples/helloworld
```

- Within your terminal execute this command to add the Istio Envoy Proxy within the HelloWorld Deployment Config
```bash

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: helloworld-v1
  annotations: 
    sidecar.istio.io/status: injected-version-releng@0d29a2c0d15f-0.2.12-998e0e00d375688bcb2af042fc81a60ce5264009  # ADDED
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: helloworld
        version: v1
      annotations:
        sidecar.istio.io/status: injected-version-releng@0d29a2c0d15f-0.2.12-998e0e00d375688bcb2af042fc81a60ce5264009  # ADDED      
    spec:
      containers:
      - name: helloworld
        image: istio/examples-helloworld-v1
        resources:
          requests:
            cpu: "100m"
        imagePullPolicy: IfNotPresent #Always
        ports:
        - containerPort: 5000
      # LINES ADDED HEREAFTER
      - args:
          - proxy
          - sidecar
          - -v
          - "2"
          - --configPath
          - /etc/istio/proxy
          - --binaryPath
          - /usr/local/bin/envoy
          - --serviceCluster
          - helloworld
          - --drainDuration
          - 45s
          - --parentShutdownDuration
          - 1m0s
          - --discoveryAddress
          - istio-pilot.istio-system:8080
          - --discoveryRefreshDelay
          - 1s
          - --zipkinAddress
          - zipkin.istio-system:9411
          - --connectTimeout
          - 10s
          - --statsdUdpAddress
          - istio-mixer.istio-system:9125
          - --proxyAdminPort
          - "15000"
          env:
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: INSTANCE_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          image: docker.io/istio/proxy_debug:0.2.12
          imagePullPolicy: IfNotPresent
          name: istio-proxy
          resources: {}
          securityContext:
            privileged: true
            readOnlyRootFilesystem: false
            runAsUser: 1337
          volumeMounts:
          - mountPath: /etc/istio/proxy
            name: istio-envoy
          - mountPath: /etc/certs/
            name: istio-certs
            readOnly: true
        initContainers:
        - args:
          - -p
          - "15001"
          - -u
          - "1337"
          image: docker.io/istio/proxy_init:0.2.12
          imagePullPolicy: IfNotPresent
          name: istio-init
          resources: {}
          securityContext:
            capabilities:
              add:
              - NET_ADMIN
            privileged: true
        - args:
          - -c
          - sysctl -w kernel.core_pattern=/etc/istio/proxy/core.%e.%p.%t && ulimit -c
            unlimited
          command:
          - /bin/sh
          image: alpine
          imagePullPolicy: IfNotPresent
          name: enable-core-dump
          resources: {}
          securityContext:
            privileged: true
        volumes:
        - emptyDir:
            medium: Memory
            sizeLimit: "0"
          name: istio-envoy
        - name: istio-certs
          secret:
            optional: true
            secretName: istio.default  
        

istioctl kube-inject -f helloworld.yaml -o helloworld-istio.yaml -v 10

I1128 10:18:13.017004   37614 loader.go:357] Config loaded from file /Users/dabou/.kube/config
I1128 10:18:13.029889   37614 loader.go:357] Config loaded from file /Users/dabou/.kube/config
I1128 10:18:13.031626   37614 round_trippers.go:386] curl -k -v -XGET  -H "Authorization: Bearer QXj8DdWfQ1Svlqe0W4kQ5P1vZXfGKNFt8cOWkMRDUKQ" -H "Accept: application/json, */*" -H "User-Agent: istioctl/v0.0.0 (darwin/amd64) kubernetes/$Format" https://192.168.64.24:8443/api/v1/namespaces/istio-system/configmaps/istio
I1128 10:18:13.046563   37614 round_trippers.go:405] GET https://192.168.64.24:8443/api/v1/namespaces/istio-system/configmaps/istio 200 OK in 14 milliseconds
I1128 10:18:13.046587   37614 round_trippers.go:411] Response Headers:
I1128 10:18:13.046595   37614 round_trippers.go:414]     Date: Tue, 28 Nov 2017 09:17:12 GMT
I1128 10:18:13.046600   37614 round_trippers.go:414]     Cache-Control: no-store
I1128 10:18:13.046605   37614 round_trippers.go:414]     Content-Type: application/json
I1128 10:18:13.046610   37614 round_trippers.go:414]     Content-Length: 2662
I1128 10:18:13.046660   37614 request.go:811] Response Body: {"kind":"ConfigMap","apiVersion":"v1","metadata":{"name":"istio","namespace":"istio-system","selfLink":"/api/v1/namespaces/istio-system/configmaps/istio","uid":"0df54d57-d41a-11e7-8655-f604c9552360","resourceVersion":"34004","creationTimestamp":"2017-11-28T08:56:42Z"},"data":{"mesh":"# Uncomment the following line to enable mutual TLS between proxies\n# authPolicy: MUTUAL_TLS\n#\n# Set the following variable to true to disable policy checks by the Mixer.\n# Note that metrics will still be reported to the Mixer.\ndisablePolicyChecks: false\n# Set enableTracing to false to disable request tracing.\nenableTracing: true\n#\n# To disable the mixer completely (including metrics), comment out\n# the following line\nmixerAddress: istio-mixer.istio-system:9091\n# This is the ingress service name, update if you used a different name\ningressService: istio-ingress\negressProxyAddress: istio-egress.istio-system:80\n#\n# Along with discoveryRefreshDelay, this setting determines how\n# frequently should Envoy fetch and update its internal configuration\n# from Istio Pilot. Lower refresh delay results in higher CPU\n# utilization and potential performance loss in exchange for faster\n# convergence. Tweak this value according to your setup.\nrdsRefreshDelay: 1s\n#\ndefaultConfig:\n  # See rdsRefreshDelay for explanation about this setting.\n  discoveryRefreshDelay: 1s\n  #\n  # TCP connection timeout between Envoy \u0026 the application, and between Envoys.\n  connectTimeout: 10s\n  #\n  ### ADVANCED SETTINGS #############\n  # Where should envoy's configuration be stored in the istio-proxy container\n  configPath: \"/etc/istio/proxy\"\n  binaryPath: \"/usr/local/bin/envoy\"\n  # The pseudo service name used for Envoy.\n  serviceCluster: istio-proxy\n  # These settings that determine how long an old Envoy\n  # process should be kept alive after an occasional reload.\n  drainDuration: 45s\n  parentShutdownDuration: 1m0s\n  #\n  # Port where Envoy listens (on local host) for admin commands\n  # You can exec into the istio-proxy container in a pod and\n  # curl the admin port (curl http://localhost:15000/) to obtain\n  # diagnostic information from Envoy. See\n  # https://lyft.github.io/envoy/docs/operations/admin.html\n  # for more details\n  proxyAdminPort: 15000\n  #\n  # Address where Istio Pilot service is running\n  discoveryAddress: istio-pilot.istio-system:8080\n  #\n  # Zipkin trace collector\n  zipkinAddress: zipkin.istio-system:9411\n  #\n  # Statsd metrics collector. Istio mixer exposes a UDP endpoint\n  # to collect and convert statsd metrics into Prometheus metrics.\n  statsdUdpAddress: istio-mixer.istio-system:9125"}}
I1128 10:18:13.054968   37614 inject.go:302] Sidecar injection policy for /helloworld-v1: namespacePolicy:enabled useDefault:true inject:false status:"" required:true
```

- Now create the deployment using the updated yaml file.
```bash
oc create -f helloworld-istio.yaml                                    
service "helloworld" created
deployment "helloworld-v1" created
deployment "helloworld-v2" created
ingress "helloworld" created
```
- Get the ingress URL and confirm it's running using curl.

```bash
export HELLOWORLD_URL=$(oc get po -l istio=ingress -o 'jsonpath={.items[0].status.hostIP}'):$(oc get svc istio-ingress -o 'jsonpath={.spec.ports[0].nodePort}')
curl http://$HELLOWORLD_URL/hello
Hello version: v2, instance: helloworld-v2-1481045861-qb2ls

```

## Istio and Say Service

- Create Say Ingress route under the `istio-system` namespace
```bash
istioctl create -f src/main/fabric8/ingress.yaml -v 10
```

