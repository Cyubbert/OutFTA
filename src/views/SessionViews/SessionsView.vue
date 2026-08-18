<script setup>
import {ref, computed, onMounted} from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useAuth } from '@/composables/useAuth'
import SessionEntryForm from '@/components/SessionEntryForm.vue'

const AughImg = supabase.storage.from('images').getPublicUrl('AUGH.webp').data.publicUrl;

const { isAdmin } = useAuth()

const sessions = ref([])
const loading = ref(true)
const error = ref(null)
const editing = ref(null)
const creating = ref(false)

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
      .select('id, number, title, cover_image, date, summary, highlights, npcs, locations')

  if (err) error.value = err
  else sessions.value = data.map(s => ({ ...s, img: s.cover_image }))
  loading.value = false
})

function startEdit(s) {
  editing.value = s
}

function startCreate() {
  creating.value = true
}

function closeModal() {
  editing.value = null
  creating.value = false
}

function onSaved(record) {
  if (editing.value) {
    const idx = sessions.value.findIndex(s => s.id === editing.value.id)
    if (idx !== -1) sessions.value[idx] = { ...sessions.value[idx], ...record, img: record.cover_image }
  } else {
    sessions.value.push({ ...record, img: record.cover_image })
  }
  closeModal()
}

async function deleteSession(s) {
  if (!confirm(`Delete "${s.title}"? This can't be undone.`)) return

  const { error: err } = await supabase.from('sessions').delete().eq('id', s.id)
  if (err) {
    alert(err.message)
    return
  }
  sessions.value = sessions.value.filter(x => x.id !== s.id)
}
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
          <button
              v-if="isAdmin"
              key="create-card"
              class="card create-card"
              @click="startCreate"
          >
            <span class="create-plus">+</span>
            <span class="create-label">New session recap</span>
          </button>

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

            <div v-if="isAdmin" class="admin-actions">
              <button class="admin-btn" title="Edit" @click.stop.prevent="startEdit(s)">✎</button>
              <button class="admin-btn delete" title="Delete" @click.stop.prevent="deleteSession(s)">✕</button>
            </div>
          </router-link>
        </transition-group>
      </section>
    </div>

    <div v-if="editing || creating" class="modal-backdrop" @click.self="closeModal">
      <div class="modal-panel">
        <SessionEntryForm :edit-session="editing" @saved="onSaved" @cancel="closeModal" />
      </div>
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

.admin-actions {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 3;
  display: flex;
  gap: 6px;
}

.admin-btn {
  width: 28px;
  height: 28px;
  border-radius: 6px;
  border: 1px solid rgba(255,255,255,0.15);
  background: rgba(18,18,18,0.75);
  backdrop-filter: blur(4px);
  color: #e0e0e0;
  cursor: pointer;
  font-size: 0.85rem;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}

.admin-btn:hover {
  border-color: #90caf9;
  color: #90caf9;
}

.admin-btn.delete:hover {
  border-color: #e05252;
  color: #e05252;
}

.create-card {
  height: 160px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6px;
  background: rgba(144, 202, 249, 0.04);
  border: 1px dashed rgba(144, 202, 249, 0.3);
  color: #90caf9;
  font-family: inherit;
  transition: background 0.2s, border-color 0.2s;
}

.create-card:hover {
  background: rgba(144, 202, 249, 0.08);
  border-color: #90caf9;
  transform: none;
}

.create-plus {
  font-size: 1.8rem;
  line-height: 1;
}

.create-label {
  font-size: 0.85rem;
  letter-spacing: 0.04em;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.7);
  z-index: 1000;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 3rem 1rem;
  overflow-y: auto;
}

.modal-panel {
  background: #181818;
  border: 1px solid #333;
  border-radius: 12px;
  padding: 1.5rem;
  width: 100%;
  max-width: 540px;
}
</style>
