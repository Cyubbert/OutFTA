<script setup>
import { computed } from "vue";
import Aasmias from "@/assets/images/Aasmias_Banner.png";
import Arrely from "@/assets/images/AarelyBanner.png";
import Virex from "@/assets/images/VirexBanner.png";
import AughImg from "@/assets/images/AUGH.png";


const cards = [
  { name: "Aasmias Wiltfen Galanodel", img: Aasmias,    route: "/npcs/aasmias" },
  { name: "Aarely", img: Arrely,    route: "/npcs/aarely" },
  { name: "Virex Halden", img: Virex,    route: "/npcs/virex" },

]
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