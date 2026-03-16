<script setup>

</script>

<template>

  <nav class="home-nav">
    <router-link to="/" class="home-button">Home</router-link>
  </nav>

  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/Aasmias_Banner.png"
        alt="Aasmias Cover"
    />
  </header>

  <main class="container">
    <h1>Aasmias Wiltfen Galanodel</h1>

    <section class="section">
      <p>
        Aasmias is a moon elf with a rugged and battle worn appearance.
        His skin is light blue with slight purple tones and covered in several scars, showing a life of many fights.
        Unlike most elves, he has a surprisingly bushy beard, which gives him a rough and unusual look.
        His ears are fully pierced, decorated with many pieces of jewelry shaped like spider lilies and crescent moons.
        His hair is long and white usually tied into a messy bun behind his head.
        Aasmias has icy blue eyes that seem to look straight into a person’s soul.
      </p>

      <p>
        He stands about 1.80 m tall and has a noticeably muscular build, much stronger and broader than Marvers.
        In battle, Aasmias prefers strength over magic.
        He often fights in full armor and wields a large great axe, relying on power and skill rather than spells.
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