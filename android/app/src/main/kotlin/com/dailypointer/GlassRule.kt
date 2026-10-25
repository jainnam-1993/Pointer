package com.dailypointer

/**
 * The see-through widget card: a dark glass body over the live wallpaper, with a legibility scrim
 * behind the text only (as iOS widgets and the lock screen do).
 *
 * Decisions (2026-10-24):
 * - The card is translucent, so a new wallpaper shows through at once with no code running.
 *   An opaque card painted from WallpaperColors went stale, because nothing redraws a widget on a
 *   wallpaper change while the app is closed.
 * - One FIXED body alpha for every wallpaper. A per-wallpaper alpha needs a recompute on each
 *   wallpaper change, which nothing reliably runs, so it went stale between redraws.
 * - The scrim (res/drawable/widget_text_scrim.xml) carries the text contrast, so the body can stay
 *   see-through. Measured on a Fold over 8 wallpapers with no redraw: body 0.45 gives the quote
 *   9.9:1 and the teacher line 6.2:1 at worst (flat card without a scrim: 0.79 needed).
 * - The tint is @android:color/system_neutral1_900 on Android 12+ (launchers re-inflate it on a
 *   wallpaper or theme change), else a fixed near-black.
 * Pure Kotlin (ARGB ints) for the contrast model, so the floors run as a JVM unit test.
 */
object GlassRule {
    /** Body alpha on every wallpaper. Guarded at <= 0.50 by GlassRuleTest (the user asked for see-through). */
    const val FIXED_ALPHA = 0.45

    /** The two scrim layers' alphas as drawn in widget_text_scrim.xml (outer 0x66, inner 0x99 at its densest point, 0x8C at its edges). */
    const val SCRIM_OUTER = 0x66 / 255.0
    const val SCRIM_INNER_EDGE = 0x8C / 255.0

    const val TINT = 0xFF1C1B1F.toInt()
    const val INK = 0xFFF5F2EE.toInt()
    const val SECONDARY_WHITE = 0.80
    const val QUOTE_MIN = 7.0
    const val SECONDARY_MIN = 4.5

    /** Tint coverage under the text: body, then the scrim's two layers at their thinnest. */
    val underText: Double get() = 1 - (1 - FIXED_ALPHA) * (1 - SCRIM_OUTER) * (1 - SCRIM_INNER_EDGE)

    /** What the text sits on over a wallpaper colour [behind]. */
    fun cardUnderText(behind: Int): Int = FrostPalette.mix(behind, TINT, underText)

    fun secondaryOver(card: Int): Int = FrostPalette.mix(card, INK, SECONDARY_WHITE)

    fun quoteContrast(behind: Int): Double = FrostPalette.contrast(INK, cardUnderText(behind))

    fun secondaryContrast(behind: Int): Double = cardUnderText(behind).let { FrostPalette.contrast(secondaryOver(it), it) }
}
