<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { sune } from '@/data/worldEntities.js'
</script>

<template>
  <InfoPage v-bind="sune" />
</template>
