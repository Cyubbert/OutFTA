<script setup>
import {ref, computed} from 'vue'

const artworks = ref([
  {
    id: 1,
    title: "Ray Reference",
    artist: "Fynn",
    img: "/images/RayRef.png",
    description: ""
  },
  {
    id: 2,
    title: "Waesstan Reference",
    artist: "Eddie",
    img: "/images/WaessRef.jpg",
    description: ""
  },
  {
    id: 3,
    title: "Marvers Reference",
    artist: "James",
    img: "/images/MarvRef.png",
    description: ""
  },
  {
    id: 4,
    title: "Campaign Poster",
    artist: "James",
    img: "/images/AncientsPoster.png",
    description: ""
  },
  {
    id: 5,
    title: "Tied up Ray",
    artist: "James",
    img: "/images/RayStool.jpg",
    description: ""
  },
  {
    id: 6,
    title: "Fullbody Marvers",
    artist: "James",
    img: "/images/marversfullbody.png",
    description: ""
  },
  {
    id: 7,
    title: "Height difference",
    artist: "James",
    img: "/images/HeightDiff.jpg",
    description: ""
  },
  {
    id: 8,
    title: "Marvers Chibi",
    artist: "James",
    img: "/images/marvChibi.png",
    description: ""
  },

  {
    id: 9,
    title: "Ray Chibi",
    artist: "James",
    img: "/images/rayChibi.png",
    description: ""
  },

  {
    id: 10,
    title: "Waesstan Chibi",
    artist: "James",
    img: "/images/waessChibi.png",
    description: ""
  },
  {
    id: 11,
    title: "DM Creature",
    artist: "Fynn",
    img: "/images/dmCreature.png",
    description: ""
  },
  {
    id: 12,
    title: "Armor Reference",
    artist: "James",
    img: "/images/marvArmor.png",
    description: ""
  },
  {
    id: 13,
    title: "Waesstan Reference 2",
    artist: "Eddie",
    img: "/images/waessref2.png",
    description: ""
  },
  {
    id: 14,
    title: "First Wanted posters",
    artist: "James",
    img: "/images/firstwanted.png",
    description: ""
  },
  {
    id: 15,
    title: "Marvers Back",
    artist: "James",
    img: "/images/marvback.png",
    description: ""
  },
  {
    id: 16,
    title: "Waesstan Roped",
    artist: "Fynn",
    img: "/images/waesstanrope.png",
    description: ""
  },
  {
    id: 17,
    title: "Marvers Carrying the Gang",
    artist: "James",
    img: "/images/MarvHolding.png",
    description: ""
  },
  {
    id: 18,
    title: "Salt and Pepper Marvers",
    artist: "James",
    img: "/images/oldmanMarv.png",
    description: ""
  },
  {
    id: 19,
    title: "Session Meme",
    artist: "James",
    img: "/images/lastsesh.png",
    description: ""
  },
  {
    id: 20,
    title: "Aarely Headshot",
    artist: "Fynn",
    img: "/images/AarelyHeadshot.png",
    description: ""
  },
  {
    id: 21,
    title: "Ray and Waesstan",
    artist: "Eddie",
    img: "/images/RayWaess.png",
    description: ""
  },
  {
    id: 22,
    title: "Aarely",
    artist: "Eddie",
    img: "/images/Aarelybody.png",
    description: ""
  },
  {
    id: 23,
    title: "Waesstan and Aarely Dancing",
    artist: "Fynn",
    img: "/images/WaessAarely.png",
    description: ""
  },
  {
    id: 24,
    title: "Commander Virex Halden",
    artist: "James",
    img: "/images/Virex1.png",
    description: ""
  },
  {
    id: 25,
    title: "Goofy Virex",
    artist: "James",
    img: "/images/goofyVIrex.png",
    description: ""
  },
  {
    id: 26,
    title: "Virex Headshot",
    artist: "Eddie",
    img: "/images/VirexHead.png",
    description: ""
  },
  {
    id: 27,
    title: "Marvers PhotoCard",
    artist: "James",
    img: "/images/MarvCard.png",
    description: ""
  },
  {
    id: 28,
    title: "Ray PhotoCard",
    artist: "James",
    img: "/images/RayCard.png",
    description: ""
  },
  {
    id: 29,
    title: "Waesstan PhotoCard",
    artist: "James",
    img: "/images/WaessCard.png",
    description: ""
  },
  {
    id: 30,
    title: "Mouse PhotoCard",
    artist: "James",
    img: "/images/MouseCard.png",
    description: ""
  },
  {
    id: 31,
    title: "Aarely PhotoCard",
    artist: "James",
    img: "/images/AarelyCard.png",
    description: ""
  },
  {
    id: 32,
    title: "Virex PhotoCard",
    artist: "James",
    img: "/images/VirexCard.png",
    description: ""
  },
  {
    id: 33,
    title: "Angel",
    artist: "James",
    img: "/images/MarvAngel.png",
    description: ""
  },
  {
    id: 34,
    title: "Baby and Mom Marv",
    artist: "James",
    img: "/images/BabyMarv.png",
    description: ""
  },
  {
    id: 35,
    title: "Baby and Mom Marv",
    artist: "James",
    img: "/images/BabyMarv2.png",
    description: ""
  },
  {
    id: 36,
    title: "Baby and Mom Marv",
    artist: "James",
    img: "/images/BabyMarv.png",
    description: ""
  },
  {
    id: 37,
    title: "Ray Present",
    artist: "Fynn",
    img: "/images/RayGu.png",
    description: ""
  },
  {
    id: 38,
    title: "Waesstan on Couch",
    artist: "Eddie",
    img: "/images/SeduceWaess.png",
    description: ""
  },
  {
    id: 39,
    title: "Ray and Marvers Hugging",
    artist: "James",
    img: "/images/RayMarvHug.png",
    description: ""
  },
  {
    id: 40,
    title: "New Wantedposter",
    artist: "James",
    img: "/images/datedwanted.png",
    description: ""
  },
  {
    id: 41,
    title: "Ray and his Horses",
    artist: "James",
    img: "/images/RayHorse.png",
    description: ""
  },
  {
    id: 42,
    title: "PJs",
    artist: "James",
    img: "/images/sleepy.png",
    description: ""
  },
  {
    id: 43,
    title: "Mory and Quinlan",
    artist: "Eddie",
    img: "/images/MoryQuin.png",
    description: ""
  },
  {
    id: 44,
    title: "Mory and Quinlan",
    artist: "Fynn",
    img: "/images/MoryQuin2.png",
    description: ""
  },
  {
    id: 45,
    title: "Lingerine Ray",
    artist: "James",
    img: "/images/RayLingerine.png",
    description: ""
  },
  {
    id: 46,
    title: "Lingerine Waesstan",
    artist: "James",
    img: "/images/WaessLingerine.png",
    description: ""
  },
  {
    id: 47,
    title: "Lingerine Marvers",
    artist: "James",
    img: "/images/MarvLingerine.png",
    description: ""
  },
  {
    id: 48,
    title: "Leather Marvers",
    artist: "James",
    img: "/images/LeatherMarv.png",
    description: ""
  },
  {
    id: 49,
    title: "Pink Marvers",
    artist: "James",
    img: "/images/PinkMarv.png",
    description: ""
  },
  {
    id: 50,
    title: "Hearteye Marvers",
    artist: "James",
    img: "/images/HeartMarv.png",
    description: ""
  },
  {
    id: 51,
    title: "Pirate Marvers",
    artist: "James",
    img: "/images/PirateMarv.png",
    description: ""
  },
  {
    id: 52,
    title: "Headscarf Marvers",
    artist: "James",
    img: "/images/MarvScarf.png",
    description: ""
  },
  {
    id: 53,
    title: "Quinlan Book",
    artist: "Eddie",
    img: "/images/QuinBook.png",
    description: ""
  },
  {
    id: 54,
    title: "Marvers Ring",
    artist: "James",
    img: "/images/MarvRings.png",
    description: ""
  },
  {
    id: 55,
    title: "Waesstan and Quinlan",
    artist: "Eddie",
    img: "/images/WaessQuin.png",
    description: ""
  },
  {
    id: 56,
    title: "Steve",
    artist: "James",
    img: "/images/MarvHorse.png",
    description: ""
  },
  {
    id: 57,
    title: "Mory",
    artist: "Eddie",
    img: "/images/MoryGr.png",
    description: ""
  },
  {
    id: 58,
    title: "Quinlan",
    artist: "Eddie",
    img: "/images/QuinlanGr.png",
    description: ""
  },
  {
    id: 59,
    title: "Marvers and Astrad",
    artist: "James",
    img: "/images/soft.png",
    description: ""
  },
  {
    id: 60,
    title: "Marvers and Astrad",
    artist: "James",
    img: "/images/anothertime.png",
    description: ""
  },
  {
    id: 62,
    title: "Marvers and Astrad",
    artist: "James",
    img: "/images/firstnight.png",
    description: ""
  },
  {
    id: 63,
    title: "Marvers and Astrad",
    artist: "James",
    img: "/images/absence.png",
    description: ""
  },
  {
    id: 64,
    title: "Marvers and Astrad",
    artist: "James",
    img: "/images/dreams.png",
    description: ""
  },
  {
    id: 65,
    title: "The Gang",
    artist: "Fynn",
    img: "/images/Gang.png",
    description: ""
  },
  {
    id: 66,
    title: "Prison Marvers",
    artist: "James",
    img: "/images/PrisonMarv.png",
    description: ""
  },
  {
    id: 67,
    title: "Drunk",
    artist: "Eddie",
    img: "/images/Drunk.png",
    description: ""
  },
  {
    id: 68,
    title: "Hand Kiss",
    artist: "Eddie",
    img: "/images/HandKiss.png",
    description: ""
  },
  {
    id: 69,
    title: "Marv Scarf",
    artist: "Fynn",
    img: "/images/MarvScarf.png",
    description: ""
  },
  {
    id: 69,
    title: "Polycule",
    artist: "James",
    img: "/images/PolyCule.png",
    description: ""
  },
])

const activeArtist = ref('All')
const lightbox = ref(null)

const artists = computed(() => {
  const a = [...new Set(artworks.value.map(art => art.artist))]
  return ['All', ...a]
})

const filtered = computed(() =>
    artworks.value.filter(a =>
        activeArtist.value === 'All' || a.artist === activeArtist.value
    )
)

function openLightbox(artwork) {
  lightbox.value = artwork
  document.body.style.overflow = 'hidden'
}

function closeLightbox() {
  lightbox.value = null
  document.body.style.overflow = ''
}

function prev() {
  const idx = filtered.value.findIndex(a => a.id === lightbox.value.id)
  const newIdx = (idx - 1 + filtered.value.length) % filtered.value.length
  lightbox.value = filtered.value[newIdx]
}

function next() {
  const idx = filtered.value.findIndex(a => a.id === lightbox.value.id)
  const newIdx = (idx + 1) % filtered.value.length
  lightbox.value = filtered.value[newIdx]
}

function onKeydown(e) {
  if (!lightbox.value) return
  if (e.key === 'Escape') closeLightbox()
  if (e.key === 'ArrowLeft') prev()
  if (e.key === 'ArrowRight') next()
}
</script>

<template>
  <article class="page sans" @keydown="onKeydown" tabindex="0">
    <header>
      <h1 class="page-title">Gallery</h1>
      <p class="page-subtitle">Art made by Players</p>

      <div class="artist-filters">
        <button
            v-for="artist in artists"
            :key="artist"
            class="artist-btn"
            :class="{ active: activeArtist === artist }"
            @click="activeArtist = artist"
        >{{ artist }}
        </button>
      </div>
    </header>

    <div class="page-body">
      <div v-if="!filtered.length" class="empty-state">No artworks found.</div>

      <!-- Masonry grid via CSS columns -->
      <div class="masonry">
        <div
            v-for="art in filtered"
            :key="art.id"
            class="masonry-item"
            @click="openLightbox(art)"
        >
          <img :src="art.img" :alt="art.title" class="masonry-img"/>
          <div class="masonry-overlay">
            <span class="art-title">{{ art.title }}</span>
            <span class="art-artist">by {{ art.artist }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Lightbox -->
    <transition name="lb">
      <div class="lightbox" v-if="lightbox" @click.self="closeLightbox">
        <button class="lb-close" @click="closeLightbox">✕</button>
        <button class="lb-nav lb-prev" @click="prev" v-if="filtered.length > 1">‹</button>
        <button class="lb-nav lb-next" @click="next" v-if="filtered.length > 1">›</button>

        <div class="lb-content">
          <img :src="lightbox.img" :alt="lightbox.title" class="lb-img"/>
          <div class="lb-info">
            <span class="lb-title">{{ lightbox.title }}</span>
            <span class="lb-artist">by {{ lightbox.artist }}</span>
          </div>
        </div>
      </div>
    </transition>
  </article>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Iosevka+Charon:wght@400;500;700&family=Jost:wght@300;400;500;700&display=swap');

.page {
  margin: 2em auto;
  max-width: 900px;
  padding: 0 1rem;
  font-family: 'Jost', sans-serif;
  color: #e0e0e0;
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 1rem 0 0.25rem;
  color: #fff;
  text-align: center;
  font-family: 'Iosevka Charon', monospace;
  letter-spacing: 0.04em;
}

.page-subtitle {
  text-align: center;
  color: #444;
  font-size: 0.8rem;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  margin: 0 0 1.2rem;
}

.artist-filters {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.artist-btn {
  font-size: 0.75rem;
  padding: 4px 12px;
  border-radius: 6px;
  background: #1a1a1a;
  border: 1px solid #2a2a2a;
  color: #555;
  cursor: pointer;
  transition: all 0.15s;
  font-family: 'Jost', sans-serif;
  letter-spacing: 0.05em;
}

.artist-btn:hover {
  border-color: #444;
  color: #aaa;
}

.artist-btn.active {
  background: #90caf9;
  border-color: #90caf9;
  color: #121212;
  font-weight: 500;
}

.empty-state {
  text-align: center;
  color: #444;
  font-style: italic;
  padding: 3rem 0;
}

.masonry {
  column-count: 3;
  column-gap: 12px;
}

.masonry-item {
  break-inside: avoid;
  position: relative;
  margin-bottom: 12px;
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  background: #1a1a1a;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.5);
  transition: transform 0.25s, box-shadow 0.25s;
}

.masonry-item:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.7);
}

.masonry-img {
  width: 100%;
  height: auto;
  display: block;
  transition: transform 0.35s;
}

.masonry-item:hover .masonry-img {
  transform: scale(1.04);
}

.masonry-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 0.7rem 0.85rem;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.88) 0%, rgba(0, 0, 0, 0.3) 60%, transparent 100%);
  display: flex;
  flex-direction: column;
  gap: 2px;
  opacity: 0;
  transition: opacity 0.2s;
}

.masonry-item:hover .masonry-overlay {
  opacity: 1;
}

.art-title {
  font-size: 0.88rem;
  font-weight: 600;
  color: #fff;
  font-family: 'Iosevka Charon', monospace;
}

.art-artist {
  font-size: 0.7rem;
  color: #90caf9;
  letter-spacing: 0.06em;
}

.lightbox {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.92);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.lb-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  max-width: 90vw;
  max-height: 90vh;
}

.lb-img {
  max-width: 90vw;
  max-height: 80vh;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 8px 40px rgba(0, 0, 0, 0.8);
}

.lb-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.lb-title {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1rem;
  font-weight: 600;
  color: #fff;
}

.lb-artist {
  font-size: 0.78rem;
  color: #90caf9;
  letter-spacing: 0.06em;
}

.lb-close {
  position: absolute;
  top: 1.2rem;
  right: 1.4rem;
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: #aaa;
  border-radius: 6px;
  width: 36px;
  height: 36px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: all 0.15s;
}

.lb-close:hover {
  background: rgba(255, 255, 255, 0.15);
  color: #fff;
}

.lb-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: #aaa;
  border-radius: 8px;
  width: 44px;
  height: 60px;
  font-size: 1.6rem;
  cursor: pointer;
  transition: all 0.15s;
  line-height: 1;
}

.lb-nav:hover {
  background: rgba(255, 255, 255, 0.15);
  color: #fff;
}

.lb-prev {
  left: 1rem;
}

.lb-next {
  right: 1rem;
}

.lb-enter-active, .lb-leave-active {
  transition: opacity 0.2s;
}

.lb-enter-from, .lb-leave-to {
  opacity: 0;
}

@media (max-width: 700px) {
  .masonry {
    column-count: 2;
  }
}

@media (max-width: 400px) {
  .masonry {
    column-count: 1;
  }

  .lb-nav {
    display: none;
  }
}
</style>