<template>
  <form class="entry-form" @submit.prevent="handleSubmit">
    <h3>{{ editPost ? 'Edit entry' : 'Leave word' }}</h3>

    <label>Text</label>
    <textarea v-model="form.body" rows="6" placeholder="What won't be signed…" required></textarea>

    <div class="form-actions">
      <button type="submit" :disabled="submitting">
        {{ submitting ? 'Saving…' : (editPost ? 'Update' : 'Leave it') }}
      </button>
      <button type="button" class="cancel-btn" @click="$emit('cancel')">Cancel</button>
    </div>

    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'

const props = defineProps({
  editPost: { type: Object, default: null }
})
const emit = defineEmits(['saved', 'cancel'])

const { user } = useAuth()

const form = reactive({
  body: props.editPost?.body ?? ''
})

const submitting = ref(false)
const errorMsg = ref('')

async function handleSubmit() {
  submitting.value = true
  errorMsg.value = ''

  const payload = { body: form.body.trim() }

  if (props.editPost) {
    const { data, error } = await supabase
        .from('mory_quinau_posts')
        .update({ ...payload, edited_at: new Date().toISOString() })
        .eq('id', props.editPost.id)
        .select()
        .single()

    submitting.value = false

    if (error) {
      errorMsg.value = error.message
      return
    }

    emit('saved', data)
    return
  }

  const { data, error } = await supabase
      .from('mory_quinau_posts')
      .insert({ ...payload, user_id: user.value.id })
      .select()
      .single()

  submitting.value = false

  if (error) {
    errorMsg.value = error.message
    return
  }

  emit('saved', data)
}
</script>

<style scoped>
.entry-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-width: 500px;
  font-family: 'EB Garamond', serif;
}
h3 {
  color: #e8ded2;
  font-family: 'Cormorant Garamond', serif;
  font-style: italic;
  font-weight: 400;
  font-size: 1.4rem;
  margin: 0;
}
label {
  font-size: 0.82rem;
  margin-top: 0.5rem;
  color: #8a7a6d;
  letter-spacing: 0.04em;
}
textarea {
  background: #0b0807;
  border: 1px solid rgba(139, 26, 26, 0.3);
  border-radius: 6px;
  color: #cfc3b8;
  padding: 0.6rem 0.75rem;
  font-size: 0.95rem;
  font-family: inherit;
  outline: none;
  resize: vertical;
}
textarea:focus {
  border-color: #3f7d4f;
}
.form-actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.5rem;
}
.cancel-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: #8a7a6d;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}
.cancel-btn:hover {
  border-color: #3f7d4f;
  color: #4c9a5f;
}
button[type="submit"] {
  background: transparent;
  border: 1px solid rgba(139, 26, 26, 0.45);
  color: #c0392b;
  padding: 0.55rem 1.2rem;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}
button[type="submit"]:hover:not(:disabled) {
  background: rgba(139, 26, 26, 0.1);
  color: #e05252;
}
button[type="submit"]:disabled {
  opacity: 0.6;
  cursor: default;
}
.error {
  color: #e05252;
  font-size: 0.85rem;
}
</style>
