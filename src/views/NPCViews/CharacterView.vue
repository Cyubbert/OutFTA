<script setup>
import {ref, computed} from 'vue'
import {useRouter} from 'vue-router'

const router = useRouter()

function loadAll() {
  const keys = Object.keys(localStorage).filter(k => k.startsWith('dnd-char-'))
  return keys.map(k => JSON.parse(localStorage.getItem(k))).filter(Boolean)
}

const characters = ref(loadAll())

const search = ref('')
const filtered = computed(() =>
    characters.value.filter(c =>
        c.name.toLowerCase().includes(search.value.toLowerCase()) ||
        c.class.toLowerCase().includes(search.value.toLowerCase()) ||
        c.race.toLowerCase().includes(search.value.toLowerCase())
    )
)

function createNew() {
  const id = 'char-' + Date.now()
  router.push('/character/' + id)
}

function deleteChar(id, e) {
  e.preventDefault()
  if (!confirm('Do you want to delete the Character?')) return
  localStorage.removeItem('dnd-char-' + id)
  characters.value = loadAll()
}

const classColors = {
  'Babarian': '#c46c6c', 'Bard': '#9c7fd4', 'Cleric': '#f0c040',
  'Druid': '#6ab04c', 'Fighter': '#4a9fd4', 'Monk': '#5dcaa5',
  'Paladin': '#f9cb42', 'Ranger': '#6ab04c', 'Thief': '#888',
  'Wizard': '#c46c6c', 'Warlock': '#9c7fd4', 'Sorcerer': '#4a9fd4',
}

function classColor(cls) {
  return classColors[cls] || '#90caf9'
}
</script>

<template>
  <article class="page sans">
    <header>
      <h1 class="page-title">Characters</h1>
      <div class="chars-topbar">
        <input v-model="search" class="search-input" placeholder="Name, Class or Species..."/>
        <button class="new-btn" @click="createNew">+ New Character</button>
      </div>
    </header>

    <div class="page-body">
      <div v-if="!filtered.length" class="empty-state">
        <p v-if="!characters.length">No Characters yet — create one!</p>
        <p v-else>No Characters found.</p>
      </div>

      <transition-group name="fade" tag="div" class="cards-container">
        <router-link
            v-for="c in filtered"
            :key="c.id"
            :to="'/charaktere/' + c.id"
            class="card char-card"
        >
          <div class="char-card-bg" :style="{ background: classColor(c.class) + '22' }"/>
          <div class="char-card-accent" :style="{ background: classColor(c.class) }"/>
          <div class="char-card-body">
            <div class="char-level">Level {{ c.level }}</div>
            <div class="card-name">{{ c.name || 'No Name' }}</div>
            <div class="char-sub">{{ c.race }} {{ c.class }}</div>
            <div class="char-hp">
              <span class="hp-dot" :style="{ background: c.hp <= c.maxHp * 0.25 ? '#ef9a9a' : '#6ab04c' }"/>
              {{ c.hp }} / {{ c.maxHp }} HP
            </div>
          </div>
          <button class="delete-btn" @click="deleteChar(c.id, $event)" title="Delete">✕</button>
        </router-link>
      </transition-group>
    </div>
  </article>
</template>

<style scoped>
.page {
  margin: 2em auto;
  max-width: 900px;
  padding: 0 1rem;
  font-family: 'Jost', sans-serif;
  color: #e0e0e0;
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 1rem 0 1.5rem;
  color: #fff;
  text-align: center;
  font-family: 'Iosevka Charon', monospace;
  letter-spacing: 0.04em;
}

.chars-topbar {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}

.search-input {
  flex: 1;
  min-width: 180px;
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  font-family: 'Jost', sans-serif;
  font-size: 0.9rem;
  padding: 0.55rem 1rem;
  outline: none;
  transition: border-color 0.2s;
}

.search-input:focus {
  border-color: #90caf9;
}

.new-btn {
  background: #1a1a1a;
  border: 1px solid #90caf9;
  color: #90caf9;
  border-radius: 6px;
  padding: 0.55rem 1.2rem;
  font-family: 'Jost', sans-serif;
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  white-space: nowrap;
  transition: background 0.2s;
}

.new-btn:hover {
  background: #0e2233;
}

.cards-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 1.4rem;
  margin-top: 0.5rem;
}

.char-card {
  position: relative;
  height: 180px;
  border-radius: 12px;
  overflow: hidden;
  background: #1a1a1a;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.5);
  cursor: pointer;
  text-decoration: none;
  transition: transform 0.25s, box-shadow 0.25s;
}

.char-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 24px rgba(0, 0, 0, 0.7);
}

.char-card-bg {
  position: absolute;
  inset: 0;
}

.char-card-accent {
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 3px;
}

.char-card::after {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.9) 0%, rgba(0, 0, 0, 0.2) 60%, transparent 100%);
}

.char-card-body {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 0.9rem 1rem;
  z-index: 2;
}

.char-level {
  font-size: 0.62rem;
  text-transform: uppercase;
  letter-spacing: 0.15em;
  color: #90caf9;
  margin-bottom: 3px;
}

.card-name {
  font-size: 1.15rem;
  font-weight: 700;
  color: #fff;
  font-family: 'Iosevka Charon', monospace;
}

.char-sub {
  font-size: 0.78rem;
  color: #888;
  margin-top: 2px;
}

.char-hp {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 0.75rem;
  color: #666;
  margin-top: 5px;
}

.hp-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  flex-shrink: 0;
}

.delete-btn {
  position: absolute;
  top: 8px;
  right: 8px;
  z-index: 3;
  background: rgba(0, 0, 0, 0.5);
  border: none;
  color: #444;
  width: 22px;
  height: 22px;
  border-radius: 4px;
  font-size: 0.7rem;
  cursor: pointer;
  transition: color 0.15s, background 0.15s;
}

.delete-btn:hover {
  color: #ef9a9a;
  background: rgba(0, 0, 0, 0.8);
}

.empty-state {
  text-align: center;
  color: #444;
  font-style: italic;
  padding: 3rem 0;
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.25s;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

@media (max-width: 600px) {
  .cards-container {
    grid-template-columns: 1fr;
  }
}
</style>