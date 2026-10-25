package com.dailypointer

import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetLookTest {
    private fun colors(path: String): Map<String, String> =
        Regex("""<color name="([a-z_]+)">([^<]+)</color>""").findAll(File(path).readText()).associate { it.groupValues[1] to it.groupValues[2] }

    private fun argb(hex: String): Int = hex.removePrefix("#").let { if (it.length == 6) "FF$it" else it }.toLong(16).toInt()

    /** The shipped look is the user's pick: see-through app glass that follows the system theme, no scrim box, at most 80% opaque. */
    @Test
    fun shippedLookIsTheSeeThroughAppGlass() {
        assertEquals(WidgetSurface.APP, WidgetLook.SHIPPED.surface)
        assertEquals(WidgetScrim.NONE, WidgetLook.SHIPPED.scrim)
        assertEquals("shipped opacity comes from the theme colours", null, WidgetLook.SHIPPED.bodyAlpha)
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

    /**
     * Controls read as controls (WCAG non-text 3:1): on Android 12+ the pill and Save fill sit at
     * least 40 tones from the card and the glyphs at least 40 tones from the fill. In Material
     * tones a 40-tone gap is about 3:1 or more; the pre-12 fallback is checked by contrast below.
     */
    @Test
    fun tonalControlsKeepNonTextContrast() {
        fun tone(res: String?): Int {
            val n = Regex("""system_[a-z]+\d_(\d+)""").find(res ?: "")?.groupValues?.get(1)?.toInt() ?: error("not a system tone: $res")
            return 100 - n / 10
        }
        for (path in listOf("src/main/res/values-v31/colors.xml", "src/main/res/values-night-v31/colors.xml")) {
            val c = colors(path)
            val card = tone(c["widget_surface"])
            val fill = tone(c["widget_control"])
            val glyph = tone(c["widget_on_control"])
            assertTrue("$path fill vs card $fill/$card", kotlin.math.abs(fill - card) >= 40)
            assertTrue("$path glyph vs fill $glyph/$fill", kotlin.math.abs(glyph - fill) >= 40)
        }
        for (path in listOf("src/main/res/values/colors.xml", "src/main/res/values-night/colors.xml")) {
            val c = colors(path)
            val card = argb(c.getValue("widget_surface"))
            val fill = argb(c.getValue("widget_control"))
            val glyph = argb(c.getValue("widget_on_control"))
            assertTrue("$path fill vs card", FrostPalette.contrast(fill, card) >= 3.0)
            assertTrue("$path glyph vs fill", FrostPalette.contrast(glyph, fill) >= 3.0)
        }
        for (name in listOf("ic_heart_outline_tonal", "ic_heart_filled_tonal", "ic_chevron_left_tonal", "ic_chevron_right_tonal")) {
            assertTrue(name, "@color/widget_on_control" in File("src/main/res/drawable/$name.xml").readText())
        }
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
