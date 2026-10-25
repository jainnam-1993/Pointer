package com.dailypointer

import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetLookTest {
    private fun colors(path: String): Map<String, String> =
        Regex("""<color name="([a-z_]+)">([^<]+)</color>""").findAll(File(path).readText()).associate { it.groupValues[1] to it.groupValues[2] }

    private fun argb(hex: String): Int = hex.removePrefix("#").let { if (it.length == 6) "FF$it" else it }.toLong(16).toInt()

    /** The shipped look is the opaque Material You tonal card with no scrim box. */
    @Test
    fun shippedLookIsTheTonalCard() {
        assertEquals(WidgetLook(WidgetSurface.TONAL, 1.0, WidgetScrim.NONE), WidgetLook.SHIPPED)
    }

    /** On Android 12+ every tonal colour is a system dynamic resource, so it follows the wallpaper with no code running. */
    @Test
    fun tonalColoursAreSystemDynamicResources() {
        for (path in listOf("src/main/res/values-v31/colors.xml", "src/main/res/values-night-v31/colors.xml")) {
            val c = colors(path)
            for (name in listOf("widget_surface", "widget_surface_variant", "widget_text", "widget_text_muted", "widget_accent")) {
                assertTrue("$path $name = ${c[name]}", c[name]?.startsWith("@android:color/system_") == true)
            }
        }
        assertTrue("@color/widget_surface" in File("src/main/res/drawable/widget_tonal.xml").readText())
    }

    /** The pre-12 fallback palette keeps the floors in light and dark: quote 7:1, teacher line 4.5:1. */
    @Test
    fun fallbackPaletteKeepsTheFloors() {
        for (path in listOf("src/main/res/values/colors.xml", "src/main/res/values-night/colors.xml")) {
            val c = colors(path)
            val surface = argb(c.getValue("widget_surface"))
            val quote = FrostPalette.contrast(argb(c.getValue("widget_text")), surface)
            val teacher = FrostPalette.contrast(argb(c.getValue("widget_text_muted")), surface)
            assertTrue("$path quote $quote", quote >= 7.0)
            assertTrue("$path teacher $teacher", teacher >= 4.5)
        }
    }
}
