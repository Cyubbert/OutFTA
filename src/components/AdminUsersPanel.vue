<template>
  <div class="users-panel">
    <p v-if="loading" class="status">Loading users…</p>
    <p v-else-if="error" class="status error">Couldn't load users.</p>
    <template v-else>
      <p class="hint">Admins always have full access — permission toggles only apply to regular users.</p>

      <div class="users-table">
        <div class="row header-row">
          <div class="col-user">User</div>
          <div class="col-toggle">Admin</div>
          <div class="col-toggle">View Moryquinau</div>
          <div class="col-toggle">Post in Community</div>
          <div class="col-toggle">Post in Moryquinau</div>
        </div>

        <div v-for="u in users" :key="u.id" class="row">
          <div class="col-user">
            <span class="avatar">
              <img v-if="u.avatar_url" :src="u.avatar_url" alt="" />
              <span v-else class="avatar-placeholder">{{ (u.username || '?')[0]?.toUpperCase() }}</span>
            </span>
            <span class="username">{{ u.username || '(no username)' }}</span>
            <span v-if="u.id === currentUserId" class="you-badge">You</span>
          </div>

          <div class="col-toggle">
            <button
                class="toggle"
                :class="{ on: u.role === 'admin' }"
                :disabled="savingId === u.id || u.id === currentUserId"
                :title="u.id === currentUserId ? 'You can\'t change your own admin status here' : ''"
                @click="toggleRole(u)"
            ><span class="knob" /></button>
          </div>

          <template v-if="u.role !== 'admin'">
            <div class="col-toggle">
              <button
                  class="toggle"
                  :class="{ on: u.can_view_moryquinau }"
                  :disabled="savingId === u.id"
                  @click="toggle(u, 'can_view_moryquinau')"
              ><span class="knob" /></button>
            </div>
            <div class="col-toggle">
              <button
                  class="toggle"
                  :class="{ on: u.can_post_community }"
                  :disabled="savingId === u.id"
                  @click="toggle(u, 'can_post_community')"
              ><span class="knob" /></button>
            </div>
            <div class="col-toggle">
              <button
                  class="toggle"
                  :class="{ on: u.can_post_moryquinau }"
                  :disabled="savingId === u.id"
                  @click="toggle(u, 'can_post_moryquinau')"
              ><span class="knob" /></button>
            </div>
          </template>
          <template v-else>
            <div class="col-toggle admin-dash">—</div>
            <div class="col-toggle admin-dash">—</div>
            <div class="col-toggle admin-dash">—</div>
          </template>
        </div>
      </div>

      <p v-if="saveError" class="status error">{{ saveError }}</p>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'

const { user } = useAuth()
const currentUserId = user.value?.id ?? null

const users = ref([])
const loading = ref(true)
const error = ref(null)
const savingId = ref(null)
const saveError = ref('')

onMounted(async () => {
  const { data, error: err } = await supabase
      .from('profiles')
      .select('id, username, avatar_url, role, can_view_moryquinau, can_post_community, can_post_moryquinau')
      .order('username', { ascending: true, nullsFirst: false })

  if (err) error.value = err
  else users.value = data
  loading.value = false
})

async function toggle(u, field) {
  const next = !u[field]
  const prev = u[field]
  u[field] = next
  savingId.value = u.id
  saveError.value = ''

  const { error: err } = await supabase
      .from('profiles')
      .update({ [field]: next })
      .eq('id', u.id)

  savingId.value = null

  if (err) {
    u[field] = prev
    saveError.value = err.message
  }
}

async function toggleRole(u) {
  if (u.id === currentUserId) return

  const next = u.role === 'admin' ? 'user' : 'admin'
  const verb = next === 'admin' ? 'Promote' : 'Demote'
  if (!confirm(`${verb} ${u.username || '(no username)'} ${next === 'admin' ? 'to admin' : 'to a regular user'}?`)) return

  const prev = u.role
  u.role = next
  savingId.value = u.id
  saveError.value = ''

  const { error: err } = await supabase
      .from('profiles')
      .update({ role: next })
      .eq('id', u.id)

  savingId.value = null

  if (err) {
    u.role = prev
    saveError.value = err.message
  }
}
</script>

<style scoped>
.users-panel {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.status {
  color: #888;
  font-style: italic;
}

.status.error {
  color: #e05252;
  font-style: normal;
}

.hint {
  font-size: 0.8rem;
  color: #666;
  margin: 0;
}

.users-table {
  display: flex;
  flex-direction: column;
  border: 1px solid #2a2a2a;
  border-radius: 10px;
  overflow: hidden;
  overflow-x: auto;
}

.row {
  display: grid;
  grid-template-columns: minmax(150px, 1.4fr) repeat(4, minmax(80px, 1fr));
  gap: 0.6rem;
  align-items: center;
  padding: 0.7rem 0.9rem;
  border-bottom: 1px solid #222;
}

.row:last-child {
  border-bottom: none;
}

.header-row {
  background: #161616;
  font-size: 0.68rem;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: #777;
}

.col-user {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 0;
}

.avatar {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
  background: #1a1a1a;
  border: 1px solid #333;
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  font-family: 'Iosevka Charon', monospace;
  color: #90caf9;
  font-size: 0.7rem;
}

.username {
  color: #e0e0e0;
  font-size: 0.9rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.you-badge {
  font-size: 0.65rem;
  color: #666;
  border: 1px solid #333;
  border-radius: 4px;
  padding: 1px 6px;
  white-space: nowrap;
  flex-shrink: 0;
}

.col-toggle {
  display: flex;
  justify-content: center;
}

.admin-dash {
  color: #444;
}

.toggle {
  position: relative;
  width: 38px;
  height: 22px;
  border-radius: 11px;
  border: 1px solid #333;
  background: #1a1a1a;
  cursor: pointer;
  padding: 0;
  transition: background 0.2s, border-color 0.2s;
  flex-shrink: 0;
}

.toggle:disabled {
  opacity: 0.6;
  cursor: default;
}

.toggle .knob {
  position: absolute;
  top: 2px;
  left: 2px;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #666;
  transition: transform 0.2s, background 0.2s;
}

.toggle.on {
  background: rgba(144, 202, 249, 0.15);
  border-color: #90caf9;
}

.toggle.on .knob {
  transform: translateX(16px);
  background: #90caf9;
}

@media (max-width: 640px) {
  .row {
    grid-template-columns: minmax(120px, 1.3fr) repeat(4, minmax(56px, 1fr));
    gap: 0.35rem;
    padding: 0.6rem;
  }

  .header-row {
    font-size: 0.6rem;
  }

  .username {
    font-size: 0.82rem;
  }
}
</style>
