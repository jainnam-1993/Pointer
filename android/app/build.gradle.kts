import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google services for Firebase
    id("com.google.gms.google-services")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.dailypointer"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Enable core library desugaring for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dailypointer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

val generatedPluginRegistrant = file("src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java")
val stripDevOnlyPluginsFromRegistrant = tasks.register("stripDevOnlyPluginsFromRegistrant") {
    doLast {
        if (!generatedPluginRegistrant.exists()) return@doLast

        var content = generatedPluginRegistrant.readText()
        val original = content

        // Flutter currently regenerates this file with dev-only plugins after `flutter pub get`.
        // Those plugins are not on release/profile classpaths, so javac fails.
        val devOnlyPluginBlocks = listOf(
            Regex(
                """(?s)\s*try \{\s*flutterEngine\.getPlugins\(\)\.add\(new dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin\(\)\);\s*\} catch \(Exception e\) \{\s*Log\.e\(TAG, "Error registering plugin integration_test, dev\.flutter\.plugins\.integration_test\.IntegrationTestPlugin", e\);\s*\}\s*"""
            ),
            Regex(
                """(?s)\s*try \{\s*flutterEngine\.getPlugins\(\)\.add\(new pl\.leancode\.patrol\.PatrolPlugin\(\)\);\s*\} catch \(Exception e\) \{\s*Log\.e\(TAG, "Error registering plugin patrol, pl\.leancode\.patrol\.PatrolPlugin", e\);\s*\}\s*"""
            ),
        )

        devOnlyPluginBlocks.forEach { block ->
            content = content.replace(block, "\n")
        }

        if (content != original) {
            generatedPluginRegistrant.writeText(content)
            logger.lifecycle("Stripped dev-only plugins from GeneratedPluginRegistrant.java for non-debug build")
        }
    }
}

tasks.matching { it.name == "compileReleaseJavaWithJavac" || it.name == "compileProfileJavaWithJavac" }
    .configureEach {
        dependsOn(stripDevOnlyPluginsFromRegistrant)
    }

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

// Configuration for Kotlin Gradle Plugin 2.x
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}
