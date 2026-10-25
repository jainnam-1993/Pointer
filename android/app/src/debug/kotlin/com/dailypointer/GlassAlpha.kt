package com.dailypointer

import android.content.Context

/**
 * Debug builds only: the fixed glass alpha, unless the measurement sweep set an override through
 * DebugWallpaperReceiver (--es glass_alpha 0.6; -1 clears). Release and profile builds have their
 * own GlassAlpha that returns GlassRule.FIXED_ALPHA (ManifestSafetyTest).
 */
object GlassAlpha {
    const val PREFS = "widget_debug"
    const val KEY = "glass_alpha"

    fun current(context: Context): Double {
        val override = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getFloat(KEY, -1f)
        return if (override in 0f..1f) override.toDouble() else GlassRule.FIXED_ALPHA
    }
}
