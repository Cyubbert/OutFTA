<script setup>
import { ref, computed } from 'vue'
import { onMounted, onUnmounted, watch } from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useAuth } from '@/composables/useAuth'
import QuinlanEntryForm from '@/components/QuinlanEntryForm.vue'
import DiaryNav from '@/components/DiaryNav.vue'

const { user, isAdmin, profile, loading: authLoading } = useAuth()
const editing = ref(null)
const creating = ref(false)

onMounted(() => {
  document.body.style.backgroundColor = '#2F171E'
  document.body.style.color = '#D1CABD'
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

const entries = ref([])
const entriesLoaded = ref(false)
const entriesLoading = ref(true)
const entriesError = ref(null)

const lightboxImg = ref(null)
const activeEntry = ref(null)
const revealed = ref(new Set())

// ADMIN-ONLY LOCKDOWN (temporary): the page is restricted to admins only
// right now, regardless of the can_view_quinlan / can_post_quinlan toggles.
// To reopen it to toggled-in users later, restore:
//   const canView = computed(() => !!user.value && (isAdmin.value || profile.value.can_view_quinlan))
//   const canWrite = computed(() => !!user.value && (isAdmin.value || profile.value.can_post_quinlan))
const canView = computed(() => !!user.value && isAdmin.value)
const canWrite = computed(() => !!user.value && isAdmin.value)
const showGate = computed(() => !authLoading.value && !canView.value)

// Reading order, like chapters in a book — ascending by session.
const sorted = computed(() =>
    [...entries.value].sort((a, b) => a.session - b.session)
)

function toRoman(num) {
  const map = [
    [1000, 'M'], [900, 'CM'], [500, 'D'], [400, 'CD'],
    [100, 'C'], [90, 'XC'], [50, 'L'], [40, 'XL'],
    [10, 'X'], [9, 'IX'], [5, 'V'], [4, 'IV'], [1, 'I']
  ]
  let n = num
  let out = ''
  for (const [v, s] of map) {
    while (n >= v) { out += s; n -= v }
  }
  return out || 'I'
}

function folio(index) {
  return String(7 + index * 4).padStart(2, '0')
}

function splitParas(text) {
  return text.split('\n\n').map(p => p.trim()).filter(Boolean)
}

const paragraphs = computed(() => {
  if (!activeEntry.value) return []
  const body = activeEntry.value.body
  const blocks = []
  let lastIndex = 0
  let match

  const twBlockRe = /\[tw(?::\s*([^\]]*))?]([\s\S]*?)\[\/tw]/gi
  while ((match = twBlockRe.exec(body))) {
    for (const p of splitParas(body.slice(lastIndex, match.index))) {
      blocks.push({ sensitive: false, text: p })
    }
    blocks.push({ sensitive: true, label: match[1]?.trim() || null, paragraphs: splitParas(match[2]) })
    lastIndex = twBlockRe.lastIndex
  }
  for (const p of splitParas(body.slice(lastIndex))) {
    blocks.push({ sensitive: false, text: p })
  }

  return blocks
})

function toggleReveal(i) {
  const next = new Set(revealed.value)
  next.has(i) ? next.delete(i) : next.add(i)
  revealed.value = next
}

function open(entry) {
  activeEntry.value = entry
  revealed.value = new Set()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

function close() {
  activeEntry.value = null
}

const moodColors = {
  obsessive: '#7D0010',
  wrathful: '#7D0010',
  ravenous: '#7D0010',
  hollow: '#51514F',
  serene: '#454D3D',
  patient: '#454D3D',
  determined: '#B17A2A',
  neutral: '#51514F',
}

function moodColor(mood) {
  return moodColors[mood] || '#B17A2A'
}

async function loadEntries() {
  entriesLoading.value = true
  const { data, error } = await supabase
      .from('quinlan_diary_entries')
      .select('id, session, title, date, location, mood, images, body, highlights')

  if (error) entriesError.value = error
  else entries.value = data
  entriesLoaded.value = true
  entriesLoading.value = false
}

watch(canView, (v) => {
  if (v && !entriesLoaded.value) loadEntries()
}, { immediate: true })

function startEdit(entry) {
  editing.value = entry
}

function startCreate() {
  creating.value = true
}

function closeModal() {
  editing.value = null
  creating.value = false
}

function onSaved(record) {
  if (editing.value) {
    const idx = entries.value.findIndex(e => e.id === editing.value.id)
    if (idx !== -1) entries.value[idx] = { ...entries.value[idx], ...record }
  } else {
    entries.value.push(record)
  }
  closeModal()
}

async function deleteEntry(entry) {
  if (!confirm(`Erase "${entry.title}" from the grimoire? This can't be undone.`)) return

  const { error } = await supabase.from('quinlan_diary_entries').delete().eq('id', entry.id)
  if (error) {
    alert(error.message)
    return
  }
  entries.value = entries.value.filter(e => e.id !== entry.id)
  if (activeEntry.value?.id === entry.id) activeEntry.value = null
}
</script>

<template>
  <div class="quinlan-root">
    <DiaryNav active="quinlan" />

    <div v-if="showGate" class="gate">
      <svg viewBox="0 0 64 48" class="scarab-icon gate-scarab" aria-hidden="true">
        <ellipse cx="32" cy="26" rx="18" ry="14" />
        <circle cx="32" cy="10" r="5" />
        <path d="M32 12 L32 40" stroke="#B17A2A" stroke-width="1.5" fill="none" opacity="0.6" />
        <path d="M20 14 Q10 10 6 18" stroke="#B17A2A" stroke-width="1.5" fill="none" />
        <path d="M44 14 Q54 10 58 18" stroke="#B17A2A" stroke-width="1.5" fill="none" />
        <path d="M14 26 Q4 26 2 32" stroke="#B17A2A" stroke-width="1.5" fill="none" />
        <path d="M50 26 Q60 26 62 32" stroke="#B17A2A" stroke-width="1.5" fill="none" />
        <path d="M16 36 Q8 40 8 46" stroke="#B17A2A" stroke-width="1.5" fill="none" />
        <path d="M48 36 Q56 40 56 46" stroke="#B17A2A" stroke-width="1.5" fill="none" />
      </svg>
      <p class="gate-text">The grimoire remains sealed to the uninitiated.</p>
      <router-link v-if="!user" to="/login" class="gate-link">Sign in</router-link>
    </div>

    <template v-else>
      <button v-if="canWrite" class="quill-fab" title="Inscribe a new entry" @click="startCreate">
        <svg viewBox="0 0 48 48" class="quill-icon" aria-hidden="true">
          <path d="M41 4C29 5 15 13 9 27c-2.5 5.5-3.5 10.5-3.5 14.5 3.5-1 8-2.3 12.5-4.6C32 31 41.5 19 43.5 7.5 43.8 5.7 43.8 4.6 41 4z" />
          <path d="M11 37 L33 14" class="quill-shaft" />
          <path d="M5 44 L12.5 36" class="quill-nib" />
        </svg>
      </button>

      <transition name="page-slide">
        <div class="diary-detail" v-if="activeEntry">
          <button class="back-btn" @click="close">← Return to the index</button>

          <div class="detail-header">
            <div class="detail-session">Chapter {{ toRoman(activeEntry.session) }}</div>
            <h1 class="detail-title">{{ activeEntry.title }}</h1>
            <div class="detail-meta">
              <span class="detail-date">{{ activeEntry.date }}</span>
              <span class="detail-sep">·</span>
              <span class="detail-location">{{ activeEntry.location }}</span>
              <span v-if="activeEntry.mood" class="detail-mood"
                    :style="{ color: moodColor(activeEntry.mood), borderColor: moodColor(activeEntry.mood) + '55' }">
                {{ activeEntry.mood }}
              </span>
            </div>
            <div class="detail-rule" />
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
            <template v-for="(block, i) in paragraphs" :key="i">
              <div v-if="block.sensitive && !revealed.has(i)" class="tw-block">
                <div class="tw-icon">⚠</div>
                <div class="tw-copy">
                  <div class="tw-title">Trigger warning<span v-if="block.label"> — {{ block.label }}</span></div>
                  <div class="tw-sub">This part of the entry contains sensitive content.</div>
                </div>
                <button class="tw-btn" @click="toggleReveal(i)">Show anyway</button>
              </div>
              <template v-else-if="block.sensitive">
                <p v-for="(p, j) in block.paragraphs" :key="j" class="detail-para tw-open" v-html="p"></p>
                <button class="tw-hide-btn" @click="toggleReveal(i)">Hide</button>
              </template>
              <p v-else class="detail-para" v-html="block.text"></p>
            </template>
          </div>

          <div class="detail-highlights" v-if="activeEntry.highlights?.length">
            <div class="hl-label">— marginalia —</div>
            <ul class="hl-list">
              <li v-for="h in activeEntry.highlights" :key="h">{{ h }}</li>
            </ul>
          </div>

          <div class="detail-footer">
            <div class="detail-rule" />
            <button class="back-btn-bottom" @click="close">← Return to the index</button>
          </div>
        </div>
      </transition>

      <transition name="page-slide">
        <div class="diary-list" v-if="!activeEntry">
          <header class="diary-header">
            <svg viewBox="0 0 64 48" class="scarab-icon" aria-hidden="true">
              <ellipse cx="32" cy="26" rx="18" ry="14" />
              <circle cx="32" cy="10" r="5" />
              <path d="M32 12 L32 40" stroke="#B17A2A" stroke-width="1.5" fill="none" opacity="0.6" />
              <path d="M20 14 Q10 10 6 18" stroke="#B17A2A" stroke-width="1.5" fill="none" />
              <path d="M44 14 Q54 10 58 18" stroke="#B17A2A" stroke-width="1.5" fill="none" />
              <path d="M14 26 Q4 26 2 32" stroke="#B17A2A" stroke-width="1.5" fill="none" />
              <path d="M50 26 Q60 26 62 32" stroke="#B17A2A" stroke-width="1.5" fill="none" />
              <path d="M16 36 Q8 40 8 46" stroke="#B17A2A" stroke-width="1.5" fill="none" />
              <path d="M48 36 Q56 40 56 46" stroke="#B17A2A" stroke-width="1.5" fill="none" />
            </svg>
            <h1 class="diary-title">Quinlan's Grimoire</h1>
            <p class="diary-subtitle">Rites, remains, and reckonings</p>
            <div class="header-rule" />
          </header>

          <p v-if="entriesLoading" class="diary-status">The pages are turning…</p>
          <p v-else-if="entriesError" class="diary-status">The binding resists — couldn't load the grimoire.</p>

          <div v-else class="toc">
            <div class="toc-caption">Table of Contents</div>

            <div
                v-for="(entry, i) in sorted"
                :key="entry.id"
                class="toc-row"
                @click="open(entry)"
            >
              <span class="toc-num">{{ toRoman(entry.session) }}</span>
              <span class="toc-entry-title">{{ entry.title }}</span>
              <span class="toc-dots" />
              <span class="toc-folio">{{ folio(i) }}</span>

              <span v-if="entry.mood" class="toc-mood" :style="{ color: moodColor(entry.mood) }">{{ entry.mood }}</span>

              <span v-if="isAdmin" class="admin-actions">
                <button class="admin-btn" title="Edit" @click.stop="startEdit(entry)">✎</button>
                <button class="admin-btn delete" title="Delete" @click.stop="deleteEntry(entry)">✕</button>
              </span>
            </div>

            <p v-if="!sorted.length" class="diary-status">No chapters have been written yet.</p>
          </div>
        </div>
      </transition>

      <div v-if="editing || creating" class="modal-backdrop">
        <div class="modal-panel q-modal-panel">
          <QuinlanEntryForm
              :edit-entry="editing"
              @saved="onSaved"
              @cancel="closeModal"
          />
        </div>
      </div>

      <transition name="lb">
        <div class="lb-backdrop" v-if="lightboxImg" @click="lightboxImg = null">
          <img :src="lightboxImg" class="lb-img" />
          <button class="lb-close" @click="lightboxImg = null">✕</button>
        </div>
      </transition>
    </template>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=UnifrakturMaguntia&family=Spectral:ital,wght@0,400;0,500;0,600;1,400&family=Pirata+One&family=IM+Fell+English:ital@0;1&family=EB+Garamond:ital,wght@0,400;0,500;0,600;1,400&display=swap');

.quinlan-root {
  min-height: 100vh;
  width: 100vw;
  margin-left: calc(-50vw + 50%);
  background: #2F171E;
  background-image:
      radial-gradient(ellipse 65% 45% at 50% 0%, rgba(125, 0, 16, 0.12), transparent 60%),
      radial-gradient(ellipse 55% 35% at 100% 100%, rgba(69, 77, 61, 0.18), transparent 60%),
      linear-gradient(180deg, #2F171E 0%, #293222 100%);
  color: #D1CABD;
  font-family: 'IM Fell English', 'EB Garamond', serif;
  position: relative;
}

.scarab-icon {
  width: 34px;
  height: 26px;
  color: #454D3D;
  fill: currentColor;
  margin: 0 auto 0.75rem;
  display: block;
  filter: drop-shadow(0 0 6px rgba(177, 122, 42, 0.25));
}

.gate {
  min-height: 80vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  text-align: center;
  padding: 2rem;
}

.gate-scarab {
  width: 48px;
  height: 36px;
}

.gate-text {
  font-style: italic;
  font-size: 1.15rem;
  color: #D1CABD;
  max-width: 360px;
}

.gate-link {
  border: 1px solid rgba(177, 122, 42, 0.5);
  color: #B17A2A;
  text-decoration: none;
  padding: 0.5rem 1.2rem;
  border-radius: 2px;
  font-size: 0.82rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  font-family: 'EB Garamond', serif;
  transition: background 0.2s, color 0.2s;
}

.gate-link:hover {
  background: rgba(177, 122, 42, 0.12);
  color: #D1CABD;
}

.diary-list {
  max-width: 700px;
  margin: 0 auto;
  padding: 3.5rem 1.5rem 6rem;
}

.diary-header {
  text-align: center;
  margin-bottom: 2.5rem;
}

.diary-title {
  font-family: 'Pirata One', serif;
  font-size: 3.4rem;
  font-weight: 400;
  color: #D1CABD;
  margin: 0 0 0.3rem;
  letter-spacing: 0.04em;
  text-shadow: 0 0 18px rgba(125, 0, 16, 0.35);
}

.diary-subtitle {
  font-family: 'EB Garamond', serif;
  font-size: 0.78rem;
  text-transform: uppercase;
  letter-spacing: 0.3em;
  color: #B17A2A;
  margin: 0 0 1.5rem;
}

.header-rule {
  width: 70px;
  height: 1px;
  background: linear-gradient(90deg, transparent, #7D0010, #B17A2A, #7D0010, transparent);
  margin: 0 auto;
  opacity: 0.8;
}

.diary-status {
  text-align: center;
  color: #A69C8D;
  font-style: italic;
  padding: 2rem 0;
}

.toc {
  border: 1px solid rgba(177, 122, 42, 0.25);
  background: rgba(55, 56, 50, 0.3);
  border-radius: 3px;
  padding: 2rem 1.8rem;
  box-shadow: inset 0 0 40px rgba(0, 0, 0, 0.25);
}

.toc-caption {
  text-align: center;
  font-family: 'EB Garamond', serif;
  font-size: 0.72rem;
  text-transform: uppercase;
  letter-spacing: 0.3em;
  color: #51514F;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid rgba(177, 122, 42, 0.2);
}

.toc-row {
  position: relative;
  display: flex;
  align-items: baseline;
  gap: 0.6rem;
  width: 100%;
  padding: 0.65rem 0.4rem;
  background: none;
  border: none;
  cursor: pointer;
  font-family: inherit;
  color: inherit;
  text-align: left;
  transition: background 0.15s;
  border-radius: 2px;
}

.toc-row:hover {
  background: rgba(125, 0, 16, 0.1);
}

.toc-row:hover .toc-entry-title {
  color: #D1CABD;
}

.toc-row:hover .toc-folio,
.toc-row:hover .toc-num {
  color: #B17A2A;
}

.toc-num {
  flex-shrink: 0;
  font-family: 'Pirata One', serif;
  font-size: 1.1rem;
  color: #7D0010;
  min-width: 2.2em;
}

.toc-entry-title {
  flex-shrink: 0;
  font-size: 1.15rem;
  color: #D1CABD;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 70%;
}

.toc-dots {
  flex: 1;
  overflow: hidden;
  white-space: nowrap;
  color: #51514F;
  letter-spacing: 2px;
  margin: 0 0.3rem;
}

.toc-dots::after {
  content: '. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .';
}

.toc-folio {
  flex-shrink: 0;
  font-size: 0.9rem;
  color: #51514F;
  font-variant-numeric: tabular-nums;
}

.toc-mood {
  flex-shrink: 0;
  font-family: 'EB Garamond', serif;
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  margin-left: 0.5rem;
}

.quill-fab {
  position: fixed;
  right: 1.8rem;
  bottom: 1.8rem;
  z-index: 60;
  width: 58px;
  height: 58px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: radial-gradient(circle at 35% 30%, #454D3D, #2F171E 70%);
  border: 1px solid rgba(177, 122, 42, 0.5);
  cursor: pointer;
  box-shadow: 0 4px 18px rgba(0, 0, 0, 0.5), 0 0 0 rgba(125, 0, 16, 0);
  transition: transform 0.18s, box-shadow 0.25s, border-color 0.25s;
}

.quill-fab:hover {
  transform: translateY(-2px) scale(1.05);
  border-color: #B17A2A;
  box-shadow: 0 6px 22px rgba(0, 0, 0, 0.55), 0 0 16px rgba(125, 0, 16, 0.45);
}

.quill-fab:active {
  transform: translateY(0) scale(0.97);
}

.quill-icon {
  width: 26px;
  height: 26px;
  fill: #B17A2A;
}

.quill-icon .quill-shaft {
  stroke: #2F171E;
  stroke-width: 1.1;
  fill: none;
  opacity: 0.45;
}

.quill-icon .quill-nib {
  stroke: #D1CABD;
  stroke-width: 2.3;
  stroke-linecap: round;
  fill: none;
}

@media (max-width: 540px) {
  .quill-fab {
    right: 1.1rem;
    bottom: 1.1rem;
    width: 52px;
    height: 52px;
  }
}

.admin-actions {
  display: flex;
  gap: 6px;
  flex-shrink: 0;
  margin-left: 0.5rem;
}

.admin-btn {
  width: 26px;
  height: 26px;
  border-radius: 3px;
  border: 1px solid rgba(177, 122, 42, 0.3);
  background: rgba(47, 23, 30, 0.6);
  color: #D1CABD;
  cursor: pointer;
  font-size: 0.8rem;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}

.admin-btn:hover {
  border-color: #B17A2A;
  color: #B17A2A;
}

.admin-btn.delete:hover {
  border-color: #7D0010;
  color: #e0556a;
}

.diary-detail {
  max-width: 680px;
  margin: 0 auto;
  padding: 2.5rem 1.5rem 6rem;
}

.back-btn {
  background: none;
  border: none;
  font-family: 'EB Garamond', serif;
  font-size: 0.82rem;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: #51514F;
  cursor: pointer;
  padding: 0;
  margin-bottom: 2.5rem;
  transition: color 0.15s;
}

.back-btn:hover,
.back-btn-bottom:hover {
  color: #B17A2A;
}

.detail-header {
  margin-bottom: 2rem;
}

.detail-session {
  font-family: 'EB Garamond', serif;
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.2em;
  color: #7D0010;
  margin-bottom: 0.6rem;
}

.detail-title {
  font-family: 'Pirata One', serif;
  font-size: 2.6rem;
  font-weight: 400;
  color: #D1CABD;
  margin: 0 0 0.75rem;
  line-height: 1.15;
  text-shadow: 0 0 14px rgba(125, 0, 16, 0.3);
}

.detail-meta {
  display: flex;
  gap: 10px;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 1.2rem;
  font-family: 'EB Garamond', serif;
}

.detail-date {
  font-size: 0.78rem;
  color: #A69C8D;
}

.detail-sep {
  color: #51514F;
  font-size: 0.7rem;
}

.detail-location {
  font-size: 0.78rem;
  color: #A69C8D;
  font-style: italic;
}

.detail-mood {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  border: 1px solid;
  padding: 1px 8px;
  border-radius: 2px;
}

.detail-rule {
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(177, 122, 42, 0.4), transparent);
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
  border-radius: 2px;
  cursor: pointer;
  filter: sepia(0.25) saturate(0.85) contrast(1.05) brightness(0.92);
  transition: filter 0.2s;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
  border: 1px solid rgba(177, 122, 42, 0.25);
}

.detail-img.single:hover {
  filter: sepia(0.05) saturate(1) contrast(1) brightness(1);
}

.detail-body {
  margin-bottom: 2.5rem;
}

.detail-para {
  font-size: 1.08rem;
  line-height: 1.9;
  color: #D1CABD;
  margin: 0 0 1.1rem;
  text-align: justify;
  hyphens: auto;
}

.detail-para:first-child::first-letter {
  font-family: 'Pirata One', serif;
  font-size: 3.4rem;
  font-weight: 400;
  float: left;
  line-height: 0.8;
  margin: 0.1rem 0.2rem 0 0;
  color: #B17A2A;
}

.tw-block {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.2rem;
  margin: 0 0 1.1rem;
  border: 1px dashed rgba(125, 0, 16, 0.5);
  border-radius: 2px;
  background: rgba(125, 0, 16, 0.08);
}

.tw-icon {
  font-size: 1.3rem;
  color: #7D0010;
  flex-shrink: 0;
}

.tw-copy {
  flex: 1;
  min-width: 0;
  font-family: 'EB Garamond', serif;
}

.tw-title {
  font-style: italic;
  font-size: 1rem;
  color: #e0556a;
}

.tw-sub {
  font-size: 0.78rem;
  color: #A69C8D;
  margin-top: 2px;
}

.tw-btn {
  flex-shrink: 0;
  background: none;
  border: 1px solid rgba(125, 0, 16, 0.5);
  color: #e0556a;
  font-family: 'EB Garamond', serif;
  font-size: 0.78rem;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  padding: 0.5rem 0.9rem;
  border-radius: 2px;
  cursor: pointer;
  transition: background 0.15s;
}

.tw-btn:hover {
  background: rgba(125, 0, 16, 0.15);
}

.detail-para.tw-open {
  padding: 0.8rem 1rem;
  border-left: 2px solid rgba(125, 0, 16, 0.5);
  background: rgba(125, 0, 16, 0.06);
}

.tw-hide-btn {
  display: block;
  margin-top: 0.5rem;
  background: none;
  border: none;
  font-family: 'EB Garamond', serif;
  font-size: 0.72rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: #A69C8D;
  cursor: pointer;
  padding: 0;
}

.tw-hide-btn:hover {
  color: #B17A2A;
}

.detail-highlights {
  border-left: 2px solid rgba(177, 122, 42, 0.5);
  padding: 1rem 1.2rem;
  margin-bottom: 2rem;
  background: rgba(69, 77, 61, 0.15);
}

.hl-label {
  font-family: 'EB Garamond', serif;
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.2em;
  color: #B17A2A;
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
  color: #D1CABD;
  font-style: italic;
  padding-left: 1rem;
  position: relative;
}

.hl-list li::before {
  content: '—';
  position: absolute;
  left: 0;
  color: #7D0010;
  opacity: 0.7;
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
  color: #51514F;
  cursor: pointer;
  padding: 0;
  margin-top: 1rem;
  display: block;
}

.lb-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(10, 4, 5, 0.94);
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
  border-radius: 2px;
  box-shadow: 0 12px 60px rgba(0, 0, 0, 0.8);
}

.lb-close {
  position: absolute;
  top: 1.2rem;
  right: 1.4rem;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(177, 122, 42, 0.3);
  color: #D1CABD;
  border-radius: 3px;
  width: 34px;
  height: 34px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: all 0.15s;
}

.lb-close:hover {
  color: #B17A2A;
  background: rgba(255, 255, 255, 0.1);
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

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(10, 4, 5, 0.8);
  z-index: 1000;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 3rem 1rem;
  overflow-y: auto;
}

.modal-panel {
  background: #181818;
  border: 1px solid #333;
  border-radius: 12px;
  padding: 1.5rem;
  width: 100%;
  max-width: 540px;
  color: #e0e0e0;
  font-family: 'Jost', ui-sans-serif, system-ui, sans-serif;
}

.modal-panel :deep(h3) {
  color: #fff;
}

.q-modal-panel {
  background: linear-gradient(180deg, #373832, #2F171E 60%);
  border: 1px solid rgba(177, 122, 42, 0.35);
  border-radius: 6px;
  max-width: 700px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.6);
}

@media (max-width: 540px) {
  .diary-title {
    font-size: 2.5rem;
  }

  .detail-title {
    font-size: 2rem;
  }

  .toc-entry-title {
    max-width: 50%;
    font-size: 1rem;
  }

  .toc-mood {
    display: none;
  }
}
</style>
