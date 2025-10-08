// ✅ Project-level build.gradle (Groovy version)

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Android Gradle plugin
        classpath "com.android.tools.build:gradle:8.3.0"
        // Firebase plugin
        classpath "com.google.gms:google-services:4.4.3"
        // Kotlin plugin
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = "../build"

subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
