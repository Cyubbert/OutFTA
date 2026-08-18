<template>
  <form class="entry-form" @submit.prevent="handleSubmit">
    <h3>New diary entry</h3>

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

    <label>Highlights (one per line)</label>
    <textarea v-model="highlightsInput" rows="3"></textarea>

    <button type="submit" :disabled="submitting">
      {{ submitting ? 'Saving…' : 'Save entry' }}
    </button>

    <p v-if="successMsg" class="success">{{ successMsg }}</p>
    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { supabase } from '@/lib/supabase'

const form = reactive({
  session: null,
  title: '',
  date: '',
  location: '',
  mood: '',
  body: ''
})

const imageUrlInput = ref('')
const highlightsInput = ref('')
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

  const { error } = await supabase.from('diary_entries').insert({
    session: form.session,
    title: form.title,
    date: form.date,
    location: form.location,
    mood: form.mood,
    body: form.body,
    images,
    highlights
  })

  submitting.value = false

  if (error) {
    errorMsg.value = error.message
    return
  }

  successMsg.value = 'Entry saved.'
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
.success {
  color: #4caf50;
}
.error {
  color: #e05252;
}
</style>