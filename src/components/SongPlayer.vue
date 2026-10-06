<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { parseYouTubeId } from '@/lib/songLookup'

const props = defineProps({
  url: { type: String, required: true },
  title: { type: String, default: '' },
  artist: { type: String, default: '' },
  cover: { type: String, default: '' }
})

// The YouTube IFrame API is a global script; load it once and share the promise.
let ytApiPromise = null
function loadYouTubeApi() {
  if (window.YT?.Player) return Promise.resolve(window.YT)
  if (!ytApiPromise) {
    ytApiPromise = new Promise((resolve) => {
      const prev = window.onYouTubeIframeAPIReady
      window.onYouTubeIframeAPIReady = () => {
        prev?.()
        resolve(window.YT)
      }
      const s = document.createElement('script')
      s.src = 'https://www.youtube.com/iframe_api'
      document.head.appendChild(s)
    })
  }
  return ytApiPromise
}

const mountEl = ref(null)
const ready = ref(false)
const playing = ref(false)
const failed = ref(false)
const current = ref(0)
const duration = ref(0)
let player = null
let ticker = null

// Volume is a per-visitor preference, remembered across entries and visits.
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
const muted = ref(volume.value === 0)
const shownVolume = computed(() => muted.value ? 0 : volume.value)

const progress = computed(() => duration.value ? (current.value / duration.value) * 100 : 0)

function fmt(sec) {
  const s = Math.max(0, Math.floor(sec))
  return `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`
}

function startTicker() {
  stopTicker()
  ticker = setInterval(() => {
    current.value = player?.getCurrentTime?.() ?? 0
    duration.value = player?.getDuration?.() || duration.value
  }, 250)
}

function stopTicker() {
  clearInterval(ticker)
  ticker = null
}

onMounted(async () => {
  const id = parseYouTubeId(props.url)
  if (!id) {
    failed.value = true
    return
  }
  const YT = await loadYouTubeApi()
  if (!mountEl.value) return // unmounted while the API was loading
  player = new YT.Player(mountEl.value, {
    videoId: id,
    width: 200,
    height: 200,
    playerVars: { controls: 0, playsinline: 1, disablekb: 1 },
    events: {
      onReady: () => {
        ready.value = true
        player.setVolume(volume.value)
        if (muted.value) player.mute()
        duration.value = player.getDuration() || 0
      },
      onStateChange: (e) => {
        // Treat buffering as playing so the button flips to "pause" right away
        playing.value = e.data === YT.PlayerState.PLAYING || e.data === YT.PlayerState.BUFFERING
        if (playing.value) startTicker()
        else stopTicker()
        if (e.data === YT.PlayerState.ENDED) current.value = 0
      },
      onError: () => {
        failed.value = true
        playing.value = false
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

function applyVolume() {
  if (!ready.value) return
  player.setVolume(volume.value)
  if (muted.value) player.mute()
  else player.unMute()
}

function setVolume(e) {
  const v = Number(e.target.value)
  volume.value = v
  muted.value = v === 0
  applyVolume()
  try { localStorage.setItem(VOLUME_KEY, String(v)) } catch { /* ignore */ }
}

function toggleMute() {
  if (muted.value) {
    // Coming back from 0 should actually make sound
    if (volume.value === 0) volume.value = 50
    muted.value = false
  } else {
    muted.value = true
  }
  applyVolume()
}

function seek(e) {
  if (!ready.value || !duration.value) return
  const t = (Number(e.target.value) / 100) * duration.value
  current.value = t
  player.seekTo(t, true)
}
</script>

<template>
  <div class="song" :class="{ playing }">
    <div class="song-cover">
      <img v-if="cover" :src="cover" :alt="title ? `Cover of ${title}` : 'Album cover'" />
      <span v-else class="song-cover-blank" aria-hidden="true">♪</span>
    </div>

    <button
        class="song-toggle"
        :disabled="!ready || failed"
        :aria-label="playing ? 'Pause' : 'Play'"
        @click="toggle"
    >
      <svg v-if="playing" viewBox="0 0 16 16" aria-hidden="true"><path d="M4.5 3h2.2v10H4.5zM9.3 3h2.2v10H9.3z" /></svg>
      <svg v-else viewBox="0 0 16 16" aria-hidden="true"><path d="M5 2.8v10.4L13.2 8z" /></svg>
    </button>

    <div class="song-info">
      <div class="song-title">{{ title || 'Untitled song' }}</div>
      <div class="song-artist">{{ failed ? "This song can't be played here." : (artist || 'Unknown artist') }}</div>

      <div class="song-progress">
        <span class="song-time">{{ fmt(current) }}</span>
        <input
            type="range"
            min="0"
            max="100"
            step="0.1"
            :value="progress"
            :style="{ '--p': progress + '%' }"
            :disabled="!ready || failed"
            aria-label="Seek"
            @input="seek"
        />
        <span class="song-time">{{ fmt(duration) }}</span>
      </div>
    </div>

    <div class="song-volume">
      <button
          class="song-mute"
          :aria-label="muted ? 'Unmute' : 'Mute'"
          :title="muted ? 'Unmute' : 'Mute'"
          @click="toggleMute"
      >
        <svg viewBox="0 0 16 16" aria-hidden="true">
          <path class="spk" d="M2.5 6h2.3L8 3.2v9.6L4.8 10H2.5z" />
          <template v-if="shownVolume === 0">
            <path d="m10.5 6 3 4M13.5 6l-3 4" />
          </template>
          <template v-else>
            <path d="M10.3 6.2a2.6 2.6 0 0 1 0 3.6" />
            <path v-if="shownVolume > 50" d="M12 4.6a4.9 4.9 0 0 1 0 6.8" />
          </template>
        </svg>
      </button>
      <input
          type="range"
          min="0"
          max="100"
          step="1"
          :value="shownVolume"
          :style="{ '--p': shownVolume + '%' }"
          aria-label="Volume"
          @input="setVolume"
      />
    </div>

    <!-- Audio comes from YouTube's embedded player, kept out of sight -->
    <div class="song-yt" aria-hidden="true"><div ref="mountEl" /></div>
  </div>
</template>

<style scoped>
.song {
  position: relative;
  z-index: 0;
  overflow: hidden;
  display: flex;
  align-items: center;
  gap: 0.9rem;
  padding: 0.7rem;
  margin: 0 0 2rem;
  border: 1px solid var(--border, #2F2F2F);
  border-radius: 8px;
  background: var(--surface, #202020);
}

.song-cover {
  flex-shrink: 0;
  width: 64px;
  height: 64px;
  border-radius: 5px;
  overflow: hidden;
  background: var(--track, #2a2a2a);
  display: grid;
  place-items: center;
}

.song-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.song-cover-blank {
  color: var(--muted, #9B9A97);
  font-size: 1.4rem;
}

.song-toggle {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 1px solid var(--border, #2F2F2F);
  background: var(--bg, #191919);
  color: var(--text-strong, #fff);
  display: grid;
  place-items: center;
  cursor: pointer;
  transition: background 0.15s, border-color 0.15s;
}

.song-toggle:hover:not(:disabled) {
  border-color: var(--blood, #8A1424);
  background: var(--surface-hover, #262626);
}

.song-toggle:disabled {
  opacity: 0.45;
  cursor: default;
}

.song-toggle svg {
  width: 16px;
  height: 16px;
  fill: currentColor;
}

.song-info {
  flex: 1;
  min-width: 0;
}

.song-title {
  color: var(--text-strong, #fff);
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.song-artist {
  color: var(--muted, #9B9A97);
  font-size: 0.875rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.song-progress {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: 0.4rem;
}

.song-time {
  flex-shrink: 0;
  font-size: 0.72rem;
  color: var(--muted, #9B9A97);
  font-variant-numeric: tabular-nums;
  min-width: 2.6em;
}

.song-time:last-child { text-align: right; }

.song-progress input[type='range'] {
  flex: 1;
  min-width: 0;
  height: 4px;
  margin: 0;
  appearance: none;
  border-radius: 2px;
  background: linear-gradient(to right, var(--blood, #8A1424) var(--p, 0%), var(--track, #3a3a3a) var(--p, 0%));
  cursor: pointer;
}

.song-progress input[type='range']:disabled { cursor: default; }

.song-progress input[type='range']::-webkit-slider-thumb {
  appearance: none;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: var(--text-strong, #fff);
  opacity: 0;
  transition: opacity 0.15s;
}

.song-progress input[type='range']::-moz-range-thumb {
  width: 12px;
  height: 12px;
  border: 0;
  border-radius: 50%;
  background: var(--text-strong, #fff);
  opacity: 0;
}

.song:hover input[type='range']::-webkit-slider-thumb,
.song-progress input[type='range']:focus-visible::-webkit-slider-thumb { opacity: 1; }
.song:hover input[type='range']::-moz-range-thumb { opacity: 1; }

.song-volume {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 0.35rem;
  align-self: flex-end;
  padding-bottom: 0.1rem;
}

.song-mute {
  width: 28px;
  height: 28px;
  border: 0;
  border-radius: 6px;
  background: transparent;
  color: var(--muted, #9B9A97);
  display: grid;
  place-items: center;
  cursor: pointer;
}

.song-mute:hover { background: var(--surface-hover, #262626); color: var(--text, #E3E2DF); }

.song-mute svg {
  width: 16px;
  height: 16px;
  fill: none;
  stroke: currentColor;
  stroke-width: 1.3;
  stroke-linecap: round;
  stroke-linejoin: round;
}

.song-mute svg .spk { fill: currentColor; stroke: none; }

.song-volume input[type='range'] {
  width: 72px;
  height: 4px;
  margin: 0;
  appearance: none;
  border-radius: 2px;
  background: linear-gradient(to right, var(--muted, #9B9A97) var(--p, 0%), var(--track, #3a3a3a) var(--p, 0%));
  cursor: pointer;
}

.song-volume input[type='range']::-webkit-slider-thumb {
  appearance: none;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--text-strong, #fff);
}

.song-volume input[type='range']::-moz-range-thumb {
  width: 10px;
  height: 10px;
  border: 0;
  border-radius: 50%;
  background: var(--text-strong, #fff);
}

.song-yt {
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

@media (max-width: 480px) {
  .song-cover { width: 52px; height: 52px; }
  .song-volume input[type='range'] { display: none; }
  .song { gap: 0.7rem; }
}
</style>
