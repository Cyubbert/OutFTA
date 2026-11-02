<script setup>
import { supabase } from '@/lib/supabase.js'
import CollectionCards from '@/components/CollectionCards.vue'

const SLUG_ORDER = ['norrun', 'talona', 'liira', 'sune']
const AughImg = supabase.storage.from('images').getPublicUrl('AUGH.webp').data.publicUrl
</script>

<template>
  <article class="page sans">
    <header>
      <img class="page-cover-image" :src="AughImg" alt="Cover image" />
      <h1 class="page-title">World & Deities</h1>
    </header>
    <div class="page-body">
      <section class="collection-content">
        <CollectionCards category="world" :slug-order="SLUG_ORDER" />
      </section>
    </div>
  </article>
</template>
