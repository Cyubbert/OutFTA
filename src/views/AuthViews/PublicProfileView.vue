<template>
  <article class="page sans container">
    <p v-if="loading" class="page-loading">Loading…</p>

    <div v-else-if="!profile" class="auth-card">
      <h1 class="page-title">No one here yet</h1>
      <p>There's no profile at <strong>@{{ username }}</strong>.</p>
    </div>

    <template v-else>
      <div class="banner-wrap">
        <img v-if="profile.banner_url" :src="profile.banner_url" class="banner-img" alt="Profile banner" />
      </div>

      <header class="profile-header">
        <div class="avatar-wrap">
          <img v-if="profile.avatar_url" :src="profile.avatar_url" class="avatar-img" alt="Profile picture" />
          <div v-else class="avatar-placeholder">{{ avatarInitial }}</div>
        </div>

        <div class="profile-info">
          <span class="username-display">{{ profile.username }}</span>
        </div>
      </header>

      <h3 class="collection-title">Gallery</h3>

      <p v-if="galleryLoading" class="page-loading">Loading…</p>
      <p v-else-if="!galleryImages.length" class="page-loading">Nothing here yet.</p>
      <div v-else class="cards-container">
        <div
            v-for="img in galleryImages"
            :key="img.id"
            class="card gallery-card"
            @click="viewingImage = img"
        >
          <img :src="img.image_url" :alt="img.caption || 'Gallery image'" />
          <div v-if="img.caption" class="sheet-text">
            <div class="card-name">{{ img.caption }}</div>
          </div>
        </div>
      </div>
    </template>

    <div v-if="viewingImage" class="modal-backdrop" @click.self="viewingImage = null">
      <div class="modal-panel gallery-viewer">
        <img :src="viewingImage.image_url" :alt="viewingImage.caption || 'Gallery image'" class="gallery-full-img" />
        <p v-if="viewingImage.caption" class="viewer-caption">{{ viewingImage.caption }}</p>
        <div class="form-actions">
          <button class="cancel-btn" @click="viewingImage = null">Close</button>
        </div>
      </div>
    </div>
  </article>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { supabase } from '@/lib/supabase'

const route = useRoute()
const username = computed(() => route.params.username)

const loading = ref(true)
const profile = ref(null)
const galleryImages = ref([])
const galleryLoading = ref(true)
const viewingImage = ref(null)

const avatarInitial = computed(() => (profile.value?.username || '?')[0]?.toUpperCase())

async function load() {
  loading.value = true
  galleryLoading.value = true
  profile.value = null
  galleryImages.value = []
  viewingImage.value = null

  const { data, error } = await supabase
      .from('profiles')
      .select('id, username, avatar_url, banner_url')
      .ilike('username', username.value)
      .maybeSingle()

  if (error || !data) {
    loading.value = false
    galleryLoading.value = false
    return
  }

  profile.value = data
  loading.value = false

  const { data: gallery } = await supabase
      .from('profile_gallery_images')
      .select('*')
      .eq('user_id', data.id)
      .order('created_at', { ascending: false })

  galleryImages.value = gallery || []
  galleryLoading.value = false
}

watch(username, load, { immediate: true })
</script>

<style scoped>
.banner-wrap {
  width: 100%;
  height: 200px;
  border-radius: 12px;
  overflow: hidden;
  background: #1a1a1a;
  border: 1px solid #2a2a2a;
  margin-bottom: -48px;
}

.banner-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.profile-header {
  display: flex;
  align-items: flex-end;
  gap: 1rem;
  padding: 0 1rem;
  margin-bottom: 1.5rem;
}

.avatar-wrap {
  width: 96px;
  height: 96px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
  background: #1a1a1a;
  border: 3px solid #121212;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #90caf9;
  font-family: 'Iosevka Charon', monospace;
  font-size: 2rem;
}

.profile-info {
  padding-bottom: 0.5rem;
}

.username-display {
  font-size: 1.3rem;
  font-weight: 600;
  color: #fff;
}

.viewer-caption {
  color: #ccc;
  margin: 0.5rem 0 0;
}

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.75);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem 1rem;
}

.modal-panel {
  background: #181818;
  border: 1px solid #333;
  border-radius: 12px;
  padding: 1.25rem;
  max-width: 640px;
  width: 100%;
}

.gallery-full-img {
  width: 100%;
  max-height: 70vh;
  object-fit: contain;
  border-radius: 8px;
  display: block;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 1rem;
}

.cancel-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #888;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}

.cancel-btn:hover {
  border-color: #90caf9;
  color: #90caf9;
}
</style>
