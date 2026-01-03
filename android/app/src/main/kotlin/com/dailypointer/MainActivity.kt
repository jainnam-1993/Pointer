package com.dailypointer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

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
        registerReceiver(
            configChangeReceiver,
            IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED),
            Context.RECEIVER_NOT_EXPORTED
        )
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
