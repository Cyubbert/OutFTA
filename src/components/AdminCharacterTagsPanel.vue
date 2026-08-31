<template>
  <div class="tags-panel">
    <h3 class="panel-title">Gallery character tags</h3>
    <p class="hint">Choose which account each tag links to when clicked on a gallery picture. Unassigned tags aren't clickable.</p>

    <p v-if="loading" class="status">Loading…</p>
    <p v-else-if="error" class="status error">Couldn't load tag assignments.</p>
    <template v-else>
      <div class="tags-table">
        <div v-for="t in tags" :key="t.tag" class="row">
          <span class="tag-label">#{{ t.tag }}</span>
          <select
              class="assign-select"
              :value="t.user_id ?? ''"
              :disabled="savingTag === t.tag"
              @change="assign(t, $event.target.value || null)"
          >
            <option value="">— Unassigned —</option>
            <option v-for="u in users" :key="u.id" :value="u.id">{{ u.username || '(no username)' }}</option>
          </select>
        </div>
      </div>

      <p v-if="saveError" class="status error">{{ saveError }}</p>
    </template>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'

const tags = ref([])
const users = ref([])
const loading = ref(true)
const error = ref(null)
const savingTag = ref(null)
const saveError = ref('')

onMounted(async () => {
  const [tagsRes, usersRes] = await Promise.all([
    supabase.from('character_tags').select('tag, user_id').order('tag'),
    supabase.from('profiles').select('id, username').order('username', { ascending: true, nullsFirst: false })
  ])

  if (tagsRes.error) error.value = tagsRes.error
  else tags.value = tagsRes.data

  users.value = usersRes.data || []
  loading.value = false
})

async function assign(t, userId) {
  const prev = t.user_id
  t.user_id = userId
  savingTag.value = t.tag
  saveError.value = ''

  const { error: err } = await supabase
      .from('character_tags')
      .update({ user_id: userId })
      .eq('tag', t.tag)

  savingTag.value = null

  if (err) {
    t.user_id = prev
    saveError.value = err.message
  }
}
</script>

<style scoped>
.tags-panel {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-top: 2rem;
}

.panel-title {
  font-size: 1.05rem;
  color: #e0e0e0;
  margin: 0;
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

.tags-table {
  display: flex;
  flex-direction: column;
  border: 1px solid #2a2a2a;
  border-radius: 10px;
  overflow: hidden;
}

.row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  padding: 0.7rem 0.9rem;
  border-bottom: 1px solid #222;
}

.row:last-child {
  border-bottom: none;
}

.tag-label {
  color: #90caf9;
  font-size: 0.9rem;
}

.assign-select {
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  padding: 0.4rem 0.6rem;
  font-size: 0.85rem;
  outline: none;
  max-width: 220px;
}

.assign-select:focus {
  border-color: #90caf9;
}

.assign-select:disabled {
  opacity: 0.6;
}
</style>
