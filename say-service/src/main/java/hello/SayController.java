package hello;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URLEncoder;

@RestController
public class SayController {

    private static Logger log = LoggerFactory.getLogger(SayController.class);

    @Value("${service.greeting.name}")
    private String greetingServiceName;

    @Value("${service.greeting.path}")
    private String greetingServicePath;

    @Autowired
    private RestTemplate restTemplate;

    @RequestMapping("/say")
    public Greeting greeting(@RequestParam(value = "name", defaultValue = "") String name)
            throws UnsupportedEncodingException {

        log.info("URL : " + getURI(name));
        log.info("Service : " + greetingServiceName);
        return restTemplate.getForObject(getURI(name), Greeting.class);
    }

    private URI getURI(String name) throws UnsupportedEncodingException {
        StringBuilder builder = new StringBuilder("http://");
        builder.append(greetingServiceName);
        builder.append(greetingServicePath);
        if(!name.isEmpty()) {
            builder.append("?name=");
            builder.append(URLEncoder.encode(name, "UTF-8"));
        }
        return URI.create(builder.toString());
    }
}
