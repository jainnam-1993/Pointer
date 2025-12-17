import '../models/teacher.dart';
import 'pointings.dart';

/// Database of teacher information for expandable teacher info feature
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
  'Pema Chödrön': Teacher(
    name: 'Pema Chödrön',
    bio:
        'American Tibetan Buddhist nun, author, and teacher. Known for practical teachings on working with difficult emotions and cultivating compassion and fearlessness.',
    dates: 'born 1936',
    tradition: Tradition.zen,
    tags: ['Buddhism', 'Compassion', 'Shambhala'],
  ),
  'Bashō': Teacher(
    name: 'Bashō',
    bio:
        'Japanese poet and master of haiku. His poems capture the essence of Zen - direct perception without conceptual elaboration.',
    dates: '1644-1694',
    tradition: Tradition.zen,
    tags: ['Haiku', 'Zen', 'Japan'],
  ),
  'Francis of Assisi / Advaita': Teacher(
    name: 'Francis of Assisi / Advaita',
    bio:
        'Pointing that bridges the Christian mystical tradition with non-dual awareness. The recognition of the divine in all things.',
    dates: null,
    tradition: Tradition.original,
    tags: ['Christian mysticism', 'Unity'],
  ),
};

/// Get teacher by name, returns null if not found
Teacher? getTeacher(String? name) {
  if (name == null) return null;
  return teachers[name];
}

/// Get all pointings by a specific teacher
List<Pointing> getPointingsByTeacher(String teacherName) {
  return pointings.where((p) => p.teacher == teacherName).toList();
}
