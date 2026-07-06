<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { selene } from '@/data/npcs.js'
</script>

<template>
  <InfoPage v-bind="selene" />
</template>
