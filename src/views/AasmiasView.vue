<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { aasmias } from '@/data/npcs.js'
</script>

<template>
  <InfoPage v-bind="aasmias" />
</template>
