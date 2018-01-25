package me.snowdrop.frontend

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.ResponseBody
import org.springframework.web.client.RestTemplate
import java.net.URI


/**
 * @author <a href="claprun@redhat.com">Christophe Laprun</a>
 */
@Controller
class MainPageController(private val restTemplate: RestTemplate,
                         private val sayServiceProperties: SayServiceProperties) {


    @GetMapping("/")
    fun main() = "index"

    @ResponseBody
    @GetMapping("/say")
    fun say(@RequestParam("name", required = false) name: String?) =
            restTemplate.getForObject(URI.create(sayServiceProperties.getURI(name)), Greeting::class.java)
}