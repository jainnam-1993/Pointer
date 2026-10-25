package com.dailypointer

import android.content.Context

/** Release builds: always the fixed glass alpha; the measurement override exists only in debug builds. */
object GlassAlpha {
    @Suppress("UNUSED_PARAMETER")
    fun current(context: Context): Double = GlassRule.FIXED_ALPHA
}
