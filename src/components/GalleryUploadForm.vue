<template>
  <form class="entry-form" @submit.prevent="handleSubmit">
    <h3>{{ editPost ? 'Edit picture' : 'Upload a picture' }}</h3>

    <label>Posting as</label>
    <input v-model="form.display_name" placeholder="Display name…" required maxlength="60" />

    <label>Title (optional)</label>
    <input v-model="form.title" placeholder="Title…" maxlength="140" />

    <label>Description (optional)</label>
    <textarea v-model="form.body" rows="3" placeholder="Say something about it…"></textarea>

    <label>Picture</label>
    <div class="image-picker" @click="triggerImagePick">
      <img v-if="form.image_url" :src="form.image_url" class="image-preview" alt="Gallery image" />
      <span v-else class="image-placeholder">{{ uploadingImage ? 'Uploading…' : '+ Add picture' }}</span>
    </div>
    <input ref="imageInputEl" type="file" accept="image/*" class="hidden-input" @change="onImageChange" />
    <button v-if="form.image_url" type="button" class="cancel-btn small" @click="form.image_url = ''">Remove picture</button>

    <label>Tags</label>
    <div class="tag-checks">
      <label v-for="tag in TAG_OPTIONS" :key="tag.value" class="tag-check">
        <input type="checkbox" :value="tag.value" v-model="form.tags" />
        <span :class="{ nsfw: tag.value === 'nsfw' }">#{{ tag.value }}</span>
      </label>
    </div>

    <div class="form-actions">
      <button type="submit" :disabled="submitting || uploadingImage">
        {{ submitting ? 'Saving…' : (editPost ? 'Update picture' : 'Upload') }}
      </button>
      <button type="button" class="cancel-btn" @click="$emit('cancel')">Cancel</button>
    </div>

    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'

const TAG_OPTIONS = [
  { value: 'nsfw' },
  { value: 'waesstan' },
  { value: 'marvers' },
  { value: 'ray' },
]

const props = defineProps({
  editPost: { type: Object, default: null }
})
const emit = defineEmits(['saved', 'cancel'])

const { user, profile } = useAuth()

const form = reactive({
  display_name: props.editPost?.display_name ?? profile.value.username ?? '',
  title: props.editPost?.title ?? '',
  body: props.editPost?.body ?? '',
  image_url: props.editPost?.image_url ?? '',
  tags: props.editPost?.tags ? [...props.editPost.tags] : []
})

const imageInputEl = ref(null)
const uploadingImage = ref(false)
const submitting = ref(false)
const errorMsg = ref('')

function triggerImagePick() {
  if (uploadingImage.value) return
  imageInputEl.value?.click()
}

async function onImageChange(e) {
  const file = e.target.files?.[0]
  if (!file) return

  uploadingImage.value = true
  errorMsg.value = ''

  const ext = file.name.split('.').pop()
  const path = `gallery-posts/${user.value.id}/${Date.now()}.${ext}`

  const { error: uploadError } = await supabase.storage.from('images').upload(path, file)

  uploadingImage.value = false
  e.target.value = ''

  if (uploadError) {
    errorMsg.value = uploadError.message
    return
  }

  const { data: pub } = supabase.storage.from('images').getPublicUrl(path)
  form.image_url = pub.publicUrl
}

async function handleSubmit() {
  if (!form.image_url) {
    errorMsg.value = 'Add a picture first.'
    return
  }

  submitting.value = true
  errorMsg.value = ''

  const payload = {
    display_name: form.display_name.trim(),
    title: form.title.trim() || null,
    body: form.body.trim() || null,
    image_url: form.image_url,
    tags: form.tags
  }

  if (props.editPost) {
    const { data, error } = await supabase
        .from('gallery_images')
        .update({ ...payload, edited_at: new Date().toISOString() })
        .eq('id', props.editPost.id)
        .select()
        .single()

    submitting.value = false

    if (error) {
      errorMsg.value = error.message
      return
    }

    emit('saved', data)
    return
  }

  const { data, error } = await supabase
      .from('gallery_images')
      .insert({ ...payload, user_id: user.value.id })
      .select()
      .single()

  submitting.value = false

  if (error) {
    errorMsg.value = error.message
    return
  }

  emit('saved', data)
}
</script>

<style scoped>
.entry-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-width: 500px;
}
label {
  font-size: 0.85rem;
  margin-top: 0.5rem;
}
input, textarea {
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  padding: 0.55rem 0.75rem;
  font-size: 0.95rem;
  font-family: inherit;
  outline: none;
  resize: vertical;
}
input:focus, textarea:focus {
  border-color: #90caf9;
}
.image-picker {
  cursor: pointer;
  border-radius: 8px;
  border: 1px dashed rgba(144, 202, 249, 0.3);
  background: rgba(144, 202, 249, 0.04);
  min-height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  transition: background 0.2s, border-color 0.2s;
}
.image-picker:hover {
  background: rgba(144, 202, 249, 0.08);
  border-color: #90caf9;
}
.image-preview {
  width: 100%;
  max-height: 260px;
  object-fit: contain;
}
.image-placeholder {
  color: #90caf9;
  font-size: 0.85rem;
}
.hidden-input {
  display: none;
}
.tag-checks {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}
.tag-check {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  font-size: 0.88rem;
  color: #ccc;
  cursor: pointer;
}
.tag-check input {
  width: auto;
  padding: 0;
  accent-color: #90caf9;
}
.tag-check .nsfw {
  color: #e08a8a;
}
.form-actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.5rem;
}
.cancel-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #888;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}
.cancel-btn:hover {
  border-color: #90caf9;
  color: #90caf9;
}
.cancel-btn.small {
  align-self: flex-start;
  padding: 0.3rem 0.7rem;
  font-size: 0.78rem;
}
button[type="submit"] {
  background: #90caf9;
  color: #121212;
  border: none;
  padding: 0.55rem 1.2rem;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}
button[type="submit"]:hover:not(:disabled) {
  background: #64b5f6;
}
button[type="submit"]:disabled {
  opacity: 0.6;
  cursor: default;
}
.error {
  color: #e05252;
  font-size: 0.85rem;
}
</style>
