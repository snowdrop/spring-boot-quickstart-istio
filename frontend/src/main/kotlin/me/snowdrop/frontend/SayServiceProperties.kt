package me.snowdrop.frontend

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "service.say")
class SayServiceProperties {

    lateinit var name: String
    lateinit var path: String

    fun getURI(input: String?) = getBaseURI() + if (input != null) "?name=$input" else ""

    private fun getBaseURI() = "http://$name$path"
}



