package com.dailypointer

import android.content.Context

/** Profile builds: always the shipped look; the review override exists only in debug builds. */
object WidgetLookSource {
    @Suppress("UNUSED_PARAMETER")
    fun current(context: Context): WidgetLook = WidgetLook.SHIPPED
}
