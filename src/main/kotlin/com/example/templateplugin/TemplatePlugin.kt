package com.example.templateplugin

/**
 * Main plugin class.
 * 
 * TODO: Implement your plugin logic here.
 * 
 * @author YourName
 * @version 1.0.0
 */
class TemplatePlugin {
    companion object {
        /**
         * Get plugin instance.
         */
        lateinit var instance: TemplatePlugin
            private set
    }

    /**
     * Constructor - Called when plugin is loaded.
     */
    init {
        instance = this
        println("[TemplatePlugin] Plugin loaded!")
    }

    /**
     * Called when plugin is enabled.
     */
    fun onEnable() {
        println("[TemplatePlugin] Plugin enabled!")


        // TODO: Initialize your plugin here
        // - Load configuration
        // - Register event listeners
        // - Register commands
        // - Start services
    }

    /**
     * Called when plugin is disabled.
     */
    fun onDisable() {
        println("[TemplatePlugin] Plugin disabled!")


        // TODO: Cleanup your plugin here
        // - Save data
        // - Stop services
        // - Close connections
    }
}
