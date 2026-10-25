package com.dailypointer

import java.io.File
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class GlassRuleTest {
    /** Brightest colours of the 8 sweep wallpapers (pastel, dark, photo, white, foliage, snow, black, saturated), plus pure white. */
    private val fixtures = mapOf(
        "pastel" to 0xFFF2D6E4.toInt(), "dark" to 0xFF140B2B.toInt(), "photo" to 0xFFFFE000.toInt(), "white" to 0xFFFFFFFF.toInt(),
        "foliage" to 0xFF9AB070.toInt(), "snow" to 0xFFF4F6FA.toInt(), "black" to 0xFF000000.toInt(), "saturated" to 0xFFFFE628.toInt(),
    )

    /** The user asked for real see-through: the body must stay at or under half opacity. */
    @Test
    fun bodyAlphaStaysSeeThrough() {
        assertTrue("body alpha ${GlassRule.FIXED_ALPHA}", GlassRule.FIXED_ALPHA <= 0.50)
    }

    /** With the scrim, the quote keeps 7:1 and the teacher line 4.5:1 over every fixture wallpaper. */
    @Test
    fun floorsHoldOverEveryFixtureWallpaper() {
        val failures = fixtures.mapNotNull { (name, c) ->
            val q = GlassRule.quoteContrast(c)
            val s = GlassRule.secondaryContrast(c)
            if (q < GlassRule.QUOTE_MIN || s < GlassRule.SECONDARY_MIN) "$name quote=%.2f teacher=%.2f".format(q, s) else null
        }
        assertEquals(emptyList<String>(), failures)
    }

    /** The two text levels survive: the teacher line stays visibly dimmer than the quote. */
    @Test
    fun teacherLineStaysTheDimmerLevel() {
        val card = GlassRule.cardUnderText(FrostPalette.WHITE)
        assertTrue(FrostPalette.luminance(GlassRule.secondaryOver(card)) < 0.85 * FrostPalette.luminance(GlassRule.INK))
    }

    /** The model matches the drawable: the scrim alphas in the test are the ones in widget_text_scrim.xml. */
    @Test
    fun scrimDrawableMatchesTheModel() {
        val xml = File("src/main/res/drawable/widget_text_scrim.xml").readText()
        assertTrue("#661C1B1F" in xml && "#8C1C1B1F" in xml)
    }

    /**
     * Layout guards: the glass body uses the system dynamic colour on Android 12+, and the text scrim
     * sits behind the quote (on its area) and behind the teacher line, in every live layout.
     */
    @Test
    fun layoutsUseDynamicTintAndPutTheScrimBehindTheText() {
        val v31 = File("src/main/res/values-v31/colors.xml").readText()
        assertTrue(Regex("""name="widget_glass_tint">@android:color/system_neutral\d_\d+<""").containsMatchIn(v31))
        assertTrue("@color/widget_glass_tint" in File("src/main/res/drawable/widget_glass.xml").readText())
        for (name in listOf("pointer_widget.xml", "pointer_widget_small.xml", "pointer_widget_large.xml")) {
            val text = File("src/main/res/layout/$name").readText().replace("\n", " ")
            assertTrue("$name: glass body", Regex("""widget_frost_bg"[^>]*android:src="@drawable/widget_glass"""").containsMatchIn(text))
            assertTrue("$name: scrim behind the quote", Regex("""widget_content_area"[^>]*android:background="@drawable/widget_text_scrim"""").containsMatchIn(text))
            assertTrue("$name: scrim behind the teacher line", Regex("""widget_teacher"[^>]*android:background="@drawable/widget_text_scrim"""").containsMatchIn(text))
        }
    }
}
