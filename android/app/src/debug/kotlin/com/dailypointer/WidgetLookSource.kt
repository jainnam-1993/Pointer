package com.dailypointer

import android.content.Context

/**
 * Debug builds only: the shipped look, unless the design review set one through
 * DebugWallpaperReceiver (--es look current|frosted|tonal; --es look shipped clears).
 * Release and profile builds return WidgetLook.SHIPPED (ManifestSafetyTest).
 */
object WidgetLookSource {
    const val PREFS = "widget_debug"
    const val KEY = "look"

    fun current(context: Context): WidgetLook {
        val name = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
        return WidgetLook.REVIEW[name] ?: WidgetLook.SHIPPED
    }
}
