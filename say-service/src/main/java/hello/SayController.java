package hello;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.net.URI;

@RestController
public class SayController {

    private static Logger log = LoggerFactory.getLogger(SayController.class);

    @Value("${service.greeting.name}")
    private String greetingServiceName;

    @Value("${service.greeting.path}")
    private String greetingServicePath;

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    @RequestMapping("/say")
    public Greeting greeting() {
        log.info("URL : " + getURI());
        log.info("Service : " + greetingServiceName);
        return restTemplate().getForObject(getURI(), Greeting.class);
    }

    private URI getURI() {
        StringBuilder builder = new StringBuilder("http://");
        builder.append(greetingServiceName);
        builder.append(greetingServicePath);
        return URI.create(builder.toString());
    }
}
