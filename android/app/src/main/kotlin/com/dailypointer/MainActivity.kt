package com.dailypointer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureWidgetTap(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        captureWidgetTap(intent)
    }

    private fun captureWidgetTap(intent: Intent?) {
        intent?.getStringExtra(WidgetRenderer.EXTRA_POINTING_ID)?.takeIf { it.isNotEmpty() }?.let { pendingPointingId = it }
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
                    // Ambient clock drops to 15 fps while battery saver is on.
                    "isLowPowerMode" -> result.success(isPowerSaveMode())
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
