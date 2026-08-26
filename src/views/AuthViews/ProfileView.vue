<template>
  <article class="page sans container">
    <div v-if="loading" class="page-loading">Loading…</div>

    <div v-else-if="!user" class="auth-card">
      <h1 class="page-title">Profile</h1>
      <p>Sign in to view your profile and character sheets.</p>
      <LoginForm />
    </div>

    <template v-else>
      <div class="banner-wrap" @click="triggerBannerPick">
        <img v-if="profile.banner_url" :src="profile.banner_url" class="banner-img" alt="Profile banner" />
        <span v-else class="banner-placeholder">+ Add banner</span>
        <div v-if="profile.banner_url || uploadingBanner" class="banner-overlay" :class="{ visible: uploadingBanner }">{{ uploadingBanner ? 'Uploading…' : 'Change banner' }}</div>
      </div>
      <input ref="bannerInputEl" type="file" accept="image/*" class="hidden-input" @change="onBannerChange" />
      <p v-if="bannerError" class="error">{{ bannerError }}</p>

      <header class="profile-header">
        <div class="avatar-wrap" @click="triggerAvatarPick">
          <img v-if="profile.avatar_url" :src="profile.avatar_url" class="avatar-img" alt="Profile picture" />
          <div v-else class="avatar-placeholder">{{ avatarInitial }}</div>
          <div class="avatar-overlay">{{ uploadingAvatar ? 'Uploading…' : 'Change' }}</div>
        </div>
        <input ref="avatarInputEl" type="file" accept="image/*" class="hidden-input" @change="onAvatarChange" />

        <div class="profile-info">
          <div v-if="editingUsername" class="username-row">
            <input v-model="usernameInput" placeholder="Username" class="username-input" @keyup.enter="saveUsername" />
            <button class="save-btn" :disabled="savingUsername" @click="saveUsername">
              {{ savingUsername ? 'Saving…' : 'Save' }}
            </button>
            <button class="cancel-btn" @click="cancelEditUsername">Cancel</button>
          </div>
          <div v-else class="username-row">
            <span class="username-display">{{ profile.username || 'No username set' }}</span>
            <button class="edit-btn" title="Edit username" @click="startEditUsername">✎</button>
          </div>
          <p class="profile-email">{{ user.email }}</p>
          <p v-if="usernameMsg" class="username-msg" :class="{ error: usernameError }">{{ usernameMsg }}</p>
          <p v-if="avatarError" class="error">{{ avatarError }}</p>
        </div>

        <button class="signout-button" @click="signOut">Sign out</button>
      </header>

      <h3 class="collection-title">Character Sheets</h3>

      <p v-if="sheetsLoading" class="page-loading">Loading…</p>
      <div v-else class="cards-container">
        <button class="card create-card" @click="startCreate">
          <span class="create-plus">+</span>
          <span class="create-label">New character sheet</span>
        </button>

        <div
            v-for="sheet in sheets"
            :key="sheet.id"
            class="card sheet-card"
            @click="startView(sheet)"
        >
          <img v-if="sheet.image" :src="sheet.image" :alt="sheet.name" />
          <div class="sheet-text">
            <div class="card-name">{{ sheet.name }}</div>
            <div class="sheet-meta">Level {{ sheet.level ?? '?' }} {{ sheet.race }} {{ sheet.class }}</div>
          </div>

          <div class="admin-actions">
            <button class="admin-btn" title="Edit" @click.stop="startEdit(sheet)">✎</button>
            <button class="admin-btn delete" title="Delete" @click.stop="deleteSheet(sheet)">✕</button>
          </div>
        </div>
      </div>

      <h3 class="collection-title">Gallery</h3>

      <p v-if="galleryLoading" class="page-loading">Loading…</p>
      <div v-else class="cards-container">
        <button class="card create-card" :disabled="uploadingGalleryImage" @click="triggerGalleryImagePick">
          <span class="create-plus">+</span>
          <span class="create-label">{{ uploadingGalleryImage ? 'Uploading…' : 'Add picture' }}</span>
        </button>
        <input ref="galleryImageInputEl" type="file" accept="image/*" class="hidden-input" @change="onGalleryImageChange" />

        <div
            v-for="img in galleryImages"
            :key="img.id"
            class="card gallery-card"
            @click="openImage(img)"
        >
          <img :src="img.image_url" :alt="img.caption || 'Gallery image'" />
          <div v-if="img.caption" class="sheet-text">
            <div class="card-name">{{ img.caption }}</div>
          </div>

          <div class="admin-actions">
            <button class="admin-btn delete" title="Delete" @click.stop="deleteImage(img)">✕</button>
          </div>
        </div>
      </div>
      <p v-if="galleryError" class="error">{{ galleryError }}</p>
    </template>

    <div v-if="creating || editing" class="modal-backdrop" @click.self="closeModal">
      <div class="modal-panel">
        <CharacterSheetForm :edit-sheet="editing" @saved="onSaved" @cancel="closeModal" />
      </div>
    </div>

    <div v-if="viewing" class="modal-backdrop" @click.self="closeModal">
      <div class="modal-panel">
        <CharacterSheetDetail :sheet="viewing" @close="closeModal" />
      </div>
    </div>

    <div v-if="viewingImage" class="modal-backdrop" @click.self="closeImageView">
      <div class="modal-panel gallery-viewer">
        <img :src="viewingImage.image_url" :alt="viewingImage.caption || 'Gallery image'" class="gallery-full-img" />

        <label>Caption</label>
        <div class="username-row">
          <input v-model="viewingCaptionInput" placeholder="Add a caption…" class="caption-input" @keyup.enter="saveCaption" />
          <button class="save-btn" :disabled="savingCaption" @click="saveCaption">
            {{ savingCaption ? 'Saving…' : 'Save' }}
          </button>
        </div>

        <div class="form-actions">
          <button class="cancel-btn danger" @click="deleteImage(viewingImage)">Delete picture</button>
          <button class="cancel-btn" @click="closeImageView">Close</button>
        </div>
      </div>
    </div>
  </article>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useAuth } from '@/composables/useAuth'
import { supabase } from '@/lib/supabase'
import LoginForm from '@/components/LoginForm.vue'
import CharacterSheetForm from '@/components/CharacterSheetForm.vue'
import CharacterSheetDetail from '@/components/CharacterSheetDetail.vue'

const { user, loading, profile, signOut } = useAuth()

const usernameInput = ref('')
const editingUsername = ref(false)
const savingUsername = ref(false)
const usernameMsg = ref('')
const usernameError = ref(false)

const avatarInputEl = ref(null)
const uploadingAvatar = ref(false)
const avatarError = ref('')

const bannerInputEl = ref(null)
const uploadingBanner = ref(false)
const bannerError = ref('')

const sheets = ref([])
const sheetsLoading = ref(true)
const creating = ref(false)
const editing = ref(null)
const viewing = ref(null)

const galleryImages = ref([])
const galleryLoading = ref(true)
const galleryImageInputEl = ref(null)
const uploadingGalleryImage = ref(false)
const galleryError = ref('')

const viewingImage = ref(null)
const viewingCaptionInput = ref('')
const savingCaption = ref(false)

const avatarInitial = computed(() => (profile.value.username || user.value?.email || '?')[0]?.toUpperCase())

watch(profile, (p) => {
  usernameInput.value = p.username
}, { immediate: true })

watch(user, async (u) => {
  if (!u) {
    sheets.value = []
    galleryImages.value = []
    return
  }

  sheetsLoading.value = true
  galleryLoading.value = true

  const [{ data: s }, { data: g }] = await Promise.all([
    supabase.from('character_sheets').select('*').eq('user_id', u.id).order('created_at'),
    supabase.from('profile_gallery_images').select('*').eq('user_id', u.id).order('created_at')
  ])

  sheets.value = s || []
  sheetsLoading.value = false

  galleryImages.value = g || []
  galleryLoading.value = false
}, { immediate: true })

function startEditUsername() {
  usernameMsg.value = ''
  usernameError.value = false
  editingUsername.value = true
}

function cancelEditUsername() {
  usernameInput.value = profile.value.username
  usernameMsg.value = ''
  usernameError.value = false
  editingUsername.value = false
}

async function saveUsername() {
  savingUsername.value = true
  usernameMsg.value = ''
  usernameError.value = false

  const { error } = await supabase
      .from('profiles')
      .update({ username: usernameInput.value.trim() || null })
      .eq('id', user.value.id)

  savingUsername.value = false

  if (error) {
    usernameError.value = true
    usernameMsg.value = error.code === '23505'
        ? 'That username is already taken.'
        : error.message
    return
  }

  profile.value = { ...profile.value, username: usernameInput.value.trim() }
  editingUsername.value = false
}

function triggerAvatarPick() {
  avatarInputEl.value?.click()
}

async function onAvatarChange(e) {
  const file = e.target.files?.[0]
  if (!file) return

  uploadingAvatar.value = true
  avatarError.value = ''

  const ext = file.name.split('.').pop()
  const path = `avatars/${user.value.id}/avatar.${ext}`

  const { error: uploadError } = await supabase.storage.from('images').upload(path, file, { upsert: true })

  if (uploadError) {
    avatarError.value = uploadError.message
    uploadingAvatar.value = false
    e.target.value = ''
    return
  }

  const { data: pub } = supabase.storage.from('images').getPublicUrl(path)
  const url = `${pub.publicUrl}?t=${Date.now()}`

  const { error: dbError } = await supabase.from('profiles').update({ avatar_url: url }).eq('id', user.value.id)

  uploadingAvatar.value = false
  e.target.value = ''

  if (dbError) {
    avatarError.value = dbError.message
    return
  }

  profile.value = { ...profile.value, avatar_url: url }
}

function triggerBannerPick() {
  bannerInputEl.value?.click()
}

async function onBannerChange(e) {
  const file = e.target.files?.[0]
  if (!file) return

  uploadingBanner.value = true
  bannerError.value = ''

  const ext = file.name.split('.').pop()
  const path = `banners/${user.value.id}/banner.${ext}`

  const { error: uploadError } = await supabase.storage.from('images').upload(path, file, { upsert: true })

  if (uploadError) {
    bannerError.value = uploadError.message
    uploadingBanner.value = false
    e.target.value = ''
    return
  }

  const { data: pub } = supabase.storage.from('images').getPublicUrl(path)
  const url = `${pub.publicUrl}?t=${Date.now()}`

  const { error: dbError } = await supabase.from('profiles').update({ banner_url: url }).eq('id', user.value.id)

  uploadingBanner.value = false
  e.target.value = ''

  if (dbError) {
    bannerError.value = dbError.message
    return
  }

  profile.value = { ...profile.value, banner_url: url }
}

function startCreate() {
  creating.value = true
}

function startEdit(sheet) {
  editing.value = sheet
}

function startView(sheet) {
  viewing.value = sheet
}

function closeModal() {
  creating.value = false
  editing.value = null
  viewing.value = null
}

function onSaved(record) {
  if (editing.value) {
    const idx = sheets.value.findIndex(s => s.id === editing.value.id)
    if (idx !== -1) sheets.value[idx] = { ...sheets.value[idx], ...record }
  } else {
    sheets.value.push(record)
  }
  closeModal()
}

async function deleteSheet(sheet) {
  if (!confirm(`Delete "${sheet.name}"? This can't be undone.`)) return

  const { error } = await supabase.from('character_sheets').delete().eq('id', sheet.id)
  if (error) {
    alert(error.message)
    return
  }
  sheets.value = sheets.value.filter(s => s.id !== sheet.id)
}

function triggerGalleryImagePick() {
  galleryImageInputEl.value?.click()
}

async function onGalleryImageChange(e) {
  const file = e.target.files?.[0]
  if (!file) return

  uploadingGalleryImage.value = true
  galleryError.value = ''

  const ext = file.name.split('.').pop()
  const path = `gallery/${user.value.id}/${Date.now()}.${ext}`

  const { error: uploadError } = await supabase.storage.from('images').upload(path, file)

  if (uploadError) {
    galleryError.value = uploadError.message
    uploadingGalleryImage.value = false
    e.target.value = ''
    return
  }

  const { data: pub } = supabase.storage.from('images').getPublicUrl(path)

  const { data, error: dbError } = await supabase
      .from('profile_gallery_images')
      .insert({ user_id: user.value.id, image_url: pub.publicUrl })
      .select()
      .single()

  uploadingGalleryImage.value = false
  e.target.value = ''

  if (dbError) {
    galleryError.value = dbError.message
    return
  }

  galleryImages.value.push(data)
}

function openImage(img) {
  viewingImage.value = img
  viewingCaptionInput.value = img.caption || ''
}

function closeImageView() {
  viewingImage.value = null
}

async function saveCaption() {
  savingCaption.value = true

  const caption = viewingCaptionInput.value.trim() || null

  const { error } = await supabase
      .from('profile_gallery_images')
      .update({ caption })
      .eq('id', viewingImage.value.id)

  savingCaption.value = false

  if (error) {
    galleryError.value = error.message
    return
  }

  viewingImage.value = { ...viewingImage.value, caption }
  const idx = galleryImages.value.findIndex(i => i.id === viewingImage.value.id)
  if (idx !== -1) galleryImages.value[idx] = { ...galleryImages.value[idx], caption }
}

async function deleteImage(img) {
  if (!confirm('Delete this picture? This can\'t be undone.')) return

  const { error } = await supabase.from('profile_gallery_images').delete().eq('id', img.id)
  if (error) {
    alert(error.message)
    return
  }
  galleryImages.value = galleryImages.value.filter(i => i.id !== img.id)
  if (viewingImage.value?.id === img.id) viewingImage.value = null
}
</script>

<style scoped>
.auth-card {
  max-width: 340px;
  margin: 2rem auto 0;
  text-align: center;
}

.banner-wrap {
  position: relative;
  width: 100%;
  height: 180px;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;
  margin-top: 1.5rem;
  background: #1a1a1a;
  border: 1px dashed rgba(144, 202, 249, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
}

.banner-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.banner-placeholder {
  color: #90caf9;
  font-size: 0.9rem;
}

.banner-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.55);
  color: #fff;
  font-size: 0.75rem;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  opacity: 0;
  transition: opacity 0.2s;
}

.banner-wrap:hover .banner-overlay,
.banner-overlay.visible {
  opacity: 1;
}

.profile-header {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  margin: 1.5rem 0 2rem;
  flex-wrap: wrap;
}

.avatar-wrap {
  position: relative;
  width: 84px;
  height: 84px;
  border-radius: 50%;
  overflow: hidden;
  cursor: pointer;
  flex-shrink: 0;
  background: #1a1a1a;
  border: 1px solid #333;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  font-family: 'Iosevka Charon', monospace;
  color: #90caf9;
}

.avatar-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.55);
  color: #fff;
  font-size: 0.7rem;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  opacity: 0;
  transition: opacity 0.2s;
}

.avatar-wrap:hover .avatar-overlay {
  opacity: 1;
}

.hidden-input {
  display: none;
}

.profile-info {
  flex: 1;
  min-width: 200px;
}

.username-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.username-display {
  font-size: 1.1rem;
  font-weight: 500;
  color: #e0e0e0;
}

.edit-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #888;
  width: 26px;
  height: 26px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}

.edit-btn:hover {
  border-color: #90caf9;
  color: #90caf9;
}

.username-input {
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  padding: 0.45rem 0.75rem;
  font-size: 0.95rem;
  outline: none;
  max-width: 220px;
}

.username-input:focus {
  border-color: #90caf9;
}

.save-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #e0e0e0;
  padding: 0.45rem 0.9rem;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}

.save-btn:hover {
  border-color: #90caf9;
  color: #90caf9;
}

.cancel-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #888;
  padding: 0.45rem 0.9rem;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}

.profile-email {
  font-size: 0.8rem;
  color: #888;
  margin: 0.4rem 0 0;
}

.username-msg {
  font-size: 0.8rem;
  color: #4caf50;
  margin: 0.3rem 0 0;
}

.error {
  color: #e05252;
  font-size: 0.8rem;
  margin: 0.3rem 0 0;
}

.signout-button {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #e0e0e0;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
  flex-shrink: 0;
}

.signout-button:hover {
  border-color: #90caf9;
  color: #90caf9;
}

.create-card {
  height: 200px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 6px;
  background: rgba(144, 202, 249, 0.04);
  border: 1px dashed rgba(144, 202, 249, 0.3);
  color: #90caf9;
  font-family: inherit;
  transition: background 0.2s, border-color 0.2s;
}

.create-card:hover {
  background: rgba(144, 202, 249, 0.08);
  border-color: #90caf9;
  transform: none;
}

.create-plus {
  font-size: 1.8rem;
  line-height: 1;
}

.create-label {
  font-size: 0.85rem;
  letter-spacing: 0.04em;
}

.sheet-card {
  position: relative;
  height: 200px;
  width: 100%;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 0;
  overflow: hidden;
  cursor: pointer;
}

.sheet-card img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.sheet-text {
  position: relative;
  z-index: 2;
  padding: 0.75rem 1rem 0.85rem;
  background: linear-gradient(to top, rgba(0,0,0,0.92) 0%, rgba(0,0,0,0.5) 60%, transparent 100%);
}

.sheet-card .card-name,
.gallery-card .card-name {
  position: relative;
  bottom: auto;
  left: auto;
  right: auto;
}

.sheet-meta {
  font-size: 0.7rem;
  color: rgba(255,255,255,0.6);
  margin-top: 2px;
}

.gallery-card {
  position: relative;
  height: 200px;
  width: 100%;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 0;
  overflow: hidden;
  cursor: pointer;
}

.gallery-card img {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.create-card:disabled {
  cursor: default;
  opacity: 0.6;
}

.admin-actions {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 3;
  display: flex;
  gap: 6px;
}

.admin-btn {
  width: 28px;
  height: 28px;
  border-radius: 6px;
  border: 1px solid rgba(255,255,255,0.15);
  background: rgba(18,18,18,0.75);
  backdrop-filter: blur(4px);
  color: #e0e0e0;
  cursor: pointer;
  font-size: 0.85rem;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}

.admin-btn:hover {
  border-color: #90caf9;
  color: #90caf9;
}

.admin-btn.delete:hover {
  border-color: #e05252;
  color: #e05252;
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
  max-width: 600px;
}

.gallery-viewer label {
  font-size: 0.85rem;
  margin-top: 0.5rem;
  display: block;
}

.gallery-full-img {
  width: 100%;
  max-height: 60vh;
  object-fit: contain;
  border-radius: 8px;
  background: #0d0d0d;
}

.caption-input {
  flex: 1;
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  padding: 0.45rem 0.75rem;
  font-size: 0.95rem;
  outline: none;
}

.caption-input:focus {
  border-color: #90caf9;
}

.form-actions {
  display: flex;
  justify-content: space-between;
  gap: 0.5rem;
  margin-top: 1.25rem;
}

.cancel-btn.danger:hover {
  border-color: #e05252;
  color: #e05252;
}
</style>
