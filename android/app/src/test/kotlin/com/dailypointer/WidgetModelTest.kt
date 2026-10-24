package com.dailypointer

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.DataInputStream
import java.io.DataOutputStream

/** In-memory stand-in for FlutterSharedPreferences that records each write. */
private class FakeKv(
    val longs: MutableMap<String, Long> = mutableMapOf(),
    val strings: MutableMap<String, String> = mutableMapOf(),
) : KeyValueStore {
    val writes = mutableListOf<Set<String>>()
    override fun getLong(key: String) = longs[key]
    override fun getString(key: String) = strings[key]
    override fun write(longs: Map<String, Long>, strings: Map<String, String>) {
        this.longs.putAll(longs)
        this.strings.putAll(strings)
        writes.add(longs.keys + strings.keys)
    }
}

class WidgetModelTest {
    private val minute = 60_000L

    @Test
    fun orderIsAStablePermutationForASeed() {
        val a = WidgetOrder.permutation(42L, 50).copyOf()
        val b = WidgetOrder.permutation(7L, 50).copyOf()
        assertArrayEquals(a, WidgetOrder.permutation(42L, 50))
        assertEquals((0 until 50).toSet(), a.toSet())
        assertFalse(a.contentEquals(b))
        assertEquals(WidgetOrder.indexAt(42L, 50, 0), WidgetOrder.indexAt(42L, 50, 50))
        assertEquals(WidgetOrder.indexAt(42L, 50, 49), WidgetOrder.indexAt(42L, 50, -1))
        assertEquals(-1, WidgetOrder.indexAt(42L, 0, 3))
    }

    @Test
    fun timerAdvancesOncePerPeriodAndFirstTickOnlyStamps() {
        val s0 = WidgetState(seed = 1, position = 5, lastAdvanceAt = 0, favorites = emptyList())
        val s1 = s0.tick(1_000 * minute)
        assertEquals(5, s1.position)
        assertEquals(s1, s1.tick(1_000 * minute + 10 * minute)) // app/launcher-triggered update: no advance
        val s2 = s1.tick(1_000 * minute + 30 * minute)
        assertEquals(6, s2.position)
    }

    /** A battery manager held the timer for 5 h 10 min: the next render catches up 10 steps at once. */
    @Test
    fun contentAdvancesWithWallClockAfterAHeldTimer() {
        val start = 1_000 * minute
        val s0 = WidgetState(seed = 42, position = 0, lastAdvanceAt = start, favorites = emptyList())
        val later = s0.tick(start + 310 * minute)
        assertEquals(10, later.position)
        assertEquals(start + 300 * minute, later.lastAdvanceAt) // anchor stays on the 30-minute grid
        assertEquals(11, later.tick(start + 330 * minute).position)
        // The shown pointing really changes from one period to the next.
        val shown = (0..3).map { WidgetOrder.indexAt(42L, 50, s0.tick(start + it * 30 * minute).position) }
        assertEquals(4, shown.toSet().size)
    }

    /** Early or repeated deliveries inside a period never double-advance; a clock set back re-anchors. */
    @Test
    fun earlyDeliveryDoesNotDoubleAdvanceAndClockSkewReanchors() {
        val s = WidgetState(seed = 1, position = 3, lastAdvanceAt = 600 * minute, favorites = emptyList())
        assertEquals(s, s.tick(629 * minute))
        assertEquals(4, s.tick(630 * minute).tick(631 * minute).tick(659 * minute).position)
        assertEquals(WidgetState(1, 3, 500 * minute, emptyList()), s.tick(500 * minute))
    }

    @Test
    fun tapStepsAndRestartsTimer() {
        val s = WidgetState(1, 5, 100 * minute, emptyList()).step(1, 110 * minute)
        assertEquals(6, s.position)
        assertEquals(s, s.tick(120 * minute))
        assertEquals(5, s.step(-1, 111 * minute).position)
    }

    @Test
    fun saveAddsIdempotentlyAndNeverToggles() {
        val s = WidgetState(1, 0, 0, listOf("a")).withFavorite("b").withFavorite("b").withFavorite("a")
        assertEquals(listOf("a", "b"), s.favorites)
        assertTrue(s.isFavorite("b"))
    }

    @Test
    fun storeUsesFlutterPrefsKeysAndWritesOnlyChangedKeys() {
        val kv = FakeKv(strings = mutableMapOf(WidgetStore.KEY_FAVORITES to """["zen-1"]"""))
        val store = WidgetStore(kv) { 99L }
        val first = store.read()
        assertEquals(99L, first.seed)
        assertEquals(listOf("zen-1"), first.favorites)
        kv.writes.clear()

        store.update { it.step(1, 5 * minute) }
        assertEquals(setOf(WidgetStore.KEY_POSITION, WidgetStore.KEY_LAST_ADVANCE), kv.writes.single())

        kv.writes.clear()
        store.update { it.withFavorite("adv-2") }
        assertEquals(setOf(WidgetStore.KEY_FAVORITES), kv.writes.single())
        assertEquals("""["zen-1","adv-2"]""", kv.strings[WidgetStore.KEY_FAVORITES])

        kv.writes.clear()
        store.update { it.withFavorite("adv-2") }
        assertTrue(kv.writes.isEmpty())
        assertEquals(99L, store.read().seed)
    }

    @Test
    fun corruptFavoritesAreNeverOverwritten() {
        val kv = FakeKv(strings = mutableMapOf(WidgetStore.KEY_FAVORITES to "not json"))
        val store = WidgetStore(kv) { 1L }
        val state = store.update { it.withFavorite("x") }
        assertNull(state.favorites)
        assertEquals("not json", kv.strings[WidgetStore.KEY_FAVORITES])
    }

    @Test
    fun parsesBundledAssetShapeAndMapsTraditions() {
        val json = """[{"id":"adv-1","content":"What is aware?","tradition":"advaita","contexts":["general"]},
            {"id":"zen-1","content":"Mu.","tradition":"zen","teacher":"Joshu"},{"id":"","content":"skip"}]"""
        val parsed = PointingsJson.parse(json)
        assertEquals(listOf("adv-1", "zen-1"), parsed.map { it.id })
        assertEquals("Advaita Vedanta", parsed[0].tradition)
        assertEquals("", parsed[0].teacher)
        assertEquals("Joshu", parsed[1].teacher)
    }

    @Test
    fun binaryCacheRoundTripsAndRejectsOtherBuilds() {
        val items = listOf(WidgetPointing("a", "Look.", "Zen Buddhism", ""), WidgetPointing("b", "Who?", "Original", "T"))
        val bytes = ByteArrayOutputStream().also { PointingsCacheCodec.write(7L, items, DataOutputStream(it)) }.toByteArray()
        assertEquals(items, PointingsCacheCodec.read(7L, DataInputStream(ByteArrayInputStream(bytes))))
        assertNull(PointingsCacheCodec.read(8L, DataInputStream(ByteArrayInputStream(bytes))))
        assertNull(PointingsCacheCodec.read(7L, DataInputStream(ByteArrayInputStream(bytes.copyOf(10)))))
    }

    @Test
    fun sizeBuckets() {
        assertEquals(WidgetSize.COMPACT, WidgetSize.forSize(120f, 60f))
        assertEquals(WidgetSize.MEDIUM, WidgetSize.forSize(250f, 110f))
        assertEquals(WidgetSize.LARGE, WidgetSize.forSize(300f, 250f))
        WidgetSize.BREAKPOINTS.forEach { (size, dims) -> assertEquals(size, WidgetSize.forSize(dims.first, dims.second)) }
    }
}
