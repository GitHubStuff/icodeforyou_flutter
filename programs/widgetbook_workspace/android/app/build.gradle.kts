plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.widgetbook_workspace"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // CHANGED: Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.widgetbook_workspace"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // CHANGED: Enable multidex support
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// CHANGED: Added dependencies block for the desugaring library
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

/*
The changes were necessary because of how Android handles newer 
Java features across different OS versions:

    isCoreLibraryDesugaringEnabled = true & com.android.tools:desugar_jdk_libs:
    The plugin flutter_local_notifications uses modern Java 
    APIs (such as java.time for scheduling notifications). Android versions prior 
    to Android 8.0 (API 26) do not support these APIs natively. Desugaring allows 
    the build tools to rewrite those modern Java calls into backwards-compatible 
    bytecode and bundle a support library so your app won't crash on older devices.

    multiDexEnabled = true:
    Adding the desugaring library increases the total number of method references
    compiled into the app. Enabling MultiDex ensures the app can exceed the standard 64k
    method limit imposed by the Android Dalvik/ART executable format without failing to build.
*/