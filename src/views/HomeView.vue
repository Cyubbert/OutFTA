<script setup>
import { ref, computed, onMounted } from "vue";
import { useWorldStore } from "../stores/worldStore";
import MapImg from "@/assets/images/Map.png";
import TalonaImg from "@/assets/images/2.png";
import LiiraImg from "@/assets/images/Liira.png";
import SuneImg from "@/assets/images/Illustration.png";
import AughImg from "@/assets/images/AUGH.png";
import LacrimaBanner from "@/assets/images/LacrimaBanner.png";

const store = useWorldStore();
onMounted(store.fetchWorld);

// Tabs
const tabs = ["World & Deities", "Kingdoms", "NPCs"];
const activeTab = ref("World & Deities");

// Card data
const cards = [
  // World & Deities
  { name: "Norrun", img: MapImg, route: "/world/norrun", category: "World & Deities" },
  { name: "Talona", img: TalonaImg, route: "/world/talona", category: "World & Deities" },
  { name: "Liira", img: LiiraImg, route: "/world/liira", category: "World & Deities" },
  { name: "Sune", img: SuneImg, route: "/world/sune", category: "World & Deities" },


  // Kingdoms
  { name: "Lacrima", img: LacrimaBanner, route: "/kingdoms/lacrima", category: "Kingdoms" },
  { name: "Duweil", img: AughImg, route: "/kingdoms/duweil", category: "Kingdoms" },
  { name: "Ivia", img: AughImg, route: "/kingdoms/ivia", category: "Kingdoms" },
  { name: "Letlon", img: AughImg, route: "/kingdoms/letlon", category: "Kingdoms" },
  { name: "Dredel", img: AughImg, route: "/kingdoms/dredel", category: "Kingdoms" },

  // NPCs
  { name: "Aasmias Wiltfen Galanodel", img: AughImg, route: "/npcs/aasmias", category: "NPCs" },
  { name: "Aarely", img: AughImg, route: "/npcs/aarely", category: "NPCs" },
  { name: "Selene Witword", img: AughImg, route: "/npcs/selene", category: "NPCs" },
  { name: "Virex Halden", img: AughImg, route: "/npcs/virex", category: "NPCs" },
  { name: "Moltyn Zeghal", img: AughImg, route: "/npcs/moltyn", category: "NPCs" },
  { name: "Naelith", img: AughImg, route: "/npcs/naelith", category: "NPCs" },
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

.tabs {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 1.5rem;

  /* Scrollable on small screens */
  overflow-x: auto;
  padding-bottom: 0.5rem;
  scrollbar-width: thin; /* Firefox */
  scrollbar-color: #90caf9 transparent;
}

.tabs::-webkit-scrollbar {
  height: 6px;
}

.tabs::-webkit-scrollbar-track {
  background: transparent;
}

.tabs::-webkit-scrollbar-thumb {
  background-color: #90caf9;
  border-radius: 3px;
}

.tabs button {
  flex: 0 0 auto; /* Prevent shrinking */
  padding: 0.6rem 1.2rem;
  border: none;
  border-radius: 6px;
  background: #333;
  color: #fff;
  cursor: pointer;
  transition: background 0.2s;
  white-space: nowrap; /* Prevent text wrapping */
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