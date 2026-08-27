<script setup>
import { ref } from 'vue'

const props = defineProps({
  title: { type: String, required: true },
  coverImage: { type: String, required: true },
  coverAlt: { type: String, default: '' },
  sections: { type: Array, default: () => [] },
  mapImage: { type: Object, default: null },
  moodboards: { type: Array, default: () => [] },
})

const activeMoodboard = ref(null)
const openMoodboard = (id) => (activeMoodboard.value = id)
const closeMoodboard = () => (activeMoodboard.value = null)
</script>

<template>
  <header class="page-header">
    <img class="page-cover-image" :src="coverImage" :alt="coverAlt" />
  </header>

  <section v-if="moodboards.length" class="moodboard-container">
    <div
        v-for="board in moodboards"
        :key="board.id"
        class="moodboard-card"
        :style="{ backgroundImage: `url('${board.thumb}')` }"
        @click="openMoodboard(board.id)"
    >
      <div class="card-overlay">
        <h3>{{ board.title }}</h3>
        <span class="click-text">Click to expand</span>
      </div>
    </div>
  </section>

  <div v-if="activeMoodboard" class="moodboard-modal" @click="closeMoodboard">
    <button class="close-button" @click="closeMoodboard">&times;</button>
    <div class="modal-content" @click.stop>
      <template v-for="board in moodboards" :key="board.id">
        <template v-if="activeMoodboard === board.id">
          <h2>{{ board.title }}</h2>
          <img :src="board.image" :alt="board.alt" class="moodboard-image" />
        </template>
      </template>
    </div>
  </div>

  <main class="container">
    <h1>{{ title }}</h1>

    <section v-for="(section, i) in sections" :key="i" class="section">
      <h2 v-if="section.heading">{{ section.heading }}</h2>
      <p v-for="(paragraph, j) in section.paragraphs" :key="j" v-html="paragraph" />
    </section>

    <img
        v-if="mapImage"
        :src="mapImage.src"
        :alt="mapImage.alt"
        class="map-again"
    />
  </main>
</template>
