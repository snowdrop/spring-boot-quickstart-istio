# Instructions to play with Quickstart 

## Locally

- Greeting Service
```bash
cd greeting-service
mvn clean compile && mvn spring-boot:run
```

- Say Service
```bash
cd say-service
mvn clean package
java -jar target/say-service-1.0-SNAPSHOT.jar Charles
or 
java -jar target/say-service-1.0-SNAPSHOT.jar
or 
mvn compile spring-boot:run
```

## Using Minishift

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

cd greeting-service
mvn fabric8:deploy -Popenshift
```
