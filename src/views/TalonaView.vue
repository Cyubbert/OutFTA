<script setup>

</script>

<template>

  <nav class="home-nav">
    <router-link to="/" class="home-button">Home</router-link>
  </nav>


  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/2.png"
        alt="Talona Cover"
    />
  </header>


  <main class="container">
    <h1>Talona</h1>

    <section class="section">
      <p>
        She is the oldest daughter of Radoon, also known as the Mother of All Plagues.
        He created her from clay gathered in a deep forest, now called Talonite Woods in Letlon.
        Radoon made Talona to be his closest ally, but he never treated her as his own child.
        Instead, he saw her as a useful tool to build Norrun from the ground up.
        She is the Goddess of Nature, Disease, Plants, Death, Recreation, and Vengeance.
      </p>

      <p>
        Talona is known as a jealous deity. Most fear her, so she has few believers.
        History records her as a pest who follows her two younger sisters,
        seeking revenge for not being as loved or beautiful as they are.
        Unlike her sisters, Talona was not created through an emotion,
        making her the only daughter whose creation did not bind Radoon to remain a demigod forever.
      </p>

      <p>
        Paladins and Clerics who draw their powers from Talona are widely feared.
        Many assume these believers harbor deep hatred and destructive emotions.
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