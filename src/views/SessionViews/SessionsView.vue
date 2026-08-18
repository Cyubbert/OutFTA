<script setup>
import {ref, computed, onMounted} from 'vue'
import { supabase } from '@/lib/supabase.js'
const AughImg = supabase.storage.from('images').getPublicUrl('AUGH.webp').data.publicUrl;

const sessions = ref([])
const loading = ref(true)
const error = ref(null)

const search = ref('')
const filtered = computed(() =>
    sessions.value
        .filter(s => s.title.toLowerCase().includes(search.value.toLowerCase()) || String(s.number).includes(search.value.trim())
        )
        .sort((a, b) => b.number - a.number)
)

onMounted(async () => {
  const { data, error: err } = await supabase
      .from('sessions')
      .select('id, number, title, cover_image, date')

  if (err) error.value = err
  else sessions.value = data.map(s => ({ ...s, img: s.cover_image }))
  loading.value = false
})
</script>

<template>
  <article class="page sans">
    <header>
      <img class="page-cover-image" :src="AughImg" alt="Cover image" />
      <h1 class="page-title">Sessions</h1>
      <input v-model="search" placeholder="Search Session..." class="search-input"/>
    </header>

    <div class="page-body">
      <p v-if="loading" class="page-loading">Loading…</p>
      <p v-else-if="error" class="page-error">Couldn't load sessions.</p>
      <section v-else class="collection-content">
        <transition-group name="fade" tag="div" class="cards-container">
          <router-link
              v-for="s in filtered"
              :key="s.id"
              :to="`/sessions/${s.id}`"
              class="card session-card"
          >
            <img v-if="s.img" :src="s.img" :alt="s.title" />
            <div class="session-text">
              <div class="session-number">Session {{ s.number }}</div>
              <div class="card-name">{{ s.title }}</div>
              <div class="session-date">{{ s.date }}</div>
            </div>
          </router-link>
        </transition-group>
      </section>
    </div>
  </article>
</template>

<style scoped>
.search-input {
  display: block;
  margin: 0 auto 1.5rem;
  width: 100%;
  max-width: 400px;
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  font-size: 0.95rem;
  padding: 0.6rem 1rem;
  outline: none;
}
.search-input:focus { border-color: #90caf9; }

.session-card {
  position: relative;
  height: 160px;
  width: 100%;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 0;
  overflow: hidden;
}

.session-card img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.35s ease;
}
.session-card:hover img {
  transform: scale(1.08);
}

.session-text {
  position: relative;
  text-decoration: none;
  z-index: 2;
  padding: 0.75rem 1rem 0.85rem;
  background: linear-gradient(to top, rgba(0,0,0,0.92) 0%, rgba(0,0,0,0.5) 60%, transparent 100%);
}

.session-number {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.18em;
  color: #90caf9;
  margin-bottom: 3px;
  font-family: 'Cinzel', serif;
}

.card-name {
  font-size: 1rem;
  font-weight: 700;
  color: #fff;
  text-shadow: 0 1px 6px rgba(0,0,0,0.8);
  letter-spacing: 0.02em;
  bottom: auto;
  left: auto;
  position: relative;
  margin-left: 10px;
}

.session-date {
  font-size: 0.7rem;
  color: rgba(255,255,255,0.5);
  margin-top: 2px;
  letter-spacing: 0.05em;
}
</style>
