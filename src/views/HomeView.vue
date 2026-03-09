<script setup>
import { ref, computed } from "vue";
import { useWorldStore } from "../stores/worldStore";

const store = useWorldStore();

const tabs = ["World & Deities", "Kingdoms", "NPCs"];
const activeTab = ref("World & Deities");

const cards = [
  { name: "Norrun", img: "/src/assets/images/Map.png", route: "/world/norrun", category: "World & Deities" },
  { name: "Talona", img: "/src/assets/images/2.png", route: "/world/talona", category: "World & Deities" },
  { name: "Liira", img: "/src/assets/images/Liira.png", route: "/world/liira", category: "World & Deities" },
  { name: "Sune", img: "/src/assets/images/Illustration.png", route: "/world/sune", category: "World & Deities" },

  { name: "Kingdom A", img: "/src/assets/images/kingdom-a.png", route: "/kingdoms/a", category: "Kingdoms" },
  { name: "Kingdom B", img: "/src/assets/images/kingdom-b.png", route: "/kingdoms/b", category: "Kingdoms" },

  { name: "NPC 1", img: "/src/assets/images/npc1.png", route: "/npcs/1", category: "NPCs" },
  { name: "NPC 2", img: "/src/assets/images/npc2.png", route: "/npcs/2", category: "NPCs" },
];

const filteredCards = computed(() => cards.filter(card => card.category === activeTab.value));
</script>

<template>
  <article class="page sans">
    <header>
      <h1 class="page-title">Out for the Ancients</h1>
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

    <div class="cards-container">
      <router-link
          v-for="card in filteredCards"
          :key="card.name"
          :to="card.route"
          class="card"
      >
        <img :src="card.img" :alt="card.name" />
        <div class="card-name">{{ card.name }}</div>
      </router-link>
    </div>
  </article>
</template>


<style>
.tabs {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
  justify-content: center;
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
</style>