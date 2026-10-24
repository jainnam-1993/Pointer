package com.dailypointer

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle

/**
 * Home-screen widget provider. Self-sufficient: content comes from the APK asset and state
 * from [WidgetStore], so no action needs the Flutter engine or the app to have been opened.
 *
 * Platform limit (W3): on Android 15+ a force-stop (Settings > Force stop, or an OEM battery
 * killer that force-stops) cancels the app's PendingIntents and disables its widgets until the
 * user next launches the app. No code can restore interaction before that launch; a normal
 * process kill (swipe away, low memory) does not have this effect.
 */
class PointerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val pending = goAsync()
        WidgetWork.runAsync(pending) {
            WidgetRenderer.render(context, appWidgetManager, appWidgetIds)
        }
    }

    override fun onAppWidgetOptionsChanged(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int, newOptions: Bundle) {
        val pending = goAsync()
        WidgetWork.runAsync(pending) { WidgetRenderer.render(context, appWidgetManager, intArrayOf(appWidgetId)) }
    }
}

/** Non-exported receiver for the widget's own buttons (M5). */
class WidgetActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action !in ACTIONS) return
        val shownId = intent.getStringExtra(WidgetRenderer.EXTRA_POINTING_ID)
        val appContext = context.applicationContext
        WidgetWork.runAsync(goAsync()) {
            val now = System.currentTimeMillis()
            WidgetStore.forContext(appContext).update { state ->
                when (action) {
                    ACTION_NEXT -> state.step(1, now)
                    ACTION_PREV -> state.step(-1, now)
                    else -> if (shownId != null) state.withFavorite(shownId) else state
                }
            }
            WidgetRenderer.renderAll(appContext)
        }
    }

    companion object {
        const val ACTION_SAVE = "com.dailypointer.widget.SAVE"
        const val ACTION_PREV = "com.dailypointer.widget.PREV"
        const val ACTION_NEXT = "com.dailypointer.widget.NEXT"
        val ACTIONS = listOf(ACTION_SAVE, ACTION_PREV, ACTION_NEXT)
    }
}
