<template>
  <form class="signup-form" @submit.prevent="handleSubmit">
    <input v-model="email" type="email" placeholder="Email" required />
    <input v-model="password" type="password" placeholder="Password" minlength="6" required />
    <input v-model="confirmPassword" type="password" placeholder="Confirm password" required />
    <button type="submit" :disabled="submitting">
      {{ submitting ? 'Creating account…' : 'Sign up' }}
    </button>
    <p v-if="infoMsg" class="info">{{ infoMsg }}</p>
    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref } from 'vue'
import { useAuth } from '@/composables/useAuth'

const emit = defineEmits(['done'])

const { signUp } = useAuth()
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const submitting = ref(false)
const errorMsg = ref('')
const infoMsg = ref('')

async function handleSubmit() {
  errorMsg.value = ''
  infoMsg.value = ''

  if (password.value !== confirmPassword.value) {
    errorMsg.value = 'Passwords do not match.'
    return
  }

  submitting.value = true
  try {
    const data = await signUp(email.value, password.value)
    if (!data.session) {
      infoMsg.value = 'Account created. Check your email to confirm before signing in.'
    } else {
      emit('done')
    }
    email.value = ''
    password.value = ''
    confirmPassword.value = ''
  } catch (err) {
    errorMsg.value = err.message
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.signup-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-width: 300px;
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
