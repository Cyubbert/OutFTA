<template>
  <article class="page sans container">
    <h1 class="page-title">Find People</h1>

    <div class="search-row">
      <input
          v-model="query"
          type="text"
          placeholder="Search by username…"
          class="search-input"
          @keyup.enter="search"
      />
      <button class="search-btn" :disabled="searching" @click="search">
        {{ searching ? 'Searching…' : 'Search' }}
      </button>
    </div>

    <p v-if="searching" class="page-loading">Loading…</p>
    <p v-else-if="searched && !results.length" class="page-loading">No profiles found.</p>

    <div v-else-if="results.length" class="cards-container people-grid">
      <router-link
          v-for="p in results"
          :key="p.id"
          :to="`/profile/${p.username}`"
          class="card person-card"
      >
        <div class="person-avatar-wrap">
          <img v-if="p.avatar_url" :src="p.avatar_url" class="person-avatar" alt="" />
          <div v-else class="person-avatar-placeholder">{{ (p.username || '?')[0]?.toUpperCase() }}</div>
        </div>
        <span class="card-name person-username">{{ p.username }}</span>
      </router-link>
    </div>
  </article>
</template>

<script setup>
import { ref } from 'vue'
import { supabase } from '@/lib/supabase'

const query = ref('')
const results = ref([])
const searching = ref(false)
const searched = ref(false)

async function search() {
  const term = query.value.trim()
  searching.value = true
  searched.value = true

  let req = supabase
      .from('profiles')
      .select('id, username, avatar_url')
      .not('username', 'is', null)
      .order('username', { ascending: true })
      .limit(40)

  if (term) req = req.ilike('username', `%${term}%`)

  const { data } = await req

  results.value = data || []
  searching.value = false
}

search()
</script>

<style scoped>
.page-title {
  margin-top: 1rem;
}

.search-row {
  display: flex;
  gap: 0.6rem;
  max-width: 420px;
  margin: 0 auto 1.5rem;
}

.search-input {
  flex: 1;
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  padding: 0.55rem 0.8rem;
  font-size: 0.95rem;
  outline: none;
}

.search-input:focus {
  border-color: #90caf9;
}

.search-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #e0e0e0;
  padding: 0.55rem 1.1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
  white-space: nowrap;
}

.search-btn:hover:not(:disabled) {
  border-color: #90caf9;
  color: #90caf9;
}

.search-btn:disabled {
  opacity: 0.6;
  cursor: default;
}

.person-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  height: 180px;
  text-decoration: none;
  background: #1a1a1a;
}

.person-avatar-wrap {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
  background: #222;
  border: 2px solid #2a2a2a;
  position: relative;
  z-index: 2;
}

.person-avatar {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.person-avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #90caf9;
  font-family: 'Iosevka Charon', monospace;
  font-size: 1.6rem;
}

.person-username {
  position: relative;
  bottom: auto;
  left: auto;
  right: auto;
  text-align: center;
}
</style>
