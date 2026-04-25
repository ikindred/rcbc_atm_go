import java.util.regex.Pattern

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

fun Project.ensureAndroidNamespace() {
    val androidExtension = extensions.findByName("android") ?: return

    val getNamespace = runCatching { androidExtension.javaClass.getMethod("getNamespace") }.getOrNull()
    val currentNamespace = getNamespace?.invoke(androidExtension) as? String
    if (!currentNamespace.isNullOrBlank()) return

    val manifestFile = file("src/main/AndroidManifest.xml")
    val manifestPackage = if (manifestFile.exists()) {
        val match = Pattern
            .compile("""package\s*=\s*"([^"]+)"""")
            .matcher(manifestFile.readText())
        if (match.find()) match.group(1) else null
    } else {
        null
    }

    val fallbackNamespace = manifestPackage ?: "com.generated.${name.replace("-", "_")}"

    runCatching {
        androidExtension.javaClass
            .getMethod("setNamespace", String::class.java)
            .invoke(androidExtension, fallbackNamespace)
    }
}

subprojects {
    plugins.withId("com.android.library") {
        ensureAndroidNamespace()
    }
    plugins.withId("com.android.application") {
        ensureAndroidNamespace()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
