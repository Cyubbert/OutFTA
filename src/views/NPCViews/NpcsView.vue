<script setup>
import { supabase } from '@/lib/supabase.js'
import CollectionCards from '@/components/CollectionCards.vue'

const SLUG_ORDER = ['aasmias', 'aarely', 'virex', 'moltyn', 'selene']
const AughImg = supabase.storage.from('images').getPublicUrl('AUGH.webp').data.publicUrl
</script>

<template>
  <article class="page sans">
    <header>
      <img class="page-cover-image" :src="AughImg" alt="Cover image" />
      <h1 class="page-title">NPCs</h1>
    </header>
    <div class="page-body">
      <section class="collection-content">
        <CollectionCards category="npc" :slug-order="SLUG_ORDER" />
      </section>
    </div>
  </article>
</template>
