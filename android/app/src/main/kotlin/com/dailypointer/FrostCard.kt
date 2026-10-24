package com.dailypointer

import android.app.WallpaperColors
import android.app.WallpaperManager
import android.content.Context
import android.content.res.Configuration
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Shader
import android.os.Build
import android.util.Log
import kotlin.random.Random

/** Reads the wallpaper's colors (API 27+, no permission; the bitmap itself is never read). */
object WallpaperTint {
    fun palette(context: Context): FrostPalette {
        val dark = (context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        val colors = read(context)
        Log.i("PointerWidget", "Wallpaper colors primary=${colors?.primaryColor} secondary=${colors?.secondaryColor} tertiary=${colors?.tertiaryColor} dark=$dark")
        return FrostPalette.from(colors?.primaryColor?.toArgb(), colors?.secondaryColor?.toArgb(), colors?.tertiaryColor?.toArgb(), dark)
    }

    private fun read(context: Context): WallpaperColors? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1) return null
        return try {
            WallpaperManager.getInstance(context).getWallpaperColors(WallpaperManager.FLAG_SYSTEM)
        } catch (e: Exception) {
            Log.w("PointerWidget", "Wallpaper colors unavailable", e)
            null
        }
    }
}

/**
 * Paints the opaque frosted card: a soft diagonal gradient between the palette stops, a sheen
 * over the upper half, a gentle shade at the bottom edge and static grain (fixed seed, so it
 * never shimmers). The rim, top highlight and corners stay in XML so they are crisp at any size.
 */
object FrostCard {
    /** Small on purpose: the card is smooth, and RemoteViews bitmaps count against a memory cap. */
    private const val WIDTH = 360
    private const val GRAIN_SEED = 7

    fun bitmap(palette: FrostPalette, aspect: Float): Bitmap {
        val w = WIDTH
        val h = (WIDTH / aspect.coerceIn(0.5f, 4f)).toInt().coerceAtLeast(60)
        val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val c = Canvas(bmp)
        val p = Paint(Paint.ANTI_ALIAS_FLAG)
        p.shader = LinearGradient(0f, 0f, w * 0.6f, h.toFloat(), palette.top, palette.bottom, Shader.TileMode.CLAMP)
        c.drawRect(0f, 0f, w.toFloat(), h.toFloat(), p)
        val sheen = (FrostPalette.SHEEN * 255).toInt() shl 24 or 0xFFFFFF
        p.shader = LinearGradient(0f, 0f, 0f, h * 0.5f, sheen, 0x00FFFFFF, Shader.TileMode.CLAMP)
        c.drawRect(0f, 0f, w.toFloat(), h * 0.5f, p)
        val shade = (FrostPalette.SHADE * 255).toInt() shl 24
        p.shader = LinearGradient(0f, h * 0.6f, 0f, h.toFloat(), 0x00000000, shade, Shader.TileMode.CLAMP)
        c.drawRect(0f, h * 0.6f, w.toFloat(), h.toFloat(), p)
        p.shader = null
        // Grain: about 3% average, alternating light and dark specks.
        val rnd = Random(GRAIN_SEED)
        repeat(w * h / 3) {
            val a = rnd.nextInt(4, 14)
            p.color = (a shl 24) or (if (rnd.nextBoolean()) 0xFFFFFF else 0x000000)
            c.drawPoint(rnd.nextInt(w).toFloat(), rnd.nextInt(h).toFloat(), p)
        }
        // Opaque by construction: every pixel started from the opaque gradient.
        return bmp
    }
}
