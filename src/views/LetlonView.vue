<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { letlon } from '@/data/kingdoms.js'
</script>

<template>
  <InfoPage v-bind="letlon" />
</template>
