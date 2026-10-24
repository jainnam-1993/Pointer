package com.dailypointer

import android.app.WallpaperManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.util.Log

/**
 * Debug-only test hook for the widget wallpaper sweep, emulator only:
 *   adb -s emulator-5590 shell am broadcast -n com.dailypointer.test/com.dailypointer.DebugWallpaperReceiver --es path /data/local/tmp/wp.png
 *   ... --es color FF808080
 * Exported only to holders of android.permission.DUMP (adb shell). Refuses to run on real devices.
 * It sets the wallpaper and logs the WallpaperColors the widget renderer will read; it does NOT
 * redraw the widget, so the sweep can show the change arriving within one ordinary redraw.
 */
class DebugWallpaperReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!isEmulator()) {
            Log.w(TAG, "Refusing: not an emulator (${Build.FINGERPRINT})")
            return
        }
        val bitmap: Bitmap = intent.getStringExtra("path")?.let { BitmapFactory.decodeFile(it) }
            ?: intent.getStringExtra("color")?.let { solid(it.toLong(16).toInt()) }
            ?: run { Log.w(TAG, "Need --es path FILE or --es color AARRGGBB"); return }
        val wm = WallpaperManager.getInstance(context)
        wm.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK)
        val c = wm.getWallpaperColors(WallpaperManager.FLAG_SYSTEM)
        Log.i(TAG, "Wallpaper set; colors primary=${c?.primaryColor} secondary=${c?.secondaryColor} tertiary=${c?.tertiaryColor}")
    }

    private fun solid(argb: Int): Bitmap = Bitmap.createBitmap(64, 64, Bitmap.Config.ARGB_8888).apply { eraseColor(argb) }

    private fun isEmulator(): Boolean =
        Build.FINGERPRINT.contains("generic") || Build.HARDWARE.contains("ranchu") || systemProperty("ro.kernel.qemu") == "1" || systemProperty("ro.boot.qemu") == "1"

    private fun systemProperty(key: String): String? = try {
        Class.forName("android.os.SystemProperties").getMethod("get", String::class.java).invoke(null, key) as? String
    } catch (e: Exception) {
        null
    }

    companion object {
        private const val TAG = "PointerWidgetDebug"
    }
}
