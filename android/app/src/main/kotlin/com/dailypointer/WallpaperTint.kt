package com.dailypointer

import android.app.WallpaperColors
import android.app.WallpaperManager
import android.content.Context
import android.os.Build
import android.util.Log

/** Reads the wallpaper's colours (API 27+, no permission; the bitmap itself is never read). */
object WallpaperTint {
    /** The glass alpha for the current wallpaper (see [GlassRule]). */
    fun glassAlpha(context: Context): Double {
        val colors = read(context)
        val list = listOfNotNull(colors?.primaryColor?.toArgb(), colors?.secondaryColor?.toArgb(), colors?.tertiaryColor?.toArgb())
        val darkText = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && colors != null &&
            (colors.colorHints and WallpaperColors.HINT_SUPPORTS_DARK_TEXT) != 0
        val alpha = GlassRule.alpha(list, darkText)
        Log.i("PointerWidget", "Wallpaper colors $list darkText=$darkText -> glass alpha $alpha")
        return alpha
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
