<script setup>
import { ref, computed, onMounted } from "vue";
import { useWorldStore } from "../stores/worldStore";

const store = useWorldStore();
onMounted(store.fetchWorld);

// Tabs
const tabs = ["World & Deities", "Kingdoms", "NPCs"];
const activeTab = ref("World & Deities");

// Card data
const cards = [
  // World & Deities
  { name: "Norrun", img: "/src/assets/images/Map.png", route: "/world/norrun", category: "World & Deities" },
  { name: "Talona", img: "/src/assets/images/2.png", route: "/world/talona", category: "World & Deities" },
  { name: "Liira", img: "/src/assets/images/Liira.png", route: "/world/liira", category: "World & Deities" },
  { name: "Sune", img: "/src/assets/images/Illustration.png", route: "/world/sune", category: "World & Deities" },

  // Kingdoms
  { name: "Kingdom A", img: "/src/assets/images/kingdom-a.png", route: "/kingdoms/a", category: "Kingdoms" },
  { name: "Kingdom B", img: "/src/assets/images/kingdom-b.png", route: "/kingdoms/b", category: "Kingdoms" },

  // NPCs
  { name: "NPC 1", img: "/src/assets/images/npc1.png", route: "/npcs/1", category: "NPCs" },
  { name: "NPC 2", img: "/src/assets/images/npc2.png", route: "/npcs/2", category: "NPCs" },
];

const filteredCards = computed(() =>
    cards.filter(card => card.category === activeTab.value)
);
</script>


<template>
  <article class="page sans">

    <header>
      <img
          class="page-cover-image"
          src="/src/assets/images/AUGH.png"
          alt="Cover image"
      />

      <h1 class="page-title">Out for the Ancients</h1>

      <!-- Tabs -->
      <div class="tabs">
        <button
            v-for="tab in tabs"
            :key="tab"
            @click="activeTab = tab"
            :class="{ active: activeTab === tab }"
        >
          {{ tab }}
        </button>
      </div>
    </header>

    <div class="page-body">
      <div class="column-list">
        <div class="column column-large">
          <section class="collection-content">
            <h3 class="collection-title">{{ activeTab }}</h3>

            <!-- Fade transition for cards -->
            <transition-group name="fade" tag="div" class="cards-container">
              <router-link
                  v-for="card in filteredCards"
                  :key="card.name"
                  :to="card.route"
                  class="card"
              >
                <img :src="card.img" :alt="card.name" />
                <div class="card-name">{{ card.name }}</div>
              </router-link>
            </transition-group>

          </section>
        </div>
      </div>
    </div>

  </article>
</template>


<style>
* {
  box-sizing: border-box;
}

body {
  margin: 2em auto;
  max-width: 900px;
  font-family: ui-sans-serif, system-ui, sans-serif;
  line-height: 1.6;
  color: #e0e0e0;
  background-color: #121212;
}

.page-cover-image {
  width: 100%;
  max-height: 30vh;
  object-fit: cover;
  filter: brightness(0.75);
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 1rem 0 2rem 0;
  color: #ffffff;
  text-align: center;
}

/* ===== TABS ===== */
.tabs {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.tabs button {
  padding: 0.6rem 1.2rem;
  border: none;
  border-radius: 6px;
  background: #333;
  color: #fff;
  cursor: pointer;
  transition: background 0.2s;
}

.tabs button.active {
  background: #90caf9;
  color: #121212;
}

.tabs button:hover {
  background: #64b5f6;
  color: #fff;
}

/* ===== COLUMNS ===== */
.column-list {
  display: flex;
  gap: 2rem;
}

.column-small {
  width: 40%;
}

.column-large {
  width: 100%; /* full width to align cards */
}

.collection-title {
  margin-bottom: 0.5rem;
  color: #ffffff;
}

/* ===== CARDS ===== */
.cards-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 1.5rem;
  margin-top: 1rem;
  justify-items: center; /* center cards */
}

.card {
  position: relative;
  height: 180px;
  width: 100%;
  max-width: 220px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 6px rgba(0,0,0,0.5);
  transition: transform 0.2s, box-shadow 0.2s;
}

.card img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.card-name {
  position: absolute;
  bottom: 0;
  width: 100%;
  text-align: center;
  padding: 0.4rem 0;
  background: rgba(0,0,0,0.55);
  color: #ffffff;
  font-weight: 600;
}

.card:hover {
  transform: translateY(-3px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.7);
}

/* ===== FADE TRANSITION ===== */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.4s;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

/* ===== RESPONSIVE ===== */
@media (max-width: 1024px) {
  .column-list {
    flex-direction: column;
  }

  .column-small,
  .column-large {
    width: 100%;
  }
}

@media (max-width: 768px) {
  .cards-container {
    grid-template-columns: 1fr;
  }

  .card {
    height: 260px;
  }

  .page-title {
    font-size: 2rem;
  }
}

@media (max-width: 480px) {
  .card {
    height: 260px;
  }

  .page-title {
    font-size: 1.8rem;
  }
}
</style>