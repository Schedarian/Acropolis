group = "schematic.mindustry"
version = "1.0.1"

plugins {
    id("java")
    id("com.github.johnrengelman.shadow") version "8.1.1"
}

repositories {
    mavenCentral()
    maven(url = "https://jitpack.io")
}

dependencies {
    implementation("net.dv8tion:JDA:5.0.0-beta.8")
    implementation("com.github.artbits:quickio:1.3.2")
    implementation("org.apache.logging.log4j:log4j-slf4j-impl:2.20.0")
    implementation("com.google.code.gson:gson:2.10.1")
    implementation("com.github.Anuken.Arc:arc-core:143.1")
    implementation("com.github.Anuken.MindustryJitpack:core:143.1")
}

tasks.withType<JavaCompile> {
    options.encoding = "UTF-8"

    sourceCompatibility = "16"
    targetCompatibility = "16"
}

tasks.jar {
    manifest {
        attributes["Main-Class"] = "schematic.mindustry.api.Main"
    }

    archiveFileName.set("MindustryAPI.jar")
    from(configurations.runtimeClasspath.get().map { if (it.isDirectory) it else zipTree(it) })
    duplicatesStrategy = DuplicatesStrategy.INCLUDE
}

tasks.shadowJar {
    archiveFileName.set("MindustryBotShadow.jar")
    isEnableRelocation = true
    relocationPrefix = "shadow"
    minimize()
}
