<script setup>
defineProps({
  active: { type: String, required: true } // 'mory' | 'quinlan'
})
</script>

<template>
  <nav class="diary-nav" :class="active">
    <router-link to="/mory" class="diary-nav-link" :class="{ active: active === 'mory' }">
      Mory's Diary
    </router-link>
    <span class="diary-nav-sep">✦</span>
    <router-link to="/quinlan" class="diary-nav-link" :class="{ active: active === 'quinlan' }">
      Quinlan's Diary
    </router-link>
  </nav>
</template>

<style scoped>
.diary-nav {
  position: sticky;
  top: 0;
  z-index: 50;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.9rem;
  padding: 0.85rem 1rem;
  font-family: 'EB Garamond', serif;
  font-size: 0.82rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  backdrop-filter: blur(6px);
}

.diary-nav-link {
  text-decoration: none;
  padding: 2px 2px 4px;
  border-bottom: 1px solid transparent;
  transition: color 0.15s, border-color 0.15s;
}

/* Mory theme */
.diary-nav.mory {
  background: rgba(245, 240, 232, 0.88);
  border-bottom: 1px solid rgba(26, 16, 8, 0.1);
}
.diary-nav.mory .diary-nav-link {
  color: #9a8878;
}
.diary-nav.mory .diary-nav-link:hover {
  color: #c0392b;
}
.diary-nav.mory .diary-nav-link.active {
  color: #1a1008;
  border-bottom-color: #c0392b;
}
.diary-nav.mory .diary-nav-sep {
  color: #c0392b;
  font-size: 0.7rem;
  opacity: 0.7;
}

/* Quinlan theme */
.diary-nav.quinlan {
  background: rgba(47, 23, 30, 0.9);
  border-bottom: 1px solid rgba(177, 122, 42, 0.25);
}
.diary-nav.quinlan .diary-nav-link {
  color: #a69c8d;
}
.diary-nav.quinlan .diary-nav-link:hover {
  color: #d1cabd;
}
.diary-nav.quinlan .diary-nav-link.active {
  color: #d1cabd;
  border-bottom-color: #b17a2a;
}
.diary-nav.quinlan .diary-nav-sep {
  color: #7d0010;
  font-size: 0.7rem;
}
</style>
