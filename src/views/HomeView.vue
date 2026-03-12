<script setup>
import { ref, computed, onMounted } from "vue";
import { useWorldStore } from "../stores/worldStore";
import MapImg from "@/assets/images/Map.png";
import TalonaImg from "@/assets/images/2.png";
import LiiraImg from "@/assets/images/Liira.png";
import SuneImg from "@/assets/images/Illustration.png";
import AughImg from "@/assets/images/AUGH.png";
import LacrimaBanner from "@/assets/images/LacrimaBanner.png";
import DredelBanner from "@/assets/images/Dredel_.png";
import IviaBanner from "@/assets/images/Ivia.png";
import DuweilBanner from "@/assets/images/Duweil.png";
import LetlonBanner from "@/assets/images/Letlon.png";

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
  { name: "Duweil", img: DuweilBanner, route: "/kingdoms/duweil", category: "Kingdoms" },
  { name: "Ivia", img: IviaBanner, route: "/kingdoms/ivia", category: "Kingdoms" },
  { name: "Letlon", img: LetlonBanner, route: "/kingdoms/letlon", category: "Kingdoms" },
  { name: "Dredel", img: DredelBanner, route: "/kingdoms/dredel", category: "Kingdoms" },

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
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.8rem;
  margin-top: 1.5rem;
}

.card {
  position: relative;
  height: 200px;
  width: 100%;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;

  background: #1a1a1a;
  box-shadow: 0 4px 14px rgba(0,0,0,0.5);

  transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.card img {
  width: 100%;
  height: 100%;
  object-fit: cover;

  transform: scale(1);
  transition: transform 0.35s ease;
}

/* Gradient Overlay */
.card::after {
  content: "";
  position: absolute;
  inset: 0;

  background: linear-gradient(
      to top,
      rgba(0,0,0,0.85) 0%,
      rgba(0,0,0,0.35) 40%,
      rgba(0,0,0,0) 70%
  );
}

/* Card title */
.card-name {
  position: absolute;
  bottom: 14px;
  left: 16px;
  right: 16px;

  z-index: 2;

  font-size: 1.1rem;
  font-weight: 700;
  color: white;
  letter-spacing: 0.02em;
}

/* Hover animation */
.card:hover {
  transform: translateY(-6px);
  box-shadow: 0 10px 24px rgba(0,0,0,0.7);
}

.card:hover img {
  transform: scale(1.08);
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
    height: 240px;
  }

  .collection-title{
    margin-left:0.8rem;
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

  .collection-title{
    margin-left:0.8rem;
  }
}
</style>