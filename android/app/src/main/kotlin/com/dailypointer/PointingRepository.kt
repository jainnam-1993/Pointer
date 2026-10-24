package com.dailypointer

import android.content.Context
import android.util.Log
import java.io.DataInputStream
import java.io.DataOutputStream
import java.io.File

/**
 * Widget content, read straight from the Flutter asset bundled in the APK, so the widget
 * never depends on the app having run. Parsed at most once per APK build: the result is
 * kept in memory for the process and in a compact cache file in noBackupFilesDir.
 * Call only from the widget worker thread ([WidgetWork]).
 */
object PointingRepository {
    private const val TAG = "PointerWidget"
    private const val ASSET = "flutter_assets/assets/data/pointings.json"
    private const val CACHE_FILE = "widget_pointings.bin"

    @Volatile
    private var memory: List<WidgetPointing>? = null

    fun load(context: Context): List<WidgetPointing> {
        memory?.let { return it }
        synchronized(this) {
            memory?.let { return it }
            val stamp = apkStamp(context)
            val file = File(context.noBackupFilesDir, CACHE_FILE)
            val cached = if (file.exists()) DataInputStream(file.inputStream().buffered()).use { PointingsCacheCodec.read(stamp, it) } else null
            val pointings = cached ?: parseAsset(context).also { parsed ->
                if (parsed.isNotEmpty()) {
                    DataOutputStream(file.outputStream().buffered()).use { PointingsCacheCodec.write(stamp, parsed, it) }
                }
            }
            if (pointings.isNotEmpty()) memory = pointings
            return pointings
        }
    }

    private fun parseAsset(context: Context): List<WidgetPointing> = try {
        val json = context.assets.open(ASSET).bufferedReader().use { it.readText() }
        PointingsJson.parse(json).also { Log.d(TAG, "Parsed ${it.size} pointings from $ASSET") }
    } catch (e: Exception) {
        Log.e(TAG, "Cannot read $ASSET", e)
        emptyList()
    }

    private fun apkStamp(context: Context): Long =
        context.packageManager.getPackageInfo(context.packageName, 0).lastUpdateTime
}
