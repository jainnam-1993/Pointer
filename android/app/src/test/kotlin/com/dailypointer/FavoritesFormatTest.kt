package com.dailypointer

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * `flutter.pointer_favorites` is shared with Dart's StorageService, which writes
 * `jsonEncode(List<String>)` and reads it back with `decodeFavoriteIds`.
 */
class FavoritesFormatTest {
    @Test
    fun `the widget writes exactly what Dart's jsonEncode writes`() {
        assertEquals("[\"adv-1\",\"zen-2\"]", PointingsJson.encodeIds(listOf("adv-1", "zen-2")))
        assertEquals("[]", PointingsJson.encodeIds(emptyList()))
    }

    @Test
    fun `the widget's output round-trips through the shared reader format`() {
        val ids = listOf("adv-1", "zen-2", "contemporary-3")
        assertEquals(ids, PointingsJson.decodeIds(PointingsJson.encodeIds(ids)))
    }

    @Test
    fun `bad shapes decode to the readable ids, or to null so nothing is written over them`() {
        assertEquals(emptyList<String>(), PointingsJson.decodeIds(null))
        assertEquals(emptyList<String>(), PointingsJson.decodeIds(""))
        assertNull(PointingsJson.decodeIds("\"adv-1\""))
        assertNull(PointingsJson.decodeIds("adv-1,zen-2"))
        // The unquoted array a seed script wrote (quotes stripped by the shell): org.json is
        // lenient and reads the bare words as ids, so the widget keeps them and its next Save
        // rewrites the value as the strict JSON Dart reads. It must never come back empty.
        assertEquals(listOf("zen-1", "dir-1", "con-1", "adv-1"), PointingsJson.decodeIds("[zen-1,dir-1,con-1,adv-1]"))
        assertEquals(listOf("adv-1", "zen-2"), PointingsJson.decodeIds("[\"adv-1\",7,null,\"zen-2\"]"))
    }

    @Test
    fun `a favorites value of another type is unreadable, not empty, and is never overwritten`() {
        val kv = object : KeyValueStore {
            val written = mutableMapOf<String, String>()
            override fun getLong(key: String): Long? = null
            override fun getString(key: String): String? = null
            override fun exists(key: String) = key == "flutter.pointer_favorites"
            override fun write(longs: Map<String, Long>, strings: Map<String, String>) { written.putAll(strings) }
        }
        val store = WidgetStore(kv)
        assertNull(store.read().favorites)
        store.update { it.withFavorite("adv-1") }
        assertTrue("flutter.pointer_favorites" !in kv.written)
    }
}
