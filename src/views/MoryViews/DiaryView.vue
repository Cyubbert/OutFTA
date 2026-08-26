<script setup>
import {ref, computed} from 'vue'
import {onMounted, onUnmounted} from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useAuth } from '@/composables/useAuth'
import AdminEntryFrom from '@/components/AdminEntryFrom.vue'

const { isAdmin } = useAuth()
const editing = ref(null)
const creating = ref(false)

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


const entries = ref([])
const entriesLoading = ref(true)
const entriesError = ref(null)

const lightboxImg = ref(null)
const activeEntry = ref(null)
const revealed = ref(new Set())

const sorted = computed(() =>
    [...entries.value].sort((a, b) => b.session - a.session)
)

const TW_RE = /^\[tw(?::\s*(.*?))?\]\s*([\s\S]*?)\s*\[\/tw\]$/i

const paragraphs = computed(() => {
  if (!activeEntry.value) return []
  return activeEntry.value.body
      .split('\n\n')
      .map(p => p.trim())
      .filter(Boolean)
      .map(p => {
        const match = p.match(TW_RE)
        return match
            ? { sensitive: true, label: match[1]?.trim() || null, text: match[2].trim() }
            : { sensitive: false, text: p }
      })
})

function toggleReveal(i) {
  const next = new Set(revealed.value)
  next.has(i) ? next.delete(i) : next.add(i)
  revealed.value = next
}

function open(entry) {
  activeEntry.value = entry
  revealed.value = new Set()
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

onMounted(async () => {
  const { data, error } = await supabase
      .from('diary_entries')
      .select('id, session, title, date, location, mood, images, body, highlights')

  if (error) entriesError.value = error
  else entries.value = data
  entriesLoading.value = false
})

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
  if (!confirm(`Delete "${entry.title}"? This can't be undone.`)) return

  const { error } = await supabase.from('diary_entries').delete().eq('id', entry.id)
  if (error) {
    alert(error.message)
    return
  }
  entries.value = entries.value.filter(e => e.id !== entry.id)
  if (activeEntry.value?.id === entry.id) activeEntry.value = null
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
          <template v-for="(para, i) in paragraphs" :key="i">
            <div v-if="para.sensitive && !revealed.has(i)" class="tw-block">
              <div class="tw-icon">⚠</div>
              <div class="tw-copy">
                <div class="tw-title">Trigger warning<span v-if="para.label"> — {{ para.label }}</span></div>
                <div class="tw-sub">This part of the entry contains sensitive content.</div>
              </div>
              <button class="tw-btn" @click="toggleReveal(i)">Show anyway</button>
            </div>
            <p v-else class="detail-para" :class="{ 'tw-open': para.sensitive }">
              {{ para.text }}
              <button v-if="para.sensitive" class="tw-hide-btn" @click="toggleReveal(i)">Hide</button>
            </p>
          </template>
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
          <p class="diary-subtitle">Prayer's for my dear</p>
          <div class="header-rule"/>
        </header>

        <p v-if="entriesLoading" class="diary-status">Loading…</p>
        <p v-else-if="entriesError" class="diary-status">Couldn't load the journal.</p>

        <div v-else class="entries">
          <button v-if="isAdmin" class="entry-card create-entry-card" @click="startCreate">
            <span class="create-plus">+</span>
            <span class="create-label">New journal entry</span>
          </button>

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

            <div v-if="isAdmin" class="admin-actions">
              <button class="admin-btn" title="Edit" @click.stop="startEdit(entry)">✎</button>
              <button class="admin-btn delete" title="Delete" @click.stop="deleteEntry(entry)">✕</button>
            </div>
          </div>
        </div>
      </div>
    </transition>

    <div v-if="editing || creating" class="modal-backdrop" @click.self="closeModal">
      <div class="modal-panel">
        <AdminEntryFrom :edit-entry="editing" @saved="onSaved" @cancel="closeModal" />
      </div>
    </div>

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

.diary-status {
  text-align: center;
  color: #9a8878;
  font-style: italic;
}

.entries {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.entry-card {
  position: relative;
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

.create-entry-card {
  width: 100%;
  align-items: center;
  justify-content: center;
  gap: 0.6rem;
  background: rgba(192, 57, 43, 0.03);
  border: 1px dashed rgba(192, 57, 43, 0.3);
  color: #c0392b;
  font-family: 'EB Garamond', serif;
}

.create-entry-card:hover {
  background: rgba(192, 57, 43, 0.07);
  border-color: #c0392b;
}

.create-entry-card .create-plus {
  font-size: 1.6rem;
  line-height: 1;
}

.create-entry-card .create-label {
  font-size: 0.85rem;
  letter-spacing: 0.06em;
  text-transform: uppercase;
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

.tw-block {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.2rem;
  margin: 0 0 1.1rem;
  border: 1px dashed rgba(192, 57, 43, 0.4);
  border-radius: 4px;
  background: rgba(192, 57, 43, 0.05);
}

.tw-icon {
  font-size: 1.3rem;
  color: #c0392b;
  flex-shrink: 0;
}

.tw-copy {
  flex: 1;
  min-width: 0;
}

.tw-title {
  font-family: 'Cormorant Garamond', serif;
  font-style: italic;
  font-size: 1.05rem;
  color: #8b0000;
}

.tw-sub {
  font-size: 0.78rem;
  color: #9a8878;
  margin-top: 2px;
}

.tw-btn {
  flex-shrink: 0;
  background: none;
  border: 1px solid rgba(192, 57, 43, 0.4);
  color: #c0392b;
  font-family: 'EB Garamond', serif;
  font-size: 0.78rem;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  padding: 0.5rem 0.9rem;
  border-radius: 3px;
  cursor: pointer;
  transition: background 0.15s;
}

.tw-btn:hover {
  background: rgba(192, 57, 43, 0.1);
}

.detail-para.tw-open {
  padding: 0.8rem 1rem;
  border-left: 2px solid rgba(192, 57, 43, 0.4);
  background: rgba(192, 57, 43, 0.03);
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
  color: #9a8878;
  cursor: pointer;
  padding: 0;
}

.tw-hide-btn:hover {
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

.admin-actions {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 3;
  display: flex;
  gap: 6px;
}

.admin-btn {
  width: 28px;
  height: 28px;
  border-radius: 6px;
  border: 1px solid rgba(26, 16, 8, 0.15);
  background: rgba(245, 240, 232, 0.85);
  color: #5a3828;
  cursor: pointer;
  font-size: 0.85rem;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}

.admin-btn:hover {
  border-color: #c0392b;
  color: #c0392b;
}

.admin-btn.delete:hover {
  border-color: #8b0000;
  color: #8b0000;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(10, 5, 0, 0.75);
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
</style>