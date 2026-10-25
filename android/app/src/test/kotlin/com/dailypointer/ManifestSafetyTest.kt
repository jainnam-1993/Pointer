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

    /** The glass-alpha override is debug-only: main never reads it, release and profile return the constant. */
    @Test
    fun glassAlphaOverrideIsDebugOnly() {
        val main = File("src/main").walkTopDown().filter { it.isFile }.joinToString("\n") { it.readText() }
        assertFalse("main must not read the debug override", "widget_debug" in main || "WidgetLookSource.KEY" in main)
        for (t in listOf("release", "profile")) {
            val f = File("src/$t/kotlin/com/dailypointer/WidgetLookSource.kt")
            assertTrue("$t WidgetLookSource exists", f.exists())
            val text = f.readText()
            assertTrue("$t returns the shipped look", "WidgetLook.SHIPPED" in text && "SharedPreferences" !in text && "getSharedPreferences" !in text)
        }
    }
}
