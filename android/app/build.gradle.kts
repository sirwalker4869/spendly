plugins {
id("com.android.application")
id("dev.flutter.flutter-gradle-plugin")
}

android {
namespace = "com.example.spendly"
compileSdk = 36

defaultConfig {
    applicationId = "com.example.spendly"
    minSdk = flutter.minSdkVersion
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}

compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

buildTypes {
    release {
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
