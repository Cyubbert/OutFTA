<template>
  <form class="s-form" @submit.prevent="handleSubmit">
    <header class="s-form-header">
      <span class="s-mark" aria-hidden="true">✦</span>
      <h3>{{ editSession ? 'Edit session recap' : 'New session recap' }}</h3>
    </header>

    <fieldset class="s-section">
      <legend>Cover</legend>
      <button
          type="button"
          class="s-image-drop"
          :class="{ filled: !!form.cover_image, dragging }"
          :disabled="uploadingCover"
          @click="coverFileEl.click()"
          @dragover.prevent="dragging = true"
          @dragleave.prevent="dragging = false"
          @drop.prevent="onCoverDrop"
      >
        <img v-if="form.cover_image" :src="form.cover_image" alt="" />
        <span v-else class="s-image-placeholder">
          <span class="s-image-plus">+</span>
          {{ uploadingCover ? 'Uploading…' : 'Upload a cover, or drop one here' }}
        </span>
        <span v-if="form.cover_image" class="s-image-change">{{ uploadingCover ? 'Uploading…' : 'Change cover' }}</span>
      </button>
      <input ref="coverFileEl" type="file" accept="image/*" class="s-hidden-input" @change="onCoverFile" />
      <div class="s-image-actions">
        <button v-if="form.cover_image" type="button" class="s-link-btn" @click="form.cover_image = ''">Remove cover</button>
        <button type="button" class="s-link-btn" @click="showCoverLink = !showCoverLink">{{ showCoverLink ? 'Hide link' : 'Use a link instead' }}</button>
      </div>
      <input v-if="showCoverLink" v-model="form.cover_image" class="s-input" aria-label="Cover image URL" placeholder="https://…" />
      <p v-if="coverError" class="s-error">{{ coverError }}</p>
    </fieldset>

    <fieldset class="s-section">
      <legend>Session</legend>
      <div class="s-grid">
        <div class="s-field">
          <label for="sf-number">Session #</label>
          <input id="sf-number" v-model.number="form.number" class="s-input" type="number" min="1" required />
        </div>
        <div class="s-field">
          <label for="sf-date">Date</label>
          <input id="sf-date" v-model="form.date" class="s-input" type="date" required />
        </div>
      </div>
      <div class="s-field">
        <label for="sf-title">Title</label>
        <input id="sf-title" v-model="form.title" class="s-input" required placeholder="What this session is called…" />
      </div>
    </fieldset>

    <fieldset class="s-section">
      <legend>Recap</legend>
      <textarea
          v-model="form.summary"
          class="s-input s-summary"
          rows="10"
          required
          aria-label="Summary"
          placeholder="What happened this session…"
      ></textarea>
    </fieldset>

    <fieldset class="s-section">
      <legend>Notable</legend>
      <textarea
          v-model="highlightsInput"
          class="s-input"
          rows="3"
          aria-label="Highlights"
          placeholder="Short highlights, one per line…"
      ></textarea>
    </fieldset>

    <fieldset class="s-section">
      <legend>Cast &amp; places</legend>
      <div class="s-field">
        <label for="sf-npcs">NPCs <span class="s-label-note">comma-separated slugs, e.g. aarely, virex</span></label>
        <input id="sf-npcs" v-model="npcsInput" class="s-input" placeholder="aarely, virex" />
      </div>
      <div class="s-field">
        <label for="sf-locations">Locations <span class="s-label-note">comma-separated</span></label>
        <input id="sf-locations" v-model="locationsInput" class="s-input" placeholder="Where the party went…" />
      </div>
    </fieldset>

    <div class="s-actions">
      <button type="submit" class="s-save" :disabled="submitting || uploadingCover">
        {{ submitting ? 'Saving…' : (editSession ? 'Update recap' : 'Save recap') }}
      </button>
      <button type="button" class="s-cancel" @click="$emit('cancel')">Cancel</button>
    </div>

    <p v-if="successMsg" class="s-success">{{ successMsg }}</p>
    <p v-if="errorMsg" class="s-error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'
import { uploadEntryImage } from '@/lib/uploadEntryImage'

const props = defineProps({
  editSession: { type: Object, default: null }
})
const emit = defineEmits(['saved', 'cancel'])

const form = reactive({
  number: props.editSession?.number ?? null,
  title: props.editSession?.title ?? '',
  date: props.editSession?.date ?? '',
  cover_image: props.editSession?.cover_image ?? '',
  summary: props.editSession?.summary ?? ''
})

const highlightsInput = ref((props.editSession?.highlights ?? []).join('\n'))
const npcsInput = ref((props.editSession?.npcs ?? []).join(', '))
const locationsInput = ref((props.editSession?.locations ?? []).join(', '))
const submitting = ref(false)
const successMsg = ref('')
const errorMsg = ref('')

// ── cover upload ──
// Sessions are admin-only, so covers go in the admin-only `pages/` folder
// (storage policy in add-page-hierarchy.sql) — no extra policy needed.
const { user } = useAuth()
const coverFileEl = ref(null)
const uploadingCover = ref(false)
const coverError = ref('')
const showCoverLink = ref(false)
const dragging = ref(false)

async function uploadCover(file) {
  if (!file) return
  uploadingCover.value = true
  coverError.value = ''
  try {
    form.cover_image = await uploadEntryImage(file, user.value.id, 'pages')
  } catch (err) {
    coverError.value = err.message
  } finally {
    uploadingCover.value = false
  }
}

function onCoverFile(e) {
  const file = e.target.files?.[0]
  e.target.value = ''
  uploadCover(file)
}

function onCoverDrop(e) {
  dragging.value = false
  if (uploadingCover.value) return
  uploadCover(e.dataTransfer?.files?.[0])
}

function splitList(value) {
  return value
      .split(',')
      .map(v => v.trim())
      .filter(Boolean)
}

async function handleSubmit() {
  submitting.value = true
  successMsg.value = ''
  errorMsg.value = ''

  const highlights = highlightsInput.value
      .split('\n')
      .map(h => h.trim())
      .filter(Boolean)

  const payload = {
    number: form.number,
    title: form.title,
    date: form.date,
    cover_image: form.cover_image?.trim() || null,
    summary: form.summary,
    highlights,
    npcs: splitList(npcsInput.value),
    locations: splitList(locationsInput.value)
  }

  if (props.editSession) {
    const { error } = await supabase.from('sessions').update(payload).eq('id', props.editSession.id)

    submitting.value = false

    if (error) {
      errorMsg.value = error.message
      return
    }

    emit('saved', { id: props.editSession.id, ...payload })
    return
  }

  const id = `s${String(form.number).padStart(2, '0')}`

  const { error } = await supabase.from('sessions').insert({ id, ...payload })

  submitting.value = false

  if (error) {
    errorMsg.value = error.message
    return
  }

  successMsg.value = 'Session recap saved.'
  emit('saved', { id, ...payload })
  form.number = null
  form.title = ''
  form.date = ''
  form.cover_image = ''
  form.summary = ''
  highlightsInput.value = ''
  npcsInput.value = ''
  locationsInput.value = ''
}
</script>

<style scoped>
.s-form {
  display: flex;
  flex-direction: column;
  gap: 1.1rem;
  max-width: 100%;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  color: #E3E2DF;
}

.s-form-header {
  display: flex;
  align-items: center;
  gap: 0.7rem;
  padding-bottom: 0.9rem;
  border-bottom: 1px solid #2F2F2F;
}

.s-mark {
  color: #A11A2D;
  font-size: 1.2rem;
}

.s-form-header h3 {
  margin: 0;
  font-family: 'Cormorant Garamond', 'EB Garamond', Georgia, serif;
  font-weight: 500;
  font-style: italic;
  font-size: 1.7rem;
  color: #FFFFFF;
  letter-spacing: 0.01em;
}

.s-section {
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

.s-section > legend {
  padding: 0 0.45rem;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: #FFFFFF;
}

.s-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.9rem;
}

.s-field {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  min-width: 0;
}

.s-field label {
  font-size: 0.72rem;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: #9B9A97;
}

.s-label-note {
  margin-left: 0.3rem;
  text-transform: none;
  letter-spacing: 0;
  font-style: italic;
  color: #6E6D6A;
}

.s-input {
  width: 100%;
  box-sizing: border-box;
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

textarea.s-input {
  line-height: 1.6;
  resize: vertical;
}

.s-summary {
  font-family: 'Spectral', 'EB Garamond', Georgia, serif;
  font-size: 1.02rem;
  line-height: 1.7;
  padding: 0.7rem 0.8rem;
}

.s-input::placeholder { color: #5A5A58; }

.s-input:focus {
  border-color: #8A1424;
  box-shadow: 0 0 0 3px rgba(138, 20, 36, 0.25);
}

.s-input[type='date'] { color-scheme: dark; }

/* ── cover drop zone ── */

.s-image-drop {
  position: relative;
  display: grid;
  place-items: center;
  width: 100%;
  aspect-ratio: 16 / 9;
  padding: 0;
  border: 1px dashed #3A3A3A;
  border-radius: 4px;
  background: #191919;
  color: #9B9A97;
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 0.9rem;
  cursor: pointer;
  overflow: hidden;
  transition: border-color 0.15s, color 0.15s, background 0.15s;
}

.s-image-drop:hover:not(:disabled),
.s-image-drop.dragging {
  border-color: #8A1424;
  color: #FFFFFF;
  background: #1D1617;
}

.s-image-drop:disabled {
  cursor: default;
  opacity: 0.7;
}

.s-image-drop.filled {
  border-style: solid;
  border-color: #2F2F2F;
}

.s-image-drop img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.s-image-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.35rem;
}

.s-image-plus {
  font-size: 1.8rem;
  line-height: 1;
  font-weight: 300;
}

.s-image-change {
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

.s-image-drop:hover .s-image-change,
.s-image-drop:focus-visible .s-image-change,
.s-image-drop:disabled .s-image-change { opacity: 1; }

@media (hover: none) {
  .s-image-change { opacity: 1; }
}

.s-hidden-input { display: none; }

.s-image-actions {
  display: flex;
  gap: 1rem;
  margin-top: -0.4rem;
}

.s-link-btn {
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

.s-link-btn:hover { color: #FFFFFF; }

/* ── actions ── */

.s-actions {
  display: flex;
  gap: 0.7rem;
  margin-top: 0.2rem;
}

.s-save,
.s-cancel {
  font-family: 'Inter', ui-sans-serif, system-ui, sans-serif;
  font-size: 0.88rem;
  letter-spacing: 0.05em;
  padding: 0.6rem 1.3rem;
  border-radius: 3px;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s, color 0.15s;
}

.s-save {
  background: #8A1424;
  border: 1px solid #8A1424;
  color: #FFFFFF;
}

.s-save:hover:not(:disabled) {
  background: #A11A2D;
  border-color: #A11A2D;
}

.s-save:disabled {
  opacity: 0.6;
  cursor: default;
}

.s-cancel {
  background: none;
  border: 1px solid #2F2F2F;
  color: #9B9A97;
}

.s-cancel:hover {
  border-color: #5A5A58;
  color: #FFFFFF;
}

.s-success {
  color: #8FBF9A;
  font-size: 0.85rem;
  margin: 0;
}

.s-error {
  color: #E06C7A;
  font-size: 0.85rem;
  margin: 0;
}

@media (max-width: 540px) {
  .s-grid { grid-template-columns: 1fr; }
}
</style>
