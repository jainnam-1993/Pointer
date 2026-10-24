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
        private const val INK_DARK = 0xFF1D1B20.toInt()
        private const val INK_LIGHT = 0xFFF5F2EE.toInt()

        /** Sheen (upper half) and shade (lower edge) strengths drawn by the card renderer. */
        const val SHEEN = 0.06
        const val SHADE = 0.08


        /**
         * [primary], [secondary] and [tertiary] are WallpaperColors ARGB values (null when absent).
         * [dark] follows the system night mode.
         */
        fun from(primary: Int?, secondary: Int?, tertiary: Int?, dark: Boolean): FrostPalette {
            // Tint source: the wallpaper's most colorful of primary/secondary/tertiary, so a white
            // or grey primary over a colored wallpaper still tints the card. No colors: a calm violet.
            val source = listOfNotNull(primary, secondary, tertiary).maxByOrNull { Oklch.of(it).c }
            val lch = source?.let { Oklch.of(it) } ?: Oklch(0.5, 0.05, 300.0)
            val neutral = lch.c < NEUTRAL_CHROMA
            // visionOS-style glass: a MID-TONE panel in the scene's own color, with white text.
            // Moderate chroma (0.035-0.075) at the wallpaper hue; neutral wallpapers stay a soft grey.
            val c = if (neutral) 0.012 else (lch.c * 0.55).coerceIn(0.035, 0.075)
            val h = if (neutral) 70.0 else lch.h
            // Start at the target lightness and step down until white text clears 4.5:1 over every
            // shade the card shows (sheen included) and 70% white clears 3:1.
            var lTop = if (dark) 0.44 else 0.54
            while (true) {
                val p = withWhiteInk(Oklch(lTop, c, h).toArgb(), Oklch(lTop - 0.05, c * 1.1, h + 8).toArgb())
                val probe = p.cardExtremes()
                val ok = probe.minOf { contrast(p.ink, it) } >= 4.6 && probe.minOf { contrast(p.secondary, it) } >= 3.1
                if (ok || lTop <= 0.30) return p
                lTop -= 0.01
            }
        }

        /** Below this OKLCH chroma a wallpaper reads as white, grey or black. */
        private const val NEUTRAL_CHROMA = 0.02

        /** White ink, and secondary text as white at 70% over the card (the target's two levels). */
        fun withWhiteInk(top: Int, bottom: Int): FrostPalette =
            FrostPalette(top, bottom, INK_LIGHT, mix(mix(top, bottom, 0.5), INK_LIGHT, 0.70), lightInk = true)

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

/** OKLCH (Björn Ottosson's OKLab in polar form), for perceptual tinting with gamut clamping. */
data class Oklch(val l: Double, val c: Double, val h: Double) {
    fun toArgb(): Int {
        var chroma = c
        repeat(30) {
            val rgb = toLinear(l, chroma, h)
            if (rgb.all { it in -0.0005..1.0005 }) return pack(rgb)
            chroma *= 0.9
        }
        return pack(toLinear(l, 0.0, h))
    }

    companion object {
        fun of(argb: Int): Oklch {
            fun lin(v: Int): Double {
                val s = v / 255.0
                return if (s <= 0.04045) s / 12.92 else Math.pow((s + 0.055) / 1.055, 2.4)
            }
            val r = lin((argb shr 16) and 0xFF); val g = lin((argb shr 8) and 0xFF); val b = lin(argb and 0xFF)
            val l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
            val m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
            val s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
            val okL = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
            val okA = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
            val okB = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
            val h = Math.toDegrees(Math.atan2(okB, okA)).let { if (it < 0) it + 360 else it }
            return Oklch(okL, Math.hypot(okA, okB), h)
        }

        private fun toLinear(L: Double, c: Double, hDeg: Double): DoubleArray {
            val a = c * Math.cos(Math.toRadians(hDeg)); val b = c * Math.sin(Math.toRadians(hDeg))
            val l = Math.pow(L + 0.3963377774 * a + 0.2158037573 * b, 3.0)
            val m = Math.pow(L - 0.1055613458 * a - 0.0638541728 * b, 3.0)
            val s = Math.pow(L - 0.0894841775 * a - 1.2914855480 * b, 3.0)
            return doubleArrayOf(
                4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
                -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
                -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
            )
        }

        private fun pack(rgb: DoubleArray): Int {
            fun enc(v: Double): Int {
                val x = v.coerceIn(0.0, 1.0)
                val s = if (x <= 0.0031308) 12.92 * x else 1.055 * Math.pow(x, 1 / 2.4) - 0.055
                return (s * 255 + 0.5).toInt().coerceIn(0, 255)
            }
            return (0xFF shl 24) or (enc(rgb[0]) shl 16) or (enc(rgb[1]) shl 8) or enc(rgb[2])
        }
    }
}

