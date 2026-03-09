<script setup>
import { ref } from "vue";
import cover from "@/assets/images/AUGH.png";
import norrun from "@/assets/images/Map.png";
import talona from "@/assets/images/2.png";
import liira from "@/assets/images/Liira.png";
import sune from "@/assets/images/Illustration.png";

const activeTab = ref("world");

const tabs = [
  { id: "world", label: "World & Deities" },
  { id: "kingdoms", label: "Kingdoms" },
  { id: "spells", label: "Spells" },
];

const cardsByTab = {
  world: [
    { name: "Norrun", img: norrun, link: "/world/norrun" },
    { name: "Talona", img: talona, link: "/world/talona" },
    { name: "Liira", img: liira, link: "/world/liira" },
    { name: "Sune", img: sune, link: "/world/sune" },
  ],
  kingdoms: [
    { name: "Lacrima", img: cover, link: "#" },
    { name: "Letlon", img: cover, link: "#" },
  ],
  spells: [
    { name: "Fireball", img: cover, link: "#" },
    { name: "Healing", img: cover, link: "#" },
  ],
};

</script>

<template>
  <article class="page sans">
    <header>
      <img class="page-cover-image" :src="cover" alt="Cover image" />
      <h1 class="page-title">Out for the Ancients</h1>
    </header>

    <main class="container">

      <!-- Rechte Seite: Tabs + Cards -->
      <div class="content">
        <!-- Tabs -->
        <div class="tabs">
          <button
              v-for="tab in tabs"
              :key="tab.id"
              :class="['tab', { active: activeTab === tab.id }]"
              @click="activeTab = tab.id"
          >
            {{ tab.label }}
          </button>
          <div class="tab-indicator" :style="{ transform: `translateX(${tabs.findIndex(t => t.id === activeTab) * 100}%)` }"></div>
        </div>

        <!-- Karten -->
        <transition-group
            name="fade-slide"
            tag="div"
            class="cards-container"
            key="activeTab"
        >
          <div v-for="card in cardsByTab[activeTab]" :key="card.name" class="card-wrapper">
            <router-link :to="card.link" class="card">
              <img :src="card.img" :alt="card.name" />
              <div class="card-name">{{ card.name }}</div>
            </router-link>
          </div>
        </transition-group>
      </div>
    </main>
  </article>
</template>


<style>
.page-title {
  text-align: center;
  margin: 1rem 0 2rem 0;
  color: #ffffff;
  font-size: 2.5rem;
  font-weight: 700;
}

/* Container */
.container {
  display: flex;
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

/* Rechte Seite: Tabs + Cards */
.content {
  flex: 1;
}

/* Tabs */
.tabs {
  position: relative;
  display: flex;
  justify-content: flex-start;
  gap: 1rem;
  margin-bottom: 2rem;
}

.tab {
  padding: 0.5rem 1.2rem;
  background: #1e1e1e;
  color: #90caf9;
  border: 1px solid #333;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
}

.tab:hover {
  background-color: #90caf9;
  color: #121212;
}

.tab.active {
  background-color: #90caf9;
  color: #121212;
}

/* Animated Tab Indicator */
.tab-indicator {
  position: absolute;
  bottom: -4px;
  left: 0;
  width: calc(100% / 3);
  height: 4px;
  background-color: #64b5f6;
  border-radius: 2px;
  transition: transform 0.3s ease;
}

/* Cards */
.cards-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 2rem;
}

.card-wrapper {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.card {
  position: relative;
  height: 180px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 3px 8px rgba(0,0,0,0.6);
  transition: transform 0.3s, box-shadow 0.3s;
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
  padding: 0.5rem 0;
  background: rgba(0,0,0,0.55);
  color: #fff;
  font-weight: 600;
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 6px 16px rgba(0,0,0,0.7);
}

/* Transition for tab cards */
.fade-slide-enter-active, .fade-slide-leave-active {
  transition: all 0.4s ease;
}
.fade-slide-enter-from {
  opacity: 0;
  transform: translateY(20px);
}
.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(-20px);
}

</style>