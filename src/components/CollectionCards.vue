<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/lib/supabase.js'
import { useAuth } from '@/composables/useAuth'
import { usePagesByCategory } from '@/composables/usePagesByCategory.js'
import PageEntryForm from '@/components/PageEntryForm.vue'

const props = defineProps({
  category: { type: String, required: true },  // 'world' | 'kingdom' | 'npc'
  slugOrder: { type: Array, default: () => [] }
})

const router = useRouter()
const { isAdmin } = useAuth()
const { cards, loading, error, reload } = usePagesByCategory(props.category, props.slugOrder)

const openSlug = ref(null)
const adding = ref(false)
const addParent = ref(null)
const editing = ref(null)
const editError = ref('')

// Cards with entries under them open a dropdown; the rest go straight to their page.
function onCardClick(card) {
  if (!card.children.length) {
    router.push(card.route)
    return
  }
  openSlug.value = openSlug.value === card.slug ? null : card.slug
}

function startAdd(parentSlug = null) {
  addParent.value = parentSlug
  adding.value = true
}

async function startEdit(card) {
  editError.value = ''
  const { data, error: err } = await supabase.from('pages').select('*').eq('slug', card.slug).single()
  if (err) editError.value = `Couldn't open ${card.name} for editing: ${err.message}`
  else editing.value = data
}

function closeForm() {
  adding.value = false
  addParent.value = null
  editing.value = null
}

async function onSaved(row) {
  closeForm()
  await reload()
  if (row.parent_slug) openSlug.value = row.parent_slug
}
</script>

<template>
  <div v-if="isAdmin" class="add-row">
    <button class="add-btn" @click="startAdd()">+ Add entry</button>
  </div>
  <p v-if="editError" class="page-error">{{ editError }}</p>

  <p v-if="loading" class="page-loading">Loading…</p>
  <p v-else-if="error" class="page-error">Couldn't load this page.</p>
  <transition-group v-else name="fade" tag="div" class="cards-container dropdown-cards">
    <div v-for="card in cards" :key="card.slug" class="card-wrap" :class="{ open: openSlug === card.slug }">
      <button
          class="card"
          :aria-expanded="card.children.length ? openSlug === card.slug : undefined"
          @click="onCardClick(card)"
      >
        <img v-if="card.img" :src="card.img" :alt="card.name" />
        <div class="card-name">
          {{ card.name }}
          <span v-if="card.children.length" class="chevron" aria-hidden="true">▾</span>
        </div>
      </button>
      <button v-if="isAdmin" class="edit-btn" :title="`Edit ${card.name}`" @click="startEdit(card)">✎</button>

      <transition name="drop">
        <ul v-if="openSlug === card.slug" class="sub-list">
          <li>
            <router-link :to="card.route" class="sub-item main">
              <span>{{ card.name }}</span><span class="arrow">→</span>
            </router-link>
          </li>
          <li v-for="child in card.children" :key="child.slug">
            <router-link :to="child.route" class="sub-item">
              <span>{{ child.name }}</span><span class="arrow">→</span>
            </router-link>
          </li>
          <li v-if="isAdmin">
            <button class="sub-item add" @click="startAdd(card.slug)">+ Add under {{ card.name }}</button>
          </li>
        </ul>
      </transition>
    </div>
  </transition-group>

  <div v-if="adding || editing" class="modal-backdrop">
    <div class="modal-panel">
      <PageEntryForm
          :category="category"
          :parent-slug="addParent"
          :edit-page="editing"
          @saved="onSaved"
          @cancel="closeForm"
      />
    </div>
  </div>
</template>

<style scoped>
.add-row {
  display: flex;
  justify-content: flex-end;
}

.add-btn {
  background: #90caf9;
  color: #121212;
  border: none;
  padding: 0.55rem 1.2rem;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  transition: background 0.2s;
}

.add-btn:hover {
  background: #64b5f6;
}

/* Open dropdowns grow their own column instead of stretching the whole row. */
.dropdown-cards {
  align-items: start;
}

.card-wrap {
  position: relative;
  min-width: 0;
}

.edit-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 3;
  width: 30px;
  height: 30px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  background: rgba(18, 18, 18, 0.8);
  color: #e0e0e0;
  font-size: 0.9rem;
  line-height: 1;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}

.edit-btn:hover {
  border-color: #90caf9;
  color: #90caf9;
}

/* The card is a button here, so strip the browser's button styling. */
button.card {
  display: block;
  border: 0;
  padding: 0;
  font: inherit;
  text-align: left;
  color: inherit;
}

.card-wrap.open .card {
  border-bottom-left-radius: 0;
  border-bottom-right-radius: 0;
  transform: none;
}

.card-name {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
}

.chevron {
  font-size: 0.9rem;
  opacity: 0.8;
  transition: transform 0.2s;
}

.card-wrap.open .chevron {
  transform: rotate(180deg);
}

.sub-list {
  list-style: none;
  margin: 0;
  padding: 0.35rem 0;
  background: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-top: 0;
  border-radius: 0 0 12px 12px;
  box-shadow: 0 10px 24px rgba(0, 0, 0, 0.5);
}

.sub-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding: 0.6rem 1rem;
  background: none;
  border: 0;
  color: #e0e0e0;
  font-family: 'Jost', sans-serif;
  font-size: 0.95rem;
  text-align: left;
  text-decoration: none;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
}

.sub-item:hover {
  background: #222;
  color: #90caf9;
}

.sub-item.main {
  font-weight: 500;
  border-bottom: 1px solid #2a2a2a;
}

.sub-item.add {
  color: #90caf9;
  font-size: 0.85rem;
}

.arrow {
  color: #555;
  transition: color 0.15s;
}

.sub-item:hover .arrow {
  color: #90caf9;
}

.drop-enter-active, .drop-leave-active {
  transition: opacity 0.15s, transform 0.15s;
}

.drop-enter-from, .drop-leave-to {
  opacity: 0;
  transform: translateY(-4px);
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
