<script setup>
import InfoPage from '@/components/InfoPage.vue'
import { usePageData } from '@/composables/usePageData.js'

const { data, loading, error } = usePageData('duweil')
</script>

<template>
  <p v-if="loading" class="page-loading">Loading…</p>
  <p v-else-if="error" class="page-error">Couldn't load this page.</p>
  <InfoPage v-else v-bind="data" />
</template>
