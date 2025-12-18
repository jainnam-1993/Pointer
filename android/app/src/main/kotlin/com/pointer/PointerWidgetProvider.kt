package com.pointer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.Toast
import com.pointer.R
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

/**
 * Home screen widget provider for Pointer app.
 * Displays the daily pointing with tradition and teacher attribution.
 * Supports interactive actions: refresh and save.
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

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        when (intent.action) {
            ACTION_REFRESH -> {
                // Send background intent to Flutter for refresh
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    android.net.Uri.parse("pointer://widget/refresh")
                )
                backgroundIntent.send()

                // Show brief feedback
                Toast.makeText(context, "Refreshing...", Toast.LENGTH_SHORT).show()
            }
            ACTION_SAVE -> {
                // Send background intent to Flutter for save
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    android.net.Uri.parse("pointer://widget/save")
                )
                backgroundIntent.send()

                // Show brief feedback
                Toast.makeText(context, "Saved to favorites", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onEnabled(context: Context) {
        // Called when first widget is placed
    }

    override fun onDisabled(context: Context) {
        // Called when last widget is removed
    }

    companion object {
        private const val KEY_CONTENT = "pointing_content"
        private const val KEY_TEACHER = "pointing_teacher"
        private const val KEY_TRADITION = "pointing_tradition"

        const val ACTION_REFRESH = "com.pointer.widget.ACTION_REFRESH"
        const val ACTION_SAVE = "com.pointer.widget.ACTION_SAVE"

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

            // Get user preferences from config
            val theme = WidgetConfigActivity.getTheme(context, appWidgetId)
            val showTeacher = WidgetConfigActivity.shouldShowTeacher(context, appWidgetId)

            // Choose layout based on theme
            val layoutId = if (theme == WidgetConfigActivity.THEME_LIGHT) {
                R.layout.pointer_widget_light
            } else {
                R.layout.pointer_widget
            }

            // Build the widget layout
            val views = RemoteViews(context.packageName, layoutId)
            views.setTextViewText(R.id.widget_content, content)

            // Show teacher if available AND user wants to see it
            if (!teacher.isNullOrEmpty() && showTeacher) {
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

            // Set click action to open app (entire widget)
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            }
            val launchPendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, launchPendingIntent)

            // Set refresh button action
            val refreshIntent = Intent(context, PointerWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
            }
            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                1,
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_refresh, refreshPendingIntent)

            // Set save button action
            val saveIntent = Intent(context, PointerWidgetProvider::class.java).apply {
                action = ACTION_SAVE
            }
            val savePendingIntent = PendingIntent.getBroadcast(
                context,
                2,
                saveIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_save, savePendingIntent)

            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
