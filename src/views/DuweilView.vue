<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { duweil } from '@/data/kingdoms.js'
</script>

<template>
  <InfoPage v-bind="duweil" />
</template>
