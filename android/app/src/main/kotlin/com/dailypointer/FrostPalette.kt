package com.dailypointer

import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

/**
 * The widget's opaque "frosted glass" colors, derived from the wallpaper's own colors.
 *
 * Decision: read WallpaperManager.getWallpaperColors (no permission, works with Material You
 * off and on OEM launchers) instead of system_accent/neutral resources, which follow the
 * wallpaper only when the user's theme does. The wallpaper colors are pulled most of the way
 * toward a calm paper tint (light) or a deep ink tint (dark), so the card reads as frost over
 * the wallpaper, not as a raw swatch. Text and icon colors are chosen from the measured
 * luminance of the rendered card, so the pointing is always at least 4.5:1.
 *
 * Pure Kotlin (ARGB ints, no android.graphics), so the contrast sweep runs as a JVM unit test.
 */
data class FrostPalette(
    val top: Int,
    val bottom: Int,
    val ink: Int,
    val secondary: Int,
    val lightInk: Boolean,
) {
    /** The darkest and lightest the card gets after sheen and shade, for contrast checks. */
    fun cardExtremes(): List<Int> = listOf(top, bottom, mix(top, WHITE, SHEEN), mix(bottom, BLACK, SHADE), mix(top, BLACK, SHADE), mix(bottom, WHITE, SHEEN))

    companion object {
        const val WHITE = 0xFFFFFFFF.toInt()
        const val BLACK = 0xFF000000.toInt()
        private const val PAPER = 0xFFF6F3EE.toInt()
        private const val DEEP = 0xFF16151B.toInt()
        private const val INK_DARK = 0xFF1D1B20.toInt()
        private const val INK_LIGHT = 0xFFF5F2EE.toInt()

        /** Share of the wallpaper color kept in each stop; the rest is the calm tint. */
        private const val LIGHT_KEEP = 0.30
        private const val DARK_KEEP = 0.36

        /** Sheen (upper half) and shade (lower edge) strengths drawn by the card renderer. */
        const val SHEEN = 0.10
        const val SHADE = 0.08

        /** App palette when the wallpaper exposes no colors (some live wallpapers). */
        private val FALLBACK_LIGHT = intArrayOf(0xFFF7F5F2.toInt(), 0xFFECE7F4.toInt())
        private val FALLBACK_DARK = intArrayOf(0xFF24222A.toInt(), 0xFF1C1B1F.toInt())

        /**
         * [primary], [secondary] and [tertiary] are WallpaperColors ARGB values (null when absent).
         * [dark] follows the system night mode.
         */
        fun from(primary: Int?, secondary: Int?, tertiary: Int?, dark: Boolean): FrostPalette {
            val (top, bottom) = if (primary == null) {
                val f = if (dark) FALLBACK_DARK else FALLBACK_LIGHT
                f[0] to f[1]
            } else {
                val second = secondary ?: tertiary ?: primary
                val tint = if (dark) DEEP else PAPER
                val keep = if (dark) DARK_KEEP else LIGHT_KEEP
                val settle = { c: Int -> settle(c, tint, dark) }
                settle(mix(tint, primary, keep)) to settle(mix(tint, mix(second, tertiary ?: second, 0.5), keep))
            }
            return withInk(opaque(top), opaque(bottom))
        }

        /**
         * Keeps a stop inside the calm band: light cards at least 0.55 luminance, dark cards at most
         * 0.045, by easing toward the tint. A white or neon wallpaper then still gives a frost, not a glare.
         */
        private fun settle(c: Int, tint: Int, dark: Boolean): Int {
            var out = c
            repeat(24) {
                val l = luminance(out)
                if (if (dark) l <= MAX_DARK_LUMINANCE else l >= MIN_LIGHT_LUMINANCE) return out
                out = mix(out, tint, 0.15)
            }
            return tint
        }

        private const val MIN_LIGHT_LUMINANCE = 0.55
        private const val MAX_DARK_LUMINANCE = 0.045

        /** Picks the ink with the higher worst-case contrast over every shade the card shows. */
        fun withInk(top: Int, bottom: Int): FrostPalette {
            val probe = FrostPalette(top, bottom, 0, 0, false).cardExtremes()
            val darkWorst = probe.minOf { contrast(INK_DARK, it) }
            val lightWorst = probe.minOf { contrast(INK_LIGHT, it) }
            val lightInk = lightWorst > darkWorst
            val ink = if (lightInk) INK_LIGHT else INK_DARK
            // Secondary: the ink eased 28% toward the card; still above 4.5:1 in practice, never below 3:1.
            var secondary = mix(ink, mix(top, bottom, 0.5), 0.28)
            if (probe.minOf { contrast(secondary, it) } < 3.0) secondary = ink
            return FrostPalette(top, bottom, ink, secondary, lightInk)
        }

        fun opaque(c: Int): Int = c or BLACK

        fun mix(a: Int, b: Int, t: Double): Int {
            fun ch(shift: Int) = (((a shr shift) and 0xFF) * (1 - t) + ((b shr shift) and 0xFF) * t).toInt().coerceIn(0, 255)
            return BLACK or (ch(16) shl 16) or (ch(8) shl 8) or ch(0)
        }

        fun luminance(c: Int): Double {
            fun lin(v: Int): Double {
                val s = v / 255.0
                return if (s <= 0.04045) s / 12.92 else ((s + 0.055) / 1.055).pow(2.4)
            }
            return 0.2126 * lin((c shr 16) and 0xFF) + 0.7152 * lin((c shr 8) and 0xFF) + 0.0722 * lin(c and 0xFF)
        }

        fun contrast(a: Int, b: Int): Double {
            val la = luminance(a)
            val lb = luminance(b)
            return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)
        }

        /** Identity of the inputs, so a renderer can tell whether the wallpaper changed. */
        fun key(primary: Int?, secondary: Int?, tertiary: Int?, dark: Boolean): Int =
            listOf(primary, secondary, tertiary, dark).hashCode()
    }
}
