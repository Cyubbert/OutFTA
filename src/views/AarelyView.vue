<script setup>

</script>

<template>

  <nav class="home-nav">
    <router-link to="/" class="home-button">Home</router-link>
  </nav>

  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/AarelyBanner.png"
        alt="Aarely Cover"
    />
  </header>

  <main class="container">
    <h1>Aarely</h1>

    <section class="section">
      <p>
        HELP ME, GET ME OUT OF GUARDIANS HEIGHT, ITS BEEN 7 DAYS, THERE IS NO FOOD LEFT, THE INFECTED ARE-
        Aarely is a slim man standing about 183 cm tall.
        He has gray blonde hair and pale, almost white eyes that give him a distant and calm appearance.
        His hair is tied into a long braid that rests down his back.
      </p>

      <p>
        He wears a long white gown that hides most of his body, making it difficult to see his true build.
        Only his slender hands emerge from the wide, puffy sleeves and part of his upper body is hugged by a black top.
        Covering the top of his head in a thin white cloth, slightly translucent, allowing hints of his hair to be seen beneath it.
      </p>

      <p>
        Aarely is a monk devoted to The Leader of the Pale Sun, his clothing and quiet presence reflect the purity and discipline most followers portray of this faith.
        His pale garments and calm movements make him appear almost ghostlike, as if he carries a piece of the pale sun’s light with him wherever he goes.
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