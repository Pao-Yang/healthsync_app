plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.pao.healthsync_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // เปิด desugaring
        isCoreLibraryDesugaringEnabled = true
    }
    
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    
    defaultConfig {
        applicationId = "com.pao.healthsync_app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
        
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
    // ใช้ Firebase BoM สำหรับเวอร์ชันที่เข้ากันได้
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))  // ใช้เวอร์ชันที่เข้ากับ Firebase Core 2.11.0
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-firestore")  // สำหรับ Cloud Firestore
        // เพิ่มบรรทัดนี้
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // ← ใช้แบบนี้ใน Kotlin DSL
    implementation("androidx.core:core-ktx:1.12.0")
}

