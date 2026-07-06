<script setup>
const cards = [
  { name: "Norrun", img: "/images/Map.png", route: "/world/norrun" },
  { name: "Talona", img: "/images/2.png", route: "/world/talona" },
  { name: "Liira", img: "/images/Liira.png", route: "/world/liira" },
  { name: "Sune", img: "/images/Illustration.png", route: "/world/sune" },
]

const AughImg = "/images/AUGH.png"
</script>

<template>
  <article class="page sans">
    <header>
      <img class="page-cover-image" :src="AughImg" alt="Cover image" />
      <h1 class="page-title">World & Deities</h1>
    </header>
    <div class="page-body">
      <section class="collection-content">
        <transition-group name="fade" tag="div" class="cards-container">
          <router-link
              v-for="card in cards"
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
  </article>
</template>