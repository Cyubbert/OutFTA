<template>
  <form class="entry-form" @submit.prevent="handleSubmit">
    <h3>{{ editPage ? 'Edit entry' : 'New entry' }}</h3>

    <label>Title</label>
    <input v-model="form.title" placeholder="e.g. a city, a deity, a character…" required maxlength="120" />

    <label>Show under</label>
    <select v-model="form.parent_slug" :disabled="hasChildren">
      <option :value="null">Its own card</option>
      <option v-for="p in parents" :key="p.slug" :value="p.slug">{{ p.name }}</option>
    </select>
    <p v-if="hasChildren" class="hint">This card has entries under it, so it stays its own card.</p>
    <p v-else class="hint">Under a card, it appears in that card's dropdown.</p>

    <label>Cover image (optional)</label>
    <div class="image-picker" @click="pick('cover')">
      <img v-if="form.cover_image" :src="form.cover_image" class="image-preview" alt="Cover image" />
      <span v-else class="image-placeholder">{{ uploading === 'cover' ? 'Uploading…' : '+ Add cover image' }}</span>
    </div>
    <button v-if="form.cover_image" type="button" class="cancel-btn small" @click="form.cover_image = ''">Remove cover</button>

    <label>Sections</label>
    <div v-for="(section, i) in form.sections" :key="i" class="section-block">
      <input v-model="section.heading" placeholder="Heading (optional), e.g. Ruler" maxlength="120" />
      <textarea v-model="section.text" rows="5" placeholder="Text… Leave a blank line between paragraphs."></textarea>
      <button v-if="form.sections.length > 1" type="button" class="cancel-btn small" @click="form.sections.splice(i, 1)">Remove section</button>
    </div>
    <button type="button" class="cancel-btn small" @click="form.sections.push({ heading: '', text: '' })">+ Add section</button>

    <label>Map image (optional)</label>
    <div class="image-picker" @click="pick('map')">
      <img v-if="form.map_image" :src="form.map_image" class="image-preview" alt="Map image" />
      <span v-else class="image-placeholder">{{ uploading === 'map' ? 'Uploading…' : '+ Add map' }}</span>
    </div>
    <button v-if="form.map_image" type="button" class="cancel-btn small" @click="form.map_image = ''">Remove map</button>

    <input ref="fileEl" type="file" accept="image/*" class="hidden-input" @change="onFile" />

    <div class="form-actions">
      <button type="submit" :disabled="submitting || !!uploading">{{ submitting ? 'Saving…' : (editPage ? 'Save changes' : 'Add entry') }}</button>
      <button type="button" class="cancel-btn" @click="$emit('cancel')">Cancel</button>
    </div>

    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'
import { uploadEntryImage } from '@/lib/uploadEntryImage'

const props = defineProps({
  category: { type: String, required: true },          // 'world' | 'kingdom' | 'npc'
  parentSlug: { type: String, default: null },         // preselected parent when adding
  editPage: { type: Object, default: null }            // full `pages` row when editing
})
const emit = defineEmits(['saved', 'cancel'])

const { user } = useAuth()

const editing = props.editPage
const form = reactive({
  title: editing?.title ?? '',
  parent_slug: editing ? editing.parent_slug : props.parentSlug,
  cover_image: editing?.cover_image ?? '',
  map_image: editing?.map_image?.src ?? '',
  // Stored as { heading, paragraphs[] }; edited as one text box with blank lines between paragraphs.
  sections: editing?.sections?.length
      ? editing.sections.map(sec => ({ heading: sec.heading ?? '', text: (sec.paragraphs ?? []).join('\n\n') }))
      : [{ heading: '', text: '' }]
})

// Top-level cards of this category, for "Show under".
const parents = ref([])
// A card with entries under it can't itself move under another card -- its entries would vanish.
const hasChildren = ref(false)

onMounted(async () => {
  const { data } = await supabase
      .from('pages')
      .select('slug, title')
      .eq('category', props.category)
      .is('parent_slug', null)
      .order('title')
  parents.value = (data ?? [])
      .filter(p => p.slug !== editing?.slug)
      .map(p => ({ slug: p.slug, name: p.title }))

  if (editing) {
    const { count } = await supabase
        .from('pages')
        .select('slug', { count: 'exact', head: true })
        .eq('parent_slug', editing.slug)
    hasChildren.value = count > 0
  }
})

const fileEl = ref(null)
const target = ref(null)
const uploading = ref(null)
const submitting = ref(false)
const errorMsg = ref('')

function pick(which) {
  if (uploading.value) return
  target.value = which
  fileEl.value?.click()
}

async function onFile(e) {
  const file = e.target.files?.[0]
  e.target.value = ''
  if (!file) return

  uploading.value = target.value
  errorMsg.value = ''
  try {
    const url = await uploadEntryImage(file, user.value.id, 'pages')
    if (target.value === 'cover') form.cover_image = url
    else form.map_image = url
  } catch (err) {
    errorMsg.value = err.message
  }
  uploading.value = null
}

function slugify(text) {
  return text
      .normalize('NFKD').replace(/[̀-ͯ]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '') || 'entry'
}

async function handleSubmit() {
  const title = form.title.trim()
  if (!title) return

  submitting.value = true
  errorMsg.value = ''

  const sections = form.sections
      .map(s => ({
        heading: s.heading.trim() || null,
        paragraphs: s.text.split(/\n\s*\n/).map(p => p.trim()).filter(Boolean)
      }))
      .filter(s => s.heading || s.paragraphs.length)

  const payload = {
    category: props.category,
    title,
    cover_image: form.cover_image || null,
    cover_alt: title,
    sections,
    map_image: form.map_image ? { src: form.map_image, alt: `Map of ${title}` } : null,
    parent_slug: form.parent_slug
  }

  // Editing keeps the slug (the page's URL) so existing links keep working.
  if (editing) {
    const { data, error } = await supabase
        .from('pages')
        .update(payload)
        .eq('slug', editing.slug)
        .select()
        .single()
    submitting.value = false
    if (error) errorMsg.value = error.message
    else emit('saved', data)
    return
  }

  // Slugs are the page URL and must be unique; add -2, -3… if the title is taken.
  const base = slugify(title)
  for (let n = 1; n <= 20; n++) {
    const slug = n === 1 ? base : `${base}-${n}`
    const { data, error } = await supabase.from('pages').insert({ ...payload, slug }).select().single()
    if (!error) {
      submitting.value = false
      emit('saved', data)
      return
    }
    if (error.code !== '23505') {
      submitting.value = false
      errorMsg.value = error.message
      return
    }
  }

  submitting.value = false
  errorMsg.value = 'Couldn’t find a free URL for that title. Try a different title.'
}
</script>

<style scoped>
.entry-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
h3 {
  margin: 0 0 0.25rem;
  color: #fff;
}
label {
  font-size: 0.85rem;
  margin-top: 0.6rem;
  color: #ccc;
}
input, textarea, select {
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
select:disabled {
  opacity: 0.6;
}
input:focus, textarea:focus, select:focus {
  border-color: #90caf9;
}
.hint {
  margin: 0;
  font-size: 0.75rem;
  color: #666;
}
.section-block {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  padding: 0.75rem;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  background: #141414;
}
.image-picker {
  cursor: pointer;
  border-radius: 8px;
  border: 1px dashed rgba(144, 202, 249, 0.3);
  background: rgba(144, 202, 249, 0.04);
  min-height: 90px;
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
  max-height: 200px;
  object-fit: cover;
}
.image-placeholder {
  color: #90caf9;
  font-size: 0.85rem;
}
.hidden-input {
  display: none;
}
.form-actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.75rem;
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
