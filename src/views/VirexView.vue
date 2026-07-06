<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { virex } from '@/data/npcs.js'
</script>

<template>
  <InfoPage v-bind="virex" />
</template>
