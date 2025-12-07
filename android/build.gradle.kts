// Removed forcing Guava globally to avoid conflicts with Gradle/AGP internal
// dependencies which may expect different Guava versions. Forcing a single
// Guava version across all configurations can break Gradle tasks (e.g. MergeJavaRes).
// If you need to enforce a Guava version for your app dependencies, do so
// per-configuration or via dependency substitution for project dependencies.

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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
