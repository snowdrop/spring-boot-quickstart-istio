package hello;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.Banner;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.core.Is.is;

@SpringBootApplication
public class Application implements CommandLineRunner {

	private static final Logger log = LoggerFactory.getLogger(Application.class);
	private static final String serviceName = "localhost";
	private static final String serviceURL = "http://" + serviceName + ":8080/greeting";

	public static void main(String args[]) {
		SpringApplication app = new SpringApplication(Application.class);
		app.run(args);
	}

	@Override
	public void run(String... args) throws Exception {
		Greeting response;
		RestTemplate restTemplate = new RestTemplate();
		if (args.length > 0) {
			response = restTemplate.getForObject(serviceURL + "?name=" + args[0], Greeting.class);
		} else {
			response = restTemplate.getForObject(serviceURL, Greeting.class);
		}
		log.info("### Service replied : " + response.getContent() + " ###");
		assertThat(response.getContent(),is(notNullValue()));
	}
}