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

- Grant access for the `Say` application to access the platform as a Kubernetes Client and get info about the environment. 
  So, assign the view access role to the `default` service account.
  This [service account](https://docs.openshift.com/container-platform/3.6/dev_guide/service_accounts.html) provides a flexible way
  to control API access without sharing a regular user’s credentials. It is mounted within the `Say` pod when it is created.
  It corresponds to a token which is permanent.
                                                                                                            
```bash
oc policy add-role-to-user view -n $(oc project -q) -z default
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


