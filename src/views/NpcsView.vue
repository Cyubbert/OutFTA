<script setup>
const cards = [
  { name: "Aasmias Wiltfen Galanodel", img: "/images/Aasmias_Banner.png", route: "/npcs/aasmias" },
  { name: "Aarely", img: "/images/AarelyBanner.png", route: "/npcs/aarely" },
  { name: "Virex Halden", img: "/images/VirexBanner.png", route: "/npcs/virex" },
  { name: "Moltyn Zeghal", img: "/images/Moltyn.png", route: "/npcs/moltyn" },
  { name: "Selene Witword", img: "/images/Selene_Banner.png", route: "/npcs/selene" },
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