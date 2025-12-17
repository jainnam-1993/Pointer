package com.pointer

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import com.pointer.R
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Home screen widget provider for Pointer app.
 * Displays the daily pointing with tradition and teacher attribution.
 */
class PointerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Called when first widget is placed
    }

    override fun onDisabled(context: Context) {
        // Called when last widget is removed
    }

    companion object {
        private const val PREFS_NAME = "PointerWidgetPrefs"
        private const val KEY_CONTENT = "pointing_content"
        private const val KEY_TEACHER = "pointing_teacher"
        private const val KEY_TRADITION = "pointing_tradition"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            // Get data from home_widget shared storage
            val widgetData = HomeWidgetPlugin.getData(context)

            val content = widgetData.getString(KEY_CONTENT, "Tap to receive today's pointing")
            val teacher = widgetData.getString(KEY_TEACHER, "")
            val tradition = widgetData.getString(KEY_TRADITION, "")

            // Build the widget layout
            val views = RemoteViews(context.packageName, R.layout.pointer_widget)
            views.setTextViewText(R.id.widget_content, content)

            // Show teacher if available
            if (!teacher.isNullOrEmpty()) {
                views.setTextViewText(R.id.widget_teacher, "— $teacher")
                views.setViewVisibility(R.id.widget_teacher, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_teacher, android.view.View.GONE)
            }

            // Show tradition badge
            if (!tradition.isNullOrEmpty()) {
                views.setTextViewText(R.id.widget_tradition, tradition)
                views.setViewVisibility(R.id.widget_tradition, android.view.View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_tradition, android.view.View.GONE)
            }

            // Set click action to open app
            val launchIntent = android.content.Intent(context, MainActivity::class.java).apply {
                flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK or android.content.Intent.FLAG_ACTIVITY_CLEAR_TASK
            }
            val pendingIntent = android.app.PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
