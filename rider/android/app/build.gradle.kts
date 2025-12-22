plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Add Firebase plugin
}

android {
    namespace = "com.rider"  // Match Firebase package name
    compileSdk = 35  // Updated to 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.rider"  // MUST match Firebase: com.rider
        minSdk = 23  // Firebase Auth requires minimum 23
        targetSdk = 35  // Updated to 35
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true  // Required for Firebase
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")

    // Multidex for Firebase
    implementation("androidx.multidex:multidex:2.0.1")
}