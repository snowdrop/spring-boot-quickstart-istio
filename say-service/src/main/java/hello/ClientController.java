package hello;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.util.concurrent.atomic.AtomicLong;

@RestController
public class ClientController {

    private static final Logger log = LoggerFactory.getLogger(Application.class);
    private final AtomicLong counter = new AtomicLong();

    @RequestMapping("/say")
    public Greeting greeting() {
        RestTemplate restTemplate = new RestTemplate();
        return restTemplate.getForObject("http://rest-service/greeting", Greeting.class);
    }
}
