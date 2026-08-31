<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useAuth } from '@/composables/useAuth'
import QuinauPostCard from '@/components/QuinauPostCard.vue'
import QuinauPostForm from '@/components/QuinauPostForm.vue'

const { user, isAdmin, profile, loading: authLoading } = useAuth()

onMounted(() => {
  document.body.style.backgroundColor = '#070504'
  document.body.style.color = '#cfc3b8'
  document.body.style.maxWidth = '100%'
  document.body.style.margin = '0'
  document.body.style.padding = '0'
  const navbar = document.querySelector('.navbar')
  if (navbar) navbar.style.display = 'none'
})

onUnmounted(() => {
  document.body.style.backgroundColor = ''
  document.body.style.color = ''
  document.body.style.maxWidth = ''
  document.body.style.margin = ''
  document.body.style.padding = ''
  const navbar = document.querySelector('.navbar')
  if (navbar) navbar.style.display = ''
})

const posts = ref([])
const postsLoaded = ref(false)
const loading = ref(true)
const error = ref(null)
const creating = ref(false)
const editing = ref(null)

const canView = computed(() => !!user.value && (isAdmin.value || profile.value.can_view_moryquinau))
const canWrite = computed(() => !!user.value && (isAdmin.value || profile.value.can_post_moryquinau))
const showGate = computed(() => !authLoading.value && !canView.value)

async function loadPosts() {
  loading.value = true
  const { data, error: err } = await supabase
      .from('mory_quinau_posts')
      .select('*')
      .order('created_at', { ascending: false })

  if (err) error.value = err
  else posts.value = data
  postsLoaded.value = true
  loading.value = false
}

watch(canView, (v) => {
  if (v && !postsLoaded.value) loadPosts()
}, { immediate: true })

function startCreate() {
  creating.value = true
}

function startEdit(post) {
  editing.value = post
}

function closeModal() {
  creating.value = false
  editing.value = null
}

function onSaved(record) {
  if (editing.value) {
    const idx = posts.value.findIndex(p => p.id === record.id)
    if (idx !== -1) posts.value[idx] = record
  } else {
    posts.value.unshift(record)
  }
  closeModal()
}

async function deletePost(post) {
  if (!confirm('Erase this entry? This can\'t be undone.')) return

  const { error: err } = await supabase.from('mory_quinau_posts').delete().eq('id', post.id)
  if (err) {
    alert(err.message)
    return
  }
  posts.value = posts.value.filter(p => p.id !== post.id)
}
</script>

<template>
  <div class="quinau-root">
    <div v-if="showGate" class="gate">
      <div class="gate-sigil">†</div>
      <p class="gate-text">This place isn't for wandering eyes.</p>
      <router-link v-if="!user" to="/login" class="gate-link">Sign in</router-link>
    </div>

    <article v-else class="page">
      <header class="page-header">
        <div class="page-sigil">†</div>
        <h1 class="page-title">MoryQuin Fanfiction text drops</h1>
        <p class="page-subtitle">Only for the intended eye.</p>
        <div class="header-rule" />
      </header>

      <div class="composer-row" v-if="canWrite">
        <button class="new-post-btn" @click="startCreate">+ Leave word</button>
      </div>

      <p v-if="loading" class="page-status">Loading…</p>
      <p v-else-if="error" class="page-status">Couldn't reach this place.</p>
      <template v-else>
        <p v-if="!posts.length" class="empty-state">Nothing left here yet.</p>
        <transition-group name="fade" tag="div" class="posts-feed">
          <QuinauPostCard
              v-for="post in posts"
              :key="post.id"
              :post="post"
              :can-write="canWrite"
              @edit="startEdit"
              @delete="deletePost"
          />
        </transition-group>
      </template>

      <div v-if="creating || editing" class="modal-backdrop" @click.self="closeModal">
        <div class="modal-panel">
          <QuinauPostForm :edit-post="editing" @saved="onSaved" @cancel="closeModal" />
        </div>
      </div>
    </article>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;0,500;0,600;1,400;1,500&family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&display=swap');

.quinau-root {
  min-height: 100vh;
  width: 100vw;
  margin-left: calc(-50vw + 50%);
  background: #070504;
  background-image:
      radial-gradient(ellipse 60% 40% at 50% 0%, rgba(139, 26, 26, 0.08), transparent 60%),
      radial-gradient(ellipse 50% 30% at 100% 100%, rgba(47, 107, 69, 0.06), transparent 60%);
  color: #cfc3b8;
  font-family: 'EB Garamond', serif;
}

.gate {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  text-align: center;
}

.gate-sigil {
  font-size: 2rem;
  color: #8b1a1a;
}

.gate-text {
  font-style: italic;
  color: #8a7a6d;
  font-size: 1.1rem;
}

.gate-link {
  border: 1px solid rgba(139, 26, 26, 0.4);
  color: #c0392b;
  text-decoration: none;
  padding: 0.5rem 1.2rem;
  border-radius: 3px;
  font-size: 0.82rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  transition: background 0.2s, color 0.2s;
}

.gate-link:hover {
  background: rgba(139, 26, 26, 0.12);
  color: #e05252;
}

.page {
  max-width: 640px;
  margin: 0 auto;
  padding: 4rem 1.5rem 6rem;
}

.page-header {
  text-align: center;
  margin-bottom: 2.5rem;
}

.page-sigil {
  font-size: 1.3rem;
  color: #8b1a1a;
  margin-bottom: 0.75rem;
  letter-spacing: 0.3em;
}

.page-title {
  font-family: 'Cormorant Garamond', serif;
  font-size: 3rem;
  font-weight: 300;
  font-style: italic;
  color: #e8ded2;
  margin: 0 0 0.25rem;
  letter-spacing: 0.06em;
}

.page-subtitle {
  font-size: 0.76rem;
  text-transform: uppercase;
  letter-spacing: 0.28em;
  color: #3f7d4f;
  margin: 0 0 1.5rem;
}

.header-rule {
  width: 60px;
  height: 1px;
  background: linear-gradient(90deg, #8b1a1a, #3f7d4f);
  margin: 0 auto;
  opacity: 0.6;
}

.composer-row {
  display: flex;
  justify-content: center;
  margin-bottom: 2rem;
}

.new-post-btn {
  background: transparent;
  border: 1px solid rgba(139, 26, 26, 0.45);
  color: #c0392b;
  padding: 0.6rem 1.4rem;
  border-radius: 3px;
  font-family: 'EB Garamond', serif;
  font-size: 0.9rem;
  letter-spacing: 0.04em;
  cursor: pointer;
  transition: background 0.2s, border-color 0.2s, color 0.2s;
}

.new-post-btn:hover {
  background: rgba(139, 26, 26, 0.1);
  border-color: #c0392b;
  color: #e05252;
}

.page-status, .empty-state {
  text-align: center;
  color: #6b5f56;
  font-style: italic;
  padding: 3rem 0;
}

.posts-feed {
  display: flex;
  flex-direction: column;
  gap: 1.1rem;
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.2s;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(3, 2, 1, 0.85);
  z-index: 1000;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 3rem 1rem;
  overflow-y: auto;
}

.modal-panel {
  background: #100b09;
  border: 1px solid rgba(139, 26, 26, 0.3);
  border-radius: 8px;
  padding: 1.5rem;
  width: 100%;
  max-width: 540px;
}
</style>
