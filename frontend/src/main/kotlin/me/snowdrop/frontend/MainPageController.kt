package me.snowdrop.frontend

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Value
import org.springframework.cloud.client.discovery.DiscoveryClient
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.servlet.ModelAndView


/**
 * @author <a href="claprun@redhat.com">Christophe Laprun</a>
 */
@Controller
class MainPageController {
    @Autowired
    private lateinit var discoveryClient: DiscoveryClient

    @Value("\${say-service.name:say-service}")
    private lateinit var serviceName: String

    @ResponseStatus(HttpStatus.OK)
    @RequestMapping("/")
    fun mainPage(): ModelAndView {
        val services = discoveryClient.getInstances(serviceName)

        val service = if (services.isNotEmpty()) services.first().uri.toString() else "say-service"
        println("service = $service")

        val view = ModelAndView("index")
        view.addObject("sayServiceURI", service)

        return view
    }

    /**
     * This is just a hack to be able to get the application working with Istio Ingress
     * The value of the mapping MUST be the same as the path specified in ingress.yml
     */
    @ResponseStatus(HttpStatus.OK)
    @RequestMapping("/front")
    fun front(): ModelAndView {
        return mainPage()
    }
}