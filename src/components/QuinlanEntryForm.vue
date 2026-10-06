<script setup>
import { ref, reactive, computed, nextTick } from 'vue'
import { supabase } from '@/lib/supabase'
import { useSongForm, songFields } from '@/composables/useSongForm'
import scarabImg from '@/assets/scarab.webp'
import { useAuth } from '@/composables/useAuth'
import { uploadEntryImage } from '@/lib/uploadEntryImage'

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
const { user } = useAuth()
const imageFileEl = ref(null)
const uploadingImage = ref(false)
const imageError = ref('')
const showImageLink = ref(false)

async function onImageFile(e) {
  const file = e.target.files?.[0]
  e.target.value = ''
  if (!file) return
  uploadingImage.value = true
  imageError.value = ''
  try {
    imageUrlInput.value = await uploadEntryImage(file, user.value.id)
  } catch (err) {
    imageError.value = err.message
  } finally {
    uploadingImage.value = false
  }
}
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
      <img :src="scarabImg" class="q-scarab" alt="" />
      <h3>{{ editEntry ? 'Amend the chapter' : 'Inscribe a new chapter' }}</h3>
    </header>

    <fieldset class="q-section">
      <legend>Chapter</legend>
      <div class="q-grid">
        <div class="q-field">
          <label for="qf-session">Session #</label>
          <input id="qf-session" v-model.number="form.session" type="number" min="1" required />
        </div>
        <div class="q-field">
          <label for="qf-date">Date</label>
          <input id="qf-date" v-model="form.date" type="date" required />
        </div>
      </div>

      <div class="q-field">
        <label for="qf-title">Title</label>
        <input id="qf-title" v-model="form.title" required placeholder="The name of this chapter…" />
      </div>

      <div class="q-field">
        <label for="qf-location">Location</label>
        <input id="qf-location" v-model="form.location" required placeholder="Where it happened…" />
      </div>

      <div class="q-field">
        <label>Image</label>
        <button
            type="button"
            class="q-image-drop"
            :class="{ filled: !!imageUrlInput }"
            :disabled="uploadingImage"
            @click="imageFileEl.click()"
        >
          <img v-if="imageUrlInput" :src="imageUrlInput" alt="" />
          <span v-else class="q-image-placeholder">{{ uploadingImage ? 'Uploading…' : '+ Upload a picture' }}</span>
          <span v-if="imageUrlInput" class="q-image-change">{{ uploadingImage ? 'Uploading…' : 'Change picture' }}</span>
        </button>
        <input ref="imageFileEl" type="file" accept="image/*" class="q-hidden-input" @change="onImageFile" />
        <div class="q-image-actions">
          <button v-if="imageUrlInput" type="button" class="q-link-btn" @click="imageUrlInput = ''">Remove picture</button>
          <button type="button" class="q-link-btn" @click="showImageLink = !showImageLink">{{ showImageLink ? 'Hide link' : 'Use a link instead' }}</button>
        </div>
        <input v-if="showImageLink" id="qf-image" v-model="imageUrlInput" aria-label="Image URL" placeholder="https://…" />
        <p v-if="imageError" class="q-error">{{ imageError }}</p>
      </div>
    </fieldset>

    <fieldset class="q-section">
      <legend>Song</legend>
      <div class="q-song-row">
        <input
            v-model="form.song_url"
            aria-label="YouTube link"
            placeholder="Paste a YouTube link…"
            @change="onSongUrlChange"
        />
        <button type="button" class="q-tool-btn q-song-btn" :disabled="!hasSong || songLooking" @click="fetchSong">
          {{ songLooking ? 'Looking up…' : 'Look up' }}
        </button>
        <button v-if="hasSong" type="button" class="q-tool-btn q-song-btn" @click="clearSong">Remove</button>
      </div>
      <p v-if="songError" class="q-error">{{ songError }}</p>

      <div v-if="hasSong" class="q-song-details">
        <div class="q-song-cover">
          <img v-if="form.song_cover" :src="form.song_cover" alt="" />
          <span v-else aria-hidden="true">♪</span>
        </div>
        <div class="q-song-fields">
          <div class="q-grid">
            <div class="q-field">
              <label for="qf-song-title">Song title</label>
              <input id="qf-song-title" v-model="form.song_title" placeholder="Track name" />
            </div>
            <div class="q-field">
              <label for="qf-song-artist">Artist</label>
              <input id="qf-song-artist" v-model="form.song_artist" placeholder="Artist" />
            </div>
          </div>
          <div class="q-field">
            <label for="qf-song-cover">Album cover URL</label>
            <input id="qf-song-cover" v-model="form.song_cover" placeholder="https://…" />
          </div>
        </div>
      </div>
    </fieldset>

    <fieldset class="q-section">
      <legend>Writing</legend>

      <div class="q-editor">
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

        <textarea
            ref="bodyEl"
            v-model="form.body"
            rows="10"
            required
            aria-label="Chapter text"
            placeholder="Begin the chapter…"
        ></textarea>
      </div>

      <div class="q-hints">
        <p class="q-hint" :class="{ 'q-hint-flash': !!toolbarHint }">{{ toolbarHint || 'Select text in the chapter, then press a style above.' }}</p>
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
    </fieldset>

    <fieldset class="q-section">
      <legend>Notable</legend>
      <textarea v-model="highlightsInput" rows="3" aria-label="Notable lines" placeholder="Short notable lines, one per row…"></textarea>
    </fieldset>

    <div class="q-actions">
      <button type="submit" class="q-save" :disabled="submitting || uploadingImage">
        {{ submitting ? 'Inscribing…' : (editEntry ? 'Update chapter' : 'Save chapter') }}
      </button>
      <button type="button" class="q-cancel" @click="$emit('cancel')">Cancel</button>
    </div>

    <p v-if="successMsg" class="q-success">{{ successMsg }}</p>
    <p v-if="errorMsg" class="q-error">{{ errorMsg }}</p>
  </form>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=UnifrakturMaguntia&family=Spectral:ital,wght@0,400;0,500;0,600;1,400&family=IM+Fell+English:ital@0;1&display=swap');

.q-form {
  display: flex;
  flex-direction: column;
  gap: 1.1rem;
  max-width: 100%;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  color: #E3E2DF;
}

.q-form-header {
  display: flex;
  align-items: center;
  gap: 0.7rem;
  padding-bottom: 0.9rem;
  border-bottom: 1px solid #2F2F2F;
}

.q-scarab {
  width: 34px;
  height: 34px;
  flex-shrink: 0;
  object-fit: contain;
}

.q-form-header h3 {
  font-family: 'UnifrakturCook', serif;
  font-weight: 700;
  font-size: 1.7rem;
  margin: 0;
  color: #E3E2DF;
  letter-spacing: 0.03em;
}

.q-section {
  margin: 0;
  padding: 1rem 1.1rem 1.15rem;
  border: 1px solid #2F2F2F;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.02);
  display: flex;
  flex-direction: column;
  gap: 0.9rem;
  min-width: 0;
}

.q-section > legend {
  padding: 0 0.45rem;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: #FFFFFF;
}

.q-section > textarea {
  background: #191919;
  border: 1px solid #2F2F2F;
  border-radius: 3px;
  color: #E3E2DF;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 1rem;
  padding: 0.55rem 0.7rem;
  outline: none;
  resize: vertical;
}

.q-section > textarea::placeholder { color: #5A5A58; }

.q-section > textarea:focus {
  border-color: #8A1424;
  box-shadow: 0 0 0 3px rgba(138, 20, 36, 0.25);
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
  color: #9B9A97;
}

.q-field input,
.q-field textarea {
  background: #191919;
  border: 1px solid #2F2F2F;
  border-radius: 3px;
  color: #E3E2DF;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 1rem;
  padding: 0.55rem 0.7rem;
  outline: none;
  transition: border-color 0.15s, box-shadow 0.15s;
}

.q-field input::placeholder,
.q-field textarea::placeholder {
  color: #5A5A58;
}

.q-field input:focus,
.q-field textarea:focus {
  border-color: #8A1424;
  box-shadow: 0 0 0 3px rgba(138, 20, 36, 0.25);
}

.q-field input[type='date'] {
  color-scheme: dark;
}

.q-editor {
  display: flex;
  flex-direction: column;
}

.q-editor textarea {
  width: 100%;
  box-sizing: border-box;
  background: #191919;
  border: 1px solid #2F2F2F;
  border-radius: 0 0 3px 3px;
  color: #E3E2DF;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 1rem;
  padding: 0.7rem 0.8rem;
  line-height: 1.7;
  resize: vertical;
  outline: none;
  transition: border-color 0.15s, box-shadow 0.15s;
}

.q-editor textarea::placeholder { color: #5A5A58; }

.q-editor textarea:focus {
  border-color: #8A1424;
  box-shadow: 0 0 0 3px rgba(138, 20, 36, 0.25);
}

.q-toolbar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.9rem;
  padding: 0.6rem 0.7rem;
  background: #1C1C1C;
  border: 1px solid #2F2F2F;
  border-radius: 3px 3px 0 0;
  border-bottom: none;
}

.q-tool-group {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  padding-right: 0.9rem;
  border-right: 1px solid #2F2F2F;
}

.q-tool-group:last-child {
  border-right: none;
  padding-right: 0;
}

.q-tool-btn {
  background: #191919;
  border: 1px solid #2F2F2F;
  border-radius: 3px;
  color: #E3E2DF;
  cursor: pointer;
  transition: border-color 0.15s, color 0.15s, transform 0.1s;
}

.q-tool-btn:hover {
  border-color: #8A1424;
  color: #FFFFFF;
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
  border: 1px solid #2F2F2F;
  border-radius: 50%;
  background: none;
  cursor: pointer;
  overflow: hidden;
}

.q-style-btn {
  width: 28px;
  height: 28px;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
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

.q-hints {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  margin-top: -0.35rem;
}

.q-hint {
  font-size: 0.78rem;
  line-height: 1.45;
  color: #9B9A97;
  margin: 0;
  transition: color 0.2s;
}

.q-hint-flash {
  color: #E06C7A;
}

.q-hint code {
  background: #2A2A2A;
  color: #E3E2DF;
  padding: 1px 5px;
  border-radius: 3px;
}

.q-preview {
  background: #191919;
  border: 1px solid #2F2F2F;
  border-radius: 3px;
  padding: 1.2rem 1.3rem;
  max-height: 260px;
  overflow-y: auto;
}

.q-preview-para {
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 1.02rem;
  line-height: 1.8;
  color: #E3E2DF;
  margin: 0 0 0.9rem;
}

.q-preview-para:last-child {
  margin-bottom: 0;
}

.q-preview-tw {
  border: 0;
  border-left: 3px solid #8A1424;
  background: #2A1A1C;
  border-radius: 3px;
  padding: 0.7rem 0.9rem;
  margin-bottom: 0.9rem;
}

.q-preview-tw-label {
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: #E06C7A;
  margin-bottom: 0.4rem;
}

.q-preview-tw p {
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  color: #E3E2DF;
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
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 0.88rem;
  letter-spacing: 0.05em;
  padding: 0.6rem 1.3rem;
  border-radius: 3px;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s, color 0.15s;
}

.q-save {
  background: #8A1424;
  border: 1px solid #8A1424;
  color: #FFFFFF;
}

.q-save:hover:not(:disabled) {
  background: #A11A2D;
  border-color: #A11A2D;
}

.q-save:disabled {
  opacity: 0.6;
  cursor: default;
}

.q-cancel {
  background: none;
  border: 1px solid #2F2F2F;
  color: #9B9A97;
}

.q-cancel:hover {
  border-color: #5A5A58;
  color: #FFFFFF;
}

.q-image-drop {
  position: relative;
  display: grid;
  place-items: center;
  width: 100%;
  height: 160px;
  padding: 0;
  border: 1px dashed #3A3A3A;
  border-radius: 4px;
  background: #191919;
  color: #9B9A97;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 0.9rem;
  cursor: pointer;
  overflow: hidden;
  transition: border-color 0.15s, color 0.15s;
}

.q-image-drop:hover:not(:disabled) {
  border-color: #8A1424;
  color: #FFFFFF;
}

.q-image-drop:disabled {
  cursor: default;
  opacity: 0.7;
}

.q-image-drop.filled {
  border-style: solid;
  border-color: #2F2F2F;
}

.q-image-drop img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.q-image-change {
  position: absolute;
  right: 0.6rem;
  bottom: 0.6rem;
  padding: 0.3rem 0.65rem;
  border-radius: 4px;
  background: rgba(25, 25, 25, 0.85);
  color: #E3E2DF;
  font-size: 0.8rem;
  opacity: 0;
  transition: opacity 0.15s;
}

.q-image-drop:hover .q-image-change,
.q-image-drop:focus-visible .q-image-change { opacity: 1; }

@media (hover: none) {
  .q-image-change { opacity: 1; }
}

.q-hidden-input { display: none; }

.q-image-actions {
  display: flex;
  gap: 1rem;
}

.q-link-btn {
  padding: 0;
  border: 0;
  background: none;
  color: #9B9A97;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 0.8rem;
  text-decoration: underline;
  text-underline-offset: 3px;
  cursor: pointer;
}

.q-link-btn:hover { color: #FFFFFF; }

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
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
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
  border: 1px solid #2F2F2F;
  background: #191919;
  display: grid;
  place-items: center;
  color: #5A5A58;
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
  color: #8FBF9A;
  font-size: 0.85rem;
  margin: 0;
}

.q-error {
  color: #E06C7A;
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
