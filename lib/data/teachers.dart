/**
 * Teacher database — name-keyed map of [Teacher] records.
 *
 * Provides the `teachers` constant and helper functions [getTeacher] and
 * [getPointingsByTeacher] used by [TeacherSheet] and the home screen.
 *
 * For richer biographical profiles used in the Library, see
 * `teacher_profiles.dart` and [TeacherProfile].
 */
library;

import '../models/teacher.dart';
import 'pointings.dart';

/** Name-keyed map of all [Teacher] records (22 teachers across traditions). */
const teachers = <String, Teacher>{
  'Ramana Maharshi': Teacher(
    name: 'Ramana Maharshi',
    bio:
        'Indian sage and jivanmukti who taught self-inquiry ("Who am I?") as the direct path to self-realization. His teachings emanate from his own experience of the Self.',
    dates: '1879-1950',
    tradition: Tradition.advaita,
    tags: ['Self-inquiry', 'Advaita', 'Tiruvannamalai'],
  ),
  'Nisargadatta Maharaj': Teacher(
    name: 'Nisargadatta Maharaj',
    bio:
        'Indian guru of nondualism, famous for "I Am That". A simple shopkeeper who became one of the most influential Advaita teachers through direct, uncompromising pointing.',
    dates: '1897-1981',
    tradition: Tradition.advaita,
    tags: ['Advaita', 'Mumbai', 'I Am That'],
  ),
  'Ashtavakra Gita': Teacher(
    name: 'Ashtavakra Gita',
    bio:
        'Ancient Sanskrit scripture presenting the teaching of sage Ashtavakra to King Janaka. One of the most radical non-dual texts, pointing directly to the already-free Self.',
    dates: 'c. 500 BCE',
    tradition: Tradition.advaita,
    tags: ['Scripture', 'Advaita', 'Ancient text'],
  ),
  'Rupert Spira': Teacher(
    name: 'Rupert Spira',
    bio:
        'British teacher of the Direct Path, influenced by Francis Lucille and Jean Klein. Known for his clear, precise explorations of the nature of experience and awareness.',
    dates: 'born 1960',
    tradition: Tradition.direct,
    tags: ['Direct Path', 'Non-duality', 'Contemporary'],
  ),
  'Francis Lucille': Teacher(
    name: 'Francis Lucille',
    bio:
        'French-American spiritual teacher in the Advaita Vedanta tradition. Student of Jean Klein, known for his gentle and direct pointing to our true nature.',
    dates: 'born 1944',
    tradition: Tradition.direct,
    tags: ['Direct Path', 'Jean Klein lineage'],
  ),
  'Eckhart Tolle': Teacher(
    name: 'Eckhart Tolle',
    bio:
        'German-born spiritual teacher and author of "The Power of Now". Teaches presence and the dissolution of the ego through awareness of the present moment.',
    dates: 'born 1948',
    tradition: Tradition.contemporary,
    tags: ['Presence', 'The Power of Now', 'Contemporary'],
  ),
  'Pema Chodron': Teacher(
    name: 'Pema Chodron',
    bio:
        'American Tibetan Buddhist nun, author, and teacher. Known for practical teachings on working with difficult emotions and cultivating compassion and fearlessness.',
    dates: 'born 1936',
    tradition: Tradition.zen,
    tags: ['Buddhism', 'Compassion', 'Shambhala'],
  ),
  'Bashō': Teacher(
    name: 'Bashō',
    bio: 'Japanese poet and master of haiku. His poems capture the essence of Zen - direct perception without conceptual elaboration.',
    dates: '1644-1694',
    tradition: Tradition.zen,
    tags: ['Haiku', 'Zen', 'Japan'],
  ),
  'Francis of Assisi / Advaita': Teacher(
    name: 'Francis of Assisi / Advaita',
    bio: 'Pointing that bridges the Christian mystical tradition with non-dual awareness. The recognition of the divine in all things.',
    dates: null,
    tradition: Tradition.original,
    tags: ['Christian mysticism', 'Unity'],
  ),
  'Mooji': Teacher(
    name: 'Mooji',
    bio:
        'Jamaican-born teacher in the lineage of Papaji and Ramana Maharshi. Known for his warm, direct invitation to recognize the Self through the simple question "Who is aware?"',
    dates: 'born 1954',
    tradition: Tradition.contemporary,
    tags: ['Self-inquiry', 'Papaji lineage', 'Satsang'],
  ),
  'Adyashanti': Teacher(
    name: 'Adyashanti',
    bio:
        'American teacher who practiced Zen for 14 years before a series of awakening experiences. Teaches "True Meditation" and uniquely emphasizes post-awakening integration.',
    dates: 'born 1962',
    tradition: Tradition.contemporary,
    tags: ['Zen roots', 'True Meditation', 'Integration'],
  ),
  'Papaji': Teacher(
    name: 'Papaji',
    bio:
        'Direct disciple of Ramana Maharshi who became the primary conduit of his teaching to the West. Famous for his radical instruction to simply stop all seeking.',
    dates: '1910-1997',
    tradition: Tradition.advaita,
    tags: ['Ramana lineage', 'Direct pointing', 'Satsang'],
  ),
  'Byron Katie': Teacher(
    name: 'Byron Katie',
    bio:
        'After a spontaneous awakening from severe depression in 1986, developed "The Work" \u2014 four questions that investigate stressful thoughts and reveal the peace beneath belief.',
    dates: 'born 1942',
    tradition: Tradition.contemporary,
    tags: ['The Work', 'Self-inquiry', 'Thought investigation'],
  ),
  'Gangaji': Teacher(
    name: 'Gangaji',
    bio:
        'Student of Papaji who carries the Ramana Maharshi lineage to the West. Known for her fierce yet tender invitation to simply stop seeking and recognize what is already free.',
    dates: 'born 1942',
    tradition: Tradition.contemporary,
    tags: ['Papaji lineage', 'Stopping', 'Emotional honesty'],
  ),
  'Jed McKenna': Teacher(
    name: 'Jed McKenna',
    bio:
        'Pseudonymous author of the "Spiritual Enlightenment" trilogy. Teaches spiritual autolysis \u2014 ruthless self-inquiry through writing \u2014 as the only process that leads to truth.',
    dates: null,
    tradition: Tradition.contemporary,
    tags: ['Spiritual Autolysis', 'Truth vs. comfort', 'Pseudonymous'],
  ),
  'Jean Klein': Teacher(
    name: 'Jean Klein',
    bio:
        'Czech-born European pioneer of non-dual teaching who uniquely integrated body awareness with Advaita and Kashmir Shaivism. Teacher of Francis Lucille.',
    dates: '1912-1998',
    tradition: Tradition.direct,
    tags: ['Body awareness', 'Kashmir Shaivism', 'Direct Path'],
  ),
  'Annamalai Swami': Teacher(
    name: 'Annamalai Swami',
    bio:
        'Served Ramana Maharshi for ten years before spending 47 years in near-total silence. Taught abiding as the pure sense "I am" as the direct path to Self-realization.',
    dates: '1906-1995',
    tradition: Tradition.advaita,
    tags: ['Ramana disciple', 'I Am', 'Silence'],
  ),
  'Tony Parsons': Teacher(
    name: 'Tony Parsons',
    bio:
        'British teacher of radical non-duality. After a spontaneous shift in 1971, communicates the uncompromising message that there is no separate self, no path, and no one to become enlightened.',
    dates: 'born 1933',
    tradition: Tradition.contemporary,
    tags: ['Radical non-duality', 'No path', 'The Open Secret'],
  ),
  'Jeff Foster': Teacher(
    name: 'Jeff Foster',
    bio:
        'British teacher who evolved beyond neo-Advaita to embrace deep acceptance that includes the full range of human experience. Bridges non-dual understanding with emotional embodiment.',
    dates: 'born 1980',
    tradition: Tradition.contemporary,
    tags: ['Deep acceptance', 'Embodiment', 'Post-neo-Advaita'],
  ),
  'Ramesh Balsekar': Teacher(
    name: 'Ramesh Balsekar',
    bio:
        'Former President of the Bank of India who became Nisargadatta Maharaj\'s translator and closest disciple. Taught that there is no individual doer \u2014 all action is the impersonal functioning of Totality.',
    dates: '1917-2009',
    tradition: Tradition.advaita,
    tags: ['Nisargadatta lineage', 'No doership', 'Consciousness'],
  ),
  'Adi Shankara': Teacher(
    name: 'Adi Shankara',
    bio:
        'Eighth-century philosopher-sage who systematized Advaita Vedanta into a rigorous philosophical framework. His teaching that Brahman alone is real transformed Indian spirituality.',
    dates: '788-820 CE',
    tradition: Tradition.advaita,
    tags: ['Advaita Vedanta', 'Classical', 'Vivekachudamani'],
  ),
  'Dattatreya': Teacher(
    name: 'Dattatreya',
    bio:
        'Legendary avadhuta sage who learned from 24 gurus drawn from nature and everyday life. The Avadhuta Gita attributed to him is among the most uncompromising non-dual texts ever composed.',
    dates: null,
    tradition: Tradition.advaita,
    tags: ['Avadhuta Gita', 'Classical', '24 Gurus'],
  ),
};

/** Get teacher by name, returns null if not found */
Teacher? getTeacher(String? name) {
  if (name == null) return null;
  return teachers[name];
}

/** Get all pointings by a specific teacher */
List<Pointing> getPointingsByTeacher(String teacherName) {
  return pointings.where((p) => p.teacher == teacherName).toList();
}
