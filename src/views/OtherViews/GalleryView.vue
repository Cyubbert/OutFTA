<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/lib/supabase.js'
import { useAuth } from '@/composables/useAuth'
import GalleryUploadForm from '@/components/GalleryUploadForm.vue'

const router = useRouter()
const { user, isAdmin, profile } = useAuth()

const CHARACTER_TAGS = ['waesstan', 'marvers', 'ray']

const images = ref([])
const galleryLoading = ref(true)
const galleryError = ref(null)

const filterTag = ref('all')
const lightbox = ref(null)
const creating = ref(false)
const editing = ref(null)

const canPost = computed(() => !!user.value && (isAdmin.value || profile.value.can_post_gallery))

const filtered = computed(() =>
    filterTag.value === 'all' ? images.value : images.value.filter(img => img.tags?.includes(filterTag.value))
)

function canEdit(img) {
  return user.value && (user.value.id === img.user_id || isAdmin.value)
}

function isCharacterTag(tag) {
  return CHARACTER_TAGS.includes(tag)
}

function goToProfile(tag) {
  lightbox.value = null
  router.push(`/profile/${tag}`)
}

function openLightbox(img) {
  lightbox.value = img
  document.body.style.overflow = 'hidden'
}

function closeLightbox() {
  lightbox.value = null
  document.body.style.overflow = ''
}

function prev() {
  const idx = filtered.value.findIndex(a => a.id === lightbox.value.id)
  lightbox.value = filtered.value[(idx - 1 + filtered.value.length) % filtered.value.length]
}

function next() {
  const idx = filtered.value.findIndex(a => a.id === lightbox.value.id)
  lightbox.value = filtered.value[(idx + 1) % filtered.value.length]
}

function onKey(e) {
  if (!lightbox.value) return
  if (e.key === 'Escape') closeLightbox()
  if (e.key === 'ArrowLeft') prev()
  if (e.key === 'ArrowRight') next()
}

async function loadGallery() {
  const { data, error } = await supabase
      .from('gallery_images')
      .select('*')
      .order('created_at', { ascending: false })

  if (error) galleryError.value = error
  else images.value = data
  galleryLoading.value = false
}

function startCreate() {
  creating.value = true
}

function startEdit(img) {
  lightbox.value = null
  editing.value = img
}

function closeModal() {
  creating.value = false
  editing.value = null
}

function onSaved(record) {
  if (editing.value) {
    const idx = images.value.findIndex(i => i.id === record.id)
    if (idx !== -1) images.value[idx] = record
  } else {
    images.value.unshift(record)
  }
  closeModal()
}

async function deleteImage(img) {
  if (!confirm('Delete this picture? This can\'t be undone.')) return

  const { error } = await supabase.from('gallery_images').delete().eq('id', img.id)
  if (error) {
    alert(error.message)
    return
  }
  images.value = images.value.filter(i => i.id !== img.id)
  if (lightbox.value?.id === img.id) closeLightbox()
}

onMounted(() => {
  window.addEventListener('keydown', onKey)
  loadGallery()
})
onUnmounted(() => window.removeEventListener('keydown', onKey))
</script>

<template>
  <article class="page sans">
    <header>
      <h1 class="page-title">Gallery</h1>
      <p class="page-subtitle">Art by the Players</p>

      <div class="gallery-tabs">
        <button class="gallery-tab" :class="{ active: filterTag === 'all' }" @click="filterTag = 'all'">All</button>
        <button class="gallery-tab nsfw-tab" :class="{ active: filterTag === 'nsfw' }" @click="filterTag = 'nsfw'">NSFW</button>
      </div>

      <div class="composer-row">
        <button v-if="canPost" class="upload-btn" @click="startCreate">+ Upload picture</button>
        <p v-else-if="user" class="sign-in-note">Your account isn't permitted to upload here.</p>
        <p v-else class="sign-in-note"><router-link to="/login">Sign in</router-link> to upload.</p>
      </div>
    </header>

    <div class="page-body">
      <p v-if="galleryLoading" class="empty-state">Loading…</p>
      <p v-else-if="galleryError" class="empty-state">Couldn't load the gallery.</p>
      <template v-else>
        <p class="count-label">{{ filtered.length }} work{{ filtered.length !== 1 ? 's' : '' }}</p>
        <div v-if="!filtered.length" class="empty-state">No pictures found.</div>

        <transition-group name="fade" tag="div" class="gallery-grid">
          <div v-for="img in filtered" :key="img.id" class="gallery-item" @click="openLightbox(img)">
            <img :src="img.image_url" :alt="img.title || 'Gallery image'" class="gallery-img" />
            <span v-if="img.tags?.includes('nsfw')" class="nsfw-badge">NSFW</span>

            <div v-if="canEdit(img)" class="admin-actions">
              <button class="admin-btn" title="Edit" @click.stop="startEdit(img)">✎</button>
              <button class="admin-btn delete" title="Delete" @click.stop="deleteImage(img)">✕</button>
            </div>

            <div class="gallery-overlay">
              <span v-if="img.title" class="art-title">{{ img.title }}</span>
              <span class="art-artist">by {{ img.display_name }}</span>
            </div>
          </div>
        </transition-group>
      </template>
    </div>

    <!-- Upload / edit modal -->
    <div v-if="creating || editing" class="modal-backdrop" @click.self="closeModal">
      <div class="modal-panel">
        <GalleryUploadForm :edit-post="editing" @saved="onSaved" @cancel="closeModal" />
      </div>
    </div>

    <!-- Lightbox -->
    <transition name="lb">
      <div class="lightbox" v-if="lightbox" @click.self="closeLightbox">
        <button class="lb-close" @click="closeLightbox">✕</button>
        <button class="lb-nav lb-prev" @click="prev" v-if="filtered.length > 1">‹</button>
        <button class="lb-nav lb-next" @click="next" v-if="filtered.length > 1">›</button>
        <div class="lb-content">
          <img :src="lightbox.image_url" :alt="lightbox.title || 'Gallery image'" class="lb-img" />
          <div class="lb-info">
            <span v-if="lightbox.title" class="lb-title">{{ lightbox.title }}</span>
            <span class="lb-artist">by {{ lightbox.display_name }}</span>
            <p v-if="lightbox.body" class="lb-body">{{ lightbox.body }}</p>

            <div v-if="lightbox.tags?.length" class="lb-tags">
              <button
                  v-for="tag in lightbox.tags"
                  :key="tag"
                  class="tag-chip"
                  :class="{ nsfw: tag === 'nsfw', clickable: isCharacterTag(tag) }"
                  :disabled="!isCharacterTag(tag)"
                  @click="isCharacterTag(tag) && goToProfile(tag)"
              >#{{ tag }}</button>
            </div>

            <div v-if="canEdit(lightbox)" class="lb-actions">
              <button class="lb-action-btn" @click="startEdit(lightbox)">Edit</button>
              <button class="lb-action-btn danger" @click="deleteImage(lightbox)">Delete</button>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </article>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Iosevka+Charon:wght@400;500;700&family=Jost:wght@300;400;500;700&display=swap');

.page {
  margin: 2em auto;
  max-width: 900px;
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
  margin: 0 0 1rem;
}

/* ── Filter tabs ── */
.gallery-tabs {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-bottom: 1rem;
}

.gallery-tab {
  padding: 0.5rem 1.4rem;
  border: none;
  border-radius: 6px;
  background: #333;
  color: #fff;
  cursor: pointer;
  font-family: 'Jost', sans-serif;
  font-weight: 500;
  font-size: 0.85rem;
  letter-spacing: 0.05em;
  transition: background 0.2s;
}

.gallery-tab.active {
  background: #90caf9;
  color: #121212;
}

.gallery-tab:hover:not(.active) {
  background: #444;
}

.nsfw-tab.active {
  background: #c46c6c;
  color: #fff;
}

.nsfw-tab:not(.active) {
  color: #c46c6c;
  border: 1px solid #3a1a1a;
  background: #1e1010;
}

.nsfw-tab:hover:not(.active) {
  background: #2a1212;
}

/* ── Upload composer row ── */
.composer-row {
  display: flex;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.upload-btn {
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
.upload-btn:hover {
  background: #64b5f6;
}

.sign-in-note {
  font-size: 0.85rem;
  color: #666;
}
.sign-in-note a { color: #90caf9; }

.count-label {
  font-size: 0.7rem;
  color: #333;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-bottom: 1rem;
}

.empty-state {
  text-align: center;
  color: #444;
  font-style: italic;
  padding: 3rem 0;
}

/* ── Grid ── */
.gallery-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.gallery-item {
  position: relative;
  aspect-ratio: 1 / 1;
  overflow: hidden;
  border-radius: 8px;
  background: #1a1a1a;
  cursor: pointer;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.5);
  transition: transform 0.25s, box-shadow 0.25s;
}

.gallery-item:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 28px rgba(0, 0, 0, 0.7);
}

.gallery-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transition: transform 0.35s;
}

.gallery-item:hover .gallery-img {
  transform: scale(1.07);
}

.nsfw-badge {
  position: absolute;
  top: 8px;
  left: 8px;
  z-index: 2;
  background: rgba(196, 108, 108, 0.9);
  color: #fff;
  font-size: 0.6rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  padding: 2px 6px;
  border-radius: 4px;
}

.admin-actions {
  position: absolute;
  top: 8px;
  right: 8px;
  z-index: 2;
  display: flex;
  gap: 6px;
}

.admin-btn {
  width: 26px;
  height: 26px;
  border-radius: 6px;
  border: 1px solid rgba(255, 255, 255, 0.15);
  background: rgba(18, 18, 18, 0.8);
  color: #e0e0e0;
  cursor: pointer;
  font-size: 0.8rem;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}
.admin-btn:hover { border-color: #90caf9; color: #90caf9; }
.admin-btn.delete:hover { border-color: #e05252; color: #e05252; }

.gallery-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.88) 0%, rgba(0, 0, 0, 0.1) 50%, transparent 100%);
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 0.8rem 0.9rem;
  opacity: 0;
  transition: opacity 0.2s;
}

.gallery-item:hover .gallery-overlay {
  opacity: 1;
}

.art-title {
  font-family: 'Iosevka Charon', monospace;
  font-size: 0.9rem;
  font-weight: 600;
  color: #fff;
}

.art-artist {
  font-size: 0.7rem;
  color: #90caf9;
  letter-spacing: 0.05em;
  margin-top: 2px;
}

/* ── Upload/edit modal ── */
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
  max-width: 540px;
}

/* ── Lightbox ── */
.lightbox {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.93);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.lb-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
}

.lb-img {
  max-width: 90vw;
  max-height: 70vh;
  object-fit: contain;
  border-radius: 6px;
  box-shadow: 0 8px 50px rgba(0, 0, 0, 0.9);
}

.lb-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  max-width: 480px;
  text-align: center;
}

.lb-title {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1rem;
  font-weight: 600;
  color: #fff;
}

.lb-artist {
  font-size: 0.78rem;
  color: #90caf9;
  letter-spacing: 0.06em;
}

.lb-body {
  font-size: 0.85rem;
  color: #ccc;
  margin: 0.5rem 0 0;
  line-height: 1.6;
}

.lb-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  justify-content: center;
  margin-top: 0.6rem;
}

.tag-chip {
  font-size: 0.72rem;
  padding: 3px 10px;
  border-radius: 12px;
  background: #1a1a1a;
  border: 1px solid #2a2a2a;
  color: #90caf9;
  font-family: 'Jost', sans-serif;
}

.tag-chip.clickable {
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s;
}
.tag-chip.clickable:hover {
  border-color: #90caf9;
  background: rgba(144, 202, 249, 0.1);
}

.tag-chip.nsfw {
  color: #e08a8a;
  border-color: #3a1a1a;
  cursor: default;
}

.lb-actions {
  display: flex;
  gap: 8px;
  margin-top: 0.75rem;
}

.lb-action-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #ccc;
  padding: 0.4rem 0.9rem;
  border-radius: 6px;
  font-size: 0.8rem;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}
.lb-action-btn:hover { border-color: #90caf9; color: #90caf9; }
.lb-action-btn.danger:hover { border-color: #e05252; color: #e05252; }

.lb-close {
  position: absolute;
  top: 1.2rem;
  right: 1.4rem;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #aaa;
  border-radius: 5px;
  width: 36px;
  height: 36px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.15s;
}

.lb-close:hover {
  background: rgba(255, 255, 255, 0.14);
  color: #fff;
}

.lb-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #aaa;
  border-radius: 6px;
  width: 44px;
  height: 60px;
  font-size: 1.8rem;
  cursor: pointer;
  transition: all 0.15s;
  line-height: 1;
}

.lb-nav:hover {
  background: rgba(255, 255, 255, 0.14);
  color: #fff;
}

.lb-prev {
  left: 1rem;
}

.lb-next {
  right: 1rem;
}

.lb-enter-active, .lb-leave-active {
  transition: opacity 0.2s;
}

.lb-enter-from, .lb-leave-to {
  opacity: 0;
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.2s;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

@media (max-width: 600px) {
  .gallery-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .lb-nav {
    display: none;
  }
}

@media (max-width: 380px) {
  .gallery-grid {
    grid-template-columns: 1fr;
  }
}
</style>
