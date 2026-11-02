<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useAuth } from '@/composables/useAuth'
import DiaryNav from '@/components/DiaryNav.vue'
import GalleryUploadForm from '@/components/GalleryUploadForm.vue'

const { user, isAdmin, profile } = useAuth()

const TABLE = 'diary_gallery_images'
const FILTER_TAGS = ['mory', 'quinlan', 'other']
const TAG_OPTIONS = [
  { value: 'nsfw' },
  { value: 'mory' },
  { value: 'quinlan' },
  { value: 'other' },
]

// Shared by both diaries: Quinlan's dark page with Mory's type and red ink.
const PAGE_BG = '#191919'
const PAGE_FG = '#e8dcc8'

const images = ref([])
const galleryLoading = ref(true)
const galleryError = ref(null)

const filterTag = ref('all')
const lightbox = ref(null)
const creating = ref(false)
const editing = ref(null)

const canPost = computed(() => !!user.value && (isAdmin.value || profile.value.can_post_diary_gallery))
const canViewNsfw = computed(() => !!user.value && (isAdmin.value || profile.value.can_view_diary_nsfw))

function isNsfw(img) {
  return !!img.tags?.includes('nsfw')
}

// NSFW art only ever shows under its own tab, never mixed into the others.
const filtered = computed(() => {
  if (filterTag.value === 'nsfw') return images.value.filter(isNsfw)
  const sfw = images.value.filter(img => !isNsfw(img))
  return filterTag.value === 'all' ? sfw : sfw.filter(img => img.tags?.includes(filterTag.value))
})

// Losing the permission (e.g. signing out) drops you back to the public art.
watch(canViewNsfw, ok => {
  if (!ok && filterTag.value === 'nsfw') filterTag.value = 'all'
})

function canEdit(img) {
  return user.value && (user.value.id === img.user_id || isAdmin.value)
}

function tagLabel(tag) {
  if (tag === 'nsfw') return 'NSFW'
  return tag.charAt(0).toUpperCase() + tag.slice(1)
}

function applyPageStyles() {
  document.body.style.backgroundColor = PAGE_BG
  document.body.style.color = PAGE_FG
  document.body.style.maxWidth = '100%'
  document.body.style.margin = '0'
  document.body.style.padding = '0'
  const navbar = document.querySelector('.navbar')
  if (navbar) navbar.style.display = 'none'
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
      .from(TABLE)
      .select('*')
      .order('created_at', { ascending: false })

  if (error) galleryError.value = error
  else images.value = data
  galleryLoading.value = false
}

// nsfw rows only come back for permitted users, so refetch when sign-in state changes.
watch(canViewNsfw, loadGallery)

function startCreate() {
  creating.value = true
}

function startEdit(img) {
  closeLightbox()
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

  const { error } = await supabase.from(TABLE).delete().eq('id', img.id)
  if (error) {
    alert(error.message)
    return
  }
  images.value = images.value.filter(i => i.id !== img.id)
  if (lightbox.value?.id === img.id) closeLightbox()
}

onMounted(() => {
  applyPageStyles()
  window.addEventListener('keydown', onKey)
  loadGallery()
})

onUnmounted(() => {
  window.removeEventListener('keydown', onKey)
  document.body.style.backgroundColor = ''
  document.body.style.color = ''
  document.body.style.maxWidth = ''
  document.body.style.margin = ''
  document.body.style.padding = ''
  document.body.style.overflow = ''
  const navbar = document.querySelector('.navbar')
  if (navbar) navbar.style.display = ''
})
</script>

<template>
  <div class="dg-root">
    <DiaryNav active="gallery" />

    <section class="dg-page">
      <header class="dg-header">
        <h1 class="dg-title">Gallery</h1>
        <p class="dg-subtitle">Art of Mory &amp; Quinlan</p>

        <div class="dg-tabs">
          <button class="dg-tab" :class="{ active: filterTag === 'all' }" @click="filterTag = 'all'">All</button>
          <button
              v-for="tag in FILTER_TAGS"
              :key="tag"
              class="dg-tab"
              :class="{ active: filterTag === tag }"
              @click="filterTag = tag"
          >{{ tagLabel(tag) }}</button>
          <button
              v-if="canViewNsfw"
              class="dg-tab nsfw-tab"
              :class="{ active: filterTag === 'nsfw' }"
              @click="filterTag = 'nsfw'"
          >NSFW</button>
        </div>

        <div class="composer-row">
          <button v-if="canPost" class="upload-btn" @click="startCreate">+ Upload picture</button>
          <p v-else-if="user" class="sign-in-note">Your account isn't permitted to upload here.</p>
          <p v-else class="sign-in-note"><router-link to="/login">Sign in</router-link> to upload.</p>
        </div>
      </header>

      <p v-if="galleryLoading" class="empty-state">Loading…</p>
      <p v-else-if="galleryError" class="empty-state">Couldn't load the gallery.</p>
      <template v-else>
        <p class="count-label">{{ filtered.length }} work{{ filtered.length !== 1 ? 's' : '' }}</p>
        <div v-if="!filtered.length" class="empty-state">No pictures yet.</div>

        <transition-group name="fade" tag="div" class="dg-grid">
          <div v-for="img in filtered" :key="img.id" class="dg-item" @click="openLightbox(img)">
            <img :src="img.image_url" :alt="img.title || 'Gallery image'" class="dg-img" />
            <span v-if="isNsfw(img)" class="nsfw-badge">NSFW</span>

            <div v-if="canEdit(img)" class="admin-actions">
              <button class="admin-btn" title="Edit" @click.stop="startEdit(img)">✎</button>
              <button class="admin-btn delete" title="Delete" @click.stop="deleteImage(img)">✕</button>
            </div>

            <div class="dg-overlay">
              <span v-if="img.title" class="art-title">{{ img.title }}</span>
              <span class="art-artist">by {{ img.display_name }}</span>
            </div>
          </div>
        </transition-group>
      </template>
    </section>

    <!-- Upload / edit modal -->
    <div v-if="creating || editing" class="modal-backdrop">
      <div class="modal-panel">
        <GalleryUploadForm
            :edit-post="editing"
            :table="TABLE"
            storage-folder="diary-gallery"
            :tag-options="TAG_OPTIONS"
            @saved="onSaved"
            @cancel="closeModal"
        />
      </div>
    </div>

    <!-- Lightbox -->
    <transition name="lb">
      <div class="lightbox" v-if="lightbox">
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
              <span
                  v-for="tag in lightbox.tags"
                  :key="tag"
                  class="tag-chip"
                  :class="{ nsfw: tag === 'nsfw' }"
              >#{{ tag }}</span>
            </div>

            <div v-if="canEdit(lightbox)" class="lb-actions">
              <button class="lb-action-btn" @click="startEdit(lightbox)">Edit</button>
              <button class="lb-action-btn danger" @click="deleteImage(lightbox)">Delete</button>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;0,500;0,600;1,400;1,500&family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&display=swap');

/* ───────── Theme: Quinlan's dark page, Mory's type and ink ───────── */
.dg-root {
  --bg: #191919;
  --text: #e8dcc8;
  --surface: #202020;
  --surface-hover: #262626;
  --border: #2F2F2F;
  --muted: #9a8878;
  --accent: #c0392b;
  --accent-text: #fff;
  --title-font: 'Cormorant Garamond', serif;
  --title-weight: 300;
  --title-style: italic;
  --body-font: 'EB Garamond', serif;
}

.dg-root {
  min-height: 100vh;
  width: 100vw;
  margin-left: calc(-50vw + 50%);
  background: var(--bg);
  color: var(--text);
  font-family: var(--body-font);
}

.dg-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 3rem 1rem 6rem;
}

/* ───────── Header ───────── */
.dg-header {
  text-align: center;
}

.dg-title {
  font-family: var(--title-font);
  font-weight: var(--title-weight);
  font-style: var(--title-style);
  font-size: 3rem;
  margin: 0 0 0.25rem;
  letter-spacing: 0.04em;
}

.dg-subtitle {
  font-size: 0.78rem;
  text-transform: uppercase;
  letter-spacing: 0.25em;
  color: var(--muted);
  margin: 0 0 1.5rem;
}

.dg-tabs {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 8px;
  margin-bottom: 1rem;
}

.dg-tab {
  padding: 0.45rem 1.2rem;
  border: 1px solid var(--border);
  border-radius: 6px;
  background: var(--surface);
  color: var(--text);
  cursor: pointer;
  font-family: inherit;
  font-size: 0.85rem;
  letter-spacing: 0.05em;
  transition: background 0.2s, border-color 0.2s;
}

.dg-tab:hover:not(.active) {
  background: var(--surface-hover);
}

.dg-tab.active {
  background: var(--accent);
  border-color: var(--accent);
  color: var(--accent-text);
}

.nsfw-tab:not(.active) {
  color: #c46c6c;
  border-color: rgba(196, 108, 108, 0.45);
}

.nsfw-tab.active {
  background: #c46c6c;
  border-color: #c46c6c;
}

.composer-row {
  display: flex;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.upload-btn {
  background: var(--accent);
  color: var(--accent-text);
  border: none;
  padding: 0.6rem 1.4rem;
  border-radius: 6px;
  font-family: inherit;
  font-size: 0.9rem;
  cursor: pointer;
  transition: filter 0.2s;
}

.upload-btn:hover {
  filter: brightness(1.12);
}

.sign-in-note {
  font-size: 0.85rem;
  color: var(--muted);
}

.sign-in-note a {
  color: var(--accent);
}

.count-label {
  font-size: 0.7rem;
  color: var(--muted);
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-bottom: 1rem;
}

.empty-state {
  text-align: center;
  color: var(--muted);
  font-style: italic;
  padding: 3rem 0;
}

/* ───────── Grid ───────── */
.dg-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.dg-item {
  position: relative;
  aspect-ratio: 1 / 1;
  overflow: hidden;
  border-radius: 6px;
  border: 1px solid var(--border);
  background: var(--surface);
  cursor: pointer;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.15);
  transition: transform 0.25s, box-shadow 0.25s;
}

.dg-item:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 28px rgba(0, 0, 0, 0.3);
}

.dg-img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  display: block;
  transition: transform 0.35s;
}

.dg-item:hover .dg-img {
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
.admin-btn:hover { border-color: #e0e0e0; color: #fff; }
.admin-btn.delete:hover { border-color: #e05252; color: #e05252; }

.dg-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.85) 0%, rgba(0, 0, 0, 0.1) 50%, transparent 100%);
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 0.8rem 0.9rem;
  opacity: 0;
  transition: opacity 0.2s;
}

.dg-item:hover .dg-overlay {
  opacity: 1;
}

.art-title {
  font-family: var(--title-font);
  font-size: 1rem;
  color: #fff;
}

.art-artist {
  font-size: 0.72rem;
  color: #d8cfc2;
  letter-spacing: 0.05em;
  margin-top: 2px;
}

/* ───────── Upload / edit modal ───────── */
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
  background: var(--bg);
  color: var(--text);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 1.5rem;
  width: 100%;
  max-width: 540px;
}

/* GalleryUploadForm is styled for the dark main gallery; re-skin it to the diary theme. */
.modal-panel :deep(input),
.modal-panel :deep(textarea) {
  background: var(--surface);
  border-color: var(--border);
  color: var(--text);
}
.modal-panel :deep(input:focus),
.modal-panel :deep(textarea:focus) {
  border-color: var(--accent);
}
.modal-panel :deep(.image-picker) {
  border-color: var(--border);
  background: var(--surface);
}
.modal-panel :deep(.image-picker:hover) {
  border-color: var(--accent);
  background: var(--surface-hover);
}
.modal-panel :deep(.image-placeholder) {
  color: var(--accent);
}
.modal-panel :deep(.tag-check) {
  color: var(--text);
}
.modal-panel :deep(.tag-check input) {
  accent-color: var(--accent);
}
.modal-panel :deep(button[type="submit"]) {
  background: var(--accent);
  color: var(--accent-text);
}
.modal-panel :deep(button[type="submit"]:hover:not(:disabled)) {
  background: var(--accent);
  filter: brightness(1.12);
}
.modal-panel :deep(.cancel-btn) {
  border-color: var(--border);
  color: var(--muted);
}
.modal-panel :deep(.cancel-btn:hover) {
  border-color: var(--accent);
  color: var(--accent);
}

/* ───────── Lightbox ───────── */
.lightbox {
  position: fixed;
  inset: 0;
  background: rgba(10, 5, 0, 0.93);
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
  border-radius: 4px;
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
  font-family: var(--title-font);
  font-size: 1.2rem;
  color: #fff;
}

.lb-artist {
  font-size: 0.8rem;
  color: #d8cfc2;
  letter-spacing: 0.06em;
}

.lb-body {
  font-size: 0.88rem;
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
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: #d8cfc2;
}

.tag-chip.nsfw {
  color: #e08a8a;
  border-color: #3a1a1a;
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
  font-family: inherit;
  font-size: 0.8rem;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}
.lb-action-btn:hover { border-color: #fff; color: #fff; }
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

.lb-prev { left: 1rem; }
.lb-next { right: 1rem; }

.lb-enter-active, .lb-leave-active { transition: opacity 0.2s; }
.lb-enter-from, .lb-leave-to { opacity: 0; }

.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

@media (max-width: 600px) {
  .dg-title { font-size: 2.4rem; }
  .dg-grid { grid-template-columns: repeat(2, 1fr); }
  .lb-nav { display: none; }
}

@media (max-width: 380px) {
  .dg-grid { grid-template-columns: 1fr; }
}
</style>
