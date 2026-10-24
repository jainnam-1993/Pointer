package com.dailypointer

import android.app.WallpaperManager
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "com.dailypointer/settings"
    private val widgetChannel = "com.dailypointer/widget"

    /** Pointing id from the last widget tap. Dart pulls it once it is ready (cold or warm start). */
    private var pendingPointingId: String? = null

    private var settingsChannel: MethodChannel? = null

    /**
     * Pushes battery saver changes to the ambient clock. Toggling battery saver from the
     * quick settings shade keeps the activity resumed, so a query on resume alone misses it.
     */
    private val powerSaveReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            settingsChannel?.invokeMethod("lowPowerModeChanged", isPowerSaveMode())
        }
    }

    /**
     * Redraws the widget when the wallpaper colors change while the app process is alive. Each
     * render also reads the colors afresh, so a change made while the app was closed shows on the
     * next redraw (timer, wake, tap or resize). ACTION_WALLPAPER_CHANGED is deprecated and cannot
     * reach a manifest receiver on Android 8+, so nothing depends on it.
     */
    private var wallpaperListener: Any? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureWidgetTap(intent)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            val app = applicationContext
            val listener = WallpaperManager.OnColorsChangedListener { _, which ->
                if (which and WallpaperManager.FLAG_SYSTEM != 0) WidgetWork.run { WidgetRenderer.renderAll(app) }
            }
            WallpaperManager.getInstance(this).addOnColorsChangedListener(listener, Handler(Looper.getMainLooper()))
            wallpaperListener = listener
        }
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            (wallpaperListener as? WallpaperManager.OnColorsChangedListener)?.let { WallpaperManager.getInstance(this).removeOnColorsChangedListener(it) }
        }
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureWidgetTap(intent)
    }

    private fun captureWidgetTap(intent: Intent?) {
        intent?.getStringExtra(WidgetRenderer.EXTRA_POINTING_ID)?.takeIf { it.isNotEmpty() }?.let { pendingPointingId = it }
    }

    private fun isPinWidgetSupported(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && AppWidgetManager.getInstance(this).isRequestPinAppWidgetSupported

    /** Asks the launcher to pin the widget; the launcher shows its own confirmation. False if unsupported. */
    private fun requestPinWidget(): Boolean {
        if (!isPinWidgetSupported()) return false
        return AppWidgetManager.getInstance(this).requestPinAppWidget(ComponentName(this, PointerWidgetProvider::class.java), null, null)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .also { settingsChannel = it }
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openNotificationSettings" -> {
                        openNotificationSettings()
                        result.success(null)
                    }
                    // "Add widget to Home Screen" (Settings): Android 8+ launchers that support pinning.
                    "isPinWidgetSupported" -> result.success(isPinWidgetSupported())
                    "requestPinWidget" -> result.success(requestPinWidget())
                    // Ambient clock drops to 15 fps while battery saver is on.
                    "isLowPowerMode" -> result.success(isPowerSaveMode())
                    else -> result.notImplemented()
                }
            }
        // Android has no public Reduce Transparency setting; Dart falls back to the high-contrast flag.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.dailypointer/accessibility")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isReduceTransparency" -> result.success(false)
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, widgetChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "takePendingPointingId" -> {
                        result.success(pendingPointingId)
                        pendingPointingId = null
                    }
                    "renderWidgets" -> {
                        WidgetWork.run { WidgetRenderer.renderAll(applicationContext) }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        val filter = IntentFilter(PowerManager.ACTION_POWER_SAVE_MODE_CHANGED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // A protected system broadcast still reaches a not-exported receiver.
            registerReceiver(powerSaveReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(powerSaveReceiver, filter)
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        unregisterReceiver(powerSaveReceiver)
        settingsChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun isPowerSaveMode(): Boolean = (getSystemService(Context.POWER_SERVICE) as PowerManager).isPowerSaveMode

    private fun openNotificationSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            }
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = android.net.Uri.fromParts("package", packageName, null)
            }
        }
        startActivity(intent)
    }
}
