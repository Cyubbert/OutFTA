<script setup>
import { usePagesByCategory } from '@/composables/usePagesByCategory.js'
import { supabase } from '@/lib/supabase.js'

const { cards, loading, error } = usePagesByCategory('kingdom', ['lacrima', 'dredel', 'duweil', 'ivia', 'letlon'])
const AughImg = supabase.storage.from('images').getPublicUrl('AUGH.webp').data.publicUrl
</script>

<template>
  <article class="page sans">
    <header>
      <img class="page-cover-image" :src="AughImg" alt="Cover image" />
      <h1 class="page-title">Kingdom's</h1>
    </header>
    <div class="page-body">
      <section class="collection-content">
        <p v-if="loading" class="page-loading">Loading…</p>
        <p v-else-if="error" class="page-error">Couldn't load this page.</p>
        <transition-group v-else name="fade" tag="div" class="cards-container">
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
