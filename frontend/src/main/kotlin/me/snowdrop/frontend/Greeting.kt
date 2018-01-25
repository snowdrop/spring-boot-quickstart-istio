package me.snowdrop.frontend

data class Greeting(val id: Long?, val content: String?)  {

    /**
     * This constructor is an explicit empty constructor
     * Simplest solution to get Jackson working
     */
    constructor() : this(0, "")

}