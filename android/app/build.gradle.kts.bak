plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties

val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val flutterVersionCode = (localProps.getProperty("flutter.versionCode") ?: "1").toInt()
val flutterVersionName = localProps.getProperty("flutter.versionName") ?: "1.0"

android {
    // ✅ 오타 수정: com.kueong.store → com.kumeong.store
    namespace = "com.kumeong.store"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.kumeong.store"
        minSdk = 23
        targetSdk = 36
        versionCode = flutterVersionCode
        versionName = flutterVersionName
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }

    buildTypes {
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Flutter는 kotlin 경로를 main 소스에 포함
    sourceSets.getByName("main").java.srcDirs("src/main/kotlin")

    // (선택) ABI 스플릿은 주석 유지
}

flutter { source = "../.." }

dependencies {
    // 보통 별도 추가 불필요 (플러그인이 처리)
}



// plugins {
//     id("com.android.application")
//     kotlin("android")
//     id("dev.flutter.flutter-gradle-plugin")
// }

// import java.util.Properties

// val localProps = Properties().apply {
//     val f = rootProject.file("local.properties")
//     if (f.exists()) f.inputStream().use { load(it) }
// }
// val flutterVersionCode = (localProps.getProperty("flutter.versionCode") ?: "1").toInt()
// val flutterVersionName = localProps.getProperty("flutter.versionName") ?: "1.0"

// android {
//     namespace = "com.kueong.store"
//     compileSdk = 36

//     defaultConfig {
//         applicationId = "com.kumeong.store"
//         minSdk = 21
//         targetSdk = 36
//         versionCode = flutterVersionCode
//         versionName = flutterVersionName
//         multiDexEnabled = true
//     }

//     compileOptions {
//         sourceCompatibility = JavaVersion.VERSION_17
//         targetCompatibility = JavaVersion.VERSION_17
//     }
//     kotlinOptions { jvmTarget = "17" }

//     buildTypes {
//         debug {
//             // 디버깅 편의: 축소/난독화 끈다
//             isMinifyEnabled = false
//             isShrinkResources = false
//         }
//         release {
//             // 릴리스 최적화 ON
//             isMinifyEnabled = true
//             isShrinkResources = true
//             // 기본 최적화 룰 + 커스텀 룰
//             proguardFiles(
//                 getDefaultProguardFile("proguard-android-optimize.txt"),
//                 "proguard-rules.pro"
//             )
//             // 데모용: 배포 전 실제 서명키로 교체
//             signingConfig = signingConfigs.getByName("debug")
//         }
//     }

//     // Flutter는 kotlin 경로를 main 소스에 포함
//     sourceSets.getByName("main").java.srcDirs("src/main/kotlin")

//     // (선택) APK 직접 배포 시 ABI 스플릿 — App Bundle 쓰면 필요 없음
//     // splits {
//     //     abi {
//     //         isEnable = true
//     //         reset()
//     //         include("armeabi-v7a", "arm64-v8a")
//     //         isUniversalApk = false
//     //     }
//     // }
// }

// flutter { source = "../.." }

// dependencies {
//     // 보통 별도 추가 불필요 (플러그인이 처리)
// }
