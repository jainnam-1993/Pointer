import java.util.Properties
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.zip.ZipFile

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

// Play Billing (com.android.billingclient:billing, via :in_app_purchase_android)
// pulls in Google's datatransport/CCT telemetry uploader and its firebase
// encoders. They are the only source of the INTERNET permission in the merged
// manifest. The app is offline by design (docs/PRIVACY_POLICY.md), so keep
// them out of every classpath. Billing still reaches Play over Binder IPC.
val offlineExcludedModules = listOf(
    "com.google.android.datatransport" to null,
    "com.google.firebase" to "firebase-encoders",
    "com.google.firebase" to "firebase-encoders-json",
    "com.google.firebase" to "firebase-encoders-proto",
)
configurations.configureEach {
    offlineExcludedModules.forEach { (group, module) ->
        if (module == null) exclude(group = group) else exclude(group = group, module = module)
    }
}

/** Type descriptors of the classes a dex file defines (its class_defs table). */
fun dexClassDescriptors(dex: ByteArray): List<String> {
    val buf = ByteBuffer.wrap(dex).order(ByteOrder.LITTLE_ENDIAN)
    val stringIdsOff = buf.getInt(0x3C)
    val typeIdsOff = buf.getInt(0x44)
    val classDefsSize = buf.getInt(0x60)
    val classDefsOff = buf.getInt(0x64)
    return (0 until classDefsSize).map { i ->
        val typeIdx = buf.getInt(classDefsOff + i * 32)
        val stringIdx = buf.getInt(typeIdsOff + typeIdx * 4)
        var pos = buf.getInt(stringIdsOff + stringIdx * 4)
        while (dex[pos].toInt() and 0x80 != 0) pos++ // skip the uleb128 length
        pos++
        val end = (pos until dex.size).first { dex[it].toInt() == 0 }
        String(dex, pos, end - pos, Charsets.UTF_8)
    }
}

/**
 * Fails when the release build could reach the network: an INTERNET permission
 * in the merged release manifest, an excluded telemetry module on the release
 * runtime classpath, or datatransport classes in the release APK's dex.
 * Run: ./gradlew :app:verifyOfflineRelease (after flutter build apk --release
 * for the dex check).
 */
tasks.register("verifyOfflineRelease") {
    dependsOn("processReleaseManifest")
    val buildDir = layout.buildDirectory
    val runtime = configurations.named("releaseRuntimeClasspath")
    doLast {
        val problems = mutableListOf<String>()
        runtime.get().incoming.resolutionResult.allComponents.forEach { c ->
            val id = c.moduleVersion ?: return@forEach
            if (offlineExcludedModules.any { (g, m) -> id.group == g && (m == null || id.name == m) }) {
                problems += "releaseRuntimeClasspath has ${id.group}:${id.name}:${id.version}"
            }
        }
        val manifests = buildDir.dir("intermediates/merged_manifests/release").get().asFile
            .walkTopDown().filter { it.name == "AndroidManifest.xml" }.toList()
        if (manifests.isEmpty()) problems += "no merged release manifest found"
        manifests.forEach { f ->
            if (Regex("""android:name="android\.permission\.INTERNET"""").containsMatchIn(f.readText())) {
                problems += "INTERNET permission in ${f.path}"
            }
        }
        val apk = rootProject.file("../build/app/outputs/flutter-apk/app-release.apk")
        if (apk.exists()) {
            ZipFile(apk).use { zip ->
                zip.entries().asSequence().filter { it.name.matches(Regex("""classes\d*\.dex""")) }.forEach { e ->
                    // Billing's own code still references datatransport types (R8 -dontwarn),
                    // so check class definitions, not every string in the dex.
                    dexClassDescriptors(zip.getInputStream(e).readBytes())
                        .filter { it.startsWith("Lcom/google/android/datatransport/") }
                        .forEach { problems += "class $it defined in ${apk.name}!${e.name}" }
                }
            }
        } else {
            logger.lifecycle("verifyOfflineRelease: ${apk.path} not built; skipped dex check")
        }
        if (problems.isNotEmpty()) throw GradleException("Release build is not offline:\n  " + problems.joinToString("\n  "))
        logger.lifecycle("verifyOfflineRelease: OK (${manifests.size} manifest(s), apk checked=${apk.exists()})")
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
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
