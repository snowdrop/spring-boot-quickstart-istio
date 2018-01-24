package me.snowdrop.frontend

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication
class FrontendApplication

fun main(args: Array<String>) {
    SpringApplication.run(FrontendApplication::class.java, *args)
}
