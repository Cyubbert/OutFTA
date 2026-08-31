<template>
  <div class="container auth-container">
    <div v-if="loading" class="page-loading">Loading…</div>

    <div v-else-if="!user" class="auth-card">
      <h1>Admin sign in</h1>
      <LoginForm />
    </div>

    <div v-else-if="!isAdmin" class="auth-card">
      <h1>Not authorized</h1>
      <p>{{ user.email }} does not have admin access.</p>
      <button class="signout-button" @click="signOut">Sign out</button>
    </div>

    <div v-else class="admin-panel">
      <div class="admin-header">
        <p>Signed in as <strong>{{ user.email }}</strong></p>
        <button class="signout-button" @click="signOut">Sign out</button>
      </div>

      <AdminUsersPanel />
      <AdminCharacterTagsPanel />
    </div>
  </div>
</template>

<script setup>
import { useAuth } from '@/composables/useAuth'
import LoginForm from '@/components/LoginForm.vue'
import AdminUsersPanel from '@/components/AdminUsersPanel.vue'
import AdminCharacterTagsPanel from '@/components/AdminCharacterTagsPanel.vue'

const { user, isAdmin, loading, signOut } = useAuth()
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

.admin-panel {
  width: 100%;
  margin-top: 2rem;
}

.admin-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.signout-button {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #e0e0e0;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
  flex-shrink: 0;
}

.signout-button:hover {
  border-color: #90caf9;
  color: #90caf9;
}
</style>
