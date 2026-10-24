package com.dailypointer

import java.io.File
import javax.xml.parsers.DocumentBuilderFactory
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.w3c.dom.Element

/**
 * Launchers inflate widget layouts through RemoteViews, which refuses any class outside its
 * allowlist ("Class not allowed to be inflated android.view.View") and shows "Can't load widget".
 * Gradle compiles such layouts without complaint, so check the tags here.
 */
class WidgetLayoutTest {

    private val allowed = setOf(
        "FrameLayout", "LinearLayout", "RelativeLayout", "GridLayout",
        "AnalogClock", "Button", "Chronometer", "ImageButton", "ImageView", "ProgressBar", "TextView", "TextClock",
        "ViewFlipper", "ListView", "GridView", "StackView", "AdapterViewFlipper", "ViewStub",
        "CheckBox", "Switch", "RadioButton", "RadioGroup",
    )

    private fun widgetLayouts(): List<File> =
        listOf("src/main/res/layout", "src/main/res/layout-night")
            .map(::File)
            .filter { it.isDirectory }
            .flatMap { dir -> dir.listFiles { f -> f.name.startsWith("pointer_widget") && f.extension == "xml" }!!.toList() }

    private fun tags(file: File): List<String> {
        val doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(file)
        val out = mutableListOf<String>()
        fun walk(e: Element) {
            out += e.tagName
            val kids = e.childNodes
            for (i in 0 until kids.length) (kids.item(i) as? Element)?.let(::walk)
        }
        walk(doc.documentElement)
        return out
    }

    @Test
    fun widgetLayoutsUseOnlyRemoteViewsClasses() {
        val layouts = widgetLayouts()
        assertTrue("no widget layouts found from ${File(".").absolutePath}", layouts.any { it.name == "pointer_widget.xml" })
        val bad = layouts.flatMap { f -> tags(f).filter { it !in allowed }.map { "${f.path}: <$it>" } }
        assertEquals("RemoteViews cannot inflate these tags", emptyList<String>(), bad)
    }
}
