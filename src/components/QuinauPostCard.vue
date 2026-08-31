<template>
  <article class="post-card">
    <header class="post-header">
      <span class="post-sigil">†</span>
      <span class="post-date">{{ formatDate(post.created_at) }}<template v-if="post.edited_at"> · edited</template></span>

      <div v-if="canEditPost" class="post-actions">
        <button class="admin-btn" title="Edit" @click="$emit('edit', post)">✎</button>
        <button class="admin-btn delete" title="Erase" @click="$emit('delete', post)">✕</button>
      </div>
    </header>

    <p class="post-body">{{ post.body }}</p>

    <div class="post-footer">
      <button class="comments-toggle" @click="toggleComments">
        {{ comments.length || (commentsLoaded ? 0 : '') }} {{ comments.length === 1 ? 'reply' : 'replies' }}
      </button>
    </div>

    <div v-if="showComments" class="comments-section">
      <p v-if="commentsLoading" class="comments-loading">Loading…</p>

      <div v-else class="comments-list">
        <div v-for="c in comments" :key="c.id" class="comment">
          <span class="comment-sigil">✦</span>
          <div class="comment-body-wrap">
            <div class="comment-meta">
              <span class="comment-date">{{ formatDate(c.created_at) }}<template v-if="c.edited_at"> · edited</template></span>
            </div>

            <template v-if="editingCommentId === c.id">
              <textarea v-model="editCommentBody" rows="2" class="comment-edit-input"></textarea>
              <div class="comment-edit-actions">
                <button class="mini-btn" :disabled="savingComment" @click="saveEditComment(c)">Save</button>
                <button class="mini-btn cancel" @click="cancelEditComment">Cancel</button>
              </div>
            </template>
            <p v-else class="comment-text">{{ c.body }}</p>

            <div v-if="editingCommentId !== c.id && canEditComment(c)" class="comment-actions">
              <button class="mini-btn" @click="startEditComment(c)">Edit</button>
              <button class="mini-btn danger" @click="deleteComment(c)">Erase</button>
            </div>
          </div>
        </div>
        <p v-if="!comments.length" class="no-comments">Nothing said yet.</p>
      </div>

      <form v-if="canWrite" class="comment-form" @submit.prevent="submitComment">
        <div class="comment-form-row">
          <textarea v-model="newCommentBody" rows="2" placeholder="Leave a reply, unsigned…" required class="comment-text-input"></textarea>
          <button type="submit" :disabled="postingComment">{{ postingComment ? '…' : 'Reply' }}</button>
        </div>
        <p v-if="commentError" class="error">{{ commentError }}</p>
      </form>
    </div>
  </article>
</template>

<script setup>
import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'

const props = defineProps({
  post: { type: Object, required: true },
  canWrite: { type: Boolean, default: false }
})
defineEmits(['edit', 'delete'])

const { user, isAdmin } = useAuth()

const showComments = ref(false)
const commentsLoaded = ref(false)
const commentsLoading = ref(false)
const comments = ref([])

const newCommentBody = ref('')
const postingComment = ref(false)
const commentError = ref('')

const editingCommentId = ref(null)
const editCommentBody = ref('')
const savingComment = ref(false)

const canEditPost = computed(() => user.value && (user.value.id === props.post.user_id || isAdmin.value))

function canEditComment(c) {
  return user.value && (user.value.id === c.user_id || isAdmin.value)
}

function formatDate(iso) {
  return new Date(iso).toLocaleString(undefined, {
    month: 'short', day: 'numeric', year: 'numeric', hour: 'numeric', minute: '2-digit'
  })
}

async function toggleComments() {
  showComments.value = !showComments.value
  if (showComments.value && !commentsLoaded.value) {
    await loadComments()
  }
}

async function loadComments() {
  commentsLoading.value = true
  const { data, error } = await supabase
      .from('mory_quinau_comments')
      .select('*')
      .eq('post_id', props.post.id)
      .order('created_at', { ascending: true })

  if (!error) comments.value = data
  commentsLoaded.value = true
  commentsLoading.value = false
}

async function submitComment() {
  postingComment.value = true
  commentError.value = ''

  const { data, error } = await supabase
      .from('mory_quinau_comments')
      .insert({
        post_id: props.post.id,
        user_id: user.value.id,
        body: newCommentBody.value.trim()
      })
      .select()
      .single()

  postingComment.value = false

  if (error) {
    commentError.value = error.message
    return
  }

  comments.value.push(data)
  commentsLoaded.value = true
  newCommentBody.value = ''
}

function startEditComment(c) {
  editingCommentId.value = c.id
  editCommentBody.value = c.body
}

function cancelEditComment() {
  editingCommentId.value = null
  editCommentBody.value = ''
}

async function saveEditComment(c) {
  savingComment.value = true

  const { data, error } = await supabase
      .from('mory_quinau_comments')
      .update({ body: editCommentBody.value.trim(), edited_at: new Date().toISOString() })
      .eq('id', c.id)
      .select()
      .single()

  savingComment.value = false

  if (error) {
    commentError.value = error.message
    return
  }

  const idx = comments.value.findIndex(x => x.id === c.id)
  if (idx !== -1) comments.value[idx] = data
  editingCommentId.value = null
}

async function deleteComment(c) {
  if (!confirm('Erase this reply?')) return

  const { error } = await supabase.from('mory_quinau_comments').delete().eq('id', c.id)
  if (error) {
    alert(error.message)
    return
  }
  comments.value = comments.value.filter(x => x.id !== c.id)
}
</script>

<style scoped>
.post-card {
  background: #100b09;
  border: 1px solid rgba(139, 26, 26, 0.22);
  border-radius: 6px;
  padding: 1.2rem 1.35rem;
  display: flex;
  flex-direction: column;
  gap: 0.7rem;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.35);
}

.post-header {
  display: flex;
  align-items: center;
  gap: 0.6rem;
}

.post-sigil {
  color: #8b1a1a;
  font-size: 1rem;
  flex-shrink: 0;
}

.post-date {
  font-size: 0.72rem;
  color: #6b5f56;
  letter-spacing: 0.04em;
}

.post-actions {
  margin-left: auto;
  display: flex;
  gap: 6px;
  flex-shrink: 0;
}

.admin-btn {
  width: 26px;
  height: 26px;
  border-radius: 4px;
  border: 1px solid rgba(139, 26, 26, 0.3);
  background: rgba(7, 5, 4, 0.6);
  color: #a89686;
  cursor: pointer;
  font-size: 0.8rem;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}
.admin-btn:hover { border-color: #3f7d4f; color: #4c9a5f; }
.admin-btn.delete:hover { border-color: #8b1a1a; color: #e05252; }

.post-body {
  white-space: pre-wrap;
  word-break: break-word;
  color: #cfc3b8;
  font-size: 1rem;
  line-height: 1.75;
  margin: 0;
  font-family: 'EB Garamond', serif;
}

.post-footer {
  border-top: 1px solid rgba(139, 26, 26, 0.15);
  padding-top: 0.5rem;
}

.comments-toggle {
  background: none;
  border: none;
  color: #3f7d4f;
  font-size: 0.78rem;
  letter-spacing: 0.04em;
  cursor: pointer;
  padding: 0;
  transition: color 0.2s;
}
.comments-toggle:hover { color: #4c9a5f; }

.comments-section {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  padding-top: 0.25rem;
}

.comments-loading, .no-comments {
  color: #6b5f56;
  font-size: 0.82rem;
  font-style: italic;
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 0.55rem;
}

.comment {
  display: flex;
  gap: 0.5rem;
}

.comment-sigil {
  color: #3f7d4f;
  font-size: 0.75rem;
  flex-shrink: 0;
  padding-top: 0.6rem;
}

.comment-body-wrap {
  flex: 1;
  min-width: 0;
  background: #0b0807;
  border: 1px solid rgba(139, 26, 26, 0.15);
  border-radius: 6px;
  padding: 0.5rem 0.7rem;
}

.comment-meta {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
}

.comment-date {
  font-size: 0.68rem;
  color: #6b5f56;
}

.comment-text {
  margin: 0.2rem 0 0;
  font-size: 0.88rem;
  color: #b8ab9d;
  white-space: pre-wrap;
  word-break: break-word;
}

.comment-actions {
  display: flex;
  gap: 8px;
  margin-top: 0.3rem;
}

.mini-btn {
  background: none;
  border: none;
  color: #6b5f56;
  font-size: 0.72rem;
  cursor: pointer;
  padding: 0;
  transition: color 0.2s;
}
.mini-btn:hover { color: #4c9a5f; }
.mini-btn.danger:hover { color: #e05252; }
.mini-btn.cancel:hover { color: #a89686; }

.comment-edit-input {
  width: 100%;
  margin-top: 0.3rem;
  background: #100b09;
  border: 1px solid rgba(139, 26, 26, 0.3);
  border-radius: 6px;
  color: #cfc3b8;
  padding: 0.4rem 0.6rem;
  font-size: 0.85rem;
  font-family: inherit;
  outline: none;
  resize: vertical;
}
.comment-edit-input:focus { border-color: #3f7d4f; }

.comment-edit-actions {
  display: flex;
  gap: 8px;
  margin-top: 0.3rem;
}

.comment-form {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  border-top: 1px solid rgba(139, 26, 26, 0.15);
  padding-top: 0.6rem;
}

.comment-form-row {
  display: flex;
  gap: 0.5rem;
  align-items: flex-start;
}

.comment-text-input {
  flex: 1;
  background: #0b0807;
  border: 1px solid rgba(139, 26, 26, 0.25);
  border-radius: 6px;
  color: #cfc3b8;
  padding: 0.5rem 0.7rem;
  font-size: 0.88rem;
  font-family: inherit;
  outline: none;
  resize: vertical;
}
.comment-text-input:focus { border-color: #3f7d4f; }

.comment-form-row button {
  background: transparent;
  border: 1px solid rgba(63, 125, 79, 0.5);
  color: #4c9a5f;
  padding: 0.5rem 0.9rem;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s, border-color 0.2s;
  flex-shrink: 0;
}
.comment-form-row button:hover:not(:disabled) { background: rgba(63, 125, 79, 0.12); border-color: #4c9a5f; }
.comment-form-row button:disabled { opacity: 0.6; cursor: default; }

.error {
  color: #e05252;
  font-size: 0.8rem;
  margin: 0;
}
</style>
