<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { ivia } from '@/data/kingdoms.js'
</script>

<template>
  <InfoPage v-bind="ivia" />
</template>
