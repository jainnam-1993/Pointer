package com.pointer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Receives boot completed broadcast to reschedule notifications.
 * The Flutter app will reschedule notifications when it's next launched.
 */
class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            Log.d(TAG, "Boot completed - notifications will reschedule on next app launch")
            // Note: flutter_local_notifications handles rescheduling automatically
            // when the app is next opened, as long as schedules are persisted
        }
    }
}
