pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // Include parent version catalog
    includeBuild("..") {
        dependencySubstitution {
            substitute(module("com.browsy:shared")).using(project(":shared"))
        }
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }

    // Use version catalog from parent project
    versionCatalogs {
        create("libs") {
            from(files("../gradle/libs.versions.toml"))
        }
    }
}

rootProject.name = "Browsy"
include(":app")
