plugins {
    id("java-library")
    id("com.gradleup.shadow") version "9.3.1"
    id("run-hytale")
    kotlin("jvm") version "2.3.0"
    kotlin("plugin.serialization") version "2.3.0"
    id("org.jetbrains.kotlin.plugin.power-assert") version "2.3.0"
    id("io.kotest") version "6.0.7"
}

group = findProperty("pluginGroup") as String? ?: "com.example"
version = findProperty("pluginVersion") as String? ?: "1.0.0"
description = findProperty("pluginDescription") as String? ?: "A Hytale plugin template"

repositories {
    mavenLocal()
    mavenCentral()
}

dependencies {
    // Hytale Server API (provided by server at runtime)
    compileOnly(files("libs/hytale-server.jar"))
    
    // Common dependencies (will be bundled in JAR)
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.9.0")
    // Optional: uncomment if you are not familiar with kotlinx.serialization
    // implementation("com.google.code.gson:gson:2.10.1")

    // Optional: coroutine for async
    // implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.10.2")
    
    // Test dependencies
    testImplementation(kotlin("test"))
    testImplementation("io.kotest:kotest-runner-junit5:6.0.7")
    // Optional: uncomment if you like JUnit rather than Kotest
    // testImplementation("org.junit.jupiter:junit-jupiter:5.10.0")
    // testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks {
    // Configure Java compilation
    compileJava {
        options.encoding = Charsets.UTF_8.name()
        options.release = 25
    }
    
    // Configure resource processing
    processResources {
        filteringCharset = Charsets.UTF_8.name()
        
        // Replace placeholders in manifest.json
        val props = mapOf(
            "group" to project.group,
            "version" to project.version,
            "description" to project.description
        )
        inputs.properties(props)
        
        filesMatching("manifest.json") {
            expand(props)
        }
    }
    
    // Configure ShadowJar (bundle dependencies)
    shadowJar {
        archiveBaseName.set(rootProject.name)
        archiveClassifier.set("")
        
        // Relocate dependencies to avoid conflicts
        relocate("com.google.gson", "${group}.libs.gson")
        relocate("kotlin", "${group}.libs.kotlin") {
            exclude("kotlinx.*")
        }
        relocate("kotlinx", "${group}.libs.kotlinx")

        // Minimize JAR size (removes unused classes)
        minimize()
    }
    
    // Configure tests
    test {
        useJUnitPlatform()
    }
    
    // Make build depend on shadowJar
    build {
        dependsOn(shadowJar)
    }
}

// Configure Java toolchain
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(25))
    }
}

powerAssert {
    functions = listOf("io.kotest.matchers.shouldBe")
}