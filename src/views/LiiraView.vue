<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { liira } from '@/data/worldEntities.js'
</script>

<template>
  <InfoPage v-bind="liira" />
</template>
