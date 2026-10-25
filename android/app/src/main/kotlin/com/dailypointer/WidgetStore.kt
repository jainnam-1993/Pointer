package com.dailypointer

import android.content.Context
import android.content.SharedPreferences

/** Minimal key-value seam so the store logic runs in JVM tests without Android. */
interface KeyValueStore {
    fun getLong(key: String): Long?
    fun getString(key: String): String?

    /** Whether [key] holds any value, of any type. */
    fun exists(key: String): Boolean = getString(key) != null || getLong(key) != null
    fun write(longs: Map<String, Long>, strings: Map<String, String>)
}

/**
 * Widget state persisted in the app's own `FlutterSharedPreferences` file.
 *
 * This is the single store both sides use: Dart's shared_preferences plugin reads and writes
 * the same file with the `flutter.` key prefix, so `flutter.pointer_favorites` is exactly the
 * list `StorageService.favorites` reads. The app calls `SharedPreferences.reload()` on resume
 * before it reads favorites, so a widget save is never lost or overwritten by a stale cache.
 * Only keys whose value changed are written, so a position update never clobbers a
 * concurrent favorites write from Dart.
 */
class WidgetStore(
    private val kv: KeyValueStore,
    private val newSeed: () -> Long = { java.util.Random().nextLong() },
) {
    @Synchronized
    fun read(): WidgetState {
        val seed = kv.getLong(KEY_SEED) ?: newSeed().also { kv.write(mapOf(KEY_SEED to it), emptyMap()) }
        return WidgetState(
            seed = seed,
            position = (kv.getLong(KEY_POSITION) ?: 0L).toInt(),
            lastAdvanceAt = kv.getLong(KEY_LAST_ADVANCE) ?: 0L,
            // A favorites value of another type (not the JSON string both apps write) is
            // unreadable, not missing: null keeps the widget from writing over it.
            favorites = kv.getString(KEY_FAVORITES).let { if (it == null && kv.exists(KEY_FAVORITES)) null else PointingsJson.decodeIds(it) },
        )
    }

    @Synchronized
    fun update(transform: (WidgetState) -> WidgetState): WidgetState {
        val old = read()
        val new = transform(old)
        val longs = buildMap<String, Long> {
            if (new.position != old.position) put(KEY_POSITION, new.position.toLong())
            if (new.lastAdvanceAt != old.lastAdvanceAt) put(KEY_LAST_ADVANCE, new.lastAdvanceAt)
        }
        val strings = buildMap<String, String> {
            val favorites = new.favorites
            if (favorites != null && favorites != old.favorites) put(KEY_FAVORITES, PointingsJson.encodeIds(favorites))
        }
        if (longs.isNotEmpty() || strings.isNotEmpty()) kv.write(longs, strings)
        return new
    }

    companion object {
        const val PREFS_FILE = "FlutterSharedPreferences"
        const val KEY_SEED = "flutter.widget_seed"
        const val KEY_POSITION = "flutter.widget_position"
        const val KEY_LAST_ADVANCE = "flutter.widget_last_advance_at"
        const val KEY_FAVORITES = "flutter.pointer_favorites"

        fun forContext(context: Context): WidgetStore =
            WidgetStore(SharedPreferencesKeyValueStore(context.getSharedPreferences(PREFS_FILE, Context.MODE_PRIVATE)))
    }
}

class SharedPreferencesKeyValueStore(private val prefs: SharedPreferences) : KeyValueStore {
    // Dart's plugin stores ints as Long; a value of another type is treated as absent.
    override fun getLong(key: String): Long? = (prefs.all[key] as? Number)?.toLong()

    override fun getString(key: String): String? = prefs.all[key] as? String

    override fun exists(key: String): Boolean = prefs.contains(key)

    override fun write(longs: Map<String, Long>, strings: Map<String, String>) {
        val editor = prefs.edit()
        longs.forEach { (k, v) -> editor.putLong(k, v) }
        strings.forEach { (k, v) -> editor.putString(k, v) }
        // Always called on the widget worker thread, so a synchronous commit is safe.
        editor.commit()
    }
}
