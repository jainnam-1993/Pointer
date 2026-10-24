package com.dailypointer

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "com.dailypointer/settings"
    private val widgetChannel = "com.dailypointer/widget"

    /** Pointing id from the last widget tap. Dart pulls it once it is ready (cold or warm start). */
    private var pendingPointingId: String? = null

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
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openNotificationSettings" -> {
                        openNotificationSettings()
                        result.success(null)
                    }
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
}
