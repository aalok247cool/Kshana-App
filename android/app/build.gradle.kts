plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
<<<<<<< HEAD
    namespace = "com.example.fresh_kshana_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
=======
    namespace = "com.example.kshana_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Manually set the NDK version
>>>>>>> 9618a4cc90c60590183dbc13f99f9260210435c7

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
<<<<<<< HEAD
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.fresh_kshana_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
=======
        applicationId = "com.example.kshana_app"
>>>>>>> 9618a4cc90c60590183dbc13f99f9260210435c7
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
<<<<<<< HEAD
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
=======
>>>>>>> 9618a4cc90c60590183dbc13f99f9260210435c7
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
<<<<<<< HEAD
=======
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.1.5")
}
>>>>>>> 9618a4cc90c60590183dbc13f99f9260210435c7
