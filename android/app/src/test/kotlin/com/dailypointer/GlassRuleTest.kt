package com.dailypointer

import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class GlassRuleTest {
    private val wallpapers = mapOf(
        "white" to listOf(0xFFFFFFFF.toInt()), "black" to listOf(0xFF000000.toInt()), "snow" to listOf(0xFFE8EEF4.toInt(), 0xFF7A8FA6.toInt()),
        "night" to listOf(0xFF101830.toInt(), 0xFF2A2040.toInt()), "red" to listOf(0xFFE01010.toInt()), "yellow" to listOf(0xFFFFE000.toInt()),
        "foliage" to listOf(0xFF4A6A2A.toInt(), 0xFF9AB070.toInt()), "grey" to listOf(0xFF808080.toInt()), "busy" to listOf(0xFF203040.toInt(), 0xFFF0C040.toInt(), 0xFF40A0E0.toInt()),
    )

    /** Both floors hold over the assumed brightest colour, for every wallpaper and the no-colours case. */
    @Test
    fun alphaKeepsBothFloors() {
        val failures = mutableListOf<String>()
        for ((name, colors) in wallpapers + ("none" to emptyList())) for (darkText in listOf(false, true)) {
            val a = GlassRule.alpha(colors, darkText)
            val behind = GlassRule.worstCase(colors, darkText)
            val q = GlassRule.quoteContrast(behind, a)
            val s = GlassRule.secondaryContrast(behind, a)
            if (q < GlassRule.QUOTE_MIN || s < GlassRule.SECONDARY_MIN) failures += "$name darkText=$darkText a=$a quote=$q secondary=$s"
        }
        assertEquals(emptyList<String>(), failures)
    }

    /** As see-through as the text allows: dark wallpapers get the glassiest card, light ones more tint. */
    @Test
    fun darkWallpapersStaySeeThroughAndLightOnesGetMoreTint() {
        val night = GlassRule.alpha(wallpapers.getValue("night"), false)
        val white = GlassRule.alpha(wallpapers.getValue("white"), true)
        assertEquals(GlassRule.MIN_ALPHA, night, 1e-9)
        assertTrue("white wallpaper needs more tint ($white vs $night)", white > night + 0.2)
        assertTrue(white <= GlassRule.MAX_ALPHA)
    }

    /** The two text levels survive: the teacher line stays visibly dimmer than the quote. */
    @Test
    fun teacherLineStaysTheDimmerLevel() {
        val card = GlassRule.composite(FrostPalette.WHITE, GlassRule.alpha(emptyList(), true))
        assertTrue(FrostPalette.luminance(GlassRule.secondaryOver(card)) < 0.85 * FrostPalette.luminance(GlassRule.INK))
    }

    /**
     * The tint follows the system palette with no code running: the glass layer is an XML drawable
     * whose colour is @android:color/system_neutral1_* on Android 12+, which launchers re-inflate.
     */
    @Test
    fun glassUsesTheSystemDynamicColour() {
        val v31 = File("src/main/res/values-v31/colors.xml").readText()
        assertTrue(Regex("""name="widget_glass_tint">@android:color/system_neutral\d_\d+<""").containsMatchIn(v31))
        assertTrue("@color/widget_glass_tint" in File("src/main/res/drawable/widget_glass.xml").readText())
        for (name in listOf("pointer_widget.xml", "pointer_widget_small.xml", "pointer_widget_large.xml")) {
            val text = File("src/main/res/layout/$name").readText()
            assertTrue("$name: glass layer", Regex("""widget_frost_bg"[^>]*android:src="@drawable/widget_glass"""").containsMatchIn(text.replace("\n", " ")))
        }
    }
}
