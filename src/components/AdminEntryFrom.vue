<template>
  <form class="entry-form" @submit.prevent="handleSubmit">
    <header class="form-header">
      <span class="form-mark" aria-hidden="true">✦</span>
      <h3>{{ editEntry ? 'Edit journal entry' : 'New journal entry' }}</h3>
      <div class="form-rule" />
    </header>

    <div class="grid">
      <div class="field">
        <label for="mf-session">Session #</label>
        <input id="mf-session" v-model.number="form.session" type="number" min="1" required />
      </div>
      <div class="field">
        <label for="mf-date">Date</label>
        <input id="mf-date" v-model="form.date" type="date" required />
      </div>
    </div>

    <div class="field">
      <label for="mf-title">Title</label>
      <input id="mf-title" v-model="form.title" required placeholder="What this entry is called…" />
    </div>

    <div class="grid">
      <div class="field">
        <label for="mf-location">Location</label>
        <input id="mf-location" v-model="form.location" required placeholder="Where it happened…" />
      </div>
      <div class="field">
        <label for="mf-mood">Mood</label>
        <input id="mf-mood" v-model="form.mood" placeholder="Optional" />
      </div>
    </div>

    <div class="field">
      <label>Image</label>
      <button
          type="button"
          class="image-drop"
          :class="{ filled: !!imageUrlInput }"
          :disabled="uploadingImage"
          @click="imageFileEl.click()"
      >
        <img v-if="imageUrlInput" :src="imageUrlInput" alt="" />
        <span v-else class="image-placeholder">{{ uploadingImage ? 'Uploading…' : '+ Upload a picture' }}</span>
        <span v-if="imageUrlInput" class="image-change">{{ uploadingImage ? 'Uploading…' : 'Change picture' }}</span>
      </button>
      <input ref="imageFileEl" type="file" accept="image/*" class="hidden-input" @change="onImageFile" />
      <div class="image-actions">
        <button v-if="imageUrlInput" type="button" class="link-btn" @click="imageUrlInput = ''">Remove picture</button>
        <button type="button" class="link-btn" @click="showImageLink = !showImageLink">{{ showImageLink ? 'Hide link' : 'Use a link instead' }}</button>
      </div>
      <input v-if="showImageLink" id="mf-image" v-model="imageUrlInput" aria-label="Image URL" placeholder="https://…" />
      <p v-if="imageError" class="error">{{ imageError }}</p>
    </div>

    <fieldset class="section">
      <legend>Song</legend>
      <div class="song-row">
        <input
            v-model="form.song_url"
            aria-label="YouTube link"
            placeholder="Paste a YouTube link…"
            @change="onSongUrlChange"
        />
        <button type="button" class="btn-ghost" :disabled="!hasSong || songLooking" @click="fetchSong">
          {{ songLooking ? 'Looking up…' : 'Look up' }}
        </button>
        <button v-if="hasSong" type="button" class="btn-ghost" @click="clearSong">Remove</button>
      </div>
      <p v-if="songError" class="error">{{ songError }}</p>

      <div v-if="hasSong" class="song-details">
        <div class="song-cover">
          <img v-if="form.song_cover" :src="form.song_cover" alt="" />
          <span v-else aria-hidden="true">♪</span>
        </div>
        <div class="song-fields">
          <div class="grid">
            <div class="field">
              <label for="mf-song-title">Song title</label>
              <input id="mf-song-title" v-model="form.song_title" />
            </div>
            <div class="field">
              <label for="mf-song-artist">Artist</label>
              <input id="mf-song-artist" v-model="form.song_artist" />
            </div>
          </div>
          <div class="field">
            <label for="mf-song-cover">Album cover URL</label>
            <input id="mf-song-cover" v-model="form.song_cover" placeholder="https://…" />
          </div>
        </div>
      </div>
    </fieldset>

    <div class="field">
      <label for="mf-body">Entry</label>
      <textarea id="mf-body" v-model="form.body" rows="10" required placeholder="Dear…"></textarea>
      <p class="hint">Separate paragraphs with a blank line. Wrap sensitive text in <code>[tw:label] … [/tw]</code> to hide it behind a warning. HTML works too, e.g. <code>&lt;b&gt;bold&lt;/b&gt;</code>.</p>
    </div>

    <div class="field">
      <label for="mf-highlights">Highlights <span class="label-note">one per line</span></label>
      <textarea id="mf-highlights" v-model="highlightsInput" rows="3"></textarea>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn-primary" :disabled="submitting || uploadingImage">
        {{ submitting ? 'Saving…' : (editEntry ? 'Update entry' : 'Save entry') }}
      </button>
      <button type="button" class="btn-ghost" @click="$emit('cancel')">Cancel</button>
    </div>

    <p v-if="successMsg" class="success">{{ successMsg }}</p>
    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { supabase } from '@/lib/supabase'
import { useSongForm, songFields } from '@/composables/useSongForm'
import { useAuth } from '@/composables/useAuth'
import { uploadEntryImage } from '@/lib/uploadEntryImage'

const props = defineProps({
  editEntry: { type: Object, default: null },
  table: { type: String, default: 'diary_entries' }
})
const emit = defineEmits(['saved', 'cancel'])

const form = reactive({
  session: props.editEntry?.session ?? null,
  title: props.editEntry?.title ?? '',
  date: props.editEntry?.date ?? '',
  location: props.editEntry?.location ?? '',
  mood: props.editEntry?.mood ?? '',
  body: props.editEntry?.body ?? '',
  ...songFields(props.editEntry)
})

const { songLooking, songError, hasSong, fetchSong, onSongUrlChange, clearSong, songPayload } = useSongForm(form)

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

async function handleSubmit() {
  submitting.value = true
  successMsg.value = ''
  errorMsg.value = ''

  const images = imageUrlInput.value
      ? [imageUrlInput.value.trim()]
      : []

  const highlights = highlightsInput.value
      .split('\n')
      .map(h => h.trim())
      .filter(Boolean)

  const payload = {
    session: form.session,
    title: form.title,
    date: form.date,
    location: form.location,
    mood: form.mood,
    body: form.body,
    images,
    highlights,
    ...songPayload()
  }

  if (props.editEntry) {
    const { error } = await supabase.from(props.table).update(payload).eq('id', props.editEntry.id)

    submitting.value = false

    if (error) {
      errorMsg.value = error.message
      return
    }

    emit('saved', { id: props.editEntry.id, ...payload })
    return
  }

  const { data, error } = await supabase.from(props.table).insert(payload).select().single()

  submitting.value = false

  if (error) {
    errorMsg.value = error.message
    return
  }

  successMsg.value = 'Entry saved.'
  emit('saved', data)
  form.session = null
  form.title = ''
  form.date = ''
  form.location = ''
  form.mood = ''
  form.body = ''
  clearSong()
  imageUrlInput.value = ''
  highlightsInput.value = ''
}
</script>

<style scoped>
.entry-form {
  --ink: #1a1008;
  --faded: #9a8878;
  --red: #c0392b;
  --paper: #f5f0e8;
  --paper-deep: #f0e8d8;
  --line: rgba(154, 136, 120, 0.4);

  display: flex;
  flex-direction: column;
  gap: 1.1rem;
  font-family: 'EB Garamond', Georgia, serif;
  color: var(--ink);
}

.form-header {
  text-align: center;
  margin-bottom: 0.25rem;
}

.form-mark {
  color: var(--red);
  font-size: 1rem;
}

.form-header h3 {
  margin: 0.2rem 0 0.8rem;
  font-family: 'Cormorant Garamond', 'EB Garamond', serif;
  font-weight: 400;
  font-style: italic;
  font-size: 1.9rem;
  color: var(--ink);
}

.form-rule {
  height: 1px;
  background: linear-gradient(to right, transparent, rgba(192, 57, 43, 0.35), transparent);
}

.grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
  min-width: 0;
}

label,
legend {
  font-size: 0.72rem;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: var(--faded);
}

.label-note {
  text-transform: none;
  letter-spacing: 0;
  font-style: italic;
}

input,
textarea {
  width: 100%;
  box-sizing: border-box;
  padding: 0.55rem 0.7rem;
  border: 1px solid var(--line);
  border-radius: 3px;
  background: #fbf8f2;
  color: var(--ink);
  font-family: 'EB Garamond', Georgia, serif;
  font-size: 1.02rem;
  outline: none;
  transition: border-color 0.15s, box-shadow 0.15s;
}

input::placeholder,
textarea::placeholder {
  color: #b8a998;
  font-style: italic;
}

input:focus,
textarea:focus {
  border-color: var(--red);
  box-shadow: 0 0 0 3px rgba(192, 57, 43, 0.12);
}

input[type='date'] {
  color-scheme: light;
}

textarea {
  line-height: 1.65;
  resize: vertical;
}

.image-drop {
  position: relative;
  display: grid;
  place-items: center;
  width: 100%;
  height: 160px;
  padding: 0;
  border: 1px dashed var(--line);
  border-radius: 4px;
  background: #fbf8f2;
  color: var(--faded);
  font-family: 'EB Garamond', Georgia, serif;
  font-size: 1rem;
  font-style: italic;
  cursor: pointer;
  overflow: hidden;
  transition: border-color 0.15s, color 0.15s;
}

.image-drop:hover:not(:disabled) {
  border-color: var(--red);
  color: var(--red);
}

.image-drop:disabled {
  cursor: default;
  opacity: 0.7;
}

.image-drop.filled {
  border-style: solid;
}

.image-drop img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.image-change {
  position: absolute;
  right: 0.6rem;
  bottom: 0.6rem;
  padding: 0.25rem 0.65rem;
  border-radius: 3px;
  background: rgba(245, 240, 232, 0.92);
  color: var(--ink);
  font-style: normal;
  font-size: 0.9rem;
  opacity: 0;
  transition: opacity 0.15s;
}

.image-drop:hover .image-change,
.image-drop:focus-visible .image-change { opacity: 1; }

@media (hover: none) {
  .image-change { opacity: 1; }
}

.hidden-input { display: none; }

.image-actions {
  display: flex;
  gap: 1rem;
}

.link-btn {
  padding: 0;
  border: 0;
  background: none;
  color: var(--faded);
  font-family: 'EB Garamond', Georgia, serif;
  font-size: 0.92rem;
  text-decoration: underline;
  text-underline-offset: 3px;
  cursor: pointer;
}

.link-btn:hover { color: var(--red); }

.section {
  margin: 0;
  padding: 0.9rem 1rem 1rem;
  border: 1px solid var(--line);
  border-radius: 4px;
  background: var(--paper-deep);
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.section legend {
  padding: 0 0.4rem;
}

.song-row {
  display: flex;
  gap: 0.5rem;
}

.song-row input {
  flex: 1;
  min-width: 0;
}

.song-details {
  display: flex;
  gap: 0.9rem;
  align-items: flex-start;
}

.song-cover {
  flex-shrink: 0;
  width: 92px;
  height: 92px;
  border-radius: 3px;
  overflow: hidden;
  border: 1px solid var(--line);
  background: #e6dccb;
  display: grid;
  place-items: center;
  color: var(--faded);
  font-size: 1.5rem;
}

.song-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.song-fields {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.hint {
  margin: 0.2rem 0 0;
  font-size: 0.85rem;
  font-style: italic;
  color: var(--faded);
}

.hint code {
  font-style: normal;
  font-size: 0.8rem;
  background: rgba(192, 57, 43, 0.07);
  color: #8a2a1f;
  padding: 1px 5px;
  border-radius: 3px;
}

.form-actions {
  display: flex;
  gap: 0.6rem;
  margin-top: 0.4rem;
}

.btn-primary,
.btn-ghost {
  font-family: 'EB Garamond', Georgia, serif;
  font-size: 0.98rem;
  letter-spacing: 0.03em;
  padding: 0.5rem 1.2rem;
  border-radius: 3px;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s, color 0.15s;
}

.btn-primary {
  background: var(--red);
  border: 1px solid var(--red);
  color: var(--paper);
}

.btn-primary:hover:not(:disabled) {
  background: #a5301f;
}

.btn-ghost {
  flex-shrink: 0;
  background: transparent;
  border: 1px solid var(--line);
  color: var(--ink);
}

.btn-ghost:hover:not(:disabled) {
  border-color: var(--red);
  color: var(--red);
}

.btn-primary:disabled,
.btn-ghost:disabled {
  opacity: 0.5;
  cursor: default;
}

.success,
.error {
  margin: 0;
  font-size: 0.95rem;
}

.success { color: #4f7a52; }
.error { color: var(--red); }

@media (max-width: 540px) {
  .grid { grid-template-columns: 1fr; }
  .song-details { flex-direction: column; }
}
</style>
