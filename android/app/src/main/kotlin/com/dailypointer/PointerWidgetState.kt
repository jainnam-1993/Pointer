package com.dailypointer

import android.content.Context
import android.net.Uri
import android.util.Log
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

/**
 * Shared widget state contract for Android.
 *
 * Mirrors the iOS widget's storage model:
 * - `pointings_cache` is the canonical data source written by Flutter.
 * - `widget_current_index` tracks the currently displayed pointing.
 * - `pointing_id` / `pointing_content` snapshot the current item for save/open actions.
 * - bundled defaults render immediately if the Flutter cache is unavailable.
 */
object PointerWidgetState {
    private const val TAG = "PointerWidgetState"
    private const val PREFS_NAME = "widget_prefs"
    private const val KEY_LAST_REFRESH_AT = "widget_last_refresh_request_at"
    private const val KEY_LAST_PREFETCH_AT = "widget_last_prefetch_request_at"
    private const val REQUEST_DEBOUNCE_MS = 5_000L

    const val KEY_POINTINGS_CACHE = "pointings_cache"
    const val KEY_FAVORITES = "widget_favorites"
    const val KEY_CURRENT_INDEX = "widget_current_index"
    const val KEY_POINTING_ID = "pointing_id"
    const val KEY_POINTING_CONTENT = "pointing_content"
    const val KEY_SAVE_PENDING_ID = "save_pending_id"

    enum class DataSource {
        CACHE,
        BUNDLED_DEFAULTS,
    }

    data class Snapshot(
        val pointings: List<PointingData>,
        val source: DataSource,
    )

    fun loadSnapshot(context: Context): Snapshot {
        val cached = loadFromCache(context)
        if (cached.isNotEmpty()) {
            return Snapshot(cached, DataSource.CACHE)
        }

        val defaults = loadBundledDefaults(context)
        requestRefresh(context)
        return Snapshot(defaults, DataSource.BUNDLED_DEFAULTS)
    }

    fun getCurrentIndex(context: Context, totalCount: Int): Int {
        if (totalCount <= 0) return 0
        val stored = HomeWidgetPlugin.getData(context)?.getInt(KEY_CURRENT_INDEX, 0) ?: 0
        return normalizeIndex(stored, totalCount)
    }

    fun setCurrentIndex(context: Context, index: Int, totalCount: Int): Int {
        val normalized = normalizeIndex(index, totalCount)
        HomeWidgetPlugin.getData(context)?.edit()?.putInt(KEY_CURRENT_INDEX, normalized)?.apply()
        return normalized
    }

    fun getCurrentPointing(context: Context): PointingData? {
        val snapshot = loadSnapshot(context)
        if (snapshot.pointings.isEmpty()) return null
        val index = getCurrentIndex(context, snapshot.pointings.size)
        return snapshot.pointings[index]
    }

    fun syncCurrentPointing(context: Context, pointings: List<PointingData>) {
        val widgetData = HomeWidgetPlugin.getData(context) ?: return
        if (pointings.isEmpty()) {
            widgetData.edit()
                .remove(KEY_POINTING_ID)
                .remove(KEY_POINTING_CONTENT)
                .apply()
            return
        }

        val current = pointings[getCurrentIndex(context, pointings.size)]
        widgetData.edit()
            .putString(KEY_POINTING_ID, current.id)
            .putString(KEY_POINTING_CONTENT, current.content)
            .apply()
    }

    fun requestRefresh(context: Context, force: Boolean = false) {
        requestBackgroundIntent(
            context = context,
            uri = "pointer://widget/refresh",
            timestampKey = KEY_LAST_REFRESH_AT,
            force = force,
        )
    }

    fun requestPrefetch(context: Context, force: Boolean = false) {
        requestBackgroundIntent(
            context = context,
            uri = "pointer://widget/prefetch",
            timestampKey = KEY_LAST_PREFETCH_AT,
            force = force,
        )
    }

    private fun requestBackgroundIntent(
        context: Context,
        uri: String,
        timestampKey: String,
        force: Boolean,
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()
        val last = prefs.getLong(timestampKey, 0L)
        if (!force && now - last < REQUEST_DEBOUNCE_MS) {
            return
        }

        try {
            HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse(uri)).send()
            prefs.edit().putLong(timestampKey, now).apply()
            Log.d(TAG, "Requested widget refresh: $uri")
        } catch (e: Exception) {
            Log.e(TAG, "Failed requesting widget refresh: ${e.message}", e)
        }
    }

    private fun loadFromCache(context: Context): List<PointingData> {
        val jsonString = HomeWidgetPlugin.getData(context)?.getString(KEY_POINTINGS_CACHE, null)
        if (jsonString.isNullOrEmpty()) return emptyList()
        return parsePointings(jsonString)
    }

    private fun loadBundledDefaults(context: Context): List<PointingData> {
        return try {
            val inputStream = context.resources.openRawResource(R.raw.default_pointings)
            val jsonString = inputStream.bufferedReader().use { it.readText() }
            parsePointings(jsonString)
        } catch (e: Exception) {
            Log.e(TAG, "Error loading bundled defaults: ${e.message}", e)
            emptyList()
        }
    }

    private fun parsePointings(jsonString: String): List<PointingData> {
        return try {
            val jsonArray = JSONArray(jsonString)
            buildList(jsonArray.length()) {
                for (i in 0 until jsonArray.length()) {
                    val obj = jsonArray.getJSONObject(i)
                    add(
                        PointingData(
                            id = obj.optString("id", ""),
                            content = obj.optString("content", ""),
                            tradition = obj.optString("tradition", ""),
                            teacher = obj.optString("teacher", ""),
                        )
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing pointings: ${e.message}", e)
            emptyList()
        }
    }

    private fun normalizeIndex(index: Int, totalCount: Int): Int {
        if (totalCount <= 0) return 0
        val safeIndex = index % totalCount
        return if (safeIndex >= 0) safeIndex else safeIndex + totalCount
    }
}

data class PointingData(
    val id: String,
    val content: String,
    val tradition: String,
    val teacher: String,
)
