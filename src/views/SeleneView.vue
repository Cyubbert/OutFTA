<script setup>

</script>

<template>


  <header class="page-header">
    <img
        class="page-cover-image"
        src="/images/Selene_Banner.png"
        alt="SeleneCover"
    />
  </header>

  <main class="container">
    <h1>Selene Witword</h1>

    <section class="section">
      <p>
        Selene Witword, a Lacrimian Commander, she stands at around 173 cm with pale pink hair that falls to her shoulders.
        She is most often seen in heavy pale rose steel armor, her shoulder plates bearing the proud crest of the Witword family.
        When her helmet is removed, it reveals a round, soft featured face, striking crimson-red eyes and a small mole beneath her right eye.

      </p>

      <p>
        Despite her bright and cheerful demeanor, Selene harbors a far more unsettling side.
        She possesses an intense curiosity, taking a particular delight in uncovering secrets others would rather keep buried.
        Blunt and unrestrained, she asks questions without hesitation or tact, never one to soften her words.
      </p>

      <p>
        She is the daughter of [redacted] and Agnes Witword. After her mother’s, Grace Witword's, death, she overtook leadership of the Witword family.
      </p>


    </section>
  </main>
</template>

<style>

.home-nav {
  position: sticky;
  top: 0;
  width: 100%;
  background-color: #1e1e1e;
  padding: 0.5rem 1rem;
  z-index: 1000;
  box-shadow: 0 2px 5px rgba(0,0,0,0.5);
}

.home-button {
  color: #90caf9;
  text-decoration: none;
  font-weight: 600;
  border: 1px solid #333;
  padding: 0.3rem 0.6rem;
  border-radius: 6px;
}

.home-button:hover {
  background-color: #90caf9;
  color: #121212;
}


.page-cover-image {
  width: 100%;
  max-height: 30vh;
  object-fit: cover;
  filter: brightness(0.75);
}

.container {
  max-width: 900px;
  margin: 2rem auto;
  padding: 0 1rem;
}

h1 {
  font-size: 2.5rem;
  color: #ffffff;
}

p {
  margin-bottom: 1.2rem;
  line-height: 1.6;
  color: #e0e0e0;
}
</style>