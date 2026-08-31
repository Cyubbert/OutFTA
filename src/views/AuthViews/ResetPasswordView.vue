<template>
  <div class="container auth-container">
    <div v-if="loading" class="page-loading">Checking your link…</div>

    <div v-else-if="!user" class="auth-card">
      <h1>Reset password</h1>
      <p class="hint">This link is invalid or has expired.</p>
      <router-link to="/login" class="back-link">Back to sign in</router-link>
    </div>

    <div v-else-if="done" class="auth-card">
      <h1>Password updated</h1>
      <p class="hint">Your password has been changed.</p>
      <router-link to="/" class="back-link">Continue</router-link>
    </div>

    <div v-else class="auth-card">
      <h1>Set a new password</h1>
      <form class="reset-form" @submit.prevent="handleSubmit">
        <input v-model="password" type="password" placeholder="New password" minlength="6" required />
        <input v-model="confirmPassword" type="password" placeholder="Confirm password" required />
        <button type="submit" :disabled="submitting">
          {{ submitting ? 'Saving…' : 'Update password' }}
        </button>
        <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useAuth } from '@/composables/useAuth'

const { user, loading, updatePassword } = useAuth()

const password = ref('')
const confirmPassword = ref('')
const submitting = ref(false)
const errorMsg = ref('')
const done = ref(false)

async function handleSubmit() {
  errorMsg.value = ''

  if (password.value !== confirmPassword.value) {
    errorMsg.value = 'Passwords do not match.'
    return
  }

  submitting.value = true
  try {
    await updatePassword(password.value)
    done.value = true
  } catch (err) {
    errorMsg.value = err.message
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.auth-container {
  display: flex;
  justify-content: center;
}

.auth-card {
  width: 100%;
  max-width: 340px;
  margin-top: 2rem;
}

.auth-card h1 {
  font-size: 1.5rem;
  margin-bottom: 1.25rem;
}

.hint {
  font-size: 0.875rem;
  color: #888;
  margin-bottom: 1rem;
}

.back-link {
  color: #90caf9;
  text-decoration: none;
  font-size: 0.9rem;
}

.back-link:hover {
  text-decoration: underline;
}

.reset-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-width: 300px;
}

.error {
  color: #e05252;
  font-size: 0.875rem;
}

.page-loading {
  color: #888;
  text-align: center;
  margin-top: 2rem;
}
</style>
