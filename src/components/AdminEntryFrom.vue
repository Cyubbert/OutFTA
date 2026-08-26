<template>
  <form class="entry-form" @submit.prevent="handleSubmit">
    <h3>{{ editEntry ? 'Edit diary entry' : 'New diary entry' }}</h3>

    <label>Session #</label>
    <input v-model.number="form.session" type="number" min="1" required />

    <label>Title</label>
    <input v-model="form.title" required />

    <label>Date</label>
    <input v-model="form.date" type="date" required />

    <label>Location</label>
    <input v-model="form.location" required />

    <label>Mood</label>
    <input v-model="form.mood" />

    <label>Image URL</label>
    <input v-model="imageUrlInput" placeholder="https://…" />

    <label>Body</label>
    <textarea v-model="form.body" rows="10" required></textarea>
    <p class="hint">Wrap sensitive text (one or more paragraphs) in <code>[tw:label] ... [/tw]</code> (label optional) to hide it behind a trigger-warning button.</p>
    <p class="hint">HTML tags render directly, e.g. <code>&lt;br&gt;</code> for a line break or <code>&lt;b&gt;text&lt;/b&gt;</code> for bold.</p>

    <label>Highlights (one per line)</label>
    <textarea v-model="highlightsInput" rows="3"></textarea>

    <div class="form-actions">
      <button type="submit" :disabled="submitting">
        {{ submitting ? 'Saving…' : (editEntry ? 'Update entry' : 'Save entry') }}
      </button>
      <button v-if="editEntry" type="button" class="cancel-btn" @click="$emit('cancel')">Cancel</button>
    </div>

    <p v-if="successMsg" class="success">{{ successMsg }}</p>
    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { supabase } from '@/lib/supabase'

const props = defineProps({
  editEntry: { type: Object, default: null }
})
const emit = defineEmits(['saved', 'cancel'])

const form = reactive({
  session: props.editEntry?.session ?? null,
  title: props.editEntry?.title ?? '',
  date: props.editEntry?.date ?? '',
  location: props.editEntry?.location ?? '',
  mood: props.editEntry?.mood ?? '',
  body: props.editEntry?.body ?? ''
})

const imageUrlInput = ref(props.editEntry?.images?.[0] ?? '')
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
    highlights
  }

  if (props.editEntry) {
    const { error } = await supabase.from('diary_entries').update(payload).eq('id', props.editEntry.id)

    submitting.value = false

    if (error) {
      errorMsg.value = error.message
      return
    }

    emit('saved', { id: props.editEntry.id, ...payload })
    return
  }

  const { data, error } = await supabase.from('diary_entries').insert(payload).select().single()

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
  imageUrlInput.value = ''
  highlightsInput.value = ''
}
</script>

<style scoped>
.entry-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-width: 500px;
}
label {
  font-size: 0.85rem;
  margin-top: 0.5rem;
}
.form-actions {
  display: flex;
  gap: 0.5rem;
}
.cancel-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #888;
}
.success {
  color: #4caf50;
}
.error {
  color: #e05252;
}
.hint {
  font-size: 0.75rem;
  color: #888;
  margin: -0.25rem 0 0;
}
.hint code {
  background: rgba(255, 255, 255, 0.08);
  padding: 1px 4px;
  border-radius: 3px;
}
</style>