// plugins/status_bar_android/android/build.gradle.kts
// Version: 0.0.1-a StatusBarAndroid

group = "com.icodeforyou.status_bar_android"
version = "1.0-SNAPSHOT"

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.1.0")
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

            // android.jar on the JVM is stubs whose every method throws
            // RuntimeException("Stub!"). With this on, stubs return
            // defaults (0, null, no-op constructors) instead, so code
            // that touches platform statics such as
            // WindowInsets.Type.statusBars() or constructs platform
            // objects such as CancellationSignal can run under test
            // with the surrounding Window / WindowInsetsController
            // mocked by Mockito.
            isReturnDefaultValues = true

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
