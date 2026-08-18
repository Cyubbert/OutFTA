<script setup>
import { onMounted } from "vue";
import { useWorldStore } from "../../stores/worldStore.js";
import { supabase } from "@/lib/supabase.js";
const AughImg = supabase.storage.from("images").getPublicUrl("AUGH.webp").data.publicUrl;

const store = useWorldStore();
onMounted(store.fetchWorld);
</script>

<template>
  <article class="page sans">
    <header>
      <img class="page-cover-image" :src="AughImg" alt="Cover image" />
      <h1 class="page-title">Out for the Ancients</h1>
    </header>
    <p>Welcome to this website! It is a private website made by me, Fynn. I host it on Github with my own Domain :)</p>
    <p>This website is a place to keep all my Dungeons & Dragons Lore, NPCs, Session Recaps and Homebrew spells from my own Campaign. I assume that you have gotten this link either through me, my Players or you found my github and if not then what are you doing here? ∑d(°∀°d)</p>
    <p>Either way, it is a constant work in progress and I do update the session recaps as soon as I can to keep the website updated.</p>
  </article>
</template>


