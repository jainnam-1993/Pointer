package com.dailypointer

/**
 * The see-through widget card: a dark glass tint over the live wallpaper, as translucent as the
 * text allows.
 *
 * Decision (2026-10-24, reverses the opaque card drawn from WallpaperColors): RemoteViews cannot
 * blur, and an opaque card painted from the wallpaper's colours only changes when the widget
 * redraws. Nothing redraws a widget on a wallpaper change with the app closed, so the card went
 * stale (user report). A translucent card shows the new wallpaper at once, with no code running.
 * The tint is @android:color/system_neutral1_900 on Android 12+ (the launcher re-inflates it on a
 * wallpaper or theme change), else a fixed near-black.
 *
 * The alpha is the least that keeps the white quote at [QUOTE_MIN] and the 80% white teacher line
 * at [SECONDARY_MIN] over the brightest colour the wallpaper is likely to put behind the card.
 * WallpaperColors are dominant colours, not the brightest pixels, so the brightest is pushed toward white
 * ([MARGIN], or [DARK_MARGIN] on a uniformly dark wallpaper); a wallpaper that supports dark text (a light wallpaper) is treated as white outright.
 * Pure Kotlin (ARGB ints), so the rule runs as a JVM unit test.
 */
object GlassRule {
    const val TINT = 0xFF1C1B1F.toInt()
    const val INK = 0xFFF5F2EE.toInt()
    const val SECONDARY_WHITE = 0.80
    const val QUOTE_MIN = 7.0
    const val SECONDARY_MIN = 4.5
    /** The glassiest the card gets, and the most opaque it may become for a white wallpaper. */
    const val MIN_ALPHA = 0.40
    const val MAX_ALPHA = 0.95
    /**
     * How far the brightest dominant colour is pushed toward white to estimate the brightest pixel
     * behind the card. Measured on a Fold: a busy photo whose dominant colours peak near 0.3
     * luminance still had bright yellow and white patches behind the card (5.6:1 at 0.35), so any
     * wallpaper that is not uniformly dark is assumed to be nearly white somewhere. A uniformly
     * dark wallpaper (brightest dominant colour under [DARK_WALLPAPER]) keeps the small margin and
     * the glassiest card.
     */
    const val MARGIN = 0.80
    const val DARK_MARGIN = 0.35
    const val DARK_WALLPAPER = 0.06
    /** Measured on a Fold: rendered glyphs and the system tint land up to about 0.5:1 under the model. */
    const val HEADROOM = 0.6

    /** The brightest colour assumed behind the card. */
    fun worstCase(colors: List<Int>, supportsDarkText: Boolean): Int {
        if (supportsDarkText || colors.isEmpty()) return FrostPalette.WHITE
        val brightest = colors.maxBy { FrostPalette.luminance(it) }
        val margin = if (FrostPalette.luminance(brightest) < DARK_WALLPAPER) DARK_MARGIN else MARGIN
        return FrostPalette.mix(brightest, FrostPalette.WHITE, margin)
    }

    /** What the card looks like over [behind] at [alpha]. */
    fun composite(behind: Int, alpha: Double): Int = FrostPalette.mix(behind, TINT, alpha)

    fun secondaryOver(card: Int): Int = FrostPalette.mix(card, INK, SECONDARY_WHITE)

    fun quoteContrast(behind: Int, alpha: Double): Double = FrostPalette.contrast(INK, composite(behind, alpha))

    fun secondaryContrast(behind: Int, alpha: Double): Double = composite(behind, alpha).let { FrostPalette.contrast(secondaryOver(it), it) }

    /** The least alpha (in 0.01 steps, from [MIN_ALPHA]) that meets both floors over [behind]. */
    fun alpha(colors: List<Int>, supportsDarkText: Boolean): Double {
        val behind = worstCase(colors, supportsDarkText)
        var a = MIN_ALPHA
        while (a < MAX_ALPHA && (quoteContrast(behind, a) < QUOTE_MIN + HEADROOM || secondaryContrast(behind, a) < SECONDARY_MIN + HEADROOM)) a += 0.01
        return a.coerceAtMost(MAX_ALPHA)
    }
}
