package com.pointer

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.Button
import android.widget.RadioButton
import android.widget.RadioGroup
import android.widget.Switch
import com.pointer.R

/**
 * Configuration activity for Pointer widget.
 * Allows users to customize widget appearance when adding to home screen.
 */
class WidgetConfigActivity : Activity() {

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_widget_config)

        // Set result to CANCELED in case user backs out
        setResult(RESULT_CANCELED)

        // Get the widget ID from the intent
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        // Load existing preferences
        val prefs = getWidgetPrefs(this, appWidgetId)
        val theme = prefs.getString(PREF_THEME, THEME_DARK) ?: THEME_DARK
        val showTeacher = prefs.getBoolean(PREF_SHOW_TEACHER, true)

        // Set up theme radio buttons
        val themeGroup = findViewById<RadioGroup>(R.id.theme_group)
        val darkRadio = findViewById<RadioButton>(R.id.theme_dark)
        val lightRadio = findViewById<RadioButton>(R.id.theme_light)

        when (theme) {
            THEME_LIGHT -> lightRadio.isChecked = true
            else -> darkRadio.isChecked = true
        }

        // Set up teacher toggle
        val teacherSwitch = findViewById<Switch>(R.id.show_teacher_switch)
        teacherSwitch.isChecked = showTeacher

        // Set up confirm button
        val confirmButton = findViewById<Button>(R.id.confirm_button)
        confirmButton.setOnClickListener {
            // Save preferences
            val selectedTheme = when (themeGroup.checkedRadioButtonId) {
                R.id.theme_light -> THEME_LIGHT
                else -> THEME_DARK
            }

            saveWidgetPrefs(
                this,
                appWidgetId,
                selectedTheme,
                teacherSwitch.isChecked
            )

            // Update the widget
            val appWidgetManager = AppWidgetManager.getInstance(this)
            PointerWidgetProvider.updateAppWidget(this, appWidgetManager, appWidgetId)

            // Return success
            val resultValue = Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            setResult(RESULT_OK, resultValue)
            finish()
        }
    }

    companion object {
        private const val PREFS_NAME = "PointerWidgetConfig"
        const val PREF_THEME = "widget_theme"
        const val PREF_SHOW_TEACHER = "show_teacher"
        const val THEME_DARK = "dark"
        const val THEME_LIGHT = "light"

        fun getWidgetPrefs(context: Context, widgetId: Int): SharedPreferences {
            return context.getSharedPreferences("${PREFS_NAME}_$widgetId", Context.MODE_PRIVATE)
        }

        fun saveWidgetPrefs(
            context: Context,
            widgetId: Int,
            theme: String,
            showTeacher: Boolean
        ) {
            getWidgetPrefs(context, widgetId).edit().apply {
                putString(PREF_THEME, theme)
                putBoolean(PREF_SHOW_TEACHER, showTeacher)
                apply()
            }
        }

        fun getTheme(context: Context, widgetId: Int): String {
            return getWidgetPrefs(context, widgetId).getString(PREF_THEME, THEME_DARK) ?: THEME_DARK
        }

        fun shouldShowTeacher(context: Context, widgetId: Int): Boolean {
            return getWidgetPrefs(context, widgetId).getBoolean(PREF_SHOW_TEACHER, true)
        }
    }
}
