package com.dailypointer

import org.json.JSONArray
import org.json.JSONException
import java.io.DataInputStream
import java.io.DataOutputStream
import java.io.IOException

/**
 * Pure widget model: content, ordering, state transitions and size buckets.
 *
 * Nothing here touches Android framework classes, so the logic runs in JVM unit tests
 * (android/app/src/test). The Android glue lives in WidgetStore.kt, PointingRepository.kt
 * and WidgetRenderer.kt.
 */
data class WidgetPointing(
    val id: String,
    val content: String,
    val tradition: String,
    val teacher: String,
)

/**
 * Persisted widget state.
 *
 * [position] indexes the seeded shuffle order (see [WidgetOrder]); it changes only on a
 * timer tick or a Prev/Next tap. [favorites] is the app's own favorites list
 * (`pointer_favorites`), or null when the stored value could not be parsed. A null list is
 * never written back, so a corrupt value cannot wipe the user's favorites.
 */
data class WidgetState(
    val seed: Long,
    val position: Int,
    val lastAdvanceAt: Long,
    val favorites: List<String>?,
) {
    fun isFavorite(id: String?): Boolean = id != null && favorites?.contains(id) == true

    /** Prev/Next tap. Restarts the timer so the chosen item stays on screen for a full period. */
    fun step(delta: Int, now: Long): WidgetState = copy(position = position + delta, lastAdvanceAt = now)

    /**
     * Wall-clock advance, applied at every render. The pointing on screen is a function of time:
     * one step per whole [PERIOD_MS] since the anchor, however many periods passed. So a widget
     * whose timer an OEM battery manager held for hours shows the right pointing on the next
     * render (the deferred updatePeriodMillis alarm on wake, an app resume, a resize, a tap), and
     * never looks stuck. The anchor moves by whole periods, so early or late timer delivery
     * neither double-advances nor drifts. The first tick only stamps the clock.
     */
    fun tick(now: Long): WidgetState {
        if (lastAdvanceAt <= 0L || now < lastAdvanceAt) return copy(lastAdvanceAt = now)
        val periods = (now - lastAdvanceAt) / PERIOD_MS
        if (periods == 0L) return this
        return copy(position = position + periods.coerceAtMost(Int.MAX_VALUE.toLong() / 2).toInt(), lastAdvanceAt = lastAdvanceAt + periods * PERIOD_MS)
    }

    /** Save is idempotent: it adds the id once and never removes it. */
    fun withFavorite(id: String): WidgetState {
        val current = favorites ?: return this
        if (id.isEmpty() || id in current) return this
        return copy(favorites = current + id)
    }

    companion object {
        /** One pointing per 30 minutes, the same cadence as updatePeriodMillis and the iOS timeline. */
        const val PERIOD_MS = 30 * 60 * 1000L
    }
}

/** Stable, seeded shuffle order. The same seed and size always give the same order. */
object WidgetOrder {
    @Volatile
    private var cache: Triple<Long, Int, IntArray>? = null

    fun permutation(seed: Long, size: Int): IntArray {
        cache?.let { (s, n, p) -> if (s == seed && n == size) return p }
        val order = IntArray(size) { it }
        val random = java.util.Random(seed)
        for (i in size - 1 downTo 1) {
            val j = random.nextInt(i + 1)
            val tmp = order[i]
            order[i] = order[j]
            order[j] = tmp
        }
        cache = Triple(seed, size, order)
        return order
    }

    /** Index into the content list for [position], or -1 when there is no content. */
    fun indexAt(seed: Long, size: Int, position: Int): Int {
        if (size <= 0) return -1
        return permutation(seed, size)[Math.floorMod(position, size)]
    }
}

/** Parsing of the bundled pointings asset and of the favorites value Dart writes. */
object PointingsJson {
    private val traditionNames = mapOf(
        "advaita" to "Advaita Vedanta",
        "zen" to "Zen Buddhism",
        "direct" to "Direct Path",
        "contemporary" to "Contemporary",
        "original" to "Original",
    )

    fun traditionName(key: String): String =
        traditionNames[key] ?: key.replaceFirstChar { it.uppercaseChar() }

    /** Parses assets/data/pointings.json, keeping only the fields the widget renders. */
    fun parse(json: String): List<WidgetPointing> {
        val array = JSONArray(json)
        return buildList(array.length()) {
            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                val id = obj.optString("id")
                val content = obj.optString("content")
                if (id.isEmpty() || content.isEmpty()) continue
                add(WidgetPointing(id, content, traditionName(obj.optString("tradition")), obj.optString("teacher")))
            }
        }
    }

    /**
     * Decodes `pointer_favorites`, a JSON array of id strings: the one format Dart's
     * StorageService and this widget both write. Missing -> empty; not a JSON array -> null,
     * so the caller never writes over it; non-string elements are dropped.
     */
    fun decodeIds(value: String?): List<String>? {
        if (value.isNullOrEmpty()) return emptyList()
        return try {
            val array = JSONArray(value)
            (0 until array.length()).mapNotNull { array.opt(it) as? String }
        } catch (e: JSONException) {
            null
        }
    }

    fun encodeIds(ids: List<String>): String = JSONArray(ids).toString()
}

/**
 * Compact binary cache of the parsed content, keyed by the APK's lastUpdateTime, so a cold
 * process reads a few hundred KB of strings instead of re-parsing the JSON asset.
 */
object PointingsCacheCodec {
    private const val MAGIC = 0x50574331 // "PWC1"

    fun write(stamp: Long, pointings: List<WidgetPointing>, out: DataOutputStream) {
        out.writeInt(MAGIC)
        out.writeLong(stamp)
        out.writeInt(pointings.size)
        for (p in pointings) {
            out.writeUTF(p.id)
            out.writeUTF(p.content)
            out.writeUTF(p.tradition)
            out.writeUTF(p.teacher)
        }
    }

    /** Returns null when the cache is from another build or unreadable. */
    fun read(stamp: Long, input: DataInputStream): List<WidgetPointing>? = try {
        if (input.readInt() != MAGIC || input.readLong() != stamp) {
            null
        } else {
            val count = input.readInt()
            List(count) { WidgetPointing(input.readUTF(), input.readUTF(), input.readUTF(), input.readUTF()) }
        }
    } catch (e: IOException) {
        null
    }
}

/** Responsive size buckets (L5). Foldable-specific sizing is left to a later stream. */
enum class WidgetSize(val contentLines: Int, val showHeader: Boolean, val showTeacher: Boolean, val showActions: Boolean, val aspect: Float) {
    COMPACT(contentLines = 3, showHeader = false, showTeacher = false, showActions = false, aspect = 2.2f),
    MEDIUM(contentLines = 5, showHeader = false, showTeacher = true, showActions = true, aspect = 2f),
    LARGE(contentLines = 12, showHeader = true, showTeacher = true, showActions = true, aspect = 1f);

    companion object {
        /**
         * The layout breakpoints, in dp, as (width, height) minimums. LARGE starts at 260 dp tall:
         * its eyebrow, teacher line and control row take about 150 dp, and below 260 dp the quote
         * was left about 50 dp and clipped mid-line (a 4x2 widget on a Fold). MEDIUM, with the
         * teacher in the control row, gives the quote nearly 100 dp there.
         */
        val BREAKPOINTS: List<Pair<WidgetSize, Pair<Float, Float>>> = listOf(
            COMPACT to (110f to 40f),
            MEDIUM to (180f to 110f),
            LARGE to (250f to 260f),
        )

        fun forSize(widthDp: Float, heightDp: Float): WidgetSize = when {
            heightDp >= 260f && widthDp >= 250f -> LARGE
            heightDp >= 110f && widthDp >= 180f -> MEDIUM
            else -> COMPACT
        }
    }
}
