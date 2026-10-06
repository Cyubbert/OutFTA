<script setup>
import { ref, reactive, computed, nextTick } from 'vue'
import { supabase } from '@/lib/supabase'
import { useSongForm, songFields } from '@/composables/useSongForm'

const props = defineProps({
  editEntry: { type: Object, default: null }
})
const emit = defineEmits(['saved', 'cancel'])

const form = reactive({
  session: props.editEntry?.session ?? null,
  title: props.editEntry?.title ?? '',
  date: props.editEntry?.date ?? '',
  location: props.editEntry?.location ?? '',
  body: props.editEntry?.body ?? '',
  ...songFields(props.editEntry)
})

const imageUrlInput = ref(props.editEntry?.images?.[0] ?? '')
const highlightsInput = ref((props.editEntry?.highlights ?? []).join('\n'))
const submitting = ref(false)
const successMsg = ref('')
const errorMsg = ref('')
const toolbarHint = ref('')

// ── rich-text toolbar ──

const bodyEl = ref(null)

const fonts = [
  { label: 'Unifraktur', family: "'UnifrakturMaguntia', cursive" },
  { label: 'Spectral', family: "'Spectral', serif" },
  { label: 'Fell English', family: "'IM Fell English', serif" }
]

const colors = [
  { label: 'Parchment', hex: '#D1CABD' },
  { label: 'Blood', hex: '#7D0010' },
  { label: 'Gold', hex: '#B17A2A' },
  { label: 'Emerald', hex: '#454D3D' }
]

function flashHint(msg) {
  toolbarHint.value = msg
  setTimeout(() => { if (toolbarHint.value === msg) toolbarHint.value = '' }, 2200)
}

function currentSelection() {
  const el = bodyEl.value
  if (!el) return null
  const start = el.selectionStart
  const end = el.selectionEnd
  if (start === end) {
    flashHint('Select some text first, then apply a style.')
    return null
  }
  return { el, start, end }
}

function wrapSelection(before, after) {
  const sel = currentSelection()
  if (!sel) return
  const { el, start, end } = sel
  const selected = form.body.slice(start, end)
  form.body = form.body.slice(0, start) + before + selected + after + form.body.slice(end)

  const newStart = start + before.length
  const newEnd = newStart + selected.length
  nextTick(() => {
    el.focus()
    el.setSelectionRange(newStart, newEnd)
  })
}

function applyFont(family) {
  wrapSelection(`<span style="font-family: ${family}">`, '</span>')
}

function applyColor(hex) {
  wrapSelection(`<span style="color: ${hex}">`, '</span>')
}

function applyBold() {
  wrapSelection('<b>', '</b>')
}

function applyItalic() {
  wrapSelection('<i>', '</i>')
}

function applyStrike() {
  wrapSelection('<s>', '</s>')
}

// ── live preview (mirrors DiaryView's paragraph / trigger-warning parsing) ──

function splitParas(text) {
  return text.split('\n\n').map(p => p.trim()).filter(Boolean)
}

const previewBlocks = computed(() => {
  const body = form.body || ''
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

// ── song ──

const { songLooking, songError, hasSong, fetchSong, onSongUrlChange, clearSong, songPayload } = useSongForm(form)

// ── submit ──

async function handleSubmit() {
  submitting.value = true
  successMsg.value = ''
  errorMsg.value = ''

  const images = imageUrlInput.value ? [imageUrlInput.value.trim()] : []
  const highlights = highlightsInput.value
      .split('\n')
      .map(h => h.trim())
      .filter(Boolean)

  const payload = {
    session: form.session,
    title: form.title,
    date: form.date,
    location: form.location,
    body: form.body,
    images,
    highlights,
    ...songPayload()
  }

  if (props.editEntry) {
    const { error } = await supabase.from('quinlan_diary_entries').update(payload).eq('id', props.editEntry.id)

    submitting.value = false

    if (error) {
      errorMsg.value = error.message
      return
    }

    emit('saved', { id: props.editEntry.id, ...payload })
    return
  }

  const { data, error } = await supabase.from('quinlan_diary_entries').insert(payload).select().single()

  submitting.value = false

  if (error) {
    errorMsg.value = error.message
    return
  }

  successMsg.value = 'Chapter inscribed.'
  emit('saved', data)
  form.session = null
  form.title = ''
  form.date = ''
  form.location = ''
  form.body = ''
  clearSong()
  imageUrlInput.value = ''
  highlightsInput.value = ''
}
</script>

<template>
  <form class="q-form" @submit.prevent="handleSubmit">
    <header class="q-form-header">
      <svg viewBox="0 0 64 48" class="q-scarab" aria-hidden="true">
        <ellipse cx="32" cy="26" rx="18" ry="14" />
        <circle cx="32" cy="10" r="5" />
        <path d="M32 12 L32 40" stroke="#B17A2A" stroke-width="1.5" fill="none" opacity="0.6" />
        <path d="M20 14 Q10 10 6 18" stroke="#B17A2A" stroke-width="1.5" fill="none" />
        <path d="M44 14 Q54 10 58 18" stroke="#B17A2A" stroke-width="1.5" fill="none" />
      </svg>
      <h3>{{ editEntry ? 'Amend the chapter' : 'Inscribe a new chapter' }}</h3>
    </header>

    <div class="q-grid">
      <div class="q-field">
        <label>Session #</label>
        <input v-model.number="form.session" type="number" min="1" required />
      </div>
      <div class="q-field">
        <label>Date</label>
        <input v-model="form.date" type="date" required />
      </div>
    </div>

    <div class="q-field">
      <label>Title</label>
      <input v-model="form.title" required placeholder="The name of this chapter…" />
    </div>

    <div class="q-field">
      <label>Location</label>
      <input v-model="form.location" required placeholder="Where it happened…" />
    </div>

    <div class="q-field">
      <label>Image URL</label>
      <input v-model="imageUrlInput" placeholder="https://…" />
    </div>

    <div class="q-field">
      <label>Song (YouTube link)</label>
      <div class="q-song-row">
        <input
            v-model="form.song_url"
            placeholder="https://www.youtube.com/watch?v=…"
            @change="onSongUrlChange"
        />
        <button type="button" class="q-tool-btn q-song-btn" :disabled="!hasSong || songLooking" @click="fetchSong">
          {{ songLooking ? 'Looking up…' : 'Look up' }}
        </button>
        <button v-if="hasSong" type="button" class="q-tool-btn q-song-btn" @click="clearSong">Remove</button>
      </div>
      <p v-if="songError" class="q-error">{{ songError }}</p>
    </div>

    <div v-if="hasSong" class="q-song-details">
      <div class="q-song-cover">
        <img v-if="form.song_cover" :src="form.song_cover" alt="" />
        <span v-else aria-hidden="true">♪</span>
      </div>
      <div class="q-song-fields">
        <div class="q-grid">
          <div class="q-field">
            <label>Song title</label>
            <input v-model="form.song_title" placeholder="Track name" />
          </div>
          <div class="q-field">
            <label>Artist</label>
            <input v-model="form.song_artist" placeholder="Artist" />
          </div>
        </div>
        <div class="q-field">
          <label>Album cover URL</label>
          <input v-model="form.song_cover" placeholder="https://…" />
        </div>
      </div>
    </div>

    <div class="q-field q-body-field">
      <label>The chapter</label>

      <div class="q-toolbar">
        <div class="q-tool-group">
          <button
              v-for="f in fonts"
              :key="f.label"
              type="button"
              class="q-tool-btn q-font-btn"
              :style="{ fontFamily: f.family }"
              :title="`Apply ${f.label} to the selected text`"
              @mousedown.prevent="applyFont(f.family)"
          >{{ f.label }}</button>
        </div>

        <div class="q-tool-group">
          <button
              v-for="c in colors"
              :key="c.hex"
              type="button"
              class="q-tool-btn q-color-btn"
              :style="{ backgroundColor: c.hex }"
              :title="`Color selected text ${c.label}`"
              @mousedown.prevent="applyColor(c.hex)"
          />
          <input
              type="color"
              class="q-color-custom"
              title="Custom color"
              @mousedown.prevent
              @input="applyColor($event.target.value)"
          />
        </div>

        <div class="q-tool-group">
          <button type="button" class="q-tool-btn q-style-btn" title="Bold" @mousedown.prevent="applyBold">B</button>
          <button type="button" class="q-tool-btn q-style-btn q-italic" title="Cursive / italic" @mousedown.prevent="applyItalic">I</button>
          <button type="button" class="q-tool-btn q-style-btn q-strike" title="Strike through" @mousedown.prevent="applyStrike">S</button>
        </div>
      </div>

      <p class="q-toolbar-hint" :class="{ visible: !!toolbarHint }">{{ toolbarHint || 'Select text in the chapter, then press a style above.' }}</p>

      <textarea
          ref="bodyEl"
          v-model="form.body"
          rows="10"
          required
          placeholder="Begin the chapter…"
      ></textarea>

      <p class="q-hint">Separate paragraphs with a blank line. Wrap sensitive text in <code>[tw:label]…[/tw]</code> to hide it behind a warning.</p>
    </div>

    <div class="q-field" v-if="form.body">
      <label>Preview</label>
      <div class="q-preview">
        <template v-for="(block, i) in previewBlocks" :key="i">
          <div v-if="block.sensitive" class="q-preview-tw">
            <div class="q-preview-tw-label">⚠ trigger warning<span v-if="block.label"> — {{ block.label }}</span></div>
            <p v-for="(p, j) in block.paragraphs" :key="j" v-html="p"></p>
          </div>
          <p v-else class="q-preview-para" v-html="block.text"></p>
        </template>
      </div>
    </div>

    <div class="q-field">
      <label>Notable (one per line)</label>
      <textarea v-model="highlightsInput" rows="3" placeholder="Short notable lines, one per row…"></textarea>
    </div>

    <div class="q-actions">
      <button type="submit" class="q-save" :disabled="submitting">
        {{ submitting ? 'Inscribing…' : (editEntry ? 'Update chapter' : 'Save chapter') }}
      </button>
      <button type="button" class="q-cancel" @click="$emit('cancel')">Cancel</button>
    </div>

    <p v-if="successMsg" class="q-success">{{ successMsg }}</p>
    <p v-if="errorMsg" class="q-error">{{ errorMsg }}</p>
  </form>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=UnifrakturMaguntia&family=Spectral:ital,wght@0,400;0,500;0,600;1,400&family=Pirata+One&family=IM+Fell+English:ital@0;1&family=EB+Garamond:ital,wght@0,400;0,500;0,600;1,400&display=swap');

.q-form {
  display: flex;
  flex-direction: column;
  gap: 1.1rem;
  max-width: 100%;
  font-family: 'EB Garamond', serif;
  color: #D1CABD;
}

.q-form-header {
  display: flex;
  align-items: center;
  gap: 0.7rem;
  padding-bottom: 0.9rem;
  border-bottom: 1px solid rgba(177, 122, 42, 0.3);
}

.q-scarab {
  width: 30px;
  height: 22px;
  flex-shrink: 0;
  color: #454D3D;
  fill: currentColor;
}

.q-form-header h3 {
  font-family: 'Pirata One', serif;
  font-weight: 400;
  font-size: 1.6rem;
  margin: 0;
  color: #D1CABD;
  letter-spacing: 0.03em;
}

.q-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.9rem;
}

.q-field {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.q-field label {
  font-size: 0.72rem;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: #B17A2A;
}

.q-field input,
.q-field textarea {
  background: rgba(23, 12, 15, 0.6);
  border: 1px solid rgba(177, 122, 42, 0.3);
  border-radius: 3px;
  color: #D1CABD;
  font-family: 'IM Fell English', 'EB Garamond', serif;
  font-size: 1rem;
  padding: 0.55rem 0.7rem;
  outline: none;
  transition: border-color 0.15s, box-shadow 0.15s;
}

.q-field input::placeholder,
.q-field textarea::placeholder {
  color: #6b625a;
}

.q-field input:focus,
.q-field textarea:focus {
  border-color: #B17A2A;
  box-shadow: 0 0 0 3px rgba(177, 122, 42, 0.15);
}

.q-field input[type='date'] {
  color-scheme: dark;
}

.q-body-field textarea {
  line-height: 1.7;
  resize: vertical;
}

.q-toolbar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.9rem;
  padding: 0.6rem 0.7rem;
  background: rgba(69, 77, 61, 0.15);
  border: 1px solid rgba(177, 122, 42, 0.25);
  border-radius: 3px 3px 0 0;
  border-bottom: none;
}

.q-tool-group {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  padding-right: 0.9rem;
  border-right: 1px solid rgba(177, 122, 42, 0.2);
}

.q-tool-group:last-child {
  border-right: none;
  padding-right: 0;
}

.q-tool-btn {
  background: rgba(23, 12, 15, 0.6);
  border: 1px solid rgba(177, 122, 42, 0.3);
  border-radius: 3px;
  color: #D1CABD;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s, transform 0.1s;
}

.q-tool-btn:hover {
  border-color: #B17A2A;
  color: #B17A2A;
  transform: translateY(-1px);
}

.q-font-btn {
  font-size: 0.95rem;
  padding: 0.35rem 0.7rem;
}

.q-color-btn {
  width: 22px;
  height: 22px;
  padding: 0;
  border-radius: 50%;
}

.q-color-custom {
  width: 22px;
  height: 22px;
  padding: 0;
  border: 1px solid rgba(177, 122, 42, 0.3);
  border-radius: 50%;
  background: none;
  cursor: pointer;
  overflow: hidden;
}

.q-style-btn {
  width: 28px;
  height: 28px;
  font-family: 'EB Garamond', serif;
  font-weight: 600;
  font-size: 0.95rem;
}

.q-style-btn.q-italic {
  font-style: italic;
  font-weight: 400;
}

.q-style-btn.q-strike {
  text-decoration: line-through;
}

.q-toolbar-hint {
  margin: 0;
  padding: 0.35rem 0.1rem;
  font-size: 0.74rem;
  font-style: italic;
  color: #6b625a;
  min-height: 1.1em;
  transition: color 0.2s;
}

.q-toolbar-hint.visible {
  color: #B17A2A;
}

.q-body-field textarea {
  border-top-left-radius: 0;
  border-top-right-radius: 0;
  margin-top: -1.05rem;
}

.q-hint {
  font-size: 0.75rem;
  color: #8a7e72;
  margin: 0.1rem 0 0;
}

.q-hint code {
  background: rgba(177, 122, 42, 0.12);
  color: #D1CABD;
  padding: 1px 5px;
  border-radius: 3px;
}

.q-preview {
  background: #2F171E;
  background-image: radial-gradient(ellipse 70% 50% at 50% 0%, rgba(125, 0, 16, 0.12), transparent 60%);
  border: 1px solid rgba(177, 122, 42, 0.25);
  border-radius: 3px;
  padding: 1.2rem 1.3rem;
  max-height: 260px;
  overflow-y: auto;
}

.q-preview-para {
  font-family: 'IM Fell English', 'EB Garamond', serif;
  font-size: 1.02rem;
  line-height: 1.8;
  color: #D1CABD;
  margin: 0 0 0.9rem;
}

.q-preview-para:last-child {
  margin-bottom: 0;
}

.q-preview-tw {
  border: 1px dashed rgba(125, 0, 16, 0.5);
  background: rgba(125, 0, 16, 0.08);
  border-radius: 3px;
  padding: 0.7rem 0.9rem;
  margin-bottom: 0.9rem;
}

.q-preview-tw-label {
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: #e0556a;
  margin-bottom: 0.4rem;
}

.q-preview-tw p {
  font-family: 'IM Fell English', 'EB Garamond', serif;
  color: #D1CABD;
  margin: 0 0 0.5rem;
}

.q-preview-tw p:last-child {
  margin-bottom: 0;
}

.q-actions {
  display: flex;
  gap: 0.7rem;
  margin-top: 0.2rem;
}

.q-save,
.q-cancel {
  font-family: 'EB Garamond', serif;
  font-size: 0.88rem;
  letter-spacing: 0.05em;
  padding: 0.6rem 1.3rem;
  border-radius: 3px;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s, color 0.15s;
}

.q-save {
  background: linear-gradient(180deg, rgba(177, 122, 42, 0.25), rgba(177, 122, 42, 0.12));
  border: 1px solid #B17A2A;
  color: #f0e6d2;
}

.q-save:hover:not(:disabled) {
  background: rgba(177, 122, 42, 0.35);
}

.q-save:disabled {
  opacity: 0.6;
  cursor: default;
}

.q-cancel {
  background: none;
  border: 1px solid rgba(209, 202, 189, 0.25);
  color: #a69c8d;
}

.q-cancel:hover {
  border-color: #D1CABD;
  color: #D1CABD;
}

.q-song-row {
  display: flex;
  gap: 0.5rem;
}

.q-song-row input {
  flex: 1;
  min-width: 0;
}

.q-song-btn {
  flex-shrink: 0;
  font-family: 'EB Garamond', serif;
  font-size: 0.88rem;
  padding: 0 0.9rem;
}

.q-song-btn:disabled {
  opacity: 0.5;
  cursor: default;
  transform: none;
}

.q-song-details {
  display: flex;
  gap: 0.9rem;
  align-items: flex-start;
}

.q-song-cover {
  flex-shrink: 0;
  width: 96px;
  height: 96px;
  border-radius: 3px;
  overflow: hidden;
  border: 1px solid rgba(177, 122, 42, 0.3);
  background: rgba(23, 12, 15, 0.6);
  display: grid;
  place-items: center;
  color: #6b625a;
  font-size: 1.6rem;
}

.q-song-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.q-song-fields {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.9rem;
}

.q-success {
  color: #7fae8a;
  font-size: 0.85rem;
  margin: 0;
}

.q-error {
  color: #e0556a;
  font-size: 0.85rem;
  margin: 0;
}

@media (max-width: 540px) {
  .q-grid {
    grid-template-columns: 1fr;
  }

  .q-song-details {
    flex-direction: column;
  }
}
</style>
