<script setup>
import { computed } from "vue";
import MapImg from "@/assets/images/Map.png";
import TalonaImg from "@/assets/images/2.png";
import LiiraImg from "@/assets/images/Liira.png";
import SuneImg from "@/assets/images/Illustration.png";
import AughImg from "@/assets/images/AUGH.png";

const cards = [
  { name: "Norrun", img: MapImg,    route: "/world/norrun" },
  { name: "Talona", img: TalonaImg, route: "/world/talona" },
  { name: "Liira",  img: LiiraImg,  route: "/world/liira"  },
  { name: "Sune",   img: SuneImg,   route: "/world/sune"   },
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