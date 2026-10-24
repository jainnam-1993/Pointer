package com.dailypointer

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class FrostPaletteTest {
    private val sweep = mapOf(
        "white" to 0xFFFFFFFF.toInt(), "black" to 0xFF000000.toInt(), "red" to 0xFFE01010.toInt(),
        "blue" to 0xFF1030E0.toInt(), "yellow" to 0xFFFFE000.toInt(), "grey" to 0xFF808080.toInt(),
        "green" to 0xFF10A040.toInt(), "magenta" to 0xFFD000C0.toInt(),
    )

    /** Quote 7:1 and the teacher line 5:1 (small text 4.5:1 plus margin) over every shade of the card, for every wallpaper and mode. */
    @Test
    fun textContrastHoldsAcrossWallpapers() {
        val failures = mutableListOf<String>()
        for (dark in listOf(false, true)) for ((pName, p) in sweep) for ((sName, s) in sweep) {
            val palette = FrostPalette.from(p, s, null, dark)
            val inkWorst = palette.cardExtremes().minOf { FrostPalette.contrast(palette.ink, it) }
            val secWorst = palette.cardExtremes().minOf { FrostPalette.contrast(palette.secondary, it) }
            if (inkWorst < FrostPalette.QUOTE_MIN || secWorst < FrostPalette.SECONDARY_MIN) failures += "$pName/$sName dark=$dark ink=%.2f secondary=%.2f".format(inkWorst, secWorst)
        }
        assertEquals(emptyList<String>(), failures)
    }

    @Test
    fun cardIsOpaqueAndFollowsTheWallpaper() {
        val red = FrostPalette.from(0xFFE01010.toInt(), null, null, dark = false)
        val blue = FrostPalette.from(0xFF1030E0.toInt(), null, null, dark = false)
        for (c in listOf(red.top, red.bottom, blue.top, blue.bottom)) assertEquals(0xFF, (c ushr 24) and 0xFF)
        assertNotEquals(red.top, blue.top)
        assertTrue("red wallpaper tints the card warm", (red.top shr 16 and 0xFF) > (red.top and 0xFF))
        assertTrue("blue wallpaper tints the card cool", (blue.top and 0xFF) > (blue.top shr 16 and 0xFF))
    }

    /** A colored wallpaper visibly tints the card toward its own hue, in both modes. */
    @Test
    fun cardCarriesTheWallpaperHue() {
        for ((name, c) in sweep) {
            val src = Oklch.of(c)
            if (src.c < 0.02) continue
            for (dark in listOf(false, true)) {
                val card = Oklch.of(FrostPalette.from(c, null, null, dark).top)
                assertTrue("$name dark=$dark chroma ${card.c}", card.c >= 0.025)
                val dh = Math.abs(((card.h - src.h + 540) % 360) - 180)
                assertTrue("$name dark=$dark hue off by $dh", dh <= 25)
            }
        }
    }

    /** The teacher line keeps a margin over 4.5:1 for every palette, including the no-colors fallback. */
    @Test
    fun secondaryTextClearsSmallTextContrastWithMargin() {
        val cases = sweep.values.map { it as Int? } + listOf(null)
        for (c in cases) for (dark in listOf(false, true)) {
            val p = FrostPalette.from(c, null, null, dark)
            val worst = p.cardExtremes().minOf { FrostPalette.contrast(p.secondary, it) }
            assertTrue("$c dark=$dark secondary $worst", worst >= FrostPalette.SECONDARY_MIN)
            // A real second level: the teacher line is visibly dimmer than the quote.
            assertTrue("$c dark=$dark hierarchy", FrostPalette.luminance(p.secondary) < 0.8 * FrostPalette.luminance(p.ink))
        }
    }

    /** The target's mid-tone glass: never near-white or near-black, a little deeper in dark mode. */
    @Test
    fun cardIsAMidTonePanelWithWhiteText() {
        for ((name, c) in sweep) for (dark in listOf(false, true)) {
            val p = FrostPalette.from(c, null, null, dark)
            val l = Oklch.of(p.top).l
            val range = if (dark) 0.26..0.45 else 0.26..0.55
            assertTrue("$name dark=$dark L=$l", l in range)
            assertTrue("$name dark=$dark ink is white", p.lightInk && FrostPalette.luminance(p.ink) > 0.85)
        }
    }

    @Test
    fun missingWallpaperColorsFallBackToACalmVioletPanel() {
        val p = FrostPalette.from(null, null, null, dark = false)
        assertTrue(Oklch.of(p.top).l in 0.26..0.55)
        assertTrue(p.cardExtremes().minOf { FrostPalette.contrast(p.ink, it) } >= 4.5)
    }
}
