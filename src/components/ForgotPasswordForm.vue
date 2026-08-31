<template>
  <form class="forgot-form" @submit.prevent="handleSubmit">
    <p class="hint">Enter your email and we'll send you a link to reset your password.</p>
    <input v-model="email" type="email" placeholder="Email" required />
    <button type="submit" :disabled="submitting || sent">
      {{ submitting ? 'Sending…' : 'Send reset link' }}
    </button>
    <p v-if="sent" class="info">Check your email for a password reset link.</p>
    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref } from 'vue'
import { useAuth } from '@/composables/useAuth'

const { resetPasswordForEmail } = useAuth()
const email = ref('')
const submitting = ref(false)
const sent = ref(false)
const errorMsg = ref('')

async function handleSubmit() {
  submitting.value = true
  errorMsg.value = ''
  try {
    await resetPasswordForEmail(email.value.trim())
    sent.value = true
  } catch (err) {
    errorMsg.value = err.message
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.forgot-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-width: 300px;
}
.hint {
  font-size: 0.85rem;
  color: #888;
  margin: 0 0 0.25rem;
}
.error {
  color: #e05252;
  font-size: 0.875rem;
}
.info {
  color: #90caf9;
  font-size: 0.875rem;
}
</style>
