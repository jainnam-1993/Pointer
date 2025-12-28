package com.pointer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
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
        Log.d(TAG, "onUpdate called for ${appWidgetIds.size} widgets")
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        Log.d(TAG, "onReceive: ${intent.action}")

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

                // Also trigger immediate widget update
                updateAllWidgets(context)
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
        Log.d(TAG, "onEnabled: First widget placed")
    }

    override fun onDisabled(context: Context) {
        Log.d(TAG, "onDisabled: Last widget removed")
    }

    companion object {
        private const val TAG = "PointerWidget"
        private const val KEY_CONTENT = "pointing_content"
        private const val KEY_TEACHER = "pointing_teacher"
        private const val KEY_TRADITION = "pointing_tradition"

        const val ACTION_REFRESH = "com.pointer.widget.ACTION_REFRESH"
        const val ACTION_SAVE = "com.pointer.widget.ACTION_SAVE"

        /**
         * Update all widget instances
         */
        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, PointerWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            Log.d(TAG, "updateAllWidgets: Found ${appWidgetIds.size} widgets")
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        }

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            Log.d(TAG, "updateAppWidget: widgetId=$appWidgetId")

            // Get data from home_widget shared storage with null safety
            val widgetData = try {
                HomeWidgetPlugin.getData(context)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to get widget data: ${e.message}")
                null
            }

            // Read content with fallbacks
            val content = widgetData?.getString(KEY_CONTENT, null)
                ?.takeIf { it.isNotEmpty() }
                ?: "Tap to open Pointer"
            val teacher = widgetData?.getString(KEY_TEACHER, "") ?: ""
            val tradition = widgetData?.getString(KEY_TRADITION, "") ?: ""

            Log.d(TAG, "Widget data - content: ${content.take(30)}..., tradition: $tradition, teacher: $teacher")

            // Get user preferences from config
            val theme = WidgetConfigActivity.getTheme(context, appWidgetId)
            val showTeacher = WidgetConfigActivity.shouldShowTeacher(context, appWidgetId)
            Log.d(TAG, "Widget config - theme: $theme, showTeacher: $showTeacher")

            // Choose layout based on theme
            val layoutId = if (theme == WidgetConfigActivity.THEME_LIGHT) {
                Log.d(TAG, "Using LIGHT theme layout")
                R.layout.pointer_widget_light
            } else {
                Log.d(TAG, "Using DARK theme layout")
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
            // Use unique request code per widget to avoid PendingIntent conflicts
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                // Add widget ID to make intent unique
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val launchPendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId * 10,  // Unique request code
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, launchPendingIntent)

            // Set refresh button action
            val refreshIntent = Intent(context, PointerWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId * 10 + 1,  // Unique request code
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_refresh, refreshPendingIntent)

            // Set save button action
            val saveIntent = Intent(context, PointerWidgetProvider::class.java).apply {
                action = ACTION_SAVE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val savePendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId * 10 + 2,  // Unique request code
                saveIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_save, savePendingIntent)

            // Update the widget
            Log.d(TAG, "Updating widget $appWidgetId with layout $layoutId")
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
