package com.dailypointer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "com.dailypointer/settings"
    private val widgetChannel = "com.dailypointer/widget"
    private var currentNightMode: Int = Configuration.UI_MODE_NIGHT_UNDEFINED
    private var pendingPointingId: String? = null

    private val configChangeReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == Intent.ACTION_CONFIGURATION_CHANGED) {
                checkThemeChange()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        currentNightMode = resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK

        // Check for widget deep-link pointing ID
        handleWidgetIntent(intent)

        // Register for configuration changes (including theme)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(
                configChangeReceiver,
                IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED),
                RECEIVER_NOT_EXPORTED
            )
        } else {
            registerReceiver(
                configChangeReceiver,
                IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED)
            )
        }
        Log.d("MainActivity", "Registered config change receiver")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleWidgetIntent(intent)
    }

    private fun handleWidgetIntent(intent: Intent) {
        // Check for explicit pointing_id (from old ACTION_ITEM_CLICK path or adb test)
        var pointingId = intent.getStringExtra("pointing_id")

        // If opened from widget tap without specific ID, resolve from current flipper position
        if (pointingId == null && intent.action == "com.pointer.widget.OPEN_FROM_WIDGET") {
            pointingId = resolveCurrentWidgetPointingId()
            Log.d("MainActivity", "Widget tap: resolved pointing_id=$pointingId from flipper position")
        }

        if (pointingId != null) {
            Log.d("MainActivity", "Widget deep-link: pointing_id=$pointingId")

            // Write skip-splash flag to Flutter's SharedPreferences BEFORE the engine starts.
            // The router reads this synchronously during redirect to bypass the splash video.
            val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
            flutterPrefs.edit().putBoolean("flutter.widget_skip_splash", true).apply()

            if (flutterEngine != null) {
                sendPointingIdToFlutter(pointingId)
            } else {
                pendingPointingId = pointingId
            }
        }
    }

    private fun resolveCurrentWidgetPointingId(): String? {
        try {
            val widgetData = es.antonborri.home_widget.HomeWidgetPlugin.getData(this)
            val cacheJson = widgetData?.getString("pointings_cache", null) ?: return null
            val jsonArray = org.json.JSONArray(cacheJson)
            if (jsonArray.length() == 0) return null

            val prefs = getSharedPreferences("widget_prefs", MODE_PRIVATE)
            val position = prefs.getInt("flipper_position", 0)
            val safePosition = if (position in 0 until jsonArray.length()) position else 0
            return jsonArray.getJSONObject(safePosition).optString("id", null)
        } catch (e: Exception) {
            Log.e("MainActivity", "Error resolving widget pointing: ${e.message}")
            return null
        }
    }

    private fun sendPointingIdToFlutter(pointingId: String) {
        flutterEngine?.let { engine ->
            MethodChannel(engine.dartExecutor.binaryMessenger, widgetChannel)
                .invokeMethod("onWidgetPointingTap", pointingId)
            Log.d("MainActivity", "Sent pointing_id=$pointingId to Flutter")
        }
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(configChangeReceiver)
        } catch (e: Exception) {
            Log.e("MainActivity", "Error unregistering receiver: ${e.message}")
        }
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openNotificationSettings" -> {
                        openNotificationSettings()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Send any pending widget deep-link pointing ID now that Flutter is ready
        pendingPointingId?.let { id ->
            sendPointingIdToFlutter(id)
            pendingPointingId = null
        }
    }

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

    private fun checkThemeChange() {
        val newNightMode = resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
        if (newNightMode != currentNightMode) {
            Log.d("MainActivity", "Theme changed: $currentNightMode -> $newNightMode")
            currentNightMode = newNightMode
            // Update widget with new theme
            PointerWidgetProvider.updateAllWidgets(this)
        }
    }
}
