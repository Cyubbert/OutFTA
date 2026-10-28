<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { parsePlaylistId, lookupTrack } from '@/lib/songLookup'
import { loadYouTubeApi } from '@/lib/youtubeApi'

const props = defineProps({
  url: { type: String, required: true },
  title: { type: String, default: '' },
  cover: { type: String, default: '' },
  owner: { type: String, default: '' },
  accent: { type: String, default: '#90caf9' }
})

const playlistId = computed(() => parsePlaylistId(props.url))
const openUrl = computed(() => `https://music.youtube.com/playlist?list=${playlistId.value}`)

const mountEl = ref(null)
const ready = ref(false)
const playing = ref(false)
const started = ref(false)
const failed = ref(false)
const shuffle = ref(false)
const current = ref(0)
const duration = ref(0)
const index = ref(-1)
// { id, title, artist, missing } per video; title/artist fill in as oEmbed answers
const tracks = ref([])
let player = null
let ticker = null

// Shares SongPlayer's remembered volume, so one setting covers both.
const VOLUME_KEY = 'songPlayerVolume'
function loadVolume() {
  try {
    const v = Number(localStorage.getItem(VOLUME_KEY))
    if (localStorage.getItem(VOLUME_KEY) !== null && v >= 0 && v <= 100) return v
  } catch {
    // storage unavailable (private mode etc.)
  }
  return 70
}
const volume = ref(loadVolume())

const progress = computed(() => duration.value ? (current.value / duration.value) * 100 : 0)
const nowPlaying = computed(() => tracks.value[index.value] ?? null)

function fmt(sec) {
  const s = Math.max(0, Math.floor(sec))
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`
}

function sync() {
  current.value = player?.getCurrentTime?.() ?? 0
  duration.value = player?.getDuration?.() || 0
  const i = player?.getPlaylistIndex?.()
  if (typeof i === 'number' && i >= 0) index.value = i
}

function startTicker() {
  stopTicker()
  ticker = setInterval(sync, 250)
}

function stopTicker() {
  clearInterval(ticker)
  ticker = null
}

// Track titles come one oEmbed call per video; a few at a time keeps it polite.
async function loadTracks(ids) {
  tracks.value = ids.map(id => ({ id, title: '', artist: '', missing: false }))
  let next = 0
  async function worker() {
    while (next < ids.length) {
      const i = next++
      const info = await lookupTrack(ids[i]).catch(() => null)
      const t = tracks.value[i]
      if (!t || t.id !== ids[i]) return // playlist replaced meanwhile
      if (info) Object.assign(t, info)
      else t.missing = true
    }
  }
  await Promise.all(Array.from({ length: 6 }, worker))
}

// getPlaylist() is empty until the list is cued, so retry briefly after ready.
async function readPlaylist() {
  for (let i = 0; i < 20 && player; i++) {
    const ids = player.getPlaylist?.()
    if (ids?.length) {
      if (ids.join() !== tracks.value.map(t => t.id).join()) loadTracks(ids)
      return
    }
    await new Promise(r => setTimeout(r, 250))
  }
  if (!tracks.value.length) failed.value = true
}

onMounted(async () => {
  if (!playlistId.value) {
    failed.value = true
    return
  }
  const YT = await loadYouTubeApi()
  if (!mountEl.value) return // unmounted while the API was loading
  player = new YT.Player(mountEl.value, {
    width: 200,
    height: 200,
    playerVars: { listType: 'playlist', list: playlistId.value, controls: 0, playsinline: 1, disablekb: 1 },
    events: {
      onReady: () => {
        ready.value = true
        player.setVolume(volume.value)
        readPlaylist()
      },
      onStateChange: (e) => {
        playing.value = e.data === YT.PlayerState.PLAYING || e.data === YT.PlayerState.BUFFERING
        if (playing.value) {
          started.value = true
          startTicker()
        } else {
          stopTicker()
        }
        sync()
      },
      onError: () => {
        // One blocked/removed video shouldn't stop the whole playlist
        if (tracks.value[index.value]) tracks.value[index.value].missing = true
        if (index.value < tracks.value.length - 1) player.nextVideo()
        else playing.value = false
      }
    }
  })
})

onUnmounted(() => {
  stopTicker()
  player?.destroy?.()
  player = null
})

function toggle() {
  if (!ready.value || failed.value) return
  if (playing.value) player.pauseVideo()
  else player.playVideo()
}

function playAt(i) {
  if (!ready.value) return
  if (i === index.value && started.value) return toggle()
  player.playVideoAt(i)
}

function prev() {
  if (!ready.value) return
  // Like most players: restart the song unless it's only just begun
  if (current.value > 3) player.seekTo(0, true)
  else player.previousVideo()
}

function next() {
  if (ready.value) player.nextVideo()
}

function toggleShuffle() {
  if (!ready.value) return
  shuffle.value = !shuffle.value
  player.setShuffle(shuffle.value)
}

function seek(e) {
  if (!ready.value || !duration.value) return
  const t = (Number(e.target.value) / 100) * duration.value
  current.value = t
  player.seekTo(t, true)
}

function setVolume(e) {
  volume.value = Number(e.target.value)
  if (ready.value) player.setVolume(volume.value)
  try { localStorage.setItem(VOLUME_KEY, String(volume.value)) } catch { /* ignore */ }
}
</script>

<template>
  <section class="pl" :class="{ playing }" :style="{ '--accent': accent }">
    <header class="pl-head">
      <div class="pl-cover">
        <img v-if="cover" :src="cover" alt="" />
        <span v-else aria-hidden="true">♪</span>
      </div>
      <div class="pl-meta">
        <span class="pl-kind">Character playlist</span>
        <h4 class="pl-title">{{ title || 'Untitled playlist' }}</h4>
        <div class="pl-sub">
          <span v-if="owner" class="pl-owner">{{ owner }}</span>
          <span v-if="tracks.length"> · {{ tracks.length }} {{ tracks.length === 1 ? 'song' : 'songs' }}</span>
        </div>
      </div>
    </header>

    <div class="pl-controls">
      <button
          class="pl-play"
          :disabled="!ready || failed"
          :aria-label="playing ? 'Pause' : 'Play'"
          @click="toggle"
      >
        <svg v-if="playing" viewBox="0 0 16 16" aria-hidden="true"><path d="M4.5 3h2.2v10H4.5zM9.3 3h2.2v10H9.3z" /></svg>
        <svg v-else viewBox="0 0 16 16" aria-hidden="true"><path d="M5 2.8v10.4L13.2 8z" /></svg>
      </button>
      <button class="pl-icon" :class="{ on: shuffle }" :disabled="!ready" :aria-pressed="shuffle" title="Shuffle" aria-label="Shuffle" @click="toggleShuffle">
        <svg viewBox="0 0 16 16" aria-hidden="true"><path d="M2 4.5h2.5c1.5 0 2.4.7 3.2 2l1.6 3c.7 1.3 1.6 2 3.2 2H14M2 11.5h2.5c1 0 1.7-.3 2.3-.9M9.2 5.4c.6-.6 1.3-.9 2.3-.9H14M12 2.5l2 2-2 2M12 9.5l2 2-2 2" /></svg>
      </button>
      <button class="pl-icon" :disabled="!ready" title="Previous" aria-label="Previous" @click="prev">
        <svg viewBox="0 0 16 16" aria-hidden="true"><path class="fill" d="M12.5 3v10L5.5 8zM3.5 3h1.6v10H3.5z" /></svg>
      </button>
      <button class="pl-icon" :disabled="!ready" title="Next" aria-label="Next" @click="next">
        <svg viewBox="0 0 16 16" aria-hidden="true"><path class="fill" d="M3.5 3v10l7-5zM10.9 3h1.6v10h-1.6z" /></svg>
      </button>

      <a class="pl-open" :href="openUrl" target="_blank" rel="noopener"><span class="pl-open-long">Open in </span>YouTube Music ↗</a>

      <label class="pl-volume">
        <span class="sr-only">Volume</span>
        <svg viewBox="0 0 16 16" aria-hidden="true"><path class="fill" d="M2.5 6h2.3L8 3.2v9.6L4.8 10H2.5z" /><path d="M10.3 6.2a2.6 2.6 0 0 1 0 3.6M12 4.6a4.9 4.9 0 0 1 0 6.8" /></svg>
        <input type="range" min="0" max="100" step="1" :value="volume" :style="{ '--p': volume + '%' }" @input="setVolume" />
      </label>
    </div>

    <div v-if="started && nowPlaying" class="pl-progress">
      <span class="pl-time">{{ fmt(current) }}</span>
      <input
          type="range"
          min="0"
          max="100"
          step="0.1"
          :value="progress"
          :style="{ '--p': progress + '%' }"
          aria-label="Seek"
          @input="seek"
      />
      <span class="pl-time">{{ fmt(duration) }}</span>
    </div>

    <p v-if="failed" class="pl-empty">This playlist can't be played here — it may be private.</p>
    <p v-else-if="!tracks.length" class="pl-empty">Loading songs…</p>

    <ol v-else class="pl-tracks">
      <li
          v-for="(t, i) in tracks"
          :key="t.id + i"
          class="pl-track"
          :class="{ current: i === index && started, missing: t.missing }"
          @click="playAt(i)"
      >
        <span class="pl-num">
          <span v-if="i === index && playing" class="pl-eq" aria-label="Playing"><i /><i /><i /></span>
          <template v-else>{{ i + 1 }}</template>
        </span>
        <img class="pl-thumb" :src="`https://i.ytimg.com/vi/${t.id}/mqdefault.jpg`" alt="" loading="lazy" />
        <span class="pl-track-text">
          <span class="pl-track-title">{{ t.missing ? 'Unavailable' : (t.title || '…') }}</span>
          <span class="pl-track-artist">{{ t.artist }}</span>
        </span>
      </li>
    </ol>

    <!-- Audio comes from YouTube's embedded player, kept out of sight -->
    <div class="pl-yt" aria-hidden="true"><div ref="mountEl" /></div>
  </section>
</template>

<style scoped>
.pl {
  --accent: #90caf9;
  position: relative;
  z-index: 0;
  overflow: hidden;
  border: 1px solid #2a2a2a;
  border-radius: 12px;
  background: #141414;
  margin-bottom: 2rem;
}

.pl-head {
  display: flex;
  align-items: flex-end;
  gap: 1.25rem;
  padding: 1.5rem 1.5rem 1.25rem;
  background: linear-gradient(to bottom, color-mix(in srgb, var(--accent) 45%, #141414), #141414);
}

.pl-cover {
  flex-shrink: 0;
  width: 160px;
  height: 160px;
  border-radius: 6px;
  overflow: hidden;
  background: #262626;
  box-shadow: 0 8px 28px rgba(0, 0, 0, 0.55);
  display: grid;
  place-items: center;
  color: #888;
  font-size: 2.5rem;
}

.pl-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.pl-meta {
  min-width: 0;
  padding-bottom: 0.25rem;
}

.pl-kind {
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  color: #fff;
}

.pl-title {
  margin: 0.25rem 0 0.5rem;
  font-size: clamp(1.6rem, 5vw, 2.6rem);
  font-weight: 800;
  line-height: 1.05;
  color: #fff;
  overflow-wrap: anywhere;
}

.pl-sub {
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.7);
}

.pl-owner {
  color: #fff;
  font-weight: 600;
}

.pl-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1.5rem 0.75rem;
}

.pl-play {
  width: 52px;
  height: 52px;
  margin-right: 0.5rem;
  border: 0;
  border-radius: 50%;
  background: var(--accent);
  color: #111;
  display: grid;
  place-items: center;
  cursor: pointer;
  transition: transform 0.1s, filter 0.15s;
}

.pl-play:hover:not(:disabled) {
  transform: scale(1.05);
  filter: brightness(1.1);
}

.pl-play:disabled {
  opacity: 0.45;
  cursor: default;
}

.pl-play svg {
  width: 20px;
  height: 20px;
  fill: currentColor;
}

.pl-icon {
  width: 34px;
  height: 34px;
  border: 0;
  border-radius: 50%;
  background: transparent;
  color: #a7a7a7;
  display: grid;
  place-items: center;
  cursor: pointer;
  transition: color 0.15s;
}

.pl-icon:hover:not(:disabled) { color: #fff; }
.pl-icon:disabled { opacity: 0.4; cursor: default; }
.pl-icon.on { color: var(--accent); }

.pl-icon svg,
.pl-volume svg {
  width: 18px;
  height: 18px;
  fill: none;
  stroke: currentColor;
  stroke-width: 1.3;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.pl-icon svg .fill,
.pl-volume svg .fill {
  fill: currentColor;
  stroke: none;
}

.pl-open {
  margin-left: auto;
  font-size: 0.78rem;
  color: #a7a7a7;
  text-decoration: none;
  white-space: nowrap;
}

.pl-open:hover { color: #fff; text-decoration: underline; }

.pl-volume {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  margin-left: 0.75rem;
  color: #a7a7a7;
}

.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
}

input[type='range'] {
  height: 4px;
  margin: 0;
  appearance: none;
  border-radius: 2px;
  background: linear-gradient(to right, var(--accent) var(--p, 0%), #3a3a3a var(--p, 0%));
  cursor: pointer;
}

.pl-volume input[type='range'] {
  width: 80px;
  background: linear-gradient(to right, #a7a7a7 var(--p, 0%), #3a3a3a var(--p, 0%));
}

input[type='range']::-webkit-slider-thumb {
  appearance: none;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #fff;
}

input[type='range']::-moz-range-thumb {
  width: 12px;
  height: 12px;
  border: 0;
  border-radius: 50%;
  background: #fff;
}

.pl-progress {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0 1.5rem 0.75rem;
}

.pl-progress input[type='range'] {
  flex: 1;
  min-width: 0;
}

.pl-time {
  flex-shrink: 0;
  min-width: 2.6em;
  font-size: 0.72rem;
  color: #a7a7a7;
  font-variant-numeric: tabular-nums;
}

.pl-time:last-child { text-align: right; }

.pl-empty {
  margin: 0;
  padding: 0.5rem 1.5rem 1.5rem;
  color: #888;
  font-size: 0.9rem;
}

.pl-tracks {
  list-style: none;
  margin: 0;
  padding: 0 0.75rem 0.75rem;
  max-height: 380px;
  overflow-y: auto;
  border-top: 1px solid #242424;
}

.pl-track {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  padding: 0.4rem 0.75rem;
  border-radius: 6px;
  cursor: pointer;
}

.pl-track:first-child { margin-top: 0.5rem; }
.pl-track:hover { background: #222; }
.pl-track.missing { opacity: 0.45; }

.pl-num {
  flex-shrink: 0;
  width: 1.6rem;
  text-align: right;
  font-size: 0.85rem;
  color: #a7a7a7;
  font-variant-numeric: tabular-nums;
}

.pl-thumb {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border-radius: 4px;
  object-fit: cover;
  background: #262626;
}

.pl-track-text {
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.pl-track-title,
.pl-track-artist {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.pl-track-title {
  color: #fff;
  font-size: 0.95rem;
}

.pl-track.current .pl-track-title { color: var(--accent); }

.pl-track-artist {
  color: #a7a7a7;
  font-size: 0.8rem;
}

.pl-eq {
  display: inline-flex;
  align-items: flex-end;
  gap: 2px;
  height: 12px;
}

.pl-eq i {
  width: 3px;
  background: var(--accent);
  animation: pl-eq 0.9s ease-in-out infinite;
}

.pl-eq i:nth-child(2) { animation-delay: -0.3s; }
.pl-eq i:nth-child(3) { animation-delay: -0.6s; }

@keyframes pl-eq {
  0%, 100% { height: 3px; }
  50% { height: 12px; }
}

@media (prefers-reduced-motion: reduce) {
  .pl-eq i { animation: none; height: 8px; }
}

.pl-yt {
  position: absolute;
  top: 0;
  left: 0;
  width: 200px;
  height: 200px;
  overflow: hidden;
  opacity: 0;
  pointer-events: none;
  z-index: -1;
}

@media (max-width: 560px) {
  .pl-head {
    flex-direction: column;
    align-items: flex-start;
    padding: 1.25rem 1rem 1rem;
  }
  .pl-cover { width: 140px; height: 140px; }
  .pl-controls { padding: 0.5rem 1rem 0.75rem; gap: 0.25rem; }
  .pl-open-long { display: none; }
  .pl-progress { padding: 0 1rem 0.75rem; }
  .pl-volume { display: none; }
  .pl-tracks { padding: 0 0.25rem 0.5rem; }
}
</style>
