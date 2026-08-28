<template>
  <article class="post-card">
    <header class="post-header">
      <div class="post-avatar">{{ (post.display_name || '?')[0]?.toUpperCase() }}</div>
      <div class="post-meta">
        <span class="post-author">{{ post.display_name }}</span>
        <span class="post-date">{{ formatDate(post.created_at) }}<template v-if="post.edited_at"> · edited</template></span>
      </div>

      <div v-if="canEditPost" class="post-actions">
        <button class="admin-btn" title="Edit" @click="$emit('edit', post)">✎</button>
        <button class="admin-btn delete" title="Delete" @click="$emit('delete', post)">✕</button>
      </div>
    </header>

    <h3 v-if="post.title" class="post-title">{{ post.title }}</h3>
    <p class="post-body">{{ post.body }}</p>
    <img v-if="post.image_url" :src="post.image_url" class="post-image" :alt="post.title || 'Post image'" />

    <div class="post-footer">
      <button class="comments-toggle" @click="toggleComments">
        💬 {{ comments.length || (commentsLoaded ? 0 : '') }} {{ comments.length === 1 ? 'comment' : 'comments' }}
      </button>
    </div>

    <div v-if="showComments" class="comments-section">
      <p v-if="commentsLoading" class="comments-loading">Loading…</p>

      <div v-else class="comments-list">
        <div v-for="c in comments" :key="c.id" class="comment">
          <div class="comment-avatar">{{ (c.display_name || '?')[0]?.toUpperCase() }}</div>
          <div class="comment-body-wrap">
            <div class="comment-meta">
              <span class="comment-author">{{ c.display_name }}</span>
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
              <button class="mini-btn danger" @click="deleteComment(c)">Delete</button>
            </div>
          </div>
        </div>
        <p v-if="!comments.length" class="no-comments">No comments yet.</p>
      </div>

      <form v-if="user" class="comment-form" @submit.prevent="submitComment">
        <input v-model="newCommentDisplayName" placeholder="Commenting as…" required maxlength="60" class="comment-name-input" />
        <div class="comment-form-row">
          <textarea v-model="newCommentBody" rows="2" placeholder="Add a comment…" required class="comment-text-input"></textarea>
          <button type="submit" :disabled="postingComment">{{ postingComment ? '…' : 'Post' }}</button>
        </div>
        <p v-if="commentError" class="error">{{ commentError }}</p>
      </form>
      <p v-else class="sign-in-note">
        <router-link to="/login">Sign in</router-link> to comment.
      </p>
    </div>
  </article>
</template>

<script setup>
import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'

const props = defineProps({
  post: { type: Object, required: true }
})
defineEmits(['edit', 'delete'])

const { user, isAdmin, profile } = useAuth()

const showComments = ref(false)
const commentsLoaded = ref(false)
const commentsLoading = ref(false)
const comments = ref([])

const newCommentDisplayName = ref(profile.value.username || '')
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
      .from('community_comments')
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
      .from('community_comments')
      .insert({
        post_id: props.post.id,
        user_id: user.value.id,
        display_name: newCommentDisplayName.value.trim(),
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
      .from('community_comments')
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
  if (!confirm('Delete this comment?')) return

  const { error } = await supabase.from('community_comments').delete().eq('id', c.id)
  if (error) {
    alert(error.message)
    return
  }
  comments.value = comments.value.filter(x => x.id !== c.id)
}
</script>

<style scoped>
.post-card {
  background: #181818;
  border: 1px solid #2a2a2a;
  border-radius: 12px;
  padding: 1.1rem 1.25rem;
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
}

.post-header {
  display: flex;
  align-items: center;
  gap: 0.65rem;
}

.post-avatar {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  flex-shrink: 0;
  background: #1a1a1a;
  border: 1px solid #333;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Iosevka Charon', monospace;
  color: #90caf9;
  font-size: 1rem;
}

.post-meta {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.post-author {
  font-weight: 600;
  color: #e0e0e0;
  font-size: 0.92rem;
}

.post-date {
  font-size: 0.72rem;
  color: #666;
}

.post-actions {
  margin-left: auto;
  display: flex;
  gap: 6px;
  flex-shrink: 0;
}

.admin-btn {
  width: 28px;
  height: 28px;
  border-radius: 6px;
  border: 1px solid rgba(255,255,255,0.15);
  background: rgba(18,18,18,0.75);
  color: #e0e0e0;
  cursor: pointer;
  font-size: 0.85rem;
  line-height: 1;
  transition: border-color 0.2s, color 0.2s;
}
.admin-btn:hover { border-color: #90caf9; color: #90caf9; }
.admin-btn.delete:hover { border-color: #e05252; color: #e05252; }

.post-title {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1.1rem;
  color: #fff;
  margin: 0;
}

.post-body {
  white-space: pre-wrap;
  word-break: break-word;
  color: #ccc;
  font-size: 0.92rem;
  line-height: 1.6;
  margin: 0;
}

.post-image {
  width: 100%;
  max-height: 480px;
  object-fit: contain;
  border-radius: 8px;
  background: #0d0d0d;
}

.post-footer {
  border-top: 1px solid #242424;
  padding-top: 0.5rem;
}

.comments-toggle {
  background: none;
  border: none;
  color: #888;
  font-size: 0.8rem;
  cursor: pointer;
  padding: 0;
  transition: color 0.2s;
}
.comments-toggle:hover { color: #90caf9; }

.comments-section {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  padding-top: 0.25rem;
}

.comments-loading, .no-comments {
  color: #555;
  font-size: 0.82rem;
  font-style: italic;
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
}

.comment {
  display: flex;
  gap: 0.5rem;
}

.comment-avatar {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  flex-shrink: 0;
  background: #1a1a1a;
  border: 1px solid #333;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: 'Iosevka Charon', monospace;
  color: #90caf9;
  font-size: 0.7rem;
}

.comment-body-wrap {
  flex: 1;
  min-width: 0;
  background: #141414;
  border: 1px solid #242424;
  border-radius: 8px;
  padding: 0.5rem 0.7rem;
}

.comment-meta {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.comment-author {
  font-weight: 600;
  font-size: 0.8rem;
  color: #e0e0e0;
}

.comment-date {
  font-size: 0.68rem;
  color: #666;
}

.comment-text {
  margin: 0.2rem 0 0;
  font-size: 0.85rem;
  color: #bbb;
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
  color: #666;
  font-size: 0.72rem;
  cursor: pointer;
  padding: 0;
  transition: color 0.2s;
}
.mini-btn:hover { color: #90caf9; }
.mini-btn.danger:hover { color: #e05252; }
.mini-btn.cancel:hover { color: #aaa; }

.comment-edit-input {
  width: 100%;
  margin-top: 0.3rem;
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  padding: 0.4rem 0.6rem;
  font-size: 0.85rem;
  font-family: inherit;
  outline: none;
  resize: vertical;
}
.comment-edit-input:focus { border-color: #90caf9; }

.comment-edit-actions {
  display: flex;
  gap: 8px;
  margin-top: 0.3rem;
}

.comment-form {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  border-top: 1px solid #242424;
  padding-top: 0.6rem;
}

.comment-name-input {
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  padding: 0.4rem 0.65rem;
  font-size: 0.8rem;
  outline: none;
  max-width: 220px;
}
.comment-name-input:focus { border-color: #90caf9; }

.comment-form-row {
  display: flex;
  gap: 0.5rem;
  align-items: flex-start;
}

.comment-text-input {
  flex: 1;
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  padding: 0.5rem 0.7rem;
  font-size: 0.85rem;
  font-family: inherit;
  outline: none;
  resize: vertical;
}
.comment-text-input:focus { border-color: #90caf9; }

.comment-form-row button {
  background: #90caf9;
  color: #121212;
  border: none;
  padding: 0.5rem 0.9rem;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
  flex-shrink: 0;
}
.comment-form-row button:hover:not(:disabled) { background: #64b5f6; }
.comment-form-row button:disabled { opacity: 0.6; cursor: default; }

.sign-in-note {
  font-size: 0.8rem;
  color: #666;
  border-top: 1px solid #242424;
  padding-top: 0.6rem;
  margin: 0;
}
.sign-in-note a { color: #90caf9; }

.error {
  color: #e05252;
  font-size: 0.8rem;
  margin: 0;
}
</style>
