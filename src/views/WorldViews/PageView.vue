<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuth } from '@/composables/useAuth'
import InfoPage from '@/components/InfoPage.vue'
import PageEntryForm from '@/components/PageEntryForm.vue'
import { usePageData } from '@/composables/usePageData.js'
import { BASE_ROUTE } from '@/composables/usePagesByCategory.js'

// Serves every /world/:slug, /kingdom/:slug and /npcs/:slug page, including entries added from the site.
const route = useRoute()
const { isAdmin } = useAuth()
const { data, meta, loading, error, reload } = usePageData(() => route.params.slug)

const COLLECTION_LABEL = { kingdom: 'Kingdoms', world: 'World & Deities', npc: 'NPCs' }

const backLink = computed(() => meta.value && {
  to: BASE_ROUTE[meta.value.category],
  label: COLLECTION_LABEL[meta.value.category] ?? 'Back',
})

// Tabs only make sense when the main card has entries under it.
const tabs = computed(() => (meta.value?.family.length > 1 ? meta.value.family : []))

const editing = ref(false)

// Saving keeps the URL; moving an entry under another card just changes its tabs.
async function onSaved() {
  editing.value = false
  await reload()
}
</script>

<template>
  <p v-if="loading" class="page-loading">Loading…</p>
  <p v-else-if="error" class="page-error">Couldn't load this page.</p>
  <template v-else>
    <nav class="page-nav">
      <div class="nav-top">
        <router-link :to="backLink.to" class="back-link">← {{ backLink.label }}</router-link>
        <button v-if="isAdmin" class="edit-btn" @click="editing = true">✎ Edit</button>
      </div>

      <div v-if="tabs.length" class="tabs" role="tablist">
        <router-link
            v-for="(tab, i) in tabs"
            :key="tab.slug"
            :to="tab.route"
            class="tab"
            :class="{ active: tab.slug === route.params.slug, main: i === 0 }"
            role="tab"
            :aria-selected="tab.slug === route.params.slug"
        >{{ tab.name }}</router-link>
      </div>
    </nav>

    <InfoPage v-bind="data" />

    <div v-if="editing" class="modal-backdrop">
      <div class="modal-panel">
        <PageEntryForm
            :category="meta.category"
            :edit-page="meta.row"
            @saved="onSaved"
            @cancel="editing = false"
        />
      </div>
    </div>
  </template>
</template>

<style scoped>
.page-nav {
  margin: 1rem 0 1.25rem;
}

.nav-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
}

.back-link {
  color: #90caf9;
  font-size: 0.9rem;
  text-decoration: none;
}

.back-link:hover {
  text-decoration: underline;
}

.edit-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #ccc;
  padding: 0.35rem 0.85rem;
  border-radius: 6px;
  font-size: 0.85rem;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}

.edit-btn:hover {
  border-color: #90caf9;
  color: #90caf9;
}

/* Scrolls sideways on narrow screens instead of wrapping into a tall block. */
.tabs {
  display: flex;
  gap: 0.25rem;
  margin-top: 0.85rem;
  border-bottom: 1px solid #2a2a2a;
  overflow-x: auto;
  scrollbar-width: none;
}

.tab {
  flex-shrink: 0;
  padding: 0.5rem 0.9rem;
  border-bottom: 2px solid transparent;
  margin-bottom: -1px;
  color: #888;
  font-size: 0.92rem;
  text-decoration: none;
  white-space: nowrap;
  transition: color 0.15s, border-color 0.15s;
}

.tab:hover {
  color: #e0e0e0;
}

.tab.main {
  font-weight: 600;
}

.tab.active {
  color: #fff;
  border-bottom-color: #90caf9;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.7);
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
  max-width: 560px;
}
</style>
