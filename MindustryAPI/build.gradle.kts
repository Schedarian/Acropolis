group = "schematic.mindustry"
version = "1.0.0"

plugins {
    id("java")
}

repositories {
    mavenCentral()
    maven(url = "https://jitpack.io")
}

dependencies {
    implementation("org.nanohttpd:nanohttpd:2.3.1")
    implementation("com.google.code.gson:gson:2.10.1")
    implementation("com.github.Anuken.Arc:arc-core:v145")
    implementation("com.github.Anuken.MindustryJitpack:core:v145")
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
    duplicatesStrategy = DuplicatesStrategy.EXCLUDE
}
