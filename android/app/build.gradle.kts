plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Plugin Google Services
    id("dev.flutter.flutter-gradle-plugin") // Flutter toujours en dernier
}

android {
    namespace = "com.example.peche_app"
    compileSdk = 35
    ndkVersion = "29.0.13113456"

    defaultConfig {
        applicationId = "com.example.peche_app"
        minSdk = 23 // Augmenté à 23 pour compatibilité avec Firebase Auth 23.2.0
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true // ✅ Active le support des API Java récentes
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5") // ✅ Important pour certaines API Java
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.12.0"))
    // Firebase products
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
}

flutter {
    source = "../.."
}
