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
    private var currentNightMode: Int = Configuration.UI_MODE_NIGHT_UNDEFINED

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
