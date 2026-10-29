// plugins/status_bar_android/android/build.gradle.kts
// Version: 0.0.1-a StatusBarAndroid

group = "com.icodeforyou.status_bar_android"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.4.0"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

android {
    namespace = "com.icodeforyou.status_bar_android"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        minSdk = 30
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                // Mockito's inline mock maker attaches Byte Buddy as a
                // dynamic agent; JDK 21+ warns unless this is set.
                // -Xshare:off silences the CDS warning caused by the
                // Android unit-test runner's bootstrap classpath.
                it.jvmArgs("-XX:+EnableDynamicAgentLoading", "-Xshare:off")

                it.testLogging {
                    events(
                        "passed",
                        "skipped",
                        "failed",
                        "standardOut",
                        "standardError",
                    )
                    showStandardStreams = true
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    // Tests run on JDK 21, which needs a Byte Buddy with JDK 21 class-file
    // support; Mockito bundles that from 5.5 onwards. Earlier releases
    // fail at mock creation with IllegalArgumentException.
    testImplementation("org.mockito:mockito-core:5.12.0")
}