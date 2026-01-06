package com.dailypointer

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

        // Check for theme change first - ensures widget shows correct theme
        checkAndHandleThemeChange(context)

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
        // Check for theme change first - if changed, full update was triggered
        if (checkAndHandleThemeChange(context)) {
            Log.d(TAG, "showPrevious: Theme changed, full update triggered")
        }

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
            // Update save button to reflect favorite status of new position
            updateSaveButton(context, views)
            appWidgetManager.partiallyUpdateAppWidget(appWidgetId, views)
        }
    }

    /**
     * Show next item in all widget flippers
     */
    private fun showNextItem(context: Context) {
        // Check for theme change first - if changed, full update was triggered
        if (checkAndHandleThemeChange(context)) {
            Log.d(TAG, "showNext: Theme changed, full update triggered")
        }

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
            // Update save button to reflect favorite status of new position
            updateSaveButton(context, views)
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
        private const val PREFS_NAME = "widget_prefs"
        private const val KEY_LAST_DARK_MODE = "last_dark_mode"
        private const val KEY_FAVORITES = "widget_favorites"
        private const val KEY_POINTINGS_CACHE = "pointings_cache"

        // Heart icons for favorite/non-favorite states
        private const val HEART_EMPTY = "♡"
        private const val HEART_FILLED = "♥"

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
         * Get the pointing ID at the current flipper position
         */
        private fun getCurrentPointingId(context: Context): String? {
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val cacheJson = widgetData?.getString(KEY_POINTINGS_CACHE, null) ?: return null

                val jsonArray = org.json.JSONArray(cacheJson)
                if (jsonArray.length() == 0) return null

                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val position = prefs.getInt("flipper_position", 0)

                val safePosition = if (position >= 0 && position < jsonArray.length()) position else 0
                return jsonArray.getJSONObject(safePosition).optString("id", null)
            } catch (e: Exception) {
                Log.e(TAG, "Error getting current pointing ID: ${e.message}")
                return null
            }
        }

        /**
         * Check if a pointing ID is in the favorites list
         */
        private fun isPointingFavorite(context: Context, pointingId: String?): Boolean {
            if (pointingId == null) return false
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val favoritesJson = widgetData?.getString(KEY_FAVORITES, null) ?: return false

                val jsonArray = org.json.JSONArray(favoritesJson)
                for (i in 0 until jsonArray.length()) {
                    if (jsonArray.getString(i) == pointingId) return true
                }
                return false
            } catch (e: Exception) {
                Log.e(TAG, "Error checking favorite status: ${e.message}")
                return false
            }
        }

        /**
         * Update the save button to show filled or empty heart based on favorite status
         */
        fun updateSaveButton(context: Context, views: RemoteViews) {
            val currentId = getCurrentPointingId(context)
            val isFavorite = isPointingFavorite(context, currentId)
            val heartDrawable = if (isFavorite) R.drawable.ic_heart_filled else R.drawable.ic_heart_outline
            val contentDesc = if (isFavorite) "Already saved to favorites" else "Save to favorites"

            views.setImageViewResource(R.id.widget_save, heartDrawable)
            views.setContentDescription(R.id.widget_save, contentDesc)
            Log.d(TAG, "Save button updated: drawable=$heartDrawable (favorite=$isFavorite, id=$currentId)")
        }

        /**
         * Check if theme changed since last widget update and handle accordingly.
         * Returns true if theme changed and widgets were updated.
         */
        fun checkAndHandleThemeChange(context: Context): Boolean {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val lastDarkMode = prefs.getBoolean(KEY_LAST_DARK_MODE, true)
            val currentDarkMode = isSystemInDarkMode(context)

            if (lastDarkMode != currentDarkMode) {
                Log.d(TAG, "Theme changed: ${if (lastDarkMode) "dark" else "light"} -> ${if (currentDarkMode) "dark" else "light"}")
                prefs.edit().putBoolean(KEY_LAST_DARK_MODE, currentDarkMode).apply()

                // Theme changed - force full widget update with data reload
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val componentName = ComponentName(context, PointerWidgetProvider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)

                // Update all widgets with new theme layout
                for (appWidgetId in appWidgetIds) {
                    updateAppWidget(context, appWidgetManager, appWidgetId)
                    // Force factory to reload data with new theme
                    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_flipper)
                }
                return true
            }
            return false
        }

        /**
         * Update all widget instances.
         * Also reloads data to ensure theme-specific layouts are used.
         */
        fun updateAllWidgets(context: Context) {
            // Check and handle theme change first
            checkAndHandleThemeChange(context)

            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, PointerWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            Log.d(TAG, "updateAllWidgets: Found ${appWidgetIds.size} widgets")
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
                // Force factory to reload data with current theme
                appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_flipper)
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
         * This creates the auto-rotation effect by incrementing flipper_position.
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

                // Get total count from cache
                val totalCount = try {
                    org.json.JSONArray(cacheJson).length()
                } catch (e: Exception) { 1 }

                if (totalCount <= 1) {
                    Log.d(TAG, "advanceStackPosition: Only $totalCount items, skipping advance")
                    return
                }

                // Get current position and advance it
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                var currentPosition = prefs.getInt("flipper_position", 0)
                currentPosition = (currentPosition + 1) % totalCount
                prefs.edit().putInt("flipper_position", currentPosition).apply()

                Log.d(TAG, "advanceStackPosition: Advanced to position $currentPosition of $totalCount")

                // Determine theme for correct layout
                val isDarkMode = isSystemInDarkMode(context)
                val layoutId = if (isDarkMode) R.layout.pointer_widget else R.layout.pointer_widget_light

                // Update all widgets to show the new position
                for (appWidgetId in appWidgetIds) {
                    val views = RemoteViews(context.packageName, layoutId)
                    views.setDisplayedChild(R.id.widget_flipper, currentPosition)
                    appWidgetManager.partiallyUpdateAppWidget(appWidgetId, views)
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

            // Check premium status and update empty state text accordingly
            val widgetData = HomeWidgetPlugin.getData(context)
            val isPremium = widgetData?.getBoolean("widget_is_premium", false) ?: false
            val emptyText = if (isPremium) {
                "Tap to load"
            } else {
                "Premium Feature\nUpgrade to unlock"
            }
            views.setTextViewText(R.id.widget_empty_text, emptyText)

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

            // Update save button to show filled/empty heart based on favorite status
            updateSaveButton(context, views)

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
