<script setup>
import {computed} from 'vue'
import {useRoute, useRouter} from 'vue-router'
import sessions from '@/data/sessions.json'

const route = useRoute()
const router = useRouter()
const session = computed(() => sessions.find(s => s.id === route.params.id))
const prev = computed(() => sessions.find(s => s.number === session.value?.number - 1))
const next = computed(() => sessions.find(s => s.number === session.value?.number + 1))
</script>

<template>
  <article class="page sans" v-if="session">
    <header>
      <div class="session-banner" v-if="session.img">
        <img :src="session.img" :alt="session.title" class="banner-img" />
        <div class="banner-overlay">
          <p class="session-meta">Session {{ session.number }} · {{ session.date }}</p>
          <h1 class="page-title">{{ session.title }}</h1>
        </div>
      </div>
      <template v-else>
        <h1 class="page-title">{{ session.title }}</h1>
        <p class="session-meta">Session {{ session.number }} · {{ session.date }}</p>
      </template>
    </header>

    <div class="page-body">
      <p
          v-for="(para, i) in session.summary.split('\n\n').filter(p => p.trim())"
          :key="i"
          class="summary-para"
      >{{ para.trim() }}</p>

      <div class="tags-row" v-if="session.npcs?.length">
        <span class="tag-label">NPCs:</span>
        <router-link v-for="npc in session.npcs" :key="npc" :to="`/npcs/${npc}`" class="tag">
          {{ npc }}
        </router-link>
      </div>

      <div class="tags-row" v-if="session.locations?.length">
        <span class="tag-label">Locations:</span>
        <span v-for="loc in session.locations" :key="loc" class="tag">{{ loc }}</span>
      </div>

      <ul class="highlights" v-if="session.highlights?.length">
        <li v-for="h in session.highlights" :key="h">{{ h }}</li>
      </ul>

      <div class="nav-row">
        <router-link v-if="prev" :to="`/sessions/${prev.id}`" class="nav-btn">← {{ prev.title }}</router-link>
        <router-link to="/sessions" class="nav-btn center">All Sessions</router-link>
        <router-link v-if="next" :to="`/sessions/${next.id}`" class="nav-btn">{{ next.title }} →</router-link>
      </div>
    </div>
  </article>
</template>

<style scoped>

.session-banner {
  position: relative;
  width: 100%;
  height: 280px;
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 2rem;
}

.banner-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  filter: brightness(0.6);
}

.banner-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 1.5rem 1.8rem;
  background: linear-gradient(to top, rgba(0,0,0,0.85) 0%, rgba(0,0,0,0.2) 60%, transparent 100%);
}

.banner-overlay .page-title {
  margin: 0;
  text-align: left;
  font-size: 1.8rem;
}

.banner-overlay .session-meta {
  text-align: left;
  margin-bottom: 0.4rem;
}

.session-meta {
  text-align: center;
  color: #90caf9;
  font-size: 0.85rem;
  margin-bottom: 2rem;
}

.summary {
  line-height: 1.8;
  color: #ccc;
  margin-bottom: 1.5rem;
}

.tags-row {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
  margin-bottom: 0.75rem;
}

.tag-label {
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: #555;
}

.tag {
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  padding: 2px 10px;
  font-size: 0.8rem;
  color: #90caf9;
  text-decoration: none;
}

.highlights {
  color: #ccc;
  line-height: 2;
  padding-left: 1.2rem;
}

.nav-row {
  display: flex;
  gap: 1rem;
  margin-top: 2.5rem;
}

.nav-btn {
  flex: 1;
  text-align: center;
  padding: 0.6rem;
  border: 1px solid #333;
  border-radius: 6px;
  background: #1a1a1a;
  color: #e0e0e0;
  text-decoration: none;
  font-size: 0.85rem;
  transition: border-color 0.2s;
}

.nav-btn:hover {
  border-color: #90caf9;
}

.nav-btn.center {
  flex: 0 0 auto;
}

.summary-para {
  line-height: 1.8;
  color: #ccc;
  margin: 0 0 1rem;
}

.summary-para:last-child {
  margin-bottom: 0;
}

</style>