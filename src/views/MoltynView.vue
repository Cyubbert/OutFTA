<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { moltyn } from '@/data/npcs.js'
</script>

<template>
  <InfoPage v-bind="moltyn" />
</template>
