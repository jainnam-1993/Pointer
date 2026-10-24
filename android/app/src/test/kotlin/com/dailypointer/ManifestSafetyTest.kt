package com.dailypointer

import java.io.File
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/** The emulator wallpaper hook must never reach a release build. */
class ManifestSafetyTest {
    private val forbidden = listOf("DebugWallpaperReceiver", "android.permission.SET_WALLPAPER")

    @Test
    fun releaseAndMainManifestsHaveNoWallpaperHook() {
        for (path in listOf("src/main/AndroidManifest.xml", "src/release/AndroidManifest.xml", "src/profile/AndroidManifest.xml")) {
            val f = File(path)
            if (!f.exists()) continue
            val text = f.readText()
            for (token in forbidden) assertFalse("$path must not contain $token", token in text)
        }
        assertFalse("the hook's code lives only in the debug source set", File("src/main/kotlin/com/dailypointer/DebugWallpaperReceiver.kt").exists())
        assertTrue(File("src/debug/kotlin/com/dailypointer/DebugWallpaperReceiver.kt").exists())
    }
}
