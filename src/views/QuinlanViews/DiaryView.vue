<script setup>
import { ref, computed, nextTick } from 'vue'
import { onMounted, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useAuth } from '@/composables/useAuth'
import QuinlanEntryForm from '@/components/QuinlanEntryForm.vue'
import DiaryNav from '@/components/DiaryNav.vue'
import headerImg from '@/assets/quinheader.png'

const { user, isAdmin, profile } = useAuth()
const editing = ref(null)
const creating = ref(false)

const PAGE_BG = '#191919'
const PAGE_FG = '#E3E2DF'

onMounted(() => {
  document.body.style.backgroundColor = PAGE_BG
  document.body.style.color = PAGE_FG
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

const headerStyle = { backgroundImage: `url(${headerImg})` }

const entries = ref([])
const entriesLoading = ref(true)
const entriesError = ref(null)

const lightboxImg = ref(null)
const activeEntry = ref(null)
const revealed = ref(new Set())

// View controls: sort direction, search
const sortAsc = ref(true)
const searchOpen = ref(false)
const query = ref('')
const searchInput = ref(null)

// Anyone can read (like Mory's diary); only admins + can_post_quinlan can write.
const canWrite = computed(() => !!user.value && (isAdmin.value || profile.value.can_post_quinlan))

// Reading order, like chapters in a book — ascending by session (toggleable).
const sorted = computed(() =>
    [...entries.value].sort((a, b) => sortAsc.value ? a.session - b.session : b.session - a.session)
)

const visible = computed(() => {
  const q = query.value.trim().toLowerCase()
  if (!q) return sorted.value
  return sorted.value.filter(e =>
      [e.title, e.location, e.date].some(v => v && String(v).toLowerCase().includes(q))
  )
})

function toggleSearch() {
  searchOpen.value = !searchOpen.value
  if (searchOpen.value) nextTick(() => searchInput.value?.focus())
  else query.value = ''
}

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
  return String(index + 1)
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

async function loadEntries() {
  entriesLoading.value = true
  const { data, error } = await supabase
      .from('quinlan_diary_entries')
      .select('id, session, title, date, location, images, body, highlights')

  if (error) entriesError.value = error
  else entries.value = data
  entriesLoading.value = false
}

onMounted(loadEntries)

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
  if (!confirm(`Erase "${entry.title}" from the Book? This can't be undone.`)) return

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

    <div class="cover" :style="headerStyle" role="img" aria-label="Torn, stained page with a red star" />

      <button v-if="canWrite" class="quill-fab" title="Inscribe a new entry" @click="startCreate">
        <svg viewBox="0 0 48 48" class="quill-icon" aria-hidden="true">
          <path d="M41 4C29 5 15 13 9 27c-2.5 5.5-3.5 10.5-3.5 14.5 3.5-1 8-2.3 12.5-4.6C32 31 41.5 19 43.5 7.5 43.8 5.7 43.8 4.6 41 4z" />
          <path d="M11 37 L33 14" class="quill-shaft" />
          <path d="M5 44 L12.5 36" class="quill-nib" />
        </svg>
      </button>

      <!-- ───────── Entry page ───────── -->
      <transition name="fade">
        <article class="page" v-if="activeEntry">
          <button class="back-btn" @click="close">
            <svg viewBox="0 0 16 16" aria-hidden="true"><path d="M10 3 5 8l5 5" /></svg>
            Quinlan's Book
          </button>

          <div class="page-session">Chapter {{ toRoman(activeEntry.session) }}</div>
          <h1 class="page-title">{{ activeEntry.title }}</h1>

          <div class="page-meta">
            <span v-if="activeEntry.date" class="meta-date">{{ activeEntry.date }}</span>
            <span v-if="activeEntry.date && activeEntry.location" class="meta-sep">·</span>
            <span v-if="activeEntry.location" class="meta-location">{{ activeEntry.location }}</span>
          </div>

          <hr class="divider" />

          <img
              v-if="activeEntry.images?.length"
              :src="activeEntry.images[0]"
              :alt="activeEntry.title"
              class="page-img"
              @click="lightboxImg = activeEntry.images[0]"
          />

          <div class="page-body">
            <template v-for="(block, i) in paragraphs" :key="i">
              <div v-if="block.sensitive && !revealed.has(i)" class="callout">
                <span class="callout-icon" aria-hidden="true">⚠</span>
                <div class="callout-copy">
                  <strong>Trigger warning<span v-if="block.label">: {{ block.label }}</span></strong>
                  <span>This part of the entry contains sensitive content.</span>
                </div>
                <button class="btn-ghost" @click="toggleReveal(i)">Show anyway</button>
              </div>
              <div v-else-if="block.sensitive" class="tw-open">
                <p v-for="(p, j) in block.paragraphs" :key="j" class="para" v-html="p"></p>
                <button class="btn-link" @click="toggleReveal(i)">Hide again</button>
              </div>
              <p v-else class="para" v-html="block.text"></p>
            </template>
          </div>

          <aside class="marginalia" v-if="activeEntry.highlights?.length">
            <h2>Notable</h2>
            <ul>
              <li v-for="h in activeEntry.highlights" :key="h">{{ h }}</li>
            </ul>
          </aside>

          <hr class="divider" />
          <button class="back-btn" @click="close">
            <svg viewBox="0 0 16 16" aria-hidden="true"><path d="M10 3 5 8l5 5" /></svg>
            Back to all entries
          </button>
        </article>
      </transition>

      <!-- ───────── Index ───────── -->
      <transition name="fade">
        <section class="index" v-if="!activeEntry">
          <h1 class="book-title">𝔎𝔞𝔢𝔩𝔞𝔩 𝔩𝔩𝔢 𝔱𝔶𝔞𝔳 𝔦𝔯𝔢𝔩 𝔯𝔦𝔢𝔩𝔱𝔥𝔞𝔩</h1>

          <div class="toolbar">
            <div class="toc-caption">Table of Contents</div>

            <div class="tools">
              <input
                  v-if="searchOpen"
                  ref="searchInput"
                  v-model="query"
                  class="search"
                  type="search"
                  placeholder="Search entries"
                  @keydown.esc="toggleSearch"
              />
              <button class="icon-btn" :title="sortAsc ? 'Oldest first' : 'Newest first'" @click="sortAsc = !sortAsc">
                <svg viewBox="0 0 16 16" aria-hidden="true"><path d="M5 2.5v11M2.5 11 5 13.5 7.5 11M11 13.5v-11M8.5 5 11 2.5 13.5 5" /></svg>
              </button>
              <button class="icon-btn" :class="{ on: searchOpen }" title="Search" @click="toggleSearch">
                <svg viewBox="0 0 16 16" aria-hidden="true"><circle cx="7" cy="7" r="4.5" /><path d="m10.5 10.5 3 3" /></svg>
              </button>
            </div>
          </div>

          <p v-if="entriesLoading" class="status">The pages are turning…</p>
          <p v-else-if="entriesError" class="status">Couldn't load the Book. Refresh the page to try again.</p>
          <p v-else-if="!entries.length" class="status">No chapters yet. Add the first entry to begin the Book.</p>
          <p v-else-if="!visible.length" class="status">Nothing matches “{{ query }}”.</p>

          <template v-else>
            <div class="toc">
              <div
                  v-for="(entry, i) in visible"
                  :key="entry.id"
                  class="toc-row"
                  role="button"
                  tabindex="0"
                  @click="open(entry)"
                  @keydown.enter="open(entry)"
              >
                <span class="toc-num">{{ toRoman(entry.session) }}</span>
                <span class="toc-title">{{ entry.title }}</span>
                <span class="toc-dots" aria-hidden="true" />
                <span class="toc-folio">{{ folio(i) }}</span>
                <span v-if="canWrite" class="admin-actions inline">
                  <button class="admin-btn" title="Edit" @click.stop="startEdit(entry)">✎</button>
                  <button class="admin-btn delete" title="Delete" @click.stop="deleteEntry(entry)">✕</button>
                </span>
              </div>
            </div>
          </template>

          <hr class="divider end" />
        </section>
      </transition>

      <div v-if="editing || creating" class="modal-backdrop">
        <div class="modal-panel">
          <QuinlanEntryForm
              :edit-entry="editing"
              @saved="onSaved"
              @cancel="closeModal"
          />
        </div>
      </div>

      <transition name="fade">
        <div class="lb-backdrop" v-if="lightboxImg" @click="lightboxImg = null">
          <img :src="lightboxImg" class="lb-img" alt="" />
          <button class="lb-close" aria-label="Close" @click="lightboxImg = null">✕</button>
        </div>
      </transition>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=UnifrakturCook:wght@700&family=Inter:wght@400;500;600&display=swap');

.quinlan-root {
  --bg: #191919;
  --surface: #202020;
  --surface-hover: #262626;
  --border: #2F2F2F;
  --text: #E3E2DF;
  --text-strong: #FFFFFF;
  --muted: #9B9A97;
  --faint: #5A5A58;
  --blood: #8A1424;
  --tag-gray-bg: #373737;
  --tag-gray-fg: #D4D4D4;
  --tag-green-bg: #2B593F;
  --tag-green-fg: #D9EFE1;

  min-height: 100vh;
  width: 100vw;
  margin-left: calc(-50vw + 50%);
  background: var(--bg);
  color: var(--text);
  font-family: 'Inter', ui-sans-serif, system-ui, -apple-system, 'Segoe UI', sans-serif;
  font-size: 16px;
  -webkit-font-smoothing: antialiased;
}

svg { flex-shrink: 0; }

/* ───────── Cover ───────── */
.cover {
  height: clamp(190px, 24vw, 400px);
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center bottom;
}

/* ───────── Shared ───────── */
.index,
.page {
  margin: 0 auto;
  padding: 0 clamp(1.25rem, 5vw, 6rem) 6rem;
}

.index { max-width: 1600px; }
.page { max-width: 760px; }

.status {
  color: var(--muted);
  padding: 2.5rem 0;
}

.divider {
  border: 0;
  border-top: 1px solid var(--border);
  margin: 1.5rem 0;
}

.divider.end { margin-top: 1.25rem; }

.tag {
  display: inline-flex;
  align-items: center;
  height: 22px;
  padding: 0 7px;
  border-radius: 4px;
  font-size: 0.875rem;
  line-height: 1;
  white-space: nowrap;
}

.tag-gray { background: var(--tag-gray-bg); color: var(--tag-gray-fg); }
.tag-green { background: var(--tag-green-bg); color: var(--tag-green-fg); }

button { font-family: inherit; }

:focus-visible {
  outline: 2px solid #5E8BC7;
  outline-offset: 2px;
}

/* ───────── Index header ───────── */
.book-title {
  font-family: 'UnifrakturCook', serif;
  font-weight: 700;
  font-size: clamp(2.4rem, 4.2vw, 3.6rem);
  line-height: 1.1;
  color: var(--text-strong);
  margin: clamp(2rem, 5vw, 4.5rem) 0 1.25rem;
  letter-spacing: 0.01em;
}

.quill-fab {
  position: fixed;
  right: 1.8rem;
  bottom: 1.8rem;
  z-index: 60;
  width: 54px;
  height: 54px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--surface);
  border: 1px solid var(--border);
  cursor: pointer;
  box-shadow: 0 4px 18px rgba(0, 0, 0, 0.5);
  transition: transform 0.15s, box-shadow 0.2s, border-color 0.2s, background 0.15s;
}

.quill-fab:hover {
  transform: translateY(-2px);
  background: var(--surface-hover);
  border-color: var(--blood);
  box-shadow: 0 6px 22px rgba(0, 0, 0, 0.55);
}

.quill-fab:active { transform: translateY(0); }

.quill-icon {
  width: 24px;
  height: 24px;
  fill: var(--muted);
}

.quill-icon .quill-shaft {
  stroke: var(--bg);
  stroke-width: 1.1;
  fill: none;
  opacity: 0.5;
}

.quill-icon .quill-nib {
  stroke: var(--text-strong);
  stroke-width: 2.2;
  stroke-linecap: round;
  fill: none;
}

.quill-fab:hover .quill-icon { fill: var(--text-strong); }

@media (max-width: 600px) {
  .quill-fab { right: 1.1rem; bottom: 1.1rem; width: 50px; height: 50px; }
}

.icon-btn svg,
.back-btn svg {
  width: 16px;
  height: 16px;
  fill: none;
  stroke: currentColor;
  stroke-width: 1.4;
  stroke-linecap: round;
  stroke-linejoin: round;
}

/* ───────── Toolbar ───────── */
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1.25rem;
  flex-wrap: wrap;
}

.toc-caption {
  color: var(--muted);
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.14em;
}

.tools {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.icon-btn {
  display: grid;
  place-items: center;
  width: 30px;
  height: 30px;
  border: 0;
  border-radius: 6px;
  background: transparent;
  color: var(--muted);
  cursor: pointer;
}

.icon-btn:hover,
.icon-btn.on { background: var(--surface-hover); color: var(--text); }

.search {
  width: 200px;
  height: 30px;
  padding: 0 0.6rem;
  border: 1px solid var(--border);
  border-radius: 6px;
  background: var(--surface);
  color: var(--text);
  font: inherit;
  font-size: 0.9rem;
}

.search::placeholder { color: var(--faint); }

/* ───────── Table of contents ───────── */
.toc {
  border-top: 1px solid var(--border);
}

.toc-row {
  position: relative;
  display: flex;
  align-items: baseline;
  gap: 0.65rem;
  padding: 0.9rem 0.5rem;
  border-bottom: 1px solid var(--border);
  cursor: pointer;
}

.toc-row:hover { background: var(--surface); }

.toc-num {
  flex-shrink: 0;
  min-width: 2.4em;
  font-family: 'UnifrakturCook', serif;
  font-size: 1.05rem;
  color: var(--blood);
}

.toc-title {
  flex-shrink: 0;
  max-width: 55%;
  color: var(--text-strong);
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.toc-dots {
  flex: 1;
  overflow: hidden;
  white-space: nowrap;
  color: var(--faint);
  letter-spacing: 2px;
  margin: 0 0.2rem;
}

.toc-dots::after {
  content: '. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .';
}

.toc-folio {
  flex-shrink: 0;
  color: var(--muted);
  font-size: 0.9rem;
  font-variant-numeric: tabular-nums;
}

/* ───────── Admin controls ───────── */
.admin-actions {
  display: flex;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.12s;
}

.toc-row:hover .admin-actions,
.toc-row:focus-within .admin-actions { opacity: 1; }

@media (hover: none) {
  .admin-actions { opacity: 1; }
}

.admin-actions.inline {
  margin-left: auto;
}

.admin-btn {
  width: 26px;
  height: 26px;
  border-radius: 5px;
  border: 1px solid var(--border);
  background: rgba(25, 25, 25, 0.9);
  color: var(--text);
  cursor: pointer;
  font-size: 0.8rem;
  line-height: 1;
}

.admin-btn:hover { background: #333; }
.admin-btn.delete:hover { color: #F2A3AD; border-color: var(--blood); }

/* ───────── Entry page ───────── */
.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  margin: 1.5rem 0 0;
  padding: 0.3rem 0.5rem 0.3rem 0.25rem;
  border: 0;
  border-radius: 6px;
  background: transparent;
  color: var(--muted);
  font-size: 0.9rem;
  cursor: pointer;
}

.back-btn:hover { background: var(--surface-hover); color: var(--text); }

.page-session {
  margin-top: 1.5rem;
  font-size: 0.78rem;
  text-transform: uppercase;
  letter-spacing: 0.18em;
  color: var(--blood);
}

.page-title {
  font-family: 'UnifrakturCook', serif;
  font-weight: 700;
  font-size: clamp(2.2rem, 5vw, 3.2rem);
  line-height: 1.12;
  color: var(--text-strong);
  margin: 0.5rem 0 0.75rem;
}

.page-meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 1.25rem;
}

.meta-date {
  font-size: 0.9rem;
  color: var(--muted);
}

.meta-sep {
  color: var(--faint);
  font-size: 0.8rem;
}

.meta-location {
  font-size: 0.9rem;
  color: var(--muted);
  font-style: italic;
}

.page-img {
  display: block;
  width: 100%;
  max-height: 460px;
  object-fit: cover;
  border-radius: 6px;
  margin-bottom: 2rem;
  cursor: zoom-in;
  filter: grayscale(1) contrast(1.1);
  transition: filter 0.2s;
}

.page-img:hover { filter: none; }

.page-body { margin-bottom: 2rem; }

.para {
  font-size: 1rem;
  line-height: 1.75;
  color: var(--text);
  margin: 0 0 1em;
  max-width: 68ch;
}

/* Trigger-warning callout */
.callout {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  padding: 1rem 1.1rem;
  margin: 0 0 1em;
  border-radius: 6px;
  background: #2A1A1C;
}

.callout-icon { color: #E06C7A; font-size: 1.15rem; }

.callout-copy {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
  font-size: 0.9rem;
  color: var(--muted);
}

.callout-copy strong { color: var(--text-strong); font-weight: 500; font-size: 0.95rem; }

.btn-ghost {
  flex-shrink: 0;
  padding: 0.4rem 0.75rem;
  border: 1px solid #4A2A2F;
  border-radius: 6px;
  background: transparent;
  color: var(--text);
  font-size: 0.875rem;
  cursor: pointer;
}

.btn-ghost:hover { background: #3A2226; }

.tw-open {
  border-left: 3px solid var(--blood);
  padding-left: 1rem;
  margin: 0 0 1em;
}

.btn-link {
  border: 0;
  background: none;
  padding: 0;
  color: var(--muted);
  font-size: 0.85rem;
  cursor: pointer;
  text-decoration: underline;
  text-underline-offset: 3px;
}

.btn-link:hover { color: var(--text); }

/* Marginalia as a quote block */
.marginalia {
  border-left: 3px solid var(--text);
  padding: 0.1rem 0 0.1rem 1rem;
  margin: 0 0 2rem;
}

.marginalia h2 {
  margin: 0 0 0.5rem;
  font-size: 1rem;
  font-weight: 600;
  color: var(--text-strong);
}

.marginalia ul {
  margin: 0;
  padding-left: 1.1rem;
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
}

.marginalia li {
  line-height: 1.6;
  color: var(--text);
}

.marginalia li::marker { color: var(--blood); }

/* ───────── Lightbox ───────── */
.lb-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(8, 8, 8, 0.94);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.lb-img {
  max-width: 92vw;
  max-height: 88vh;
  object-fit: contain;
  border-radius: 4px;
}

.lb-close {
  position: absolute;
  top: 1.2rem;
  right: 1.4rem;
  width: 34px;
  height: 34px;
  border-radius: 6px;
  border: 1px solid var(--border);
  background: var(--surface);
  color: var(--text);
  cursor: pointer;
}

.lb-close:hover { background: var(--surface-hover); }

/* ───────── Modal ───────── */
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(8, 8, 8, 0.75);
  z-index: 1000;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 3rem 1rem;
  overflow-y: auto;
}

.modal-panel {
  width: 100%;
  max-width: 700px;
  background: #202020;
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 1.5rem;
  color: var(--text);
  box-shadow: 0 24px 64px rgba(0, 0, 0, 0.6);
}

.modal-panel :deep(h3) { color: var(--text-strong); }


.fade-enter-active, .fade-leave-active { transition: opacity 0.18s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

@media (prefers-reduced-motion: reduce) {
  .fade-enter-active, .fade-leave-active { transition: none; }
}

/* ───────── Small screens ───────── */
@media (max-width: 600px) {
  .search { width: 140px; }
  .toc-title { max-width: 70%; font-size: 0.95rem; }
}
</style>