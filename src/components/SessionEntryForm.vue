<template>
  <form class="entry-form" @submit.prevent="handleSubmit">
    <h3>{{ editSession ? 'Edit session recap' : 'New session recap' }}</h3>

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

    <div class="form-actions">
      <button type="submit" :disabled="submitting">
        {{ submitting ? 'Saving…' : (editSession ? 'Update recap' : 'Save recap') }}
      </button>
      <button v-if="editSession" type="button" class="cancel-btn" @click="$emit('cancel')">Cancel</button>
    </div>

    <p v-if="successMsg" class="success">{{ successMsg }}</p>
    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { supabase } from '@/lib/supabase'

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
    cover_image: form.cover_image || null,
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
</style>
