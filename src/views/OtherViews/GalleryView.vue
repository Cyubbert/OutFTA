<script setup>
import {ref, computed, onMounted, onUnmounted} from 'vue'
import { supabase } from '@/lib/supabase.js'

const galleryLoading = ref(true)
const galleryError = ref(null)
const SFW_ARTWORKS = ref([])
const NSFW_ARTWORKS = ref([])

const NSFW_PASSWORD = "pig"

const activeTab = ref('sfw')
const activeArtist = ref('All')
const lightbox = ref(null)
const nsfwUnlocked = ref(false)
const passwordInput = ref('')
const passwordError = ref(false)
const showPasswordModal = ref(false)

const currentArtworks = computed(() =>
    activeTab.value === 'nsfw' && nsfwUnlocked.value ? NSFW_ARTWORKS.value : SFW_ARTWORKS.value
)

const artists = computed(() => {
  const a = [...new Set(currentArtworks.value.map(art => art.artist))]
  return ['All', ...a]
})

const filtered = computed(() =>
    currentArtworks.value.filter(a =>
        activeArtist.value === 'All' || a.artist === activeArtist.value
    )
)

function switchTab(tab) {
  if (tab === 'nsfw' && !nsfwUnlocked.value) {
    showPasswordModal.value = true
    return
  }
  activeTab.value = tab
  activeArtist.value = 'All'
}

function submitPassword() {
  if (passwordInput.value === NSFW_PASSWORD) {
    nsfwUnlocked.value = true
    showPasswordModal.value = false
    activeTab.value = 'nsfw'
    activeArtist.value = 'All'
    passwordInput.value = ''
    passwordError.value = false
  } else {
    passwordError.value = true
    passwordInput.value = ''
  }
}

function closeModal() {
  showPasswordModal.value = false
  passwordInput.value = ''
  passwordError.value = false
}

function openLightbox(art) {
  lightbox.value = art
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
  if (showPasswordModal.value && e.key === 'Enter') {
    submitPassword();
    return
  }
  if (showPasswordModal.value && e.key === 'Escape') {
    closeModal();
    return
  }
  if (!lightbox.value) return
  if (e.key === 'Escape') closeLightbox()
  if (e.key === 'ArrowLeft') prev()
  if (e.key === 'ArrowRight') next()
}

async function loadGallery() {
  const { data, error } = await supabase
      .from('gallery_images')
      .select('id, title, artist, image_path, description, is_nsfw')
      .order('sort_order', { ascending: true })

  if (error) {
    galleryError.value = error
  } else {
    const toArt = (row) => ({
      id: row.id,
      title: row.title,
      artist: row.artist,
      img: row.image_path,
      description: row.description,
    })
    SFW_ARTWORKS.value = data.filter((row) => !row.is_nsfw).map(toArt)
    NSFW_ARTWORKS.value = data.filter((row) => row.is_nsfw).map(toArt)
  }
  galleryLoading.value = false
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

      <!-- SFW / NSFW tabs -->
      <div class="gallery-tabs">
        <button
            class="gallery-tab"
            :class="{ active: activeTab === 'sfw' }"
            @click="switchTab('sfw')"
        >Art
        </button>
        <button
            class="gallery-tab nsfw-tab"
            :class="{ active: activeTab === 'nsfw' }"
            @click="switchTab('nsfw')"
        >
          <span v-if="!nsfwUnlocked">🔒 </span>NSFW
        </button>
      </div>

      <!-- Artist filter -->
      <div class="artist-filters">
        <button
            v-for="artist in artists"
            :key="artist"
            class="artist-btn"
            :class="{ active: activeArtist === artist }"
            @click="activeArtist = artist"
        >{{ artist }}
        </button>
      </div>
    </header>

    <div class="page-body">
      <p v-if="galleryLoading" class="empty-state">Loading…</p>
      <p v-else-if="galleryError" class="empty-state">Couldn't load the gallery.</p>
      <template v-else>
        <p class="count-label">{{ filtered.length }} work{{ filtered.length !== 1 ? 's' : '' }}</p>
        <div v-if="!filtered.length" class="empty-state">No artworks found.</div>

        <transition-group name="fade" tag="div" class="gallery-grid">
          <div
              v-for="art in filtered"
              :key="art.id"
              class="gallery-item"
              @click="openLightbox(art)"
          >
            <img :src="art.img" :alt="art.title" class="gallery-img"/>
            <div class="gallery-overlay">
              <span class="art-title">{{ art.title }}</span>
              <span class="art-artist">by {{ art.artist }}</span>
            </div>
          </div>
        </transition-group>
      </template>
    </div>

    <!-- Password modal -->
    <transition name="lb">
      <div class="lightbox" v-if="showPasswordModal" @click.self="closeModal">
        <div class="password-modal">
          <h2 class="modal-title">NSFW Gallery</h2>
          <p class="modal-desc">This section contains mature content. Enter the password to continue.</p>
          <input
              class="password-input"
              type="password"
              v-model="passwordInput"
              placeholder="Password..."
              autofocus
          />
          <p class="password-error" v-if="passwordError">Wrong password. Try again.</p>
          <div class="modal-buttons">
            <button class="modal-btn cancel" @click="closeModal">Cancel</button>
            <button class="modal-btn confirm" @click="submitPassword">Enter</button>
          </div>
        </div>
      </div>
    </transition>

    <!-- Lightbox -->
    <transition name="lb">
      <div class="lightbox" v-if="lightbox" @click.self="closeLightbox">
        <button class="lb-close" @click="closeLightbox">✕</button>
        <button class="lb-nav lb-prev" @click="prev" v-if="filtered.length > 1">‹</button>
        <button class="lb-nav lb-next" @click="next" v-if="filtered.length > 1">›</button>
        <div class="lb-content">
          <img :src="lightbox.img" :alt="lightbox.title" class="lb-img"/>
          <div class="lb-info">
            <span class="lb-title">{{ lightbox.title }}</span>
            <span class="lb-artist">by {{ lightbox.artist }}</span>
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

/* ── Gallery tabs ── */
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

/* ── Artist filters ── */
.artist-filters {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.artist-btn {
  font-size: 0.72rem;
  padding: 4px 12px;
  border-radius: 6px;
  background: #1a1a1a;
  border: 1px solid #2a2a2a;
  color: #555;
  cursor: pointer;
  transition: all 0.15s;
  font-family: 'Jost', sans-serif;
}

.artist-btn:hover {
  border-color: #444;
  color: #aaa;
}

.artist-btn.active {
  background: #90caf9;
  border-color: #90caf9;
  color: #121212;
  font-weight: 600;
}

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

/* ── Password modal ── */
.password-modal {
  background: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 12px;
  padding: 2rem;
  width: 100%;
  max-width: 380px;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.modal-title {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1.3rem;
  color: #fff;
  margin: 0;
}

.modal-desc {
  font-size: 0.85rem;
  color: #666;
  margin: 0;
  line-height: 1.6;
}

.password-input {
  background: #121212;
  border: 1px solid #2a2a2a;
  border-radius: 6px;
  color: #e0e0e0;
  font-family: 'Jost', sans-serif;
  font-size: 0.95rem;
  padding: 0.6rem 0.9rem;
  outline: none;
  transition: border-color 0.2s;
}

.password-input:focus {
  border-color: #90caf9;
}

.password-error {
  font-size: 0.78rem;
  color: #ef9a9a;
  margin: -0.5rem 0 0;
}

.modal-buttons {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
}

.modal-btn {
  padding: 0.5rem 1.2rem;
  border-radius: 6px;
  border: none;
  font-family: 'Jost', sans-serif;
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.15s;
}

.modal-btn.cancel {
  background: #2a2a2a;
  color: #888;
}

.modal-btn.cancel:hover {
  background: #333;
  color: #aaa;
}

.modal-btn.confirm {
  background: #90caf9;
  color: #121212;
}

.modal-btn.confirm:hover {
  background: #64b5f6;
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
}

.lb-img {
  max-width: 90vw;
  max-height: 80vh;
  object-fit: contain;
  border-radius: 6px;
  box-shadow: 0 8px 50px rgba(0, 0, 0, 0.9);
}

.lb-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
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