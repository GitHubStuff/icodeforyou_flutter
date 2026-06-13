import org.jetbrains.kotlin.gradle.dsl.JvmTarget
 
plugins {
    id("com.android.application")
// START: FlutterFire Configuration
    id("com.google.gms.google-services")
// END: FlutterFire Configuration
    id("kotlin-android")
// The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
 
android {
    namespace = "com.icodeforyou.creature_comfort"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion
 
    compileOptions {
        // Required by flutter_local_notifications (transitively via remind_me).
        // The plugin uses java.time APIs that need desugaring on older Android.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
 
    defaultConfig {
        applicationId = "com.icodeforyou.creature_comforts"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }
}
 
kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}
 
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
 
flutter {
    source = "../.."
}
