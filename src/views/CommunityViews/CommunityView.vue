<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useAuth } from '@/composables/useAuth'
import CommunityPostCard from '@/components/CommunityPostCard.vue'
import CommunityPostForm from '@/components/CommunityPostForm.vue'

const { user, isAdmin, profile } = useAuth()
const canPost = computed(() => !!user.value && (isAdmin.value || profile.value.can_post_community))

const posts = ref([])
const loading = ref(true)
const error = ref(null)
const creating = ref(false)
const editing = ref(null)

onMounted(async () => {
  const { data, error: err } = await supabase
      .from('community_posts')
      .select('*')
      .order('created_at', { ascending: false })

  if (err) error.value = err
  else posts.value = data
  loading.value = false
})

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
  if (!confirm('Delete this post? This can\'t be undone.')) return

  const { error: err } = await supabase.from('community_posts').delete().eq('id', post.id)
  if (err) {
    alert(err.message)
    return
  }
  posts.value = posts.value.filter(p => p.id !== post.id)
}
</script>

<template>
  <article class="page sans">
    <header>
      <h1 class="page-title">Community Hub</h1>
      <p class="page-subtitle">Chewing the rags</p>
    </header>

    <div class="page-body">
      <div class="composer-row">
        <button v-if="canPost" class="new-post-btn" @click="startCreate">+ New post</button>
        <p v-else-if="user" class="sign-in-note">Your account isn't permitted to post here.</p>
        <p v-else class="sign-in-note"><router-link to="/login">Sign in</router-link> to post or comment.</p>
      </div>

      <p v-if="loading" class="page-loading">Loading…</p>
      <p v-else-if="error" class="page-error">Couldn't load the community hub.</p>
      <template v-else>
        <p v-if="!posts.length" class="empty-state">No posts yet. Be the first!</p>
        <transition-group name="fade" tag="div" class="posts-feed">
          <CommunityPostCard
              v-for="post in posts"
              :key="post.id"
              :post="post"
              @edit="startEdit"
              @delete="deletePost"
          />
        </transition-group>
      </template>
    </div>

    <div v-if="creating || editing" class="modal-backdrop" @click.self="closeModal">
      <div class="modal-panel">
        <CommunityPostForm :edit-post="editing" @saved="onSaved" @cancel="closeModal" />
      </div>
    </div>
  </article>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Iosevka+Charon:wght@400;500;700&family=Jost:wght@300;400;500;700&display=swap');

.page {
  margin: 2em auto;
  max-width: 700px;
  padding: 0 1rem;
  font-family: 'Jost', sans-serif;
  color: #e0e0e0;
}

.page-title {
  font-family: 'Iosevka Charon', monospace;
  font-size: 2.5rem;
  font-weight: 700;
  color: #fff;
  text-align: center;
  margin: 1rem 0 0.25rem;
  letter-spacing: 0.04em;
}

.page-subtitle {
  text-align: center;
  color: #444;
  font-size: 0.8rem;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  margin: 0 0 1.5rem;
}

.composer-row {
  display: flex;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.new-post-btn {
  background: #90caf9;
  color: #121212;
  border: none;
  padding: 0.6rem 1.4rem;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  transition: background 0.2s;
}
.new-post-btn:hover {
  background: #64b5f6;
}

.sign-in-note {
  font-size: 0.85rem;
  color: #666;
}
.sign-in-note a { color: #90caf9; }

.page-loading, .page-error, .empty-state {
  text-align: center;
  color: #444;
  font-style: italic;
  padding: 3rem 0;
}

.posts-feed {
  display: flex;
  flex-direction: column;
  gap: 1rem;
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
