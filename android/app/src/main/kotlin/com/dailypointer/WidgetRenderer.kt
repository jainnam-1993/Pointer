package com.dailypointer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import java.util.concurrent.Executors

/** One worker thread for all widget I/O: serializes store updates and keeps parsing off the main thread. */
object WidgetWork {
    private val executor = Executors.newSingleThreadExecutor()

    fun run(block: () -> Unit) = executor.execute {
        try {
            block()
        } catch (e: Exception) {
            Log.e("PointerWidget", "Widget work failed", e)
        }
    }

    fun runAsync(pending: BroadcastReceiver.PendingResult, block: () -> Unit) = executor.execute {
        try {
            block()
        } catch (e: Exception) {
            Log.e("PointerWidget", "Widget work failed", e)
        } finally {
            pending.finish()
        }
    }
}

/**
 * Renders the single current pointing into RemoteViews.
 *
 * Decision: RemoteViews with one item, not Glance. Glance would pull in the Compose runtime
 * (about 1-2 MB of APK) and a new rendering stack for a widget that shows one text item and
 * three buttons. A single RemoteViews item removes the RemoteViewsService, the adapter and the
 * shown-vs-stored desync that the old flipper had, with no new dependency.
 */
object WidgetRenderer {
    const val EXTRA_POINTING_ID = "pointing_id"
    const val ACTION_OPEN = "com.dailypointer.widget.OPEN"

    fun renderAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, PointerWidgetProvider::class.java))
        if (ids.isNotEmpty()) render(context, manager, ids)
    }

    fun render(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val pointings = PointingRepository.load(context)
        // Every render first catches up with the clock, so any update shows the current pointing.
        val state = WidgetStore.forContext(context).update { it.tick(System.currentTimeMillis()) }
        val index = WidgetOrder.indexAt(state.seed, pointings.size, state.position)
        val pointing = if (index >= 0) pointings[index] else null
        // One look for every wallpaper, with nothing to recompute when the wallpaper changes (a
        // wallpaper change redraws nothing). The tonal look's colours are system resources that
        // the launcher re-resolves on a wallpaper or theme change.
        val look = WidgetLookSource.current(context)
        for (id in ids) {
            manager.updateAppWidget(id, build(context, id, manager.getAppWidgetOptions(id), pointing, state, look))
        }
    }

    private fun build(
        context: Context, widgetId: Int, options: Bundle, pointing: WidgetPointing?, state: WidgetState,
        look: WidgetLook,
    ): RemoteViews {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val variants = WidgetSize.BREAKPOINTS.associate { (size, dims) ->
                SizeF(dims.first, dims.second) to views(context, widgetId, size, pointing, state, look, options)
            }
            return RemoteViews(variants)
        }
        val width = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 250).toFloat()
        val height = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 110).toFloat()
        return WidgetSize.forSize(width, height).let { views(context, widgetId, it, pointing, state, look, options) }
    }

    private fun views(
        context: Context, widgetId: Int, size: WidgetSize, pointing: WidgetPointing?, state: WidgetState,
        look: WidgetLook, options: Bundle,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, layoutFor(size, look))
        paint(context, views, size, look)
        if (pointing == null) {
            views.setTextViewText(R.id.widget_content, context.getString(R.string.widget_empty))
            views.setViewVisibility(R.id.widget_header, View.GONE)
            views.setViewVisibility(R.id.widget_teacher, View.GONE)
            views.setViewVisibility(R.id.widget_action_bar, View.GONE)
            return views
        }
        views.setTextViewText(R.id.widget_content, pointing.content)
        views.setInt(R.id.widget_content, "setMaxLines", size.contentLines)
        if (look.surface == WidgetSurface.APP || look.surface == WidgetSurface.GLASS) {
            // Brand serif: draw the quote ourselves (launchers ignore res/font in RemoteViews).
            val maxSp = when (size) { WidgetSize.COMPACT -> 32f; WidgetSize.MEDIUM -> 40f; WidgetSize.LARGE -> 46f }
            val bmp = QuoteBitmap.render(context, pointing.content, QuoteBitmap.boxFor(options, size), maxSp = maxSp)
            views.setImageViewBitmap(R.id.widget_quote_img, bmp)
            views.setContentDescription(R.id.widget_quote_img, pointing.content)
            views.setViewVisibility(R.id.widget_quote_img, View.VISIBLE)
            views.setViewVisibility(R.id.widget_content, View.GONE)
            // Glass is white ink in both modes; the XML tint (app ink) is for the app look.
            if (look.surface == WidgetSurface.GLASS) views.setInt(R.id.widget_quote_img, "setColorFilter", GlassRule.INK)
        } else {
            views.setViewVisibility(R.id.widget_quote_img, View.GONE)
            views.setViewVisibility(R.id.widget_content, View.VISIBLE)
        }
        views.setTextViewText(R.id.widget_tradition, pointing.tradition)
        views.setViewVisibility(R.id.widget_header, if (size.showHeader) View.VISIBLE else View.GONE)
        views.setTextViewText(R.id.widget_teacher, teacherLine(pointing, size))
        views.setViewVisibility(R.id.widget_teacher, if (size.showTeacher && teacherLine(pointing, size).isNotEmpty()) View.VISIBLE else View.GONE)
        views.setViewVisibility(R.id.widget_action_bar, if (size.showActions) View.VISIBLE else View.GONE)

        // Open carries the id that is on screen, so it always acts on the shown item.
        views.setOnClickPendingIntent(R.id.widget_content_area, openIntent(context, widgetId, pointing.id))
        // The small layout has no controls; only sizes with an action bar wire Save, Previous and Next.
        if (size.showActions) {
            val saved = state.isFavorite(pointing.id)
            val tonal = look.surface == WidgetSurface.TONAL
            views.setImageViewResource(
                R.id.widget_save,
                when {
                    look.surface == WidgetSurface.APP && saved -> R.drawable.ic_heart_filled_app
                    look.surface == WidgetSurface.APP -> R.drawable.ic_heart_outline_app
                    tonal && saved -> R.drawable.ic_heart_filled_tonal
                    tonal -> R.drawable.ic_heart_outline_tonal
                    saved -> R.drawable.ic_heart_filled
                    else -> R.drawable.ic_heart_outline
                },
            )
            views.setContentDescription(R.id.widget_save, context.getString(if (saved) R.string.widget_saved else R.string.widget_save))
            views.setOnClickPendingIntent(R.id.widget_save, actionIntent(context, widgetId, WidgetActionReceiver.ACTION_SAVE, pointing.id))
            views.setOnClickPendingIntent(R.id.widget_prev, actionIntent(context, widgetId, WidgetActionReceiver.ACTION_PREV, pointing.id))
            views.setOnClickPendingIntent(R.id.widget_next, actionIntent(context, widgetId, WidgetActionReceiver.ACTION_NEXT, pointing.id))
        }
        return views
    }

    /** Applies the look: surface, scrim, and the two text levels (quote, then teacher and eyebrow). */
    private fun paint(context: Context, views: RemoteViews, size: WidgetSize, look: WidgetLook) {
        val scrim = if (look.scrim == WidgetScrim.BOX) R.drawable.widget_text_scrim else 0
        views.setInt(R.id.widget_content_area, "setBackgroundResource", scrim)
        views.setInt(R.id.widget_teacher, "setBackgroundResource", scrim)
        when (look.surface) {
            WidgetSurface.GLASS, WidgetSurface.CLEAR -> {
                views.setImageViewResource(R.id.widget_frost_bg, R.drawable.widget_glass)
                views.setInt(R.id.widget_frost_bg, "setImageAlpha", (look.bodyAlpha * 255).toInt().coerceIn(0, 255))
                val secondary = (0xD9 shl 24) or (GlassRule.INK and 0xFFFFFF)
                views.setTextColor(R.id.widget_content, GlassRule.INK)
                views.setTextColor(R.id.widget_teacher, secondary)
                views.setTextColor(R.id.widget_tradition, secondary)
                if (size.showActions) {
                    for (id in intArrayOf(R.id.widget_save, R.id.widget_prev, R.id.widget_next)) views.setInt(id, "setColorFilter", GlassRule.INK)
                    views.setInt(R.id.widget_pill, "setBackgroundResource", R.drawable.widget_pill_on_dark)
                }
            }
            WidgetSurface.APP -> {
                views.setImageViewResource(R.id.widget_frost_bg, R.drawable.widget_app_glass)
                views.setInt(R.id.widget_frost_bg, "setImageAlpha", (look.bodyAlpha * 255).toInt().coerceIn(0, 255))
                tint(context, views, R.id.widget_content, "setTextColor", R.color.widget_app_ink)
                tint(context, views, R.id.widget_teacher, "setTextColor", R.color.widget_app_ink_secondary)
                tint(context, views, R.id.widget_tradition, "setTextColor", R.color.widget_app_accent)
                if (size.showActions) {
                    views.setImageViewResource(R.id.widget_prev, R.drawable.ic_chevron_left_app)
                    views.setImageViewResource(R.id.widget_next, R.drawable.ic_chevron_right_app)
                    views.setInt(R.id.widget_save, "setBackgroundResource", R.drawable.widget_save_app)
                    views.setInt(R.id.widget_pill, "setBackgroundResource", R.drawable.widget_pill_app)
                }
            }
            WidgetSurface.TONAL -> {
                views.setImageViewResource(R.id.widget_frost_bg, R.drawable.widget_tonal)
                views.setInt(R.id.widget_frost_bg, "setImageAlpha", (look.bodyAlpha * 255).toInt().coerceIn(0, 255))
                tint(context, views, R.id.widget_content, "setTextColor", R.color.widget_text)
                tint(context, views, R.id.widget_teacher, "setTextColor", R.color.widget_text_muted)
                tint(context, views, R.id.widget_tradition, "setTextColor", R.color.widget_accent)
                if (size.showActions) {
                    // Tonal controls: secondary-tone fills with glyph drawables whose colour is a
                    // resource (widget_on_control), so the launcher resolves it; no runtime tint.
                    views.setImageViewResource(R.id.widget_prev, R.drawable.ic_chevron_left_tonal)
                    views.setImageViewResource(R.id.widget_next, R.drawable.ic_chevron_right_tonal)
                    views.setInt(R.id.widget_save, "setBackgroundResource", R.drawable.widget_save_tonal)
                    views.setInt(R.id.widget_pill, "setBackgroundResource", R.drawable.widget_pill_tonal)
                }
            }
        }
    }

    /**
     * Android 12+: pass the colour as a resource, so the launcher resolves it (and re-resolves it on
     * a wallpaper or theme change) with no app code running. Older versions get the resolved colour.
     */
    private fun tint(context: Context, views: RemoteViews, id: Int, method: String, color: Int) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            views.setColorStateList(id, method, color)
        } else if (method == "setTextColor") {
            views.setTextColor(id, context.getColor(color))
        } else {
            views.setInt(id, "setColorFilter", context.getColor(color))
        }
    }

    /** Each size has its own layout (small, medium, large) rather than one stretched layout. */
    fun layoutFor(size: WidgetSize, look: WidgetLook = WidgetLook.SHIPPED): Int = if (look.surface == WidgetSurface.CLEAR) {
        // Text shadows are XML-only in RemoteViews, so the clear look has its own layouts.
        when (size) {
            WidgetSize.COMPACT -> R.layout.pointer_widget_clear_small
            WidgetSize.MEDIUM -> R.layout.pointer_widget_clear
            WidgetSize.LARGE -> R.layout.pointer_widget_clear_large
        }
    } else when (size) {
        WidgetSize.COMPACT -> R.layout.pointer_widget_small
        WidgetSize.MEDIUM -> R.layout.pointer_widget
        WidgetSize.LARGE -> R.layout.pointer_widget_large
    }

    /** Medium has no tradition eyebrow, so its footer carries the tradition after the teacher. */
    fun teacherLine(pointing: WidgetPointing, size: WidgetSize): String {
        if (pointing.teacher.isEmpty()) return if (size == WidgetSize.MEDIUM) pointing.tradition else ""
        return if (size == WidgetSize.MEDIUM) "\u2014 ${pointing.teacher} \u00b7 ${pointing.tradition}" else "\u2014 ${pointing.teacher}"
    }

    private fun openIntent(context: Context, widgetId: Int, pointingId: String): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = ACTION_OPEN
            putExtra(EXTRA_POINTING_ID, pointingId)
            // singleTop activity: a running app gets onNewIntent instead of a task restart.
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        return PendingIntent.getActivity(context, widgetId * 10, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }

    private fun actionIntent(context: Context, widgetId: Int, action: String, pointingId: String): PendingIntent {
        val intent = Intent(context, WidgetActionReceiver::class.java).apply {
            this.action = action
            putExtra(EXTRA_POINTING_ID, pointingId)
        }
        val code = widgetId * 10 + WidgetActionReceiver.ACTIONS.indexOf(action) + 1
        return PendingIntent.getBroadcast(context, code, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }
}
