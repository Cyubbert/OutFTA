<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { lacrima } from '@/data/kingdoms.js'
</script>

<template>
  <InfoPage v-bind="lacrima" />
</template>
