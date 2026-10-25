package com.dailypointer

import android.appwidget.AppWidgetManager
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Typeface
import android.os.Build
import android.os.Bundle
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.text.TextUtils
import kotlin.math.min

/**
 * The quote drawn into a bitmap in Newsreader, the brand serif.
 *
 * Why: launchers inflate a widget's TextViews in their own process and ignore the app's
 * res/font resources (the quote rendered as the system sans on the emulator), so the only robust
 * way to show the brand face is to draw the text ourselves. The bitmap is an alpha mask (ALPHA_8):
 * the ImageView tints it with @color/widget_app_ink in XML, which the launcher resolves, so the
 * ink still follows a light/dark switch without a re-render.
 *
 * Sizing mirrors the TextView's auto-size: the largest size from [maxSp] down to [minSp] (18 sp,
 * so the quote stays WCAG large text) that fits the box; at the floor it ellipsizes at the last
 * line that fits. Memory stays modest: at most 2 px per dp, one byte per pixel.
 */
object QuoteBitmap {
    data class Box(val widthDp: Float, val heightDp: Float)

    /** The quote box inside the card, from the widget's current size minus the size's chrome. */
    fun boxFor(options: Bundle, size: WidgetSize): Box {
        // Portrait size (min width, max height), as launchers report it; the max width is the
        // landscape width, which made the bitmap too wide and the text tiny once scaled to fit.
        // Android 12+ reports the actual sizes; use the first (portrait). Older launchers: min
        // width x max height. A box narrower than the slot made the quote wrap at about half width.
        val sizes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            @Suppress("DEPRECATION") options.getParcelableArrayList<android.util.SizeF>(AppWidgetManager.OPTION_APPWIDGET_SIZES)
        } else null
        val w = sizes?.firstOrNull()?.width ?: options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 320).toFloat()
        // Height: the smallest the launcher reports. The bitmap is scaled to fit its view (fitStart), so a
        // box taller than the real view shrank the text by height and left a dead right column (the quote
        // used 70% of the width on the Fold); a box no taller than the view lets the text fill the width.
        val h = sizes?.minOfOrNull { it.height } ?: options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110).toFloat()
        val chrome = when (size) {
            WidgetSize.COMPACT -> 32f
            WidgetSize.MEDIUM -> 32f + 8f + 48f
            WidgetSize.LARGE -> 32f + 30f + 12f + 26f + 8f + 48f
        }
        return Box((w - 32f).coerceAtLeast(60f), (h - chrome).coerceAtLeast(24f))
    }

    fun render(context: Context, text: String, box: Box, minSp: Float = 18f, maxSp: Float): Bitmap {
        val dm = context.resources.displayMetrics
        val scale = min(dm.density, 2f)
        val w = (box.widthDp * scale).toInt().coerceAtLeast(1)
        val h = (box.heightDp * scale).toInt().coerceAtLeast(1)
        val face = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) context.resources.getFont(R.font.newsreader) else Typeface.SERIF
        val paint = TextPaint(TextPaint.ANTI_ALIAS_FLAG).apply { typeface = face; color = 0xFFFFFFFF.toInt() }
        var sp = maxSp
        var layout: StaticLayout
        while (true) {
            paint.textSize = sp * dm.scaledDensity / dm.density * scale
            layout = StaticLayout.Builder.obtain(text, 0, text.length, paint, w)
                .setAlignment(Layout.Alignment.ALIGN_NORMAL).setLineSpacing(0f, 1.2f).setIncludePad(false)
                .setBreakStrategy(Layout.BREAK_STRATEGY_BALANCED).build()
            if (layout.height <= h || sp <= minSp) break
            sp -= 1f
        }
        if (layout.height > h) {
            // At the 18 sp floor and still too tall: keep the lines that fit and end with an ellipsis.
            var lines = layout.lineCount
            while (lines > 1 && layout.getLineBottom(lines - 1) > h) lines--
            layout = StaticLayout.Builder.obtain(text, 0, text.length, paint, w)
                .setAlignment(Layout.Alignment.ALIGN_NORMAL).setLineSpacing(0f, 1.2f).setIncludePad(false)
                .setBreakStrategy(Layout.BREAK_STRATEGY_BALANCED)
                .setMaxLines(lines).setEllipsize(TextUtils.TruncateAt.END).build()
        }
        // Only as tall as the text, so leftover height never forces a height-limited scale.
        val bmp = Bitmap.createBitmap(w, layout.height.coerceIn(1, h), Bitmap.Config.ALPHA_8)
        layout.draw(Canvas(bmp))
        return bmp
    }
}
