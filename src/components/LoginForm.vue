<template>
  <form class="login-form" @submit.prevent="handleSubmit">
    <input v-model="email" type="email" placeholder="Email" required />
    <input v-model="password" type="password" placeholder="Password" required />
    <button type="submit" :disabled="submitting">
      {{ submitting ? 'Signing in…' : 'Sign in' }}
    </button>
    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref } from 'vue'
import { useAuth } from '@/composables/useAuth'

const emit = defineEmits(['done'])

const { signIn } = useAuth()
const email = ref('')
const password = ref('')
const submitting = ref(false)
const errorMsg = ref('')

async function handleSubmit() {
  submitting.value = true
  errorMsg.value = ''
  try {
    await signIn(email.value, password.value)
    email.value = ''
    password.value = ''
    emit('done')
  } catch (err) {
    errorMsg.value = err.message
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.login-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-width: 300px;
}
.error {
  color: #e05252;
  font-size: 0.875rem;
}
</style>