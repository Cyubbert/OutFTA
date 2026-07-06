<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { dredel } from '@/data/kingdoms.js'
</script>

<template>
  <InfoPage v-bind="dredel" />
</template>
