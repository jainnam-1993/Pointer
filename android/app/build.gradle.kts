import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val allowDebugSigning = (findProperty("pointerAllowDebugSigning") as String?) == "true"

// Fail release packaging without android/key.properties instead of producing
// an unsigned or debug-signed artifact.
tasks.matching { it.name == "packageRelease" || it.name == "signReleaseBundle" }.configureEach {
    doFirst {
        if (!keystorePropertiesFile.exists() && !allowDebugSigning) {
            throw GradleException(
                "Release signing is not configured: add android/key.properties, " +
                    "or pass -PpointerAllowDebugSigning=true for a local, non-distributable build."
            )
        }
    }
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
        // Launcher and widget-picker label. Test build types override it below.
        resValue("string", "launcher_label", "Here Now")
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
        // Debug and profile builds install BESIDE the real app (com.dailypointer.test),
        // never over it: their own data, widgets, notifications and launcher entry.
        // namespace (Kotlin package, R class) stays com.dailypointer; only applicationId changes.
        debug {
            applicationIdSuffix = ".test"
            versionNameSuffix = "-test"
            resValue("string", "launcher_label", "Here Now Test")
        }
        maybeCreate("profile").apply {
            applicationIdSuffix = ".test"
            versionNameSuffix = "-test"
            resValue("string", "launcher_label", "Here Now Test")
        }
        release {
            // Never ship a debug-signed release by accident. Local verification can
            // opt in with -PpointerAllowDebugSigning=true or the env var
            // ORG_GRADLE_PROJECT_pointerAllowDebugSigning=true.
            signingConfig = when {
                keystorePropertiesFile.exists() -> signingConfigs.getByName("release")
                allowDebugSigning -> signingConfigs.getByName("debug")
                else -> null
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
    // Installs src/main/baseline-prof.txt on sideloads, so startup code is compiled ahead of time.
    implementation("androidx.profileinstaller:profileinstaller:1.4.1")
    // JVM unit tests for the widget model (org.json is stubbed in android.jar)
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.json:json:20240303")
}

// Configuration for Kotlin Gradle Plugin 2.x
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}
