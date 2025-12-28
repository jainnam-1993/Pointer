package com.pointer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import android.util.Log
import android.widget.RemoteViews
import android.widget.Toast
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Home screen widget provider for Pointer app.
 * Displays a scrollable StackView of pointings.
 * Auto-rotates every 30 minutes and supports manual refresh/save.
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

        // Auto-rotate: advance the displayed pointing on each update (every 30 min)
        advanceStackPosition(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        Log.d(TAG, "onReceive: ${intent.action}")

        when (intent.action) {
            ACTION_REFRESH -> {
                // Send background intent to Flutter for refresh
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("pointer://widget/refresh")
                )
                backgroundIntent.send()

                // Show brief feedback
                Toast.makeText(context, "Refreshing...", Toast.LENGTH_SHORT).show()

                // Notify all widgets to refresh their data
                notifyDataChanged(context)
            }
            ACTION_SAVE -> {
                // Get the current pointing ID from intent
                val pointingId = intent.getStringExtra(EXTRA_POINTING_ID)
                Log.d(TAG, "Save action for pointing: $pointingId")

                // Send background intent to Flutter for save
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("pointer://widget/save")
                )
                backgroundIntent.send()

                // Show brief feedback
                Toast.makeText(context, "Saved to favorites", Toast.LENGTH_SHORT).show()
            }
            ACTION_ITEM_CLICK -> {
                // User tapped on a stack item - open app
                val pointingId = intent.getStringExtra(PointerRemoteViewsFactory.EXTRA_POINTING_ID)
                val position = intent.getIntExtra(PointerRemoteViewsFactory.EXTRA_POINTING_POSITION, 0)
                Log.d(TAG, "Item click: position=$position, id=$pointingId")

                // Launch the app
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                    putExtra("pointing_id", pointingId)
                }
                context.startActivity(launchIntent)
            }
            ACTION_PREV -> {
                Log.d(TAG, "Previous action - showing previous item")
                showPreviousItem(context)
            }
            ACTION_NEXT -> {
                Log.d(TAG, "Next action - showing next item")
                showNextItem(context)
            }
            Intent.ACTION_CONFIGURATION_CHANGED -> {
                Log.d(TAG, "Configuration changed - updating widgets for theme change")
                updateAllWidgets(context)
            }
        }
    }

    /**
     * Show previous item in all widget flippers
     */
    private fun showPreviousItem(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, PointerWidgetProvider::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
        val isDarkMode = isSystemInDarkMode(context)
        val layoutId = if (isDarkMode) R.layout.pointer_widget else R.layout.pointer_widget_light

        // Get total count from cache
        val widgetData = HomeWidgetPlugin.getData(context)
        val cacheJson = widgetData?.getString("pointings_cache", null)
        val totalCount = if (!cacheJson.isNullOrEmpty()) {
            try {
                org.json.JSONArray(cacheJson).length()
            } catch (e: Exception) { 1 }
        } else 1

        // Get and update current position
        val prefs = context.getSharedPreferences("widget_prefs", Context.MODE_PRIVATE)
        var currentPosition = prefs.getInt("flipper_position", 0)
        currentPosition = if (currentPosition <= 0) totalCount - 1 else currentPosition - 1
        prefs.edit().putInt("flipper_position", currentPosition).apply()

        Log.d(TAG, "showPrevious: position=$currentPosition of $totalCount")

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, layoutId)
            views.setDisplayedChild(R.id.widget_flipper, currentPosition)
            appWidgetManager.partiallyUpdateAppWidget(appWidgetId, views)
        }
    }

    /**
     * Show next item in all widget flippers
     */
    private fun showNextItem(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, PointerWidgetProvider::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
        val isDarkMode = isSystemInDarkMode(context)
        val layoutId = if (isDarkMode) R.layout.pointer_widget else R.layout.pointer_widget_light

        // Get total count from cache
        val widgetData = HomeWidgetPlugin.getData(context)
        val cacheJson = widgetData?.getString("pointings_cache", null)
        val totalCount = if (!cacheJson.isNullOrEmpty()) {
            try {
                org.json.JSONArray(cacheJson).length()
            } catch (e: Exception) { 1 }
        } else 1

        // Get and update current position
        val prefs = context.getSharedPreferences("widget_prefs", Context.MODE_PRIVATE)
        var currentPosition = prefs.getInt("flipper_position", 0)
        currentPosition = (currentPosition + 1) % totalCount
        prefs.edit().putInt("flipper_position", currentPosition).apply()

        Log.d(TAG, "showNext: position=$currentPosition of $totalCount")

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, layoutId)
            views.setDisplayedChild(R.id.widget_flipper, currentPosition)
            appWidgetManager.partiallyUpdateAppWidget(appWidgetId, views)
        }
    }

    override fun onEnabled(context: Context) {
        Log.d(TAG, "onEnabled: First widget placed")
        // Request initial data load from Flutter
        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("pointer://widget/refresh")
        )
        backgroundIntent.send()
    }

    override fun onDisabled(context: Context) {
        Log.d(TAG, "onDisabled: Last widget removed")
    }

    companion object {
        private const val TAG = "PointerWidget"

        const val ACTION_REFRESH = "com.pointer.widget.ACTION_REFRESH"
        const val ACTION_SAVE = "com.pointer.widget.ACTION_SAVE"
        const val ACTION_ITEM_CLICK = "com.pointer.widget.ACTION_ITEM_CLICK"
        const val ACTION_PREV = "com.pointer.widget.ACTION_PREV"
        const val ACTION_NEXT = "com.pointer.widget.ACTION_NEXT"

        const val EXTRA_POINTING_ID = "pointing_id"

        /**
         * Check if system is in dark mode
         */
        fun isSystemInDarkMode(context: Context): Boolean {
            val nightMode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
            return nightMode == Configuration.UI_MODE_NIGHT_YES
        }

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

        /**
         * Notify widgets that data has changed (triggers onDataSetChanged in factory)
         */
        fun notifyDataChanged(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, PointerWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            Log.d(TAG, "notifyDataChanged: ${appWidgetIds.size} widgets")
            for (appWidgetId in appWidgetIds) {
                appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_flipper)
            }
        }

        /**
         * Advance the stack position on auto-update (every 30 minutes).
         * This creates the auto-rotation effect.
         */
        private fun advanceStackPosition(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetIds: IntArray
        ) {
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val cacheJson = widgetData?.getString("pointings_cache", null)

                if (cacheJson.isNullOrEmpty()) {
                    Log.d(TAG, "No cache found, requesting initial load")
                    // Request Flutter to load initial data
                    val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("pointer://widget/refresh")
                    )
                    backgroundIntent.send()
                    return
                }

                // Notify data changed to potentially show different item
                for (appWidgetId in appWidgetIds) {
                    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_flipper)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error advancing stack: ${e.message}", e)
            }
        }

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            Log.d(TAG, "updateAppWidget START: widgetId=$appWidgetId")

            // Auto-detect system theme
            val isDarkMode = isSystemInDarkMode(context)
            Log.d(TAG, "System theme: ${if (isDarkMode) "DARK" else "LIGHT"}")

            // Choose layout based on system theme
            val layoutId = if (isDarkMode) {
                R.layout.pointer_widget
            } else {
                R.layout.pointer_widget_light
            }

            val views = RemoteViews(context.packageName, layoutId)

            // Set up AdapterViewFlipper with RemoteViewsService
            val serviceIntent = Intent(context, PointerWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                // Make intent unique per widget
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            views.setRemoteAdapter(R.id.widget_flipper, serviceIntent)

            // Set empty view for when no data
            views.setEmptyView(R.id.widget_flipper, R.id.widget_empty_state)

            // Set up pending intent template for item clicks (open app)
            val itemClickIntent = Intent(context, PointerWidgetProvider::class.java).apply {
                action = ACTION_ITEM_CLICK
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val itemClickPendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId * 10,
                itemClickIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
            )
            views.setPendingIntentTemplate(R.id.widget_flipper, itemClickPendingIntent)

            // Set up Previous button
            val prevIntent = Intent(context, PointerWidgetProvider::class.java).apply {
                action = ACTION_PREV
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val prevPendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId * 10 + 3,
                prevIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_prev, prevPendingIntent)

            // Set up Next button
            val nextIntent = Intent(context, PointerWidgetProvider::class.java).apply {
                action = ACTION_NEXT
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val nextPendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId * 10 + 4,
                nextIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_next, nextPendingIntent)

            // Set refresh button action
            val refreshIntent = Intent(context, PointerWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId * 10 + 1,
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
                appWidgetId * 10 + 2,
                saveIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_save, savePendingIntent)

            // Update the widget
            Log.d(TAG, "Calling appWidgetManager.updateAppWidget for $appWidgetId")
            try {
                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "updateAppWidget COMPLETED SUCCESSFULLY for $appWidgetId")
            } catch (e: Exception) {
                Log.e(TAG, "EXCEPTION in updateAppWidget: ${e.message}", e)
            }
        }
    }
}
