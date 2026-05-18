<script setup>
import {ref, computed} from 'vue'
import {onMounted, onUnmounted} from 'vue'

onMounted(() => {
  document.body.style.backgroundColor = '#f5f0e8'
  document.body.style.color = '#1a1008'
  document.body.style.maxWidth = '100%'
  document.body.style.margin = '0'
  document.body.style.padding = '0'
  const navbar = document.querySelector('.navbar')
  if (navbar) navbar.style.display = 'none'
})

onUnmounted(() => {
  document.body.style.backgroundColor = ''
  document.body.style.color = ''
  document.body.style.maxWidth = ''
  document.body.style.margin = ''
  document.body.style.padding = ''
  const navbar = document.querySelector('.navbar')
  if (navbar) navbar.style.display = ''
})

const entries = ref([
  {
    id: 1,
    session: 1,
    title: "01 - Arrival in Halivaara",
    date: "2026-03-29",
    location: "Halivaara",
    mood: "neutral",
    images: ["/images/mory_s1.png"],
    body: `˖⁺‧₊˚ O, câine mereu atent, ascultă rugăciunea credincioșilor tăi˚₊‧⁺˖

I have arrived safely in Halivaara. My passage towards Silverkeep was… interrupted by this town, unknown to me until now.

At first glance, Halivaara presents itself as unremarkable, quiet, pleasant. Yet beneath that surface lies a troubling simplicity in its people. They condemned a woman to death with alarming haste, offering her as a scapegoat for the misfortunes that plagues them. Whether she bore any guilt remains uncertain. As the red thread hung, an intrusive voice echoed within my mind. I believe it came from her… or through her. The moment carried an eerie familiarity. It recalled something I would rather not name. You may remember, it was the first time we met.

Then the sky turned.

Panic took hold when lightning struck the suspended body. Birds fell, lifeless strewn across the streets.

I acted while others fled. I cut her down and placed a ward upon her remains. The officer who proclaimed her death was struck by one of the falling birds and collapsed. I took some of his blood, he had no further use for it. When the carcasses began to rupture and spill acid upon the ground, I was forced to take shelter beneath the gallows.

I was not alone there for long. Another outsider joined me, a half elf, by appearance. Frail, observant. He watched me closely but offered little. I chose not to question it. Instead, I ensured his survival and later aided what few others survivors remained.

When the chaos subsided, I returned. I quickly drank the blood gathered from before and at last, removed my helmet. Weeks enclosed within it had taken their toll on me.

Upon my arrival the gallows had already collapsed. Among the wreckage, I encountered three others: Sir Nathaniel, his companion Miss Penny, who is a fairy and a tiefling named Miss Raya. All of them had heard the same voice. That alone was enough to bind our interests. Sir Nathaniel, in particular, carries himself with purpose. I have chosen, for now, to follow his lead.

We withdrew to a tavern to gather what knowledge we could. An elderly man spoke of the executed woman, newly arrived, living with her father in a fisherman's hut. She had been accused of devotion to Haberen, a deity said to belong to a pantheon of chaos. There are many such entities, it seems. Sir Nathaniel and the frail half elf, Sir Quinlan, offered what explanations they could. Names such as Mortis and Anguis were mentioned with surprising familiarity, as though their influence has grown in recent years.

We later crossed the water to the fisherman's hut. Sir Nathaniel and Miss Raya spoke with the red thread's father and learned of a pendant the woman wore, a ribcage, of all things. A detail worth remembering.

For now, we have returned to the tavern to rest and prepare. Tomorrow may offer clarity.

I will be sharing a room with Miss Raya and Sir Quinlan.

˖⁺‧₊˚Fie ca misiunea mea să dea roade, întoarcerea mea o vei aștepta. Rest well, my dear.˚₊‧⁺˖`,
    highlights: ["Arrival in Halivaara", "Divine Intervention", "Meeting a Group"],
  },

  {
    id: 2,
    session: 2,
    title: "02 - The Ill",
    date: "2026-05-9",
    location: "Halivaara",
    mood: "Hungry",
    images: ["/images/mory_s2.png"],
    body: `⁺‧₊˚ O, câine mereu atent, ascultă rugăciunea credincioșilor tăi˚₊‧⁺˖

Sir Quinlan, Miss Raya and I withdrew to the room we had agreed to share for the night. My hunger has continued to worsen. Though I found brief relief earlier, it did little to quiet the thing stirring beneath my skin. I did not dare remove my armor completely. Steel remains easier to trust than myself.

    Sir Quinlan watched me often.

    Eventually, I returned the gesture and exclaimed that I find his gaze amusing. He reminds me greatly of [redacted]. In the way he speaks. The way curiosity overtakes him. The small reactions he fails to conceal. I continue to notice fragments of him within this otherwise unfamiliar man. It is unsettling, though not unpleasant. Stranger still is the sense that Sir Quinlan feels drawn toward me for reasons I cannot understand.

    Our exchange ended only after I jokingly offered him my shield to sleep with.

Sleep itself proved difficult. I have come to prefer exhaustion over the possibility of waking beside another corpse.

    During the night, a loud crash echoed from below. I descended immediately to investigate. The tavern’s kitchen staff lay injured upon the floor beneath an open window, blood trailing from where his head had struck the counter. When he regained consciousness, confusion clouded him. He insisted he had merely slipped.

    Sir Quinlan followed, as he often seems to do. It was he who discovered a fragment of white cloth caught upon the window frame, embroidered with gold stitching.

    We instructed the man to return home and rest for the night before retreating once more to our room. The others returned to sleep eventually. I found little success in it myself, though resting upright proved more tolerable than lying still and listening to my own pulse hunger for another’s.

    When I next opened my eyes, Sir Quinlan was watching me again with careful attention. I chose not to acknowledge it.

    Downstairs, I noticed immediately that the tavern lacked its usual staff. I questioned the waitress regarding her missing colleague and confirmed he was the same man injured the previous evening. I informed her of his condition and requested his address.

    Upon arriving at his home, he refused us entry. He claimed he had contracted "The Ill".

    A curious name for something supposedly so lethal. To reduce a plague to such a vague title feels almost dismissive. Logically speaking, how terrible can it truly be? Throughout my travels I have encountered countless sicknesses and remained untouched by all of them.

    Regardless, the others did not share my confidence.

    We sent Mx Penny to warn the waitress. The news appeared to freeze her where she stood. Sir Nathaniel himself grew uneasy at the possibility he had also become infected. I doubt that he has, though I advised him to use his remaining time wisely should fate prove uncharacteristically cruel.

    From there, our wandering through Halivaara continued.

    At the jeweler’s stand, another merchant informed me where Miss Brynn resided. He also convinced me to purchase a topaz bracelet. It now rests among my belongings.

    Miss Brynn’s home stood empty when we arrived.

    Rotting fish hung from hooks along the kitchen walls. Food scraps had been left to spoil where they sat. The air itself seemed abandoned. Amidst the filth, I discovered a letter addressed to the Red Thread. I shared its contents with the others, though it offered little clarity. By that point, I believe all of us had begun longing for escape from this town.

    Still, we chose to investigate the castle.

    On our way there, guards halted us and searched our belongings. They uncovered the Pendant of Haberen hidden within Sir Quinlan’s pack. The guards attempted to detain him. I volunteered to accompany them, partly to prevent Sir Quinlan from worsening his situation and partly because confinement often grants access to information otherwise hidden. I had no desire to see him vanish the same way the Red Thread did.

    Before matters could escalate further, Sir Nathaniel used some manner of magic upon the guard. Whatever he did proved effective enough to make the man abandon the matter entirely.

    We proceeded to the castle regardless.

    There, I acquired temporary work as a transcriber. The task itself was uneventful, though I did learn several modern expressions currently in use.

    Homie appears to refer to trusted companions.
    GOAT is an abbreviation meaning Greatest Of All Time. The youth refers to Mortis as "The GOAT", not in a literal sense.

    During my shift I was served food. Out of politeness, I forced myself to eat some of it.

    It was a raspberry tart accompanied with small sliced lemon skin. The first taste carried a sharp sourness that softened quickly into a comfortable sweetness. The pastry beneath was balanced perfectly, neither overly flaky nor dense. For a brief moment, it rested pleasantly upon my tongue before instinct reminded me that such things no longer belong into my stomach.

    I enjoyed it more than I should have. I will deal with it later.

    Shortly before my work concluded, I noticed a yellow serpent with crimson eyes slither silently into the library and disappear into my bag.

    When I departed the castle, Sir Quinlan and Miss Raya waited outside for my return. I gave Sir Quinlan my pay and informed them both that infiltrating the castle further may ultimately prove futile.

    For a short while, I believed I had somehow acquired a new companion. It turns out the serpent already belonged to Miss Raya, or rather had been residing within her bag for some time. It possesses an unusual intelligence for a creature of its kind and appears strangely affectionate.

    We have since returned to the tavern to discuss our next steps.

    Most likely, our departure from Halivaara.

    I miss you greatly, my love.

˖⁺‧₊˚Fie ca misiunea mea să dea roade, întoarcerea mea o vei aștepta˚₊‧⁺˖`,
    highlights: ["Roaming in Halivaara", "Kitchen worker caught the Ill", "Finding a job"],
  },
])


const lightboxImg = ref(null)
const activeEntry = ref(null)

const sorted = computed(() =>
    [...entries.value].sort((a, b) => b.session - a.session)
)

function open(entry) {
  activeEntry.value = entry
  window.scrollTo({top: 0, behavior: 'smooth'})
}

function close() {
  activeEntry.value = null
}

const moodColors = {
  anxious: '#c0392b',
  hopeful: '#e8d5b0',
  angry: '#8b0000',
  melancholy: '#a09080',
  determined: '#c0392b',
  broken: '#555',
  triumphant: '#e8d5b0',
  neutral: '#9a8878',
}

function moodColor(mood) {
  return moodColors[mood] || '#c0392b'
}
</script>

<template>
  <div class="diary-root">

    <transition name="page-slide">
      <div class="diary-detail" v-if="activeEntry">
        <button class="back-btn" @click="close">← Back</button>

        <div class="detail-header">
          <div class="detail-session">Session {{ activeEntry.session }}</div>
          <h1 class="detail-title">{{ activeEntry.title }}</h1>
          <div class="detail-meta">
            <span class="detail-date">{{ activeEntry.date }}</span>
            <span class="detail-sep">·</span>
            <span class="detail-location">{{ activeEntry.location }}</span>
            <span v-if="activeEntry.mood" class="detail-mood"
                  :style="{ color: moodColor(activeEntry.mood), borderColor: moodColor(activeEntry.mood) + '44' }">
              {{ activeEntry.mood }}
            </span>
          </div>
          <div class="detail-rule"/>
        </div>

        <div class="detail-images" v-if="activeEntry.images?.length">
          <img
              :src="activeEntry.images[0]"
              :alt="activeEntry.title"
              class="detail-img single"
              @click="lightboxImg = activeEntry.images[0]"
          />
        </div>

        <div class="detail-body">
          <p
              v-for="(para, i) in activeEntry.body.split('\n\n').filter(p => p.trim())"
              :key="i"
              class="detail-para"
          >{{ para.trim() }}</p>
        </div>

        <div class="detail-highlights" v-if="activeEntry.highlights?.length">
          <div class="hl-label">— notable —</div>
          <ul class="hl-list">
            <li v-for="h in activeEntry.highlights" :key="h">{{ h }}</li>
          </ul>
        </div>

        <div class="detail-footer">
          <div class="detail-rule"/>
          <button class="back-btn-bottom" @click="close">← All Entries</button>
        </div>
      </div>
    </transition>

    <transition name="page-slide">
      <div class="diary-list" v-if="!activeEntry">
        <header class="diary-header">
          <div class="diary-mark">✦</div>
          <h1 class="diary-title">Morythieven's Journal</h1>
          <p class="diary-subtitle">Prayer's for my dear Hound</p>
          <div class="header-rule"/>
        </header>

        <div class="entries">
          <div
              v-for="entry in sorted"
              :key="entry.id"
              class="entry-card"
              @click="open(entry)"
          >
            <div class="entry-left">
              <div class="entry-session">S{{ String(entry.session).padStart(2, '0') }}</div>
              <div class="entry-line"/>
            </div>
            <div class="entry-right">
              <div class="entry-top-row">
                <span class="entry-date">{{ entry.date }}</span>
                <span class="entry-location">{{ entry.location }}</span>
                <span v-if="entry.mood" class="entry-mood" :style="{ color: moodColor(entry.mood) }">{{
                    entry.mood
                  }}</span>
              </div>
              <h2 class="entry-title">{{ entry.title }}</h2>
              <p class="entry-preview">{{ entry.body.replace(/\n/g, ' ').slice(0, 120).trim() }}…</p>
              <div class="entry-read">read →</div>
            </div>
          </div>
        </div>
      </div>
    </transition>

    <transition name="lb">
      <div class="lb-backdrop" v-if="lightboxImg" @click="lightboxImg = null">
        <img :src="lightboxImg" class="lb-img"/>
        <button class="lb-close" @click="lightboxImg = null">✕</button>
      </div>
    </transition>

  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;0,500;0,600;1,400;1,500&family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&display=swap');

.diary-root {
  min-height: 100vh;
  background: #f5f0e8;
  color: #1a1008;
  font-family: 'EB Garamond', serif;
  position: relative;
  width: 100vw;
  margin-left: calc(-50vw + 50%);
}

.diary-list {
  max-width: 680px;
  margin: 0 auto;
  padding: 4rem 1.5rem 6rem;
}

.diary-header {
  text-align: center;
  margin-bottom: 3rem;
}

.diary-mark {
  font-size: 1.2rem;
  color: #c0392b;
  margin-bottom: 0.75rem;
  letter-spacing: 0.3em;
}

.diary-title {
  font-family: 'Cormorant Garamond', serif;
  font-size: 3.2rem;
  font-weight: 300;
  color: #1a1008;
  margin: 0 0 0.25rem;
  letter-spacing: 0.08em;
  font-style: italic;
}

.diary-subtitle {
  font-size: 0.78rem;
  text-transform: uppercase;
  letter-spacing: 0.25em;
  color: #9a8878;
  margin: 0 0 1.5rem;
}

.header-rule {
  width: 60px;
  height: 1px;
  background: #c0392b;
  margin: 0 auto;
  opacity: 0.6;
}

.entries {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.entry-card {
  display: flex;
  gap: 1.5rem;
  padding: 1.8rem 1.2rem;
  border: 1px solid rgba(26, 16, 8, 0.08);
  border-radius: 4px;
  background: #f0e8d8;
  margin-bottom: 4px;
  cursor: pointer;
  box-shadow: 0 2px 8px rgba(26, 16, 8, 0.07);
  transition: background 0.15s;
}

.entry-card:hover {
  background: #e8dcc8;
}

.entry-card:hover .entry-read {
  color: #c0392b;
}

.entry-left {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  flex-shrink: 0;
  padding-top: 4px;
}

.entry-session {
  font-family: 'Cormorant Garamond', serif;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.15em;
  color: #c0392b;
  text-transform: uppercase;
  white-space: nowrap;
  writing-mode: vertical-rl;
  text-orientation: mixed;
}

.entry-line {
  flex: 1;
  width: 1px;
  background: rgba(192, 57, 43, 0.2);
  min-height: 30px;
}

.entry-right {
  flex: 1;
  min-width: 0;
}

.entry-top-row {
  display: flex;
  gap: 10px;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 0.3rem;
}

.entry-date {
  font-size: 0.72rem;
  color: #9a8878;
  letter-spacing: 0.08em;
}

.entry-location {
  font-size: 0.72rem;
  color: #9a8878;
  font-style: italic;
}

.entry-mood {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  font-family: 'EB Garamond', serif;
}

.entry-title {
  font-family: 'Cormorant Garamond', serif;
  font-size: 1.5rem;
  font-weight: 400;
  font-style: italic;
  color: #1a1008;
  margin: 0 0 0.5rem;
  line-height: 1.2;
}

.entry-preview {
  font-size: 0.92rem;
  color: #6a5848;
  line-height: 1.7;
  margin: 0 0 0.6rem;
}

.entry-read {
  font-size: 0.72rem;
  text-transform: uppercase;
  letter-spacing: 0.15em;
  color: #b0a090;
  transition: color 0.15s;
}

.diary-detail {
  max-width: 680px;
  margin: 0 auto;
  padding: 2rem 1.5rem 6rem;
}

.back-btn {
  background: none;
  border: none;
  font-family: 'EB Garamond', serif;
  font-size: 0.82rem;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: #9a8878;
  cursor: pointer;
  padding: 0;
  margin-bottom: 2.5rem;
  transition: color 0.15s;
}

.back-btn:hover {
  color: #c0392b;
}

.detail-header {
  margin-bottom: 2rem;
}

.detail-session {
  font-size: 0.68rem;
  text-transform: uppercase;
  letter-spacing: 0.2em;
  color: #c0392b;
  margin-bottom: 0.5rem;
}

.detail-title {
  font-family: 'Cormorant Garamond', serif;
  font-size: 2.6rem;
  font-weight: 300;
  font-style: italic;
  color: #1a1008;
  margin: 0 0 0.75rem;
  line-height: 1.15;
}

.detail-meta {
  display: flex;
  gap: 10px;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 1.2rem;
}

.detail-date {
  font-size: 0.78rem;
  color: #9a8878;
}

.detail-sep {
  color: #c0c0b0;
  font-size: 0.7rem;
}

.detail-location {
  font-size: 0.78rem;
  color: #9a8878;
  font-style: italic;
}

.detail-mood {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  border: 1px solid;
  padding: 1px 8px;
  border-radius: 3px;
}

.detail-rule {
  height: 1px;
  background: rgba(26, 16, 8, 0.12);
  margin: 1rem 0;
}

.detail-images {
  margin-bottom: 2rem;
}

.detail-img.single {
  width: 100%;
  height: auto;
  max-height: 420px;
  object-fit: cover;
  border-radius: 4px;
  cursor: pointer;
  filter: sepia(0.08);
  transition: filter 0.2s;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.detail-img.single:hover {
  filter: sepia(0);
}

.detail-body {
  margin-bottom: 2.5rem;
}

.detail-para {
  font-size: 1.05rem;
  line-height: 1.9;
  color: #2a1a10;
  margin: 0 0 1.1rem;
  text-align: justify;
  hyphens: auto;
}

.detail-para:first-child::first-letter {
  font-family: 'Cormorant Garamond', serif;
  font-size: 3.2rem;
  font-weight: 600;
  float: left;
  line-height: 0.85;
  margin: 0.1rem 0.15rem 0 0;
  color: #c0392b;
}

.detail-highlights {
  border-left: 2px solid rgba(192, 57, 43, 0.4);
  padding: 1rem 1.2rem;
  margin-bottom: 2rem;
  background: rgba(192, 57, 43, 0.03);
}

.hl-label {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.2em;
  color: #c0392b;
  margin-bottom: 0.6rem;
}

.hl-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.hl-list li {
  font-size: 0.9rem;
  color: #5a3828;
  font-style: italic;
  padding-left: 1rem;
  position: relative;
}

.hl-list li::before {
  content: '—';
  position: absolute;
  left: 0;
  color: #c0392b;
  opacity: 0.5;
}

.detail-footer {
  margin-top: 3rem;
}

.back-btn-bottom {
  background: none;
  border: none;
  font-family: 'EB Garamond', serif;
  font-size: 0.82rem;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: #9a8878;
  cursor: pointer;
  padding: 0;
  margin-top: 1rem;
  transition: color 0.15s;
  display: block;
}

.back-btn-bottom:hover {
  color: #c0392b;
}

.lb-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(10, 5, 0, 0.92);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.lb-img {
  max-width: 90vw;
  max-height: 88vh;
  object-fit: contain;
  border-radius: 3px;
  box-shadow: 0 12px 60px rgba(0, 0, 0, 0.8);
}

.lb-close {
  position: absolute;
  top: 1.2rem;
  right: 1.4rem;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: #aaa;
  border-radius: 4px;
  width: 34px;
  height: 34px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.15s;
}

.lb-close:hover {
  color: #fff;
  background: rgba(255, 255, 255, 0.14);
}

.page-slide-enter-active, .page-slide-leave-active {
  transition: opacity 0.2s;
}

.page-slide-enter-from, .page-slide-leave-to {
  opacity: 0;
}

.lb-enter-active, .lb-leave-active {
  transition: opacity 0.2s;
}

.lb-enter-from, .lb-leave-to {
  opacity: 0;
}

@media (max-width: 540px) {
  .diary-title {
    font-size: 2.4rem;
  }

  .detail-title {
    font-size: 2rem;
  }

  .entry-card {
    gap: 1rem;
  }
}
</style>