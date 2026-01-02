package com.pointer

import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.util.Log
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

/**
 * RemoteViewsService for the Pointer widget StackView.
 * Provides RemoteViewsFactory instances to populate the scrollable stack.
 */
class PointerWidgetService : RemoteViewsService() {

    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        Log.d(TAG, "onGetViewFactory called")
        return PointerRemoteViewsFactory(applicationContext)
    }

    companion object {
        private const val TAG = "PointerWidgetService"
    }
}

/**
 * Factory that creates RemoteViews for each pointing in the stack.
 * Implements circular buffer logic with 40+ item cache.
 */
class PointerRemoteViewsFactory(
    private val context: Context
) : RemoteViewsService.RemoteViewsFactory {

    private var pointings: List<PointingData> = emptyList()
    private var favorites: Set<String> = emptySet()
    private var isDarkMode: Boolean = true

    override fun onCreate() {
        Log.d(TAG, "onCreate")
        loadData()
    }

    override fun onDataSetChanged() {
        Log.d(TAG, "onDataSetChanged - reloading pointings")
        loadData()
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy")
        pointings = emptyList()
    }

    override fun getCount(): Int = pointings.size

    override fun getViewAt(position: Int): RemoteViews {
        Log.d(TAG, "getViewAt position=$position of ${pointings.size}")

        if (position < 0 || position >= pointings.size) {
            return getLoadingView()
        }

        val pointing = pointings[position]

        // Check if we're near the end and need more data (prefetch trigger)
        if (position >= PREFETCH_THRESHOLD && pointings.size <= INITIAL_CACHE_SIZE) {
            Log.d(TAG, "Prefetch trigger at position $position")
            triggerPrefetch()
        }

        // Choose layout based on system theme
        val layoutId = if (isDarkMode) {
            R.layout.widget_stack_item_dark
        } else {
            R.layout.widget_stack_item_light
        }

        return RemoteViews(context.packageName, layoutId).apply {
            // Set content
            setTextViewText(R.id.stack_item_content, pointing.content)

            // Set tradition badge with color
            if (pointing.tradition.isNotEmpty()) {
                setTextViewText(R.id.stack_item_tradition, pointing.tradition)
                setViewVisibility(R.id.stack_item_tradition, android.view.View.VISIBLE)
                val accentColor = getAccentColorForTradition(pointing.tradition)
                setTextColor(R.id.stack_item_tradition, accentColor)
                setInt(R.id.stack_item_accent_stripe, "setBackgroundColor", accentColor)
            } else {
                setViewVisibility(R.id.stack_item_tradition, android.view.View.GONE)
            }

            // Set teacher attribution
            if (pointing.teacher.isNotEmpty()) {
                setTextViewText(R.id.stack_item_teacher, "— ${pointing.teacher}")
                setViewVisibility(R.id.stack_item_teacher, android.view.View.VISIBLE)
            } else {
                setViewVisibility(R.id.stack_item_teacher, android.view.View.GONE)
            }

            // Set position indicator (e.g., "3 / 40")
            setTextViewText(R.id.stack_item_position, "${position + 1} / ${pointings.size}")

            // Fill-in intent for item clicks - passes pointing ID
            val fillInIntent = Intent().apply {
                putExtra(EXTRA_POINTING_ID, pointing.id)
                putExtra(EXTRA_POINTING_POSITION, position)
            }
            setOnClickFillInIntent(R.id.stack_item_container, fillInIntent)
        }
    }

    override fun getLoadingView(): RemoteViews {
        val layoutId = if (isDarkMode) {
            R.layout.widget_stack_item_dark
        } else {
            R.layout.widget_stack_item_light
        }
        return RemoteViews(context.packageName, layoutId).apply {
            setTextViewText(R.id.stack_item_content, "Loading...")
            setViewVisibility(R.id.stack_item_tradition, android.view.View.GONE)
            setViewVisibility(R.id.stack_item_teacher, android.view.View.GONE)
            setTextViewText(R.id.stack_item_position, "")
        }
    }

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = false

    /**
     * Load pointings data from shared storage.
     * Flutter stores pointings as JSON array in home_widget storage.
     */
    private fun loadData() {
        isDarkMode = isSystemInDarkMode()

        try {
            val widgetData = HomeWidgetPlugin.getData(context)
            val jsonString = widgetData?.getString(KEY_POINTINGS_CACHE, null)

            if (jsonString.isNullOrEmpty()) {
                Log.d(TAG, "No cached pointings found, using empty list")
                pointings = emptyList()
                return
            }

            val jsonArray = JSONArray(jsonString)
            val loadedPointings = mutableListOf<PointingData>()

            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                loadedPointings.add(
                    PointingData(
                        id = obj.optString("id", ""),
                        content = obj.optString("content", ""),
                        tradition = obj.optString("tradition", ""),
                        teacher = obj.optString("teacher", "")
                    )
                )
            }

            pointings = loadedPointings
            Log.d(TAG, "Loaded ${pointings.size} pointings from cache")

            // Load favorites list
            val favoritesJson = widgetData?.getString(KEY_FAVORITES, null)
            favorites = if (!favoritesJson.isNullOrEmpty()) {
                try {
                    val favArray = JSONArray(favoritesJson)
                    (0 until favArray.length()).map { favArray.getString(it) }.toSet()
                } catch (e: Exception) {
                    emptySet()
                }
            } else {
                emptySet()
            }
            Log.d(TAG, "Loaded ${favorites.size} favorites")

        } catch (e: Exception) {
            Log.e(TAG, "Error loading pointings: ${e.message}", e)
            pointings = emptyList()
            favorites = emptySet()
        }
    }

    /**
     * Check if a pointing ID is in the favorites set.
     */
    fun isFavorite(pointingId: String): Boolean = favorites.contains(pointingId)

    private fun isSystemInDarkMode(): Boolean {
        val nightMode = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        return nightMode == Configuration.UI_MODE_NIGHT_YES
    }

    private fun getAccentColorForTradition(tradition: String): Int {
        val colorHex = TRADITION_COLORS[tradition] ?: "#8B5CF6"
        return Color.parseColor(colorHex)
    }

    /**
     * Trigger Flutter to load more pointings when nearing end of cache.
     */
    private fun triggerPrefetch() {
        try {
            val intent = es.antonborri.home_widget.HomeWidgetBackgroundIntent.getBroadcast(
                context,
                android.net.Uri.parse("pointer://widget/prefetch")
            )
            intent.send()
            Log.d(TAG, "Prefetch intent sent")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to trigger prefetch: ${e.message}")
        }
    }

    companion object {
        private const val TAG = "PointerWidgetFactory"
        private const val KEY_POINTINGS_CACHE = "pointings_cache"
        private const val KEY_FAVORITES = "widget_favorites"

        const val EXTRA_POINTING_ID = "pointing_id"
        const val EXTRA_POINTING_POSITION = "pointing_position"

        // Prefetch when reaching item 35 of initial 40
        const val INITIAL_CACHE_SIZE = 40
        const val PREFETCH_THRESHOLD = 35

        private val TRADITION_COLORS = mapOf(
            "Advaita Vedanta" to "#FF6B35",  // Saffron orange
            "Zen Buddhism" to "#4A5568",      // Zen gray
            "Direct Path" to "#8B5CF6",       // Purple violet
            "Contemporary" to "#F59E0B",      // Gold amber
            "Original" to "#06B6D4"           // Teal cyan
        )
    }
}

/**
 * Data class for pointing information displayed in widget.
 */
data class PointingData(
    val id: String,
    val content: String,
    val tradition: String,
    val teacher: String
)
