<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { norrun } from '@/data/worldEntities.js'
</script>

<template>
  <InfoPage v-bind="norrun" />
</template>
