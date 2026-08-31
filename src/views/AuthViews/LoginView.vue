<template>
  <div class="container auth-container">
    <div v-if="loading" class="page-loading">Loading…</div>

    <div v-else-if="user" class="auth-card">
      <h1>You're signed in</h1>
      <p>Signed in as <strong>{{ user.email }}</strong>.</p>
      <button class="signout-button" @click="signOut">Sign out</button>
    </div>

    <div v-else class="auth-card">
      <h1>{{ modeTitle }}</h1>

      <LoginForm v-if="mode === 'signin'" />
      <SignupForm v-else-if="mode === 'signup'" />
      <ForgotPasswordForm v-else />

      <p v-if="mode === 'signin'" class="forgot-link">
        <a href="#" @click.prevent="mode = 'forgot'">Forgot password?</a>
      </p>

      <p class="switch-mode">
        <template v-if="mode === 'signin'">
          Don't have an account?
          <a href="#" @click.prevent="mode = 'signup'">Sign up</a>
        </template>
        <template v-else>
          Already have an account?
          <a href="#" @click.prevent="mode = 'signin'">Sign in</a>
        </template>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useAuth } from '@/composables/useAuth'
import LoginForm from '@/components/LoginForm.vue'
import SignupForm from '@/components/SignupForm.vue'
import ForgotPasswordForm from '@/components/ForgotPasswordForm.vue'

const { user, loading, signOut } = useAuth()
const mode = ref('signin')

const modeTitle = computed(() => {
  if (mode.value === 'signup') return 'Create an account'
  if (mode.value === 'forgot') return 'Reset password'
  return 'Sign in'
})
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

.switch-mode {
  margin-top: 1rem;
  font-size: 0.875rem;
  color: #888;
}

.switch-mode a {
  color: #90caf9;
  text-decoration: none;
}

.switch-mode a:hover {
  text-decoration: underline;
}

.forgot-link {
  margin-top: 0.6rem;
  font-size: 0.82rem;
}

.forgot-link a {
  color: #90caf9;
  text-decoration: none;
}

.forgot-link a:hover {
  text-decoration: underline;
}

.signout-button {
  margin-top: 1rem;
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #e0e0e0;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}

.signout-button:hover {
  border-color: #90caf9;
  color: #90caf9;
}
</style>
