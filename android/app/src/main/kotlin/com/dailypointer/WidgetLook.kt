package com.dailypointer

/**
 * The widget's surface treatment, as data, so the renderer has one place that applies it and the
 * design review could compare looks on real renders (debug builds can override it; see
 * WidgetLookSource in the debug source set).
 */
enum class WidgetSurface {
    /** Translucent dark glass over the wallpaper, white text (GlassRule). */
    GLASS,

    /** No panel: white text with a soft legibility shadow straight on the wallpaper (iOS clear style). */
    CLEAR,

    /**
     * The app's own glass card on the home screen: sage-and-sand paper (light) or ink on black
     * (dark) at the look's body alpha over the wallpaper, a soft sheen and the app's thin bright
     * rim, the app's ink colours, Newsreader and Inter, and sage (dark: lavender) glass pills with
     * line icons. No Material You neutral.
     */
    APP,

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
            "tonal-glass" to WidgetLook(WidgetSurface.TONAL, 0.85, WidgetScrim.NONE),
            "clear" to WidgetLook(WidgetSurface.CLEAR, 0.0, WidgetScrim.NONE),
            "app-72" to WidgetLook(WidgetSurface.APP, 0.72, WidgetScrim.NONE),
            "app-82" to WidgetLook(WidgetSurface.APP, 0.82, WidgetScrim.NONE),
            "app-90" to WidgetLook(WidgetSurface.APP, 0.90, WidgetScrim.NONE),
        )
    }
}
