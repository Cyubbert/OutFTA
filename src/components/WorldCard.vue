<script setup>
defineProps(["id", "data"]);
</script>

<template>

  <router-link :to="`/world/${id}`" class="card">
    <img :src="`/src/assets/images/${data.image}`" />
    <div class="card-name">{{ data.title }}</div>
  </router-link>

</template>

<style>

</style>