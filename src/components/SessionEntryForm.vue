<template>
  <form class="entry-form" @submit.prevent="handleSubmit">
    <h3>New session recap</h3>

    <label>Session #</label>
    <input v-model.number="form.number" type="number" min="1" required />

    <label>Title</label>
    <input v-model="form.title" required />

    <label>Date</label>
    <input v-model="form.date" type="date" required />

    <label>Cover image URL</label>
    <input v-model="form.cover_image" placeholder="https://…" />

    <label>Summary</label>
    <textarea v-model="form.summary" rows="10" required></textarea>

    <label>Highlights (one per line)</label>
    <textarea v-model="highlightsInput" rows="3"></textarea>

    <label>NPCs (comma-separated slugs, e.g. aarely, virex)</label>
    <input v-model="npcsInput" />

    <label>Locations (comma-separated)</label>
    <input v-model="locationsInput" />

    <button type="submit" :disabled="submitting">
      {{ submitting ? 'Saving…' : 'Save recap' }}
    </button>

    <p v-if="successMsg" class="success">{{ successMsg }}</p>
    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { supabase } from '@/lib/supabase'

const form = reactive({
  number: null,
  title: '',
  date: '',
  cover_image: '',
  summary: ''
})

const highlightsInput = ref('')
const npcsInput = ref('')
const locationsInput = ref('')
const submitting = ref(false)
const successMsg = ref('')
const errorMsg = ref('')

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

  const id = `s${String(form.number).padStart(2, '0')}`

  const { error } = await supabase.from('sessions').insert({
    id,
    number: form.number,
    title: form.title,
    date: form.date,
    cover_image: form.cover_image || null,
    summary: form.summary,
    highlights,
    npcs: splitList(npcsInput.value),
    locations: splitList(locationsInput.value)
  })

  submitting.value = false

  if (error) {
    errorMsg.value = error.message
    return
  }

  successMsg.value = 'Session recap saved.'
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
