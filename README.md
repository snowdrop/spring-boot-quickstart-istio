# Instructions to play with Quickstart 

- Service
```bash
cd rest-service
mvn clean compile && mvn spring-boot:run
```

- Client
```bash
cd consuming-rest
mvn clean package
java -jar target/consuming-rest-1.0-SNAPSHOT.jar Charles
or 
java -jar target/consuming-rest-1.0-SNAPSHOT.jar
```