<template>
  <article class="page sans container">
    <div v-if="loading" class="page-loading">Loading…</div>

    <div v-else-if="!user" class="auth-card">
      <h1 class="page-title">Profile</h1>
      <p>Sign in to view your profile and character sheets.</p>
      <LoginForm />
    </div>

    <template v-else>
      <header class="profile-header">
        <div class="avatar-wrap" @click="triggerAvatarPick">
          <img v-if="profile.avatar_url" :src="profile.avatar_url" class="avatar-img" alt="Profile picture" />
          <div v-else class="avatar-placeholder">{{ avatarInitial }}</div>
          <div class="avatar-overlay">{{ uploadingAvatar ? 'Uploading…' : 'Change' }}</div>
        </div>
        <input ref="avatarInputEl" type="file" accept="image/*" class="hidden-input" @change="onAvatarChange" />

        <div class="profile-info">
          <div class="username-row">
            <input v-model="usernameInput" placeholder="Username" class="username-input" />
            <button class="save-btn" :disabled="savingUsername" @click="saveUsername">
              {{ savingUsername ? 'Saving…' : 'Save' }}
            </button>
          </div>
          <p class="profile-email">{{ user.email }}</p>
          <p v-if="usernameMsg" class="username-msg">{{ usernameMsg }}</p>
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
  </article>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { useAuth } from '@/composables/useAuth'
import { supabase } from '@/lib/supabase'
import LoginForm from '@/components/LoginForm.vue'
import CharacterSheetForm from '@/components/CharacterSheetForm.vue'
import CharacterSheetDetail from '@/components/CharacterSheetDetail.vue'

const { user, loading, signOut } = useAuth()

const profile = reactive({ username: '', avatar_url: '' })
const usernameInput = ref('')
const savingUsername = ref(false)
const usernameMsg = ref('')

const avatarInputEl = ref(null)
const uploadingAvatar = ref(false)
const avatarError = ref('')

const sheets = ref([])
const sheetsLoading = ref(true)
const creating = ref(false)
const editing = ref(null)
const viewing = ref(null)

const avatarInitial = computed(() => (profile.username || user.value?.email || '?')[0]?.toUpperCase())

watch(user, async (u) => {
  if (!u) {
    profile.username = ''
    profile.avatar_url = ''
    sheets.value = []
    return
  }

  sheetsLoading.value = true

  const [{ data: p }, { data: s }] = await Promise.all([
    supabase.from('profiles').select('username, avatar_url').eq('id', u.id).single(),
    supabase.from('character_sheets').select('*').eq('user_id', u.id).order('created_at')
  ])

  profile.username = p?.username || ''
  profile.avatar_url = p?.avatar_url || ''
  usernameInput.value = profile.username
  sheets.value = s || []
  sheetsLoading.value = false
}, { immediate: true })

async function saveUsername() {
  savingUsername.value = true
  usernameMsg.value = ''

  const { error } = await supabase
      .from('profiles')
      .update({ username: usernameInput.value.trim() || null })
      .eq('id', user.value.id)

  savingUsername.value = false

  if (error) {
    usernameMsg.value = error.message
    return
  }

  profile.username = usernameInput.value.trim()
  usernameMsg.value = 'Saved.'
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

  profile.avatar_url = url
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
</script>

<style scoped>
.auth-card {
  max-width: 340px;
  margin: 2rem auto 0;
  text-align: center;
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
  gap: 0.5rem;
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

.sheet-card .card-name {
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
</style>
