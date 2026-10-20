<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabase.js'
import { useAuth } from '@/composables/useAuth'

const { user, isAdmin, profile, loading: authLoading } = useAuth()

const PAGE_BG = '#0c0405'
const PAGE_FG = '#d9d4c7'
const FLIP_MS = 900

onMounted(() => {
  document.body.style.backgroundColor = PAGE_BG
  document.body.style.color = PAGE_FG
  document.body.style.maxWidth = '100%'
  document.body.style.margin = '0'
  document.body.style.padding = '0'
  const navbar = document.querySelector('.navbar')
  if (navbar) navbar.style.display = 'none'
  window.addEventListener('keydown', onKey)
})

onUnmounted(() => {
  document.body.style.backgroundColor = ''
  document.body.style.color = ''
  document.body.style.maxWidth = ''
  document.body.style.margin = ''
  document.body.style.padding = ''
  const navbar = document.querySelector('.navbar')
  if (navbar) navbar.style.display = ''
  window.removeEventListener('keydown', onKey)
})

// Same gate as /moryquinau: signed in AND (admin or the admin-granted flag).
// RLS on notebook_pages and the private `notebook` bucket enforces it too
// (create-star-notebook.sql), so this is only about what to render.
const canView = computed(() => !!user.value && (isAdmin.value || profile.value.can_view_notebook))
const showGate = computed(() => !authLoading.value && !canView.value)

// ── Pages ──

const pages = ref([])
const pagesLoaded = ref(false)
const loading = ref(true)
const error = ref(null)

async function loadPages() {
  loading.value = true
  error.value = null

  const { data, error: err } = await supabase
      .from('notebook_pages')
      .select('*')
      .order('position', { ascending: true })
      .order('created_at', { ascending: true })

  if (err) {
    error.value = err
    loading.value = false
    return
  }

  // The bucket is private -- every image needs a signed URL.
  let urls = {}
  if (data.length) {
    const { data: signed, error: signErr } = await supabase.storage
        .from('notebook')
        .createSignedUrls(data.map(p => p.image_path), 60 * 60)
    if (signErr) {
      error.value = signErr
      loading.value = false
      return
    }
    urls = Object.fromEntries(signed.map(s => [s.path, s.signedUrl]))
  }

  pages.value = data.map(p => ({ ...p, url: urls[p.image_path] }))
  pagesLoaded.value = true
  loading.value = false
}

watch(canView, (v) => {
  if (v && !pagesLoaded.value) loadPages()
}, { immediate: true })

// ── Book layout ──
// The book is a stack of leaves; each leaf has a front (right-hand page
// while unturned) and a back (left-hand page once turned). Sides run:
// cover, inside cover, uploaded pages (padded to an even count), inside
// back cover, back cover.

const sides = computed(() => {
  const list = [{ kind: 'cover' }, { kind: 'endpaper' }]
  pages.value.forEach((p, i) => list.push({ kind: 'page', page: p, num: i + 1 }))
  if (pages.value.length % 2) list.push({ kind: 'blank' })
  list.push({ kind: 'endpaper', end: true }, { kind: 'backcover' })
  return list
})

const leaves = computed(() => {
  const out = []
  for (let i = 0; i < sides.value.length; i += 2) {
    out.push({ front: sides.value[i], back: sides.value[i + 1] })
  }
  return out
})

const current = ref(0) // number of leaves turned
const flipping = ref([]) // leaves mid-turn, kept on top until they land

const isClosed = computed(() => current.value === 0)
const isFinished = computed(() => current.value === leaves.value.length)

watch(leaves, (l) => {
  if (current.value > l.length) current.value = l.length
})

function turnTo(target) {
  const n = leaves.value.length
  target = Math.max(0, Math.min(n, target))
  if (target === current.value) return

  const lo = Math.min(target, current.value)
  const hi = Math.max(target, current.value)
  const moving = []
  for (let i = lo; i < hi; i++) moving.push(i)

  flipping.value = [...flipping.value, ...moving]
  current.value = target
  setTimeout(() => {
    flipping.value = flipping.value.filter(i => !moving.includes(i))
  }, FLIP_MS)
}

const next = () => turnTo(current.value + 1)
const prev = () => turnTo(current.value - 1)

function leafStyle(i) {
  const n = leaves.value.length
  const turned = i < current.value
  let z = turned ? i + 1 : n - i
  if (flipping.value.includes(i)) z = n + 2
  return {
    zIndex: z,
    transform: turned ? 'rotateY(-180deg)' : 'rotateY(0deg)'
  }
}

function onLeafClick(i) {
  if (i < current.value) prev()
  else next()
}

function onKey(e) {
  if (!canView.value || managing.value || zoomed.value) {
    if (e.key === 'Escape') zoomed.value = null
    return
  }
  if (e.key === 'ArrowRight') next()
  else if (e.key === 'ArrowLeft') prev()
}

let touchX = null
function onTouchStart(e) {
  touchX = e.touches[0].clientX
}
function onTouchEnd(e) {
  if (touchX === null) return
  const dx = e.changedTouches[0].clientX - touchX
  touchX = null
  if (Math.abs(dx) < 40) return
  if (dx < 0) next()
  else prev()
}

// The two sides currently lying open (left, right).
const openSides = computed(() => [
  sides.value[2 * current.value - 1],
  sides.value[2 * current.value]
].filter(Boolean))

const pageLabel = computed(() => {
  if (isClosed.value) return 'Closed'
  if (isFinished.value) return 'The end'
  const nums = openSides.value.filter(s => s.kind === 'page').map(s => s.num)
  if (!nums.length) return current.value === 1 ? 'Inside cover' : 'Last page'
  const range = nums.length > 1 ? `${nums[0]}–${nums[nums.length - 1]}` : `${nums[0]}`
  return `Page ${range} of ${pages.value.length}`
})

// ── Zoom ──

const zoomed = ref(null)
const openImages = computed(() => openSides.value.filter(s => s.kind === 'page'))

function openZoom() {
  if (openImages.value.length) zoomed.value = openImages.value
}

// ── Admin: manage pages ──

const managing = ref(false)
const uploading = ref(false)
const manageError = ref('')
const fileInput = ref(null)

async function onFilesPicked(e) {
  const files = [...e.target.files]
  e.target.value = ''
  if (!files.length) return

  uploading.value = true
  manageError.value = ''
  let position = pages.value.reduce((max, p) => Math.max(max, p.position), -1) + 1

  try {
    for (const file of files) {
      if (!file.type.startsWith('image/')) throw new Error(`${file.name} isn’t an image.`)
      if (file.size > 15 * 1024 * 1024) throw new Error(`${file.name} is too large (max 15 MB).`)

      const ext = file.name.split('.').pop()?.toLowerCase() || 'png'
      const path = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}.${ext}`

      const { error: upErr } = await supabase.storage.from('notebook').upload(path, file)
      if (upErr) throw upErr

      const { error: insErr } = await supabase
          .from('notebook_pages')
          .insert({ image_path: path, position: position++ })
      if (insErr) throw insErr
    }
  } catch (err) {
    manageError.value = err.message
  }

  uploading.value = false
  await loadPages()
}

async function movePage(index, dir) {
  const a = pages.value[index]
  const b = pages.value[index + dir]
  if (!a || !b) return
  manageError.value = ''

  // Positions can tie (e.g. equal defaults), so assign by list order.
  const posA = index + dir
  const posB = index
  const [r1, r2] = await Promise.all([
    supabase.from('notebook_pages').update({ position: posA }).eq('id', a.id),
    supabase.from('notebook_pages').update({ position: posB }).eq('id', b.id)
  ])
  if (r1.error || r2.error) {
    manageError.value = (r1.error || r2.error).message
    return
  }

  a.position = posA
  b.position = posB
  const list = [...pages.value]
  list[index] = b
  list[index + dir] = a
  pages.value = list
}

async function deletePage(page) {
  if (!confirm(`Tear out page ${pages.value.indexOf(page) + 1}? This can't be undone.`)) return
  manageError.value = ''

  const { error: err } = await supabase.from('notebook_pages').delete().eq('id', page.id)
  if (err) {
    manageError.value = err.message
    return
  }
  await supabase.storage.from('notebook').remove([page.image_path])
  pages.value = pages.value.filter(p => p.id !== page.id)
}
</script>

<template>
  <div class="notebook-root">
    <div class="sky" aria-hidden="true">
      <div class="stars stars-far" />
      <div class="stars stars-near" />
    </div>

    <div v-if="showGate" class="gate">
      <svg class="gate-star" viewBox="0 0 100 100" aria-hidden="true">
        <path d="M50 0 L57 43 L100 50 L57 57 L50 100 L43 57 L0 50 L43 43 Z" />
      </svg>
      <p class="gate-text">These pages were not meant for you.</p>
      <router-link v-if="!user" to="/login" class="gate-link">Sign in</router-link>
    </div>

    <main v-else class="notebook-page">
      <router-link to="/" class="leave-link">← leave</router-link>

      <header class="page-header">
        <p class="eyebrow">From Misha to Ray</p>
        <h1 class="title">Notebook of the Stars</h1>
      </header>

      <p v-if="loading" class="status">Opening…</p>
      <p v-else-if="error" class="status">You cannot read its contents...</p>

      <template v-else>
        <div
            class="stage"
            @touchstart.passive="onTouchStart"
            @touchend.passive="onTouchEnd"
        >
          <div
              class="book"
              :class="{ closed: isClosed, finished: isFinished }"
          >
            <div
                v-for="(leaf, i) in leaves"
                :key="i"
                class="leaf"
                :style="leafStyle(i)"
                @click="onLeafClick(i)"
            >
              <div
                  v-for="face in ['front', 'back']"
                  :key="face"
                  class="face"
                  :class="[face, leaf[face].kind, { end: leaf[face].end }]"
              >
                <!-- Front cover -->
                <template v-if="leaf[face].kind === 'cover'">
                  <div class="cover-frame">
                    <svg class="constellation" viewBox="0 0 200 200" aria-hidden="true">
                      <g class="lines">
                        <polyline points="30,52 62,38 96,60 128,44 168,70" />
                        <polyline points="96,60 100,100" />
                        <polyline points="44,150 74,132 100,100 132,138 160,150" />
                      </g>
                      <g class="dots">
                        <circle cx="30" cy="52" r="2.2" />
                        <circle cx="62" cy="38" r="1.6" />
                        <circle cx="96" cy="60" r="2.6" />
                        <circle cx="128" cy="44" r="1.8" />
                        <circle cx="168" cy="70" r="2.2" />
                        <circle cx="44" cy="150" r="1.8" />
                        <circle cx="74" cy="132" r="2.2" />
                        <circle cx="132" cy="138" r="1.6" />
                        <circle cx="160" cy="150" r="2.4" />
                      </g>
                      <path class="north-star" d="M100 78 L104 96 L122 100 L104 104 L100 122 L96 104 L78 100 L96 96 Z" />
                    </svg>
                    <h2 class="cover-title">Vael Norfaelriel</h2>
                    <p class="cover-sub">May the stars lead my way</p>
                    <span class="corner tl" /><span class="corner tr" />
                    <span class="corner bl" /><span class="corner br" />
                  </div>
                </template>

                <!-- Inside covers -->
                <template v-else-if="leaf[face].kind === 'endpaper'">
                  <div v-if="!leaf[face].end" class="inscription">
                    <p>If found, keep looking up.</p>
                    <svg class="tiny-star" viewBox="0 0 100 100" aria-hidden="true">
                      <path d="M50 0 L57 43 L100 50 L57 57 L50 100 L43 57 L0 50 L43 43 Z" />
                    </svg>
                  </div>
                </template>

                <!-- Uploaded page -->
                <template v-else-if="leaf[face].kind === 'page'">
                  <img
                      class="page-img"
                      :src="leaf[face].page.url"
                      :alt="`Page ${leaf[face].num}`"
                      loading="lazy"
                      draggable="false"
                  />
                  <span class="page-num">✦ {{ leaf[face].num }}</span>
                </template>

                <!-- Back cover -->
                <template v-else-if="leaf[face].kind === 'backcover'">
                  <svg class="back-star" viewBox="0 0 100 100" aria-hidden="true">
                    <path d="M50 0 L57 43 L100 50 L57 57 L50 100 L43 57 L0 50 L43 43 Z" />
                  </svg>
                </template>

                <div class="shade" />
              </div>
            </div>
          </div>
        </div>

        <nav class="controls">
          <button class="ctrl" :disabled="isClosed" @click="prev" aria-label="Previous page">‹</button>
          <span class="page-label">{{ pageLabel }}</span>
          <button class="ctrl" :disabled="isFinished" @click="next" aria-label="Next page">›</button>
        </nav>

        <div class="sub-controls">
          <button v-if="openImages.length" class="text-btn" @click="openZoom">Look closer</button>
          <button v-if="!isClosed" class="text-btn" @click="turnTo(0)">Close the book</button>
          <button v-if="isAdmin" class="text-btn admin" @click="managing = true">Manage pages</button>
        </div>

        <p v-if="!pages.length" class="status empty">
          The pages are still blank.<template v-if="isAdmin"> Add some from “Manage pages”.</template>
        </p>
      </template>

      <!-- Zoom -->
      <div v-if="zoomed" class="overlay zoom" @click="zoomed = null">
        <div class="zoom-pages">
          <img v-for="s in zoomed" :key="s.page.id" :src="s.page.url" :alt="`Page ${s.num}`" />
        </div>
      </div>

      <!-- Admin page manager -->
      <div v-if="managing" class="overlay" @click.self="managing = false">
        <div class="manage-panel">
          <div class="manage-header">
            <h2>Pages</h2>
            <button class="text-btn" @click="managing = false">Done</button>
          </div>

          <p class="manage-hint">Pages appear in this order. Images upload in the order you pick them.</p>

          <input ref="fileInput" type="file" accept="image/*" multiple hidden @change="onFilesPicked" />
          <button class="add-btn" :disabled="uploading" @click="fileInput.click()">
            {{ uploading ? 'Binding pages…' : '+ Add pages' }}
          </button>

          <p v-if="manageError" class="manage-error">{{ manageError }}</p>

          <ol class="manage-list">
            <li v-for="(p, i) in pages" :key="p.id">
              <span class="manage-num">{{ i + 1 }}</span>
              <img :src="p.url" alt="" />
              <div class="manage-actions">
                <button :disabled="i === 0" @click="movePage(i, -1)" aria-label="Move earlier">↑</button>
                <button :disabled="i === pages.length - 1" @click="movePage(i, 1)" aria-label="Move later">↓</button>
                <button class="danger" @click="deletePage(p)" aria-label="Remove page">✕</button>
              </div>
            </li>
          </ol>
        </div>
      </div>
    </main>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600&family=Cormorant+Garamond:ital,wght@0,300;0,400;0,600;1,300;1,400&display=swap');

.notebook-root {
  --gold: #d8b56a;
  --gold-dim: rgba(216, 181, 106, 0.45);
  --ink: #2e1a0f;
  --leather: #3b2214;
  --paper: #efe6d2;
  --page-w: min(560px, calc((100vw - 2rem) / 2), calc((100vh - 190px) / 1.38));
  --page-h: calc(var(--page-w) * 1.38);

  position: relative;
  min-height: 100vh;
  width: 100vw;
  margin-left: calc(-50vw + 50%);
  overflow-x: hidden;
  background: radial-gradient(ellipse 80% 60% at 50% 30%, #3a0c12 0%, #1a0608 55%, #0c0405 100%);
  color: #d9d4c7;
  font-family: 'Cormorant Garamond', serif;
}

/* ── Starfield ── */

.sky {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
}

.stars {
  position: absolute;
  inset: 0;
  background-repeat: repeat;
}

.stars-far {
  background-image:
      radial-gradient(1px 1px at 20px 30px, #fff, transparent),
      radial-gradient(1px 1px at 120px 80px, rgba(255, 255, 255, 0.7), transparent),
      radial-gradient(1px 1px at 200px 160px, #fff, transparent),
      radial-gradient(1px 1px at 60px 190px, rgba(255, 255, 255, 0.6), transparent),
      radial-gradient(1px 1px at 170px 20px, rgba(255, 255, 255, 0.8), transparent);
  background-size: 230px 230px;
  opacity: 0.5;
}

.stars-near {
  background-image:
      radial-gradient(1.5px 1.5px at 50px 60px, #fff6dc, transparent),
      radial-gradient(1.5px 1.5px at 260px 200px, #fff, transparent),
      radial-gradient(2px 2px at 330px 90px, #ffe9b0, transparent),
      radial-gradient(1.5px 1.5px at 140px 310px, #fff, transparent);
  background-size: 380px 380px;
  animation: twinkle 5s ease-in-out infinite alternate;
}

@keyframes twinkle {
  from { opacity: 0.35; }
  to { opacity: 0.9; }
}

/* ── Gate ── */

.gate {
  position: relative;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  text-align: center;
  padding: 0 1rem;
}

.gate-star {
  width: 34px;
  fill: var(--gold);
  filter: drop-shadow(0 0 8px rgba(216, 181, 106, 0.6));
}

.gate-text {
  font-style: italic;
  color: #b0948c;
  font-size: 1.2rem;
}

.gate-link {
  border: 1px solid var(--gold-dim);
  color: var(--gold);
  text-decoration: none;
  padding: 0.5rem 1.3rem;
  border-radius: 3px;
  font-family: 'Cinzel', serif;
  font-size: 0.78rem;
  letter-spacing: 0.14em;
  transition: background 0.2s;
}

.gate-link:hover {
  background: rgba(216, 181, 106, 0.1);
}

/* ── Page ── */

.notebook-page {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1.25rem 1rem 2rem;
}

.leave-link {
  position: absolute;
  top: 1rem;
  left: 1rem;
  color: #8a6a64;
  text-decoration: none;
  font-size: 0.95rem;
  font-style: italic;
}

.leave-link:hover {
  color: var(--gold);
}

.page-header {
  text-align: center;
  margin-bottom: 1rem;
}

.eyebrow {
  margin: 0 0 0.4rem;
  font-size: 0.72rem;
  letter-spacing: 0.3em;
  text-transform: uppercase;
  color: #9c7a72;
}

.title {
  margin: 0;
  font-family: 'Cinzel', serif;
  font-weight: 400;
  font-size: clamp(1.6rem, 5vw, 2.4rem);
  letter-spacing: 0.08em;
  color: #f1e6c8;
  text-shadow: 0 0 18px rgba(216, 181, 106, 0.25);
}

.status {
  color: #9c7a72;
  font-style: italic;
  font-size: 1.1rem;
  padding: 2rem 0;
}

.status.empty {
  padding: 1rem 0 0;
}

/* ── Book ── */

.stage {
  width: calc(var(--page-w) * 2);
  height: var(--page-h);
  touch-action: pan-y;
  user-select: none;
}

/* Perspective lives here (not preserve-3d) so leaves composite flat in
   z-index order -- in a shared 3D context coplanar leaves ignore z-index. */
.book {
  position: relative;
  width: 100%;
  height: 100%;
  perspective: 2400px;
  transition: transform 0.9s cubic-bezier(0.645, 0.045, 0.355, 1);
}

/* Closed: slide so the lone cover sits centered. */
.book.closed {
  transform: translateX(-25%);
}

.book.finished {
  transform: translateX(25%);
}

.leaf {
  position: absolute;
  top: 0;
  left: 50%;
  width: var(--page-w);
  height: var(--page-h);
  transform-origin: left center;
  transform-style: preserve-3d;
  transition: transform 0.9s cubic-bezier(0.645, 0.045, 0.355, 1);
  cursor: pointer;
}

.face {
  position: absolute;
  inset: 0;
  overflow: hidden;
  backface-visibility: hidden;
  -webkit-backface-visibility: hidden;
  background: var(--paper);
  background-image:
      radial-gradient(ellipse at 30% 20%, rgba(255, 255, 255, 0.35), transparent 60%),
      radial-gradient(ellipse at 80% 90%, rgba(150, 120, 70, 0.12), transparent 60%);
  border-radius: 0 6px 6px 0;
  box-shadow: inset 0 0 30px rgba(120, 95, 50, 0.18);
}

.face.back {
  transform: rotateY(180deg);
  border-radius: 6px 0 0 6px;
}

/* Spine-side shading so the spread reads as bound pages. */
.shade {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.face.front .shade {
  background: linear-gradient(90deg, rgba(0, 0, 0, 0.28) 0%, rgba(0, 0, 0, 0.06) 7%, transparent 16%);
}

.face.back .shade {
  background: linear-gradient(270deg, rgba(0, 0, 0, 0.28) 0%, rgba(0, 0, 0, 0.06) 7%, transparent 16%);
}

/* Uploaded pages */

.page-img {
  position: absolute;
  inset: 4% 5% 8%;
  width: 90%;
  height: 88%;
  object-fit: contain;
  pointer-events: none;
}

.page-num {
  position: absolute;
  bottom: 2.5%;
  left: 0;
  right: 0;
  text-align: center;
  font-size: 0.8rem;
  color: #8a7350;
  letter-spacing: 0.1em;
}

/* Covers */

/* Leather: uneven dye (low-frequency noise) over the base red, a pebbled
   grain (noise run through a lighting filter) blended on top, darkened
   worn edges. */
.face.cover,
.face.backcover {
  background-color: var(--leather);
  background-image:
      url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='400' height='400'%3E%3Cfilter id='m'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.012' numOctaves='3' seed='7'/%3E%3CfeColorMatrix values='0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 -1.6 1.05'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23m)' opacity='0.55'/%3E%3C/svg%3E"),
      radial-gradient(ellipse at 30% 22%, rgba(150, 90, 45, 0.32), transparent 55%),
      radial-gradient(ellipse at 75% 85%, rgba(28, 14, 5, 0.5), transparent 60%);
  background-size: cover;
  border-radius: 2px 10px 10px 2px;
  box-shadow:
      inset 0 0 0 1px rgba(0, 0, 0, 0.55),
      inset 0 0 18px 4px rgba(22, 11, 3, 0.75),
      inset 0 0 60px rgba(0, 0, 0, 0.45);
}

.face.backcover {
  border-radius: 10px 2px 2px 10px;
}

.face.cover::before,
.face.backcover::before {
  content: '';
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='260' height='260'%3E%3Cfilter id='g'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='3' seed='3' stitchTiles='stitch'/%3E%3CfeDiffuseLighting lighting-color='%23fff' surfaceScale='2.2'%3E%3CfeDistantLight azimuth='225' elevation='50'/%3E%3C/feDiffuseLighting%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23g)'/%3E%3C/svg%3E");
  background-size: 260px 260px;
  mix-blend-mode: overlay;
  opacity: 0.55;
  pointer-events: none;
}

.cover-frame {
  position: absolute;
  inset: 7%;
  border: 1px solid var(--gold-dim);
  outline: 1px solid rgba(216, 181, 106, 0.18);
  outline-offset: 4px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
}

.constellation {
  width: 72%;
  margin-bottom: 4%;
}

.constellation .lines {
  fill: none;
  stroke: var(--gold-dim);
  stroke-width: 0.6;
}

.constellation .dots {
  fill: #f3dc9e;
}

.north-star {
  fill: var(--gold);
  filter: drop-shadow(0 0 4px rgba(243, 220, 158, 0.8));
}

.cover-title {
  margin: 0;
  font-family: 'Cinzel', serif;
  font-weight: 600;
  font-size: calc(var(--page-w) * 0.064);
  letter-spacing: 0.1em;
  color: var(--gold);
  /* Debossed foil: pressed into the leather, lit from the top left. */
  text-shadow:
      0 -1px 0 rgba(0, 0, 0, 0.7),
      0 1px 0 rgba(255, 210, 160, 0.18);
}

.cover-sub {
  margin: 0.3em 0 0;
  font-style: italic;
  font-size: calc(var(--page-w) * 0.045);
  color: #b9a37a;
}

.corner {
  position: absolute;
  width: 9%;
  aspect-ratio: 1;
  border-color: var(--gold);
  border-style: solid;
  border-width: 0;
}
.corner.tl { top: -1px; left: -1px; border-top-width: 2px; border-left-width: 2px; }
.corner.tr { top: -1px; right: -1px; border-top-width: 2px; border-right-width: 2px; }
.corner.bl { bottom: -1px; left: -1px; border-bottom-width: 2px; border-left-width: 2px; }
.corner.br { bottom: -1px; right: -1px; border-bottom-width: 2px; border-right-width: 2px; }

.back-star {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 14%;
  transform: translate(-50%, -50%);
  fill: var(--gold-dim);
}

/* Endpapers: a faint star chart */

.face.endpaper {
  background-color: var(--ink);
  background-image:
      radial-gradient(circle at 50% 50%, transparent 38%, rgba(216, 181, 106, 0.12) 38.3%, transparent 38.8%),
      radial-gradient(circle at 50% 50%, transparent 24%, rgba(216, 181, 106, 0.1) 24.3%, transparent 24.8%),
      radial-gradient(1px 1px at 12px 18px, rgba(243, 220, 158, 0.7), transparent),
      radial-gradient(1px 1px at 44px 52px, rgba(255, 255, 255, 0.5), transparent),
      radial-gradient(1.5px 1.5px at 70px 10px, rgba(243, 220, 158, 0.8), transparent);
  background-size: 100% 100%, 100% 100%, 80px 80px, 80px 80px, 80px 80px;
  box-shadow: inset 0 0 40px rgba(0, 0, 0, 0.5);
}

.inscription {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.6rem;
  text-align: center;
  padding: 0 12%;
}

.inscription p {
  margin: 0;
  font-style: italic;
  font-size: calc(var(--page-w) * 0.06);
  color: #e6d6ab;
}

.tiny-star {
  width: 12px;
  fill: var(--gold);
}

/* Blank filler page */

.face.blank::before {
  content: '✦';
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(138, 115, 80, 0.35);
}

/* ── Controls ── */

.controls {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  margin-top: 1rem;
}

.ctrl {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 1px solid var(--gold-dim);
  background: rgba(60, 10, 16, 0.6);
  color: var(--gold);
  font-size: 1.5rem;
  line-height: 1;
  cursor: pointer;
  transition: background 0.2s, opacity 0.2s;
}

.ctrl:hover:not(:disabled) {
  background: rgba(216, 181, 106, 0.12);
}

.ctrl:disabled {
  opacity: 0.25;
  cursor: default;
}

.page-label {
  min-width: 9rem;
  text-align: center;
  font-family: 'Cinzel', serif;
  font-size: 0.78rem;
  letter-spacing: 0.12em;
  color: #b9a37a;
}

.sub-controls {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 0.4rem 1.25rem;
  margin-top: 0.9rem;
}

.text-btn {
  background: none;
  border: none;
  padding: 0.25rem 0;
  color: #9c7a72;
  font-family: 'Cormorant Garamond', serif;
  font-size: 1rem;
  font-style: italic;
  cursor: pointer;
}

.text-btn:hover {
  color: var(--gold);
}

.text-btn.admin {
  color: #e09a6a;
}

/* ── Overlays ── */

.overlay {
  position: fixed;
  inset: 0;
  z-index: 1000;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: 2.5rem 1rem;
  overflow-y: auto;
  background: rgba(12, 3, 4, 0.88);
}

.overlay.zoom {
  align-items: center;
  cursor: zoom-out;
}

.zoom-pages {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 1rem;
}

.zoom-pages img {
  max-width: min(92vw, 720px);
  max-height: 88vh;
  object-fit: contain;
  border-radius: 4px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.6);
}

.manage-panel {
  width: 100%;
  max-width: 520px;
  background: #2a080d;
  border: 1px solid var(--gold-dim);
  border-radius: 8px;
  padding: 1.25rem 1.5rem 1.5rem;
}

.manage-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.manage-header h2 {
  margin: 0;
  font-family: 'Cinzel', serif;
  font-weight: 400;
  font-size: 1.2rem;
  letter-spacing: 0.1em;
  color: var(--gold);
}

.manage-hint {
  margin: 0.5rem 0 1rem;
  font-size: 0.95rem;
  color: #9c7a72;
}

.add-btn {
  width: 100%;
  padding: 0.65rem;
  border: 1px dashed var(--gold-dim);
  border-radius: 6px;
  background: transparent;
  color: var(--gold);
  font-family: 'Cinzel', serif;
  font-size: 0.85rem;
  letter-spacing: 0.1em;
  cursor: pointer;
}

.add-btn:hover:not(:disabled) {
  background: rgba(216, 181, 106, 0.08);
}

.add-btn:disabled {
  opacity: 0.6;
  cursor: progress;
}

.manage-error {
  margin: 0.75rem 0 0;
  color: #e07a7a;
  font-size: 0.95rem;
}

.manage-list {
  list-style: none;
  margin: 1rem 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.manage-list li {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.4rem 0.5rem;
  border: 1px solid rgba(216, 181, 106, 0.15);
  border-radius: 6px;
}

.manage-num {
  width: 1.6rem;
  text-align: right;
  font-family: 'Cinzel', serif;
  color: #b9a37a;
}

.manage-list img {
  width: 44px;
  height: 60px;
  object-fit: cover;
  border-radius: 3px;
  background: var(--paper);
}

.manage-actions {
  margin-left: auto;
  display: flex;
  gap: 0.35rem;
}

.manage-actions button {
  width: 32px;
  height: 32px;
  border-radius: 4px;
  border: 1px solid rgba(216, 181, 106, 0.25);
  background: transparent;
  color: #d9d4c7;
  cursor: pointer;
}

.manage-actions button:disabled {
  opacity: 0.25;
  cursor: default;
}

.manage-actions button.danger:hover {
  border-color: #e07a7a;
  color: #e07a7a;
}

@media (prefers-reduced-motion: reduce) {
  .stars-near { animation: none; }
  .book, .leaf { transition-duration: 0.01s; }
}
</style>
