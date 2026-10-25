package com.dailypointer

/**
 * The widget's surface treatment, as data, so the renderer has one place that applies it and the
 * design review could compare looks on real renders (debug builds can override it; see
 * WidgetLookSource in the debug source set).
 */
enum class WidgetSurface {
    /** Translucent dark glass over the wallpaper, white text (GlassRule). */
    GLASS,

    /** Opaque Material You tonal card (system_accent2/neutral tones), dark text in light mode. */
    TONAL,
}

enum class WidgetScrim {
    NONE,

    /** Rounded box behind the quote and teacher line (the 0.45 glass look the user called ugly). */
    BOX,
}

data class WidgetLook(val surface: WidgetSurface, val bodyAlpha: Double, val scrim: WidgetScrim) {
    companion object {
        /** The shipped look. */
        val SHIPPED = WidgetLook(WidgetSurface.TONAL, 1.0, WidgetScrim.NONE)

        /** The looks compared in the 2026-10-24 design review. */
        val REVIEW = mapOf(
            "current" to WidgetLook(WidgetSurface.GLASS, 0.45, WidgetScrim.BOX),
            "frosted" to WidgetLook(WidgetSurface.GLASS, 0.80, WidgetScrim.NONE),
            "tonal" to WidgetLook(WidgetSurface.TONAL, 1.0, WidgetScrim.NONE),
        )
    }
}
