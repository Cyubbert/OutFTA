<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { talona } from '@/data/worldEntities.js'
</script>

<template>
  <InfoPage v-bind="talona" />
</template>
