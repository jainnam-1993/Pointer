// Article Seed Data
// Curated articles from classic non-dual teachings and contemporary teachers
//
// Content includes excerpts from classic texts, essays on key concepts,
// and practical guides for self-inquiry and direct recognition.

import '../models/article.dart';
import 'pointings.dart';

/// Curated articles for the Library
const articles = <Article>[
  // === ADVAITA VEDANTA ARTICLES ===

  Article(
    id: 'art_iam_that_001',
    title: 'I Am That',
    subtitle: 'Excerpts from Nisargadatta Maharaj',
    content: '''# I Am That

## On the Nature of Self

> "You are not what you think yourself to be. Find out what you are. Watch the sense 'I am', find your real Self."

The teaching of Nisargadatta Maharaj is disarmingly simple: You are not the body, you are not the mind, you are pure awareness. But this simplicity is not simplistic. It requires a complete revolution in understanding.

## The Questioner and the Answer

When we ask "Who am I?", we expect an answer in the form of a concept, an image, a definition. But Maharaj points to something prior to all concepts:

> "Wisdom tells me I am nothing. Love tells me I am everything. Between these two my life flows."

The investigation is not about finding a better self-image. It's about discovering what you are before all images arise.

## Practical Pointing

Don't try to understand this intellectually. Instead:

1. Notice the sense of being present right now
2. Ask: Who is aware of this presence?
3. Don't answer with a thought - just look

What remains when you stop looking for an answer?

## The Final Understanding

> "When I look inside and see that I am nothing, that is wisdom. When I look outside and see that I am everything, that is love. Between these two my life turns."

The separate self is a useful fiction for daily life, but it has no ultimate reality. What you truly are was never born and will never die.''',
    excerpt:
        'Nisargadatta\'s radical teaching: You are not what you think yourself to be. Find out what you are.',
    tradition: Tradition.advaita,
    teacher: 'Nisargadatta Maharaj',
    categories: [
      ArticleCategory.traditionalTeachings,
      ArticleCategory.natureOfAwareness,
    ],
    readingTimeMinutes: 4,
    isPremium: false,
  ),

  Article(
    id: 'art_who_am_i_001',
    title: 'Who Am I?',
    subtitle: 'The Fundamental Inquiry',
    content: '''# Who Am I?

## Ramana Maharshi's Teaching

The question "Who am I?" is not meant to be answered. It is meant to dissolve the questioner.

When Ramana Maharshi was asked how to attain Self-realization, his answer was consistently the same: inquire "Who am I?" But this is not an intellectual exercise. It is a direct investigation into the nature of awareness itself.

## The Method

When a thought arises, ask: "To whom does this thought arise?"

The answer will come: "To me."

Then ask: "Who am I?"

Do not try to answer this question with another thought. Simply turn attention back to its source.

## Beyond the Mind

> "The mind is only a bundle of thoughts. Of all thoughts, the thought 'I' is the root. Therefore, seeking the source of the 'I' thought is the way to annihilate all thoughts."

The investigation is not about finding a better definition of yourself. It's about discovering what remains when all definitions fall away.

## The Discovery

What you discover is not something new. It is what has always been present:

- Before your first thought of the day
- In the gap between two thoughts
- As the unchanging witness of all experience

This awareness is not personal. It is the same awareness looking out of all eyes, hearing through all ears. Recognition of this is enlightenment.''',
    excerpt:
        'Ramana Maharshi\'s self-inquiry method: the direct path to Self-realization.',
    tradition: Tradition.advaita,
    teacher: 'Ramana Maharshi',
    categories: [
      ArticleCategory.selfInquiry,
      ArticleCategory.traditionalTeachings,
    ],
    readingTimeMinutes: 3,
    isPremium: false,
  ),

  Article(
    id: 'art_ashtavakra_001',
    title: 'The Ashtavakra Gita',
    subtitle: 'Song of the Already Free',
    content: '''# The Ashtavakra Gita

## The Most Radical Non-Dual Text

The Ashtavakra Gita is perhaps the most uncompromising expression of non-dual truth. It doesn't offer a path or a practice. It simply declares what is already true:

> "You are not the body. The body is not yours. You are not the doer. You are awareness itself, the one witness, unchanging, free."

## No Gradual Path

Unlike many spiritual texts, the Ashtavakra Gita offers no steps, no stages, no gradual unfoldment:

> "If you desire liberation, avoid the objects of the senses like poison. Practice tolerance, sincerity, compassion, contentment, and truthfulness like nectar."

But even this is not a practice for attainment. It is a recognition of what is already so.

## The Teaching to King Janaka

The text is structured as a dialogue between the sage Ashtavakra and King Janaka. When Janaka asks how to attain liberation, Ashtavakra responds:

> "Bondage is believing you can be bound. Freedom is seeing you were never the one who could be bound."

This is the radical insight: there is no one to be liberated because there is no one who was ever bound.

## For the Mature Seeker

This teaching is not for beginners. It requires a readiness to let go of all spiritual ambition, all hope of attainment:

> "You are already free. Your only bondage is believing you are not."''',
    excerpt:
        'The most radical non-dual scripture: You are already free. Your only bondage is believing you are not.',
    tradition: Tradition.advaita,
    teacher: 'Ashtavakra Gita',
    categories: [
      ArticleCategory.traditionalTeachings,
      ArticleCategory.natureOfAwareness,
    ],
    readingTimeMinutes: 4,
    isPremium: false,
  ),

  Article(
    id: 'art_be_as_you_are_001',
    title: 'Be As You Are',
    subtitle: 'The Direct Teaching of Ramana Maharshi',
    content: '''# Be As You Are

## The Simplicity of the Teaching

Ramana Maharshi's teaching can be summarized in four words: Be as you are.

Not "become something else." Not "attain a higher state." Simply be what you already are.

## The Problem with Seeking

> "Your duty is to be, and not to be this or that. 'I am that I am' sums up the whole truth."

The spiritual search often becomes another form of ego-enhancement. We seek experiences, states, attainments. But Ramana points out that the seeker and the sought are one:

> "The Self is always realized. It is not that you have to realize it. There is nothing new to get. Remove the obstacles to its realization, that is all."

## The Practice of Self-Abidance

Self-inquiry is not a technique to be perfected. It is a returning to what you already are:

1. Notice the sense of being present
2. Rest in this sense of presence
3. When thoughts arise, let them pass without engagement
4. Return to simple being

## The Final Truth

> "The mind turned inward is the Self. Turned outward, it becomes the ego and the world."

There is only awareness. It appears as the world when directed outward through the senses. It knows itself as Self when it rests in itself. Both are the same awareness.''',
    excerpt:
        'Ramana\'s essential teaching: Your duty is to be, and not to be this or that.',
    tradition: Tradition.advaita,
    teacher: 'Ramana Maharshi',
    categories: [
      ArticleCategory.selfInquiry,
      ArticleCategory.everydayAwakening,
    ],
    readingTimeMinutes: 3,
    isPremium: false,
  ),

  Article(
    id: 'art_advaita_intro_001',
    title: 'What is Advaita Vedanta?',
    subtitle: 'An Introduction to Non-Duality',
    content: '''# What is Advaita Vedanta?

## The Philosophy of Non-Duality

Advaita Vedanta is one of the oldest and most influential spiritual philosophies in human history. The word "Advaita" means "not-two" - pointing to the fundamental unity of all existence.

## Core Insights

**There is only one reality.** What appears as many - countless objects, beings, and experiences - is actually one seamless whole. The apparent multiplicity is like waves on an ocean: many forms, one water.

**You are that reality.** The consciousness that reads these words is not separate from the consciousness that pervades the universe. The sense of being a separate self is a case of mistaken identity.

**Liberation is recognition, not attainment.** You don't become enlightened - you recognize that you were never not enlightened. The sun doesn't have to "attain" brightness.

## The Three States

Advaita examines our experience through three states:

- **Waking:** The familiar world of objects and others
- **Dreaming:** A world equally real while it lasts
- **Deep sleep:** Pure being without content

What is present in all three states? Only awareness itself.

## The Practical Path

While Advaita is often presented philosophically, its heart is practical:

1. **Hearing (Shravana):** Learning the teaching
2. **Reflection (Manana):** Contemplating deeply
3. **Meditation (Nididhyasana):** Abiding in understanding

The goal is not belief but direct recognition.''',
    excerpt:
        'Introduction to the ancient teaching of non-duality: there is only one reality, and you are that.',
    tradition: Tradition.advaita,
    categories: [
      ArticleCategory.traditionalTeachings,
      ArticleCategory.natureOfAwareness,
    ],
    readingTimeMinutes: 4,
    isPremium: false,
  ),

  // === ZEN BUDDHISM ARTICLES ===

  Article(
    id: 'art_gateless_gate_001',
    title: 'The Gateless Gate',
    subtitle: 'Classic Zen Koans',
    content: '''# The Gateless Gate (Mumonkan)

## What is a Koan?

A koan is not a riddle to be solved. It is a pointing that bypasses the rational mind entirely. The "answer" to a koan is not conceptual - it is a direct seeing.

## Zhaozhou's Dog (Case 1)

A monk asked Zhaozhou, "Does a dog have Buddha nature?"

Zhaozhou said, "Mu!" (No/Nothing)

### The Commentary

Mu is not "no" as opposed to "yes." It cuts through the entire framework of the question. What is this Mu? Don't think about it. Become it.

## Nansen Kills the Cat (Case 14)

The monks of the eastern and western halls were arguing about a cat. Nansen picked up the cat and said, "If you can say a word of Zen, I will spare the cat. If not, I will kill it." No one could answer, so Nansen cut the cat in two.

That evening, Zhaozhou returned. Nansen told him what had happened. Zhaozhou took off his sandals, put them on his head, and walked out.

Nansen said, "If you had been there, I could have saved the cat."

### The Pointing

Don't analyze. What would YOU have done?

## Working with Koans

1. Take the koan into meditation
2. Don't try to figure it out
3. Let it work on you until there is no separation between you and the koan
4. Present your understanding to a teacher

The breakthrough is not understanding about the koan - it is the koan understanding itself through you.''',
    excerpt:
        'Classic Zen koans from the Mumonkan: pointing beyond the rational mind.',
    tradition: Tradition.zen,
    categories: [
      ArticleCategory.traditionalTeachings,
      ArticleCategory.selfInquiry,
    ],
    readingTimeMinutes: 4,
    isPremium: false,
  ),

  Article(
    id: 'art_zen_intro_001',
    title: 'What is Zen?',
    subtitle: 'Direct Pointing, Mind to Mind',
    content: '''# What is Zen?

## Beyond Words and Letters

Zen is defined by what it is not:

> "A special transmission outside the scriptures,
> Not depending on words and letters,
> Pointing directly to the human mind,
> Seeing into one's nature and attaining Buddhahood."

This doesn't mean Zen has no words - obviously it does. But the words point beyond themselves to direct experience.

## The Origin

Zen traces its origin to a simple moment: The Buddha held up a flower. Mahakashyapa smiled. The teaching was transmitted without a word.

This "mind-to-mind transmission" is the essence of Zen. It cannot be captured in concepts because it is prior to concepts.

## Sitting Zen (Zazen)

While Zen emphasizes sudden awakening, the primary practice is just sitting:

- Sit with spine straight
- Let thoughts come and go
- Don't grasp or push away
- Just be present

This is not a technique for achieving enlightenment. It is the expression of your already-enlightened nature.

## Everyday Zen

> "Before enlightenment: chop wood, carry water.
> After enlightenment: chop wood, carry water."

Zen is not about special states or experiences. It is about being fully present to ordinary life. Washing dishes can be as profound as any meditation.

## The Zen Warning

Zen masters are famous for their fierce compassion. They destroy all spiritual bypasses:

> "If you meet the Buddha on the road, kill him."

Even the concept of Buddha can become an obstacle to direct seeing.''',
    excerpt:
        'Introduction to Zen: direct pointing beyond words to your original nature.',
    tradition: Tradition.zen,
    categories: [
      ArticleCategory.traditionalTeachings,
      ArticleCategory.everydayAwakening,
    ],
    readingTimeMinutes: 4,
    isPremium: false,
  ),

  Article(
    id: 'art_original_face_001',
    title: 'Your Original Face',
    subtitle: 'The Zen Inquiry into True Nature',
    content: '''# Your Original Face

## The Most Famous Zen Question

> "What was your face before your parents were born?"

This question stops the mind. It points to something prior to birth, prior to the body, prior to any identity you have assumed.

## Not a Philosophical Question

This is not asking about metaphysics or past lives. It is asking: What are you, right now, beneath all the layers of conditioning, personality, and history?

## The Investigation

Look at your face in a mirror. This is the face your parents gave you. It changes with time - young, old, happy, sad.

Now: What is looking?

The eyes that see the face - can they see themselves? What is the nature of that which is aware of the reflection?

## Answers That Miss

Common wrong answers:
- "Pure awareness" (still a concept)
- "Nothing" (still something)
- "God" (still an image)

The true response is not verbal. It is a direct showing. When you really see your original face, there is nothing to say about it.

## The Gateless Gate

The question itself is the gate. But here's the secret: there is no gate. You have never been separate from your original face. You are looking at everything through it right now.

The question doesn't give you something new. It removes the belief that you ever lost it.''',
    excerpt:
        'What was your face before your parents were born? The Zen inquiry into true nature.',
    tradition: Tradition.zen,
    categories: [
      ArticleCategory.selfInquiry,
      ArticleCategory.natureOfAwareness,
    ],
    readingTimeMinutes: 3,
    isPremium: false,
  ),

  // === DIRECT PATH ARTICLES ===

  Article(
    id: 'art_direct_path_001',
    title: 'The Direct Path',
    subtitle: 'Awareness Recognizing Itself',
    content: '''# The Direct Path

## A Contemporary Expression

The Direct Path is a contemporary expression of the perennial teaching of non-duality. While rooted in Advaita Vedanta, it is expressed in modern, accessible language free from cultural and religious trappings.

## Key Teachers

- **Jean Klein** (1916-1998): French teacher who brought this approach to the West
- **Francis Lucille**: Klein's student, known for his precision and warmth
- **Rupert Spira**: Contemporary teacher reaching a wide audience

## The Core Investigation

The Direct Path begins with a simple question: **Are you aware?**

Not "what are you aware of" but simply: Is awareness present?

The answer is immediately obvious. Yes, awareness is present. You don't need to think about it - it is self-evident.

Now: What is this awareness like?

## The Discovery

When we look directly at awareness itself, we discover it has no:
- Location
- Size or shape
- Beginning or end
- Personal qualities

It is simply open, knowing presence. And this is what we are.

## The Implications

If awareness is what we fundamentally are, then:
- We cannot be harmed by experience
- We are never actually separate from anything
- Peace is our natural condition, not something to achieve

## The Practice

This is not about having a particular experience. It is about recognizing what is always already the case. The "practice" is simply returning attention to awareness itself, again and again, until this recognition stabilizes.''',
    excerpt:
        'Contemporary non-duality: the Direct Path approach to self-recognition.',
    tradition: Tradition.direct,
    categories: [
      ArticleCategory.modernPointers,
      ArticleCategory.natureOfAwareness,
    ],
    readingTimeMinutes: 4,
    isPremium: false,
  ),

  Article(
    id: 'art_presence_001',
    title: 'The Nature of Presence',
    subtitle: 'Rupert Spira on Awareness',
    content: '''# The Nature of Presence

## What is Presence?

Presence is not a state to be achieved. It is what you already are. Right now, as you read these words, there is awareness. This awareness is presence.

> "We don't become present. We notice that we already are."

## The Investigation

Consider your current experience:
- There is seeing (these words)
- There is hearing (whatever sounds are present)
- There is feeling (body sensations, emotions)
- There is thinking (commentary about all this)

Now: What is aware of all this?

## The Nature of Awareness

When we look directly at awareness itself:

**It has no form.** We cannot find any shape or boundary to it.

**It is not located.** We cannot find a place where awareness is located.

**It is always now.** We never experience awareness in the past or future.

**It is unchanging.** Experiences come and go, but awareness itself doesn't change.

**It is inherently peaceful.** It is not disturbed by any experience that appears in it.

## The Shift

Most of us live as if we were a person who sometimes experiences awareness. The recognition is that we are awareness having the experience of being a person.

This is not a belief to adopt. It is a direct seeing.

## Living as Awareness

When this recognition stabilizes:
- Experience continues as before
- But there is no longer resistance to what is
- Peace is not sought because it is recognized as ever-present
- Life becomes an exploration, not a problem to solve''',
    excerpt:
        'Rupert Spira\'s teaching on awareness: we don\'t become present, we notice that we already are.',
    tradition: Tradition.direct,
    teacher: 'Rupert Spira',
    categories: [
      ArticleCategory.natureOfAwareness,
      ArticleCategory.modernPointers,
    ],
    readingTimeMinutes: 4,
    isPremium: false,
  ),

  Article(
    id: 'art_francis_lucille_001',
    title: 'The Perfume of Silence',
    subtitle: 'Francis Lucille on Liberation',
    content: '''# The Perfume of Silence

## The Teaching of Francis Lucille

Francis Lucille is known for his gentle yet precise pointing to our true nature. His approach emphasizes direct experience over philosophy.

> "The separate self is not eliminated. It is seen through."

## The Investigation

Lucille often begins with the question of experience itself:

Look at any object in your visual field. Where does the seeing end and the object begin?

We assume there is a gap - a seer here, an object there. But when we look carefully, we cannot find this boundary. Seeing and seen arise together as one seamless experience.

## The Nature of Separation

The sense of being a separate self is not wrong - it is simply incomplete. It takes one aspect of experience (the body-mind) and identifies it as "me," while relegating the rest to "not-me."

But when we look at experience directly:
- Where are the boundaries of "me"?
- Can we find where "inside" ends and "outside" begins?
- Is awareness itself inside the body or is the body inside awareness?

## The Recognition

Liberation is not a state. It is the recognition that:
- There is only awareness
- This awareness is not personal
- What we are has never been bound

> "You are the space in which experience appears. You are not the experience."

## The Perfume

Why "perfume of silence"? Because this recognition brings a quality to life that is difficult to describe - a peace that is not dependent on circumstances, a love that is not conditional, a freedom that is not attained.

It is the natural fragrance of our true nature.''',
    excerpt:
        'Francis Lucille\'s teaching: The separate self is not eliminated. It is seen through.',
    tradition: Tradition.direct,
    teacher: 'Francis Lucille',
    categories: [
      ArticleCategory.natureOfAwareness,
      ArticleCategory.modernPointers,
    ],
    readingTimeMinutes: 4,
    isPremium: true,
  ),

  // === CONTEMPORARY ARTICLES ===

  Article(
    id: 'art_power_of_now_001',
    title: 'The Power of Now',
    subtitle: 'Eckhart Tolle on Presence',
    content: '''# The Power of Now

## The Gateway to Presence

Eckhart Tolle's teaching centers on one simple truth: The present moment is all you ever have.

> "The present moment is all you ever have. There is never a time when your life is not 'this moment.'"

## The Time-Bound Mind

Most suffering comes from being lost in thought - particularly thoughts about past and future:

- **Regret:** Living in the past
- **Anxiety:** Living in the future
- **Depression:** Resisting the present

The mind creates a false sense of time that takes us away from the only moment that actually exists: now.

## The Practice

Tolle offers a simple practice: Notice that you are thinking.

The moment you notice you are thinking, you are no longer completely identified with thought. There is awareness of thinking. This awareness is not itself a thought - it is presence.

## The Pain Body

Tolle introduces the concept of the "pain body" - the accumulated residue of past emotional pain that lives in the body-mind. It periodically awakens and feeds on negative experience.

The key is not to fight it but to witness it:

> "The moment you observe it, you are no longer it."

## Beyond the Ego

The ego is the identification with form - the body, thoughts, possessions, roles. It is not evil or wrong, just limited. When we see beyond it, life becomes:

- Less serious
- More playful
- More compassionate
- More alive

## The Teaching

> "You are not your thoughts. You are the awareness in which thoughts appear."

This simple recognition is the doorway to freedom.''',
    excerpt:
        'Eckhart Tolle\'s teaching: The present moment is all you ever have.',
    tradition: Tradition.contemporary,
    teacher: 'Eckhart Tolle',
    categories: [
      ArticleCategory.everydayAwakening,
      ArticleCategory.modernPointers,
    ],
    readingTimeMinutes: 4,
    isPremium: false,
  ),

  Article(
    id: 'art_mooji_001',
    title: 'Freedom in This Moment',
    subtitle: 'Mooji on Self-Recognition',
    content: '''# Freedom in This Moment

## Mooji's Teaching

Mooji is known for his warmth, humor, and direct pointing. His teaching is simple: You are already free. The recognition of this is enlightenment.

> "Don't be a storehouse of memories. Leave past, future and even present thoughts behind. Be a witness to life unfolding by itself. Be free of all attachments, fears and concerns by keeping your mind inside your own heart. Rest in being."

## The Invitation

Mooji often invites:

> "Can you just be? Not be something - just be?"

This is not a doing. It is a stopping. Stop trying to figure out what you are. Stop trying to become something. Just be.

## The Recognition

When we stop the activity of becoming, what remains?

- Not nothing - there is still awareness
- Not something - not an object that can be found
- Just this - open, empty, aware presence

This is what you are. It has always been here. It will always be here.

## The Invitation to Inquiry

When a thought or emotion arises, Mooji invites:

> "To whom does this arise? Find out."

Don't answer with another thought. Look. Is there actually someone there to whom things arise?

## The Pointing

> "Keep quiet. Do nothing. Be as you are. That's it."

The simplicity is deceptive. The mind wants complexity, wants a project, wants something to do. But freedom is simpler than the mind can accept.''',
    excerpt: 'Mooji\'s invitation: Can you just be? Not be something - just be?',
    tradition: Tradition.contemporary,
    teacher: 'Mooji',
    categories: [
      ArticleCategory.modernPointers,
      ArticleCategory.selfInquiry,
    ],
    readingTimeMinutes: 3,
    isPremium: false,
  ),

  Article(
    id: 'art_papaji_001',
    title: 'Wake Up and Roar',
    subtitle: 'Papaji on Instant Awakening',
    content: '''# Wake Up and Roar

## H.W.L. Poonja (Papaji)

Papaji was a direct disciple of Ramana Maharshi and became one of the most influential Advaita teachers of the 20th century. His teaching is characterized by fierce directness and the insistence on immediate awakening.

> "Don't postpone. Don't say 'tomorrow.' This instant is freedom."

## The Urgency

Unlike many teachers who speak of gradual paths, Papaji insisted:

> "You don't need time to be free. You are already free. You just don't see it."

This is not cruel. It is compassionate. Why suffer for another moment in the illusion of separation?

## The Method (or Lack of One)

Papaji often frustrated seekers by refusing to give them a practice:

> "Do nothing. Make no effort. Simply be alert and aware."

When students asked for techniques, he would say:

> "Technique is for later. First, see what you are right now."

## The Inquiry

His inquiry was immediate:

- "Who is asking this question?"
- "Look at who wants enlightenment."
- "Find the one who feels bound."

When we actually look, we cannot find this separate one. The seeker dissolves in the looking.

## The Roar

Why "wake up and roar"?

Because awakening is not passive. It is not a withdrawal from life. It is a full-hearted engagement with existence, without the burden of a separate self.

> "Celebrate! You were never bound!"''',
    excerpt:
        'Papaji\'s teaching: Don\'t postpone. This instant is freedom.',
    tradition: Tradition.advaita,
    teacher: 'Papaji (H.W.L. Poonja)',
    categories: [
      ArticleCategory.traditionalTeachings,
      ArticleCategory.selfInquiry,
    ],
    readingTimeMinutes: 3,
    isPremium: false,
  ),

  // === PRACTICAL ARTICLES ===

  Article(
    id: 'art_self_inquiry_guide_001',
    title: 'A Guide to Self-Inquiry',
    subtitle: 'Practical Steps for Investigation',
    content: '''# A Guide to Self-Inquiry

## What is Self-Inquiry?

Self-inquiry is the direct investigation into the nature of the "I" thought. Unlike meditation techniques that manipulate experience, self-inquiry simply asks: Who is having this experience?

## The Basic Practice

### Step 1: Notice a Thought or Experience
Any thought, sensation, or emotion can be the starting point. Perhaps there's a worry, a desire, a memory.

### Step 2: Ask "To Whom Does This Arise?"
Don't answer philosophically. Actually look. To whom does this thought appear?

The mind will answer: "To me."

### Step 3: Ask "Who Am I?"
Now turn attention to this "me." What is it? Where is it? Can you find it?

Don't answer with another thought. Just look.

### Step 4: Rest in What Remains
When you cannot find a separate self, don't panic. Rest in the open awareness that remains. This is not nothing - it is your true nature.

## Common Obstacles

**The mind keeps answering:** This is normal. Each answer is another thought to be inquired into.

**Nothing seems to happen:** The absence of spectacular experience is fine. Self-inquiry is about recognition, not experience.

**It feels frustrating:** The frustration belongs to the ego that wants to "get" enlightenment. Can you inquire into who is frustrated?

## Tips for Practice

- Practice for short periods throughout the day
- Don't strain or force anything
- Let the inquiry be gentle but persistent
- Trust the process

## The Result

Self-inquiry doesn't produce a result. It reveals what has always been present: awareness itself, free and unbounded.''',
    excerpt:
        'Practical guide to self-inquiry: step-by-step instructions for investigation.',
    tradition: Tradition.advaita,
    categories: [
      ArticleCategory.selfInquiry,
      ArticleCategory.everydayAwakening,
    ],
    readingTimeMinutes: 4,
    isPremium: false,
  ),

  Article(
    id: 'art_everyday_awakening_001',
    title: 'Awakening in Daily Life',
    subtitle: 'Bringing Recognition into Every Moment',
    content: '''# Awakening in Daily Life

## Beyond the Meditation Cushion

Awakening is not reserved for special states or sacred spaces. It is the recognition of what we always already are, and it can happen anywhere: in traffic, at work, doing dishes.

## The Myth of "After Enlightenment"

Many seekers imagine that enlightenment will solve all problems and create a life of perpetual bliss. But awakening is not about changing experience - it's about recognizing what is aware of experience.

> "Before enlightenment: chop wood, carry water. After enlightenment: chop wood, carry water."

## Practical Pointers

### During Routine Activities
- Notice: Who is brushing teeth?
- Ask: Is awareness affected by this activity?
- Rest: Let the activity continue while resting in awareness

### During Stress
- Notice: What is aware of this stress?
- Ask: Is awareness itself stressed?
- Rest: Even stress appears in peaceful awareness

### During Strong Emotions
- Notice: Where does this emotion appear?
- Ask: What contains this emotion?
- Rest: The emotion may continue, but you know yourself as the container

## The Integration

Integration is not about maintaining a special state. It's about increasingly recognizing that awareness is always present, regardless of what appears in it.

Eventually, there is no longer a sense of "maintaining" awareness. There is simply awareness, appearing as this ordinary life.

## The Simplicity

> "Nothing special is required. Just be what you are."

Awakening is the end of seeking, not the beginning of a new spiritual project.''',
    excerpt:
        'How to bring recognition into everyday activities - awakening is not reserved for meditation.',
    tradition: Tradition.contemporary,
    categories: [
      ArticleCategory.everydayAwakening,
      ArticleCategory.modernPointers,
    ],
    readingTimeMinutes: 3,
    isPremium: false,
  ),

  Article(
    id: 'art_obstacles_001',
    title: 'Common Obstacles on the Path',
    subtitle: 'Recognizing and Moving Beyond Blocks',
    content: '''# Common Obstacles on the Path

## The Path Without a Path

Paradoxically, the greatest obstacles on the spiritual path are our ideas about the path itself. Here are some common traps.

## 1. Seeking Experiences

**The trap:** Looking for special states, visions, bliss, or cosmic experiences.

**The truth:** Awareness is present in ordinary experience. Chasing special states keeps us looking away from what is always here.

**The release:** Ask: "Who wants this experience?" The seeker is the illusion.

## 2. Postponement

**The trap:** "I'll awaken when I've meditated more, read more books, found the right teacher."

**The truth:** Liberation is always now or never. The future is a concept appearing in present awareness.

**The release:** Ask: "What is aware right now?"

## 3. Spiritual Identity

**The trap:** Creating a new, improved spiritual self that meditates, eats consciously, uses spiritual language.

**The truth:** The spiritual ego is still ego. It's just wearing robes.

**The release:** Who is the one being spiritual?

## 4. Understanding Instead of Being

**The trap:** Accumulating knowledge about awakening while never actually looking.

**The truth:** You can know everything about awareness while missing the simple recognition of it.

**The release:** Stop reading. Look. What is aware?

## 5. Comparing

**The trap:** Measuring your progress against others, teachers, or ideals of what awakening should look like.

**The truth:** Awareness is equally present in everyone. There is no hierarchy in being.

**The release:** Whose awakening do you want?

## The Ultimate Obstacle

The ultimate obstacle is the belief that there are obstacles. What you are has never been obstructed.''',
    excerpt:
        'Common spiritual traps and how to recognize them - including the trap of believing in obstacles.',
    tradition: Tradition.contemporary,
    categories: [
      ArticleCategory.everydayAwakening,
      ArticleCategory.selfInquiry,
    ],
    readingTimeMinutes: 4,
    isPremium: true,
  ),

  Article(
    id: 'art_jean_klein_001',
    title: 'The Listening Attention',
    subtitle: 'Jean Klein on Silent Awareness',
    content: '''# The Listening Attention

## Jean Klein's Teaching

Jean Klein (1916-1998) brought the Direct Path to the West with remarkable clarity. A European who found awakening in India, he expressed the teaching in a way that bypasses cultural and religious frameworks.

> "Remain with a listening attention, without conclusion."

## The Approach

Klein's teaching is characterized by:

- **Simplicity:** No complex techniques or practices
- **Immediacy:** Direct pointing to present awareness
- **Elegance:** Beautiful, precise language

## The Listening Attention

Klein often spoke of a "listening attention" - an alert but non-grasping awareness:

> "It is not the object that is important but your relation to it, your looking."

This listening is not passive. It is fully alive, fully present, but without agenda.

## The Body as Gateway

Unlike some teachers who dismiss the body, Klein saw it as a doorway:

> "Listen to the body. Let it reveal its secrets."

When we truly feel the body without conceptual overlay, we discover it is not solid matter but a field of sensation appearing in awareness.

## Beyond the Student-Teacher Game

Klein refused to play the enlightened master:

> "There is no one here who is enlightened. There is only light."

He pointed away from himself to what is always already present in everyone.

## The Ultimate Teaching

> "You are the light in which all appears. You are not in the picture. You are what makes the picture possible."''',
    excerpt:
        'Jean Klein\'s teaching: Remain with a listening attention, without conclusion.',
    tradition: Tradition.direct,
    teacher: 'Jean Klein',
    categories: [
      ArticleCategory.traditionalTeachings,
      ArticleCategory.natureOfAwareness,
    ],
    readingTimeMinutes: 3,
    isPremium: true,
  ),

  Article(
    id: 'art_meditation_vs_inquiry_001',
    title: 'Meditation vs Self-Inquiry',
    subtitle: 'Two Approaches to Truth',
    content: '''# Meditation vs Self-Inquiry

## Two Different Approaches

Both meditation and self-inquiry are valid approaches to awakening, but they work differently.

## Meditation

Traditional meditation typically involves:
- Focusing attention (on breath, mantra, etc.)
- Calming the mind
- Creating conducive conditions for insight
- Gradually purifying the mind-body system

**The assumption:** The mind needs to be prepared for awakening.

## Self-Inquiry

Self-inquiry takes a different approach:
- Directly questioning the nature of the "I"
- Not manipulating experience
- Not depending on conditions
- Immediate investigation

**The assumption:** You are already what you seek; you just need to recognize it.

## Which is Right?

Neither is "right" - they serve different purposes and different temperaments.

Meditation can be valuable for:
- Calming a very agitated mind
- Developing concentration
- Preparing the ground for inquiry

Self-inquiry is direct when:
- You're ready to question the seeker itself
- You're tired of waiting for the right conditions
- You want the shortest path

## The Integration

Many practitioners find value in both:

1. Use meditation to settle the mind
2. Use inquiry to recognize what is always present
3. Let go of both when recognition stabilizes

## The Final Word

Whatever approach you use, remember:

> "The practice is not meant to continue forever. It is a pointer to what needs no practice."

You are already what you seek.''',
    excerpt:
        'Understanding the difference between meditation and self-inquiry - and when to use each.',
    tradition: Tradition.contemporary,
    categories: [
      ArticleCategory.selfInquiry,
      ArticleCategory.everydayAwakening,
    ],
    readingTimeMinutes: 3,
    isPremium: false,
  ),
];

/// Get articles filtered by tradition
List<Article> getArticlesByTradition(Tradition tradition) {
  return articles.where((a) => a.tradition == tradition).toList();
}

/// Get articles filtered by category
List<Article> getArticlesByCategory(ArticleCategory category) {
  return articles.where((a) => a.hasCategory(category)).toList();
}

/// Get articles filtered by teacher
List<Article> getArticlesByTeacher(String teacherName) {
  return articles.where((a) => a.isBy(teacherName)).toList();
}

/// Get featured articles (non-premium, highly relevant)
List<Article> getFeaturedArticles({int limit = 5}) {
  return articles.where((a) => !a.isPremium).take(limit).toList();
}

/// Search articles by title or content
List<Article> searchArticles(String query) {
  final lowerQuery = query.toLowerCase();
  return articles.where((a) {
    return a.title.toLowerCase().contains(lowerQuery) ||
        (a.subtitle?.toLowerCase().contains(lowerQuery) ?? false) ||
        a.content.toLowerCase().contains(lowerQuery);
  }).toList();
}
