<script setup>
import { computed } from "vue";
import Lacrima from "@/assets/images/LacrimaBanner.png";
import Dredel from "@/assets/images/Dredel_.png";
import Duweil from "@/assets/images/Duweil.png";
import Ivia from "@/assets/images/Ivia.png";
import Letlon from "@/assets/images/Letlon.png";
import AughImg from "@/assets/images/AUGH.png";


const cards = [
  { name: "Lacrima", img: Lacrima,    route: "/kingdom/lacrima" },
  { name: "Dredel", img: Dredel, route: "/kingdom/dredel" },
  { name: "Duweil",  img: Duweil,  route: "/kingdom/duweil"  },
  { name: "Ivia",   img: Ivia,   route: "/kingdom/ivia"   },
  { name: "Letlon",   img: Letlon,   route: "/kingdom/letlon" }
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