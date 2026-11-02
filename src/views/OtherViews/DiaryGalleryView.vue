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
        <div class="dg-mark" aria-hidden="true">✦</div>
        <h1 class="dg-title">Gallery</h1>

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
@import url('https://fonts.googleapis.com/css2?family=EB+Garamond:ital,wght@0,400;0,500;0,600;1,400;1,500&family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&family=UnifrakturCook:wght@700&display=swap');

/* ───────── Theme: gothic — Quinlan's dark page, Mory's type and ink ───────── */
.dg-root {
  --bg: #141212;
  --text: #e8dcc8;
  --surface: #1c1818;
  --surface-hover: #241d1d;
  --border: #2F2F2F;
  --muted: #9a8878;
  --accent: #8A1424;
  --accent-text: #fff;
  --gold: #b17a2a;
  --gold-faint: rgba(177, 122, 42, 0.35);
  --blackletter: 'UnifrakturCook', serif;
  --title-font: 'Cormorant Garamond', serif;
  --body-font: 'EB Garamond', serif;
}

.dg-root {
  min-height: 100vh;
  width: 100%;
  overflow-x: clip;
  color: var(--text);
  font-family: var(--body-font);
  /* Candlelit vignette: a faint red glow from above, darkness at the edges. */
  background:
      radial-gradient(ellipse 80% 45% at 50% 0%, rgba(138, 20, 36, 0.22), transparent 70%),
      radial-gradient(ellipse at center, transparent 55%, rgba(0, 0, 0, 0.55) 100%),
      var(--bg);
}

.dg-page {
  max-width: 960px;
  margin: 0 auto;
  padding: 3rem 1rem 6rem;
}

/* ───────── Header ───────── */
.dg-header {
  text-align: center;
}

.dg-mark {
  color: var(--accent);
  font-size: 1.4rem;
  line-height: 1;
  margin-bottom: 0.5rem;
}

.dg-title {
  font-family: var(--blackletter);
  font-weight: 700;
  font-size: clamp(3rem, 9vw, 4.6rem);
  line-height: 1.05;
  margin: 0 0 1.75rem;
  color: var(--text);
}

.dg-tabs {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 0.35rem 1.4rem;
  margin-bottom: 1.5rem;
}

.dg-tab {
  padding: 0.3rem 0.1rem;
  border: 0;
  border-bottom: 1px solid transparent;
  background: none;
  color: var(--muted);
  cursor: pointer;
  font-family: var(--title-font);
  font-size: 0.95rem;
  font-weight: 600;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  transition: color 0.2s, border-color 0.2s, text-shadow 0.2s;
}

.dg-tab:hover:not(.active) {
  color: var(--text);
}

.dg-tab.active {
  color: var(--text);
  border-bottom-color: var(--accent);
  text-shadow: 0 0 10px rgba(138, 20, 36, 0.55);
}

.nsfw-tab:not(.active) {
  color: var(--accent);
}

.nsfw-tab.active {
  color: var(--text);
  border-bottom-color: var(--accent);
}

.composer-row {
  display: flex;
  justify-content: center;
  margin-bottom: 2rem;
}

.upload-btn {
  background: rgba(138, 20, 36, 0.18);
  color: var(--text);
  border: 1px solid var(--accent);
  outline: 1px solid var(--gold-faint);
  outline-offset: 3px;
  padding: 0.55rem 1.6rem;
  border-radius: 0;
  font-family: var(--title-font);
  font-size: 0.85rem;
  font-weight: 600;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  cursor: pointer;
  transition: background 0.2s, box-shadow 0.2s;
}

.upload-btn:hover {
  background: rgba(138, 20, 36, 0.4);
  box-shadow: 0 0 18px rgba(138, 20, 36, 0.35);
}

.sign-in-note {
  font-family: var(--title-font);
  font-style: italic;
  font-size: 1rem;
  color: var(--muted);
}

.sign-in-note a {
  color: var(--accent);
}

.empty-state {
  text-align: center;
  font-family: var(--title-font);
  color: var(--muted);
  font-style: italic;
  font-size: 1.1rem;
  padding: 3rem 0;
}

/* ───────── Grid ───────── */
.dg-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14px;
}

.dg-item {
  position: relative;
  aspect-ratio: 1 / 1;
  overflow: hidden;
  border: 1px solid var(--accent);
  background: #0f0d0d;
  cursor: pointer;
  box-shadow: 0 6px 18px rgba(0, 0, 0, 0.6);
  transition: transform 0.25s, box-shadow 0.25s, border-color 0.25s;
}

.dg-item:hover {
  transform: translateY(-4px);
  border-color: var(--accent);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.7), 0 0 22px rgba(138, 20, 36, 0.45);
}

/* Thumbnails fill the tile; the full, uncropped picture shows in the viewer. */
.dg-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transition: transform 0.35s;
}

.dg-item:hover .dg-img {
  transform: scale(1.05);
}

.nsfw-badge {
  position: absolute;
  bottom: 10px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 2;
  background: rgba(20, 8, 8, 0.85);
  border: 1px solid var(--accent);
  color: var(--text);
  font-family: var(--title-font);
  font-size: 0.62rem;
  font-weight: 600;
  letter-spacing: 0.18em;
  padding: 1px 8px;
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
  border-radius: 0;
  border: 1px solid var(--gold-faint);
  background: rgba(15, 13, 13, 0.85);
  color: var(--text);
  cursor: pointer;
  font-size: 0.8rem;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}
.admin-btn:hover { border-color: var(--gold); color: #fff; }
.admin-btn.delete:hover { border-color: #8A1424; color: #8A1424; }

.dg-overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgba(8, 4, 4, 0.92) 0%, rgba(8, 4, 4, 0.15) 50%, transparent 100%);
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  align-items: center;
  text-align: center;
  padding: 1rem 0.9rem;
  opacity: 0;
  transition: opacity 0.25s;
}

.dg-item:hover .dg-overlay {
  opacity: 1;
}

.art-title {
  font-family: var(--title-font);
  font-style: italic;
  font-size: 1.15rem;
  color: #fff;
}

.art-artist {
  font-family: var(--title-font);
  font-size: 0.72rem;
  color: var(--gold);
  letter-spacing: 0.18em;
  text-transform: uppercase;
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
  background: radial-gradient(ellipse at center, rgba(30, 8, 10, 0.93), rgba(5, 2, 2, 0.97));
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  /* Room above for the close button, so a tall picture never sits under it. */
  padding: 4rem 1rem 1.5rem;
}

/* The picture shrinks to whatever room the caption leaves, so the viewer never scrolls. */
.lb-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  width: 100%;
  height: 100%;
  max-width: 90vw;
  min-height: 0;
  overflow: hidden;
}

.lb-img {
  flex: 0 1 auto;
  min-height: 0;
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  border: 1px solid var(--accent);
  outline: 1px solid rgba(138, 20, 36, 0.4);
  outline-offset: 5px;
  box-shadow: 0 8px 50px rgba(0, 0, 0, 0.9), 0 0 40px rgba(138, 20, 36, 0.25);
}

.lb-info {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  max-width: 480px;
  text-align: center;
}

.lb-title {
  font-family: var(--title-font);
  font-style: italic;
  font-size: 1.4rem;
  color: #fff;
}

.lb-artist {
  font-family: var(--title-font);
  font-size: 0.78rem;
  color: var(--gold);
  letter-spacing: 0.18em;
  text-transform: uppercase;
}

.lb-body {
  font-size: 0.88rem;
  color: #ccc;
  margin: 0.5rem 0 0;
  line-height: 1.6;
  max-height: 6.4em;
  overflow-y: auto;
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
  color: var(--text);
  border-color: var(--accent);
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
.lb-action-btn.danger:hover { border-color: #8A1424; color: #8A1424; }

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
  .dg-grid { grid-template-columns: repeat(2, 1fr); gap: 12px; }
  .lb-nav { display: none; }
}

@media (max-width: 380px) {
  .dg-grid { grid-template-columns: 1fr; }
}
</style>
