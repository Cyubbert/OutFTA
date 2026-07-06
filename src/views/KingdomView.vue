<script setup>
const cards = [
  { name: "Lacrima", img: "/images/LacrimaBanner.png", route: "/kingdom/lacrima" },
  { name: "Dredel", img: "/images/Dredel_.png", route: "/kingdom/dredel" },
  { name: "Duweil", img: "/images/Duweil.png", route: "/kingdom/duweil" },
  { name: "Ivia", img: "/images/Ivia.png", route: "/kingdom/ivia" },
  { name: "Letlon", img: "/images/Letlon.png", route: "/kingdom/letlon" },
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