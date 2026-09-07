<template>
  <div class="cropper-backdrop" @click.self="$emit('cancel')">
    <div class="cropper-panel">
      <h3 class="cropper-title">{{ title }}</h3>
      <p class="cropper-hint">Drag to reposition · scroll or use the slider to zoom</p>

      <div
          class="crop-viewport"
          :class="{ circle: shape === 'circle' }"
          :style="{ width: viewportWidth + 'px', height: viewportHeight + 'px' }"
          @wheel.prevent="onWheel"
          @pointerdown="onPointerDown"
          @pointermove="onPointerMove"
          @pointerup="onPointerUp"
          @pointercancel="onPointerUp"
      >
        <img
            v-if="imgSrc"
            ref="imgEl"
            :src="imgSrc"
            class="crop-image"
            :style="imageStyle"
            draggable="false"
            @load="onImageLoad"
        />
      </div>

      <div class="zoom-row">
        <span class="zoom-label">Zoom</span>
        <input
            type="range"
            min="1"
            max="3"
            step="0.01"
            v-model.number="zoom"
            :disabled="!ready"
        />
      </div>

      <div class="cropper-actions">
        <button type="button" class="cancel-btn" @click="$emit('cancel')">Cancel</button>
        <button type="button" class="save-btn" :disabled="!ready" @click="confirmCrop">Save</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onBeforeUnmount } from 'vue'

const props = defineProps({
  file: { type: File, required: true },
  viewportWidth: { type: Number, required: true },
  viewportHeight: { type: Number, required: true },
  outputWidth: { type: Number, required: true },
  outputHeight: { type: Number, required: true },
  shape: { type: String, default: 'rect' }, // 'rect' | 'circle'
  title: { type: String, default: 'Crop image' }
})
const emit = defineEmits(['cropped', 'cancel'])

const imgEl = ref(null)
const imgSrc = ref('')
const ready = ref(false)
const zoom = ref(1)
const baseScale = ref(1)
const naturalWidth = ref(0)
const naturalHeight = ref(0)
const offsetX = ref(0)
const offsetY = ref(0)

const effectiveScale = computed(() => baseScale.value * zoom.value)
const scaledW = computed(() => naturalWidth.value * effectiveScale.value)
const scaledH = computed(() => naturalHeight.value * effectiveScale.value)

const imageStyle = computed(() => ({
  width: scaledW.value + 'px',
  height: scaledH.value + 'px',
  transform: `translate(${offsetX.value}px, ${offsetY.value}px)`
}))

watch(() => props.file, (file) => {
  if (imgSrc.value) URL.revokeObjectURL(imgSrc.value)
  ready.value = false
  zoom.value = 1
  imgSrc.value = file ? URL.createObjectURL(file) : ''
}, { immediate: true })

onBeforeUnmount(() => {
  if (imgSrc.value) URL.revokeObjectURL(imgSrc.value)
})

function onImageLoad() {
  naturalWidth.value = imgEl.value.naturalWidth
  naturalHeight.value = imgEl.value.naturalHeight
  baseScale.value = Math.max(
      props.viewportWidth / naturalWidth.value,
      props.viewportHeight / naturalHeight.value
  )
  offsetX.value = (props.viewportWidth - scaledW.value) / 2
  offsetY.value = (props.viewportHeight - scaledH.value) / 2
  ready.value = true
}

function clampOffset() {
  const minX = props.viewportWidth - scaledW.value
  const minY = props.viewportHeight - scaledH.value
  offsetX.value = Math.min(0, Math.max(minX, offsetX.value))
  offsetY.value = Math.min(0, Math.max(minY, offsetY.value))
}

watch(zoom, clampOffset)

let dragging = false
let startX = 0
let startY = 0
let startOffsetX = 0
let startOffsetY = 0

function onPointerDown(e) {
  if (!ready.value) return
  dragging = true
  startX = e.clientX
  startY = e.clientY
  startOffsetX = offsetX.value
  startOffsetY = offsetY.value
  e.currentTarget.setPointerCapture?.(e.pointerId)
}

function onPointerMove(e) {
  if (!dragging) return
  offsetX.value = startOffsetX + (e.clientX - startX)
  offsetY.value = startOffsetY + (e.clientY - startY)
  clampOffset()
}

function onPointerUp() {
  dragging = false
}

function onWheel(e) {
  if (!ready.value) return
  zoom.value = Math.min(3, Math.max(1, zoom.value - e.deltaY * 0.001))
}

function confirmCrop() {
  const canvas = document.createElement('canvas')
  canvas.width = props.outputWidth
  canvas.height = props.outputHeight
  const ctx = canvas.getContext('2d')

  const sx = -offsetX.value / effectiveScale.value
  const sy = -offsetY.value / effectiveScale.value
  const sw = props.viewportWidth / effectiveScale.value
  const sh = props.viewportHeight / effectiveScale.value

  ctx.drawImage(imgEl.value, sx, sy, sw, sh, 0, 0, props.outputWidth, props.outputHeight)

  canvas.toBlob(blob => {
    if (blob) emit('cropped', blob)
  }, 'image/webp', 0.92)
}
</script>

<style scoped>
.cropper-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.75);
  z-index: 1100;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem 1rem;
}

.cropper-panel {
  background: #181818;
  border: 1px solid #333;
  border-radius: 12px;
  padding: 1.25rem;
  max-width: 640px;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
}

.cropper-title {
  margin: 0;
  color: #fff;
  font-family: 'Iosevka Charon', monospace;
  font-weight: 400;
  align-self: flex-start;
}

.cropper-hint {
  margin: -0.5rem 0 0;
  color: #888;
  font-size: 0.78rem;
  align-self: flex-start;
}

.crop-viewport {
  position: relative;
  overflow: hidden;
  background: #0d0d0d;
  border: 1px solid #333;
  border-radius: 8px;
  cursor: grab;
  touch-action: none;
  max-width: 100%;
}

.crop-viewport.circle {
  border-radius: 50%;
}

.crop-viewport:active {
  cursor: grabbing;
}

.crop-image {
  position: absolute;
  top: 0;
  left: 0;
  user-select: none;
  pointer-events: none;
}

.zoom-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  width: 100%;
  max-width: 320px;
}

.zoom-label {
  font-size: 0.8rem;
  color: #888;
  flex-shrink: 0;
}

.zoom-row input[type="range"] {
  flex: 1;
  accent-color: #90caf9;
}

.cropper-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  width: 100%;
  margin-top: 0.25rem;
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

.save-btn {
  background: #90caf9;
  color: #121212;
  border: none;
  padding: 0.5rem 1.1rem;
  border-radius: 6px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.save-btn:hover:not(:disabled) {
  background: #64b5f6;
}

.save-btn:disabled {
  opacity: 0.5;
  cursor: default;
}
</style>
