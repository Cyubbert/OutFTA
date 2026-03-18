<script setup>

</script>

<template>


  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/Illustration.png"
        alt="Sune Cover"
    />
  </header>

  <main class="container">
    <h1>Sune</h1>

    <section class="section">
      <p>
        Radoon's youngest daughter, also known as the Guardian of Love. Sune was
        created through the first kiss Radoon shared with his wife, Tymora.
        Tymora came late into Radoon's life and was essentially only Sune's
        mother. Both Radoon and Tymora loved Sune deeply, which is why she became
        the Goddess of Love, Peace, Life, Light, Beauty, and Passion. Sune is
        often represented as a creature holding many different shapes and forms
        in one being. Her round body and long blonde hair represent the softness
        that love and peace can bring. Her horns, tails, and different shaped
        limbs represent the equality between every being on Norrun, showing that
        everyone deserves love and light, and that beauty holds a different
        meaning for every culture.
      </p>

      <p>
        Sune has many believers on Norrun. Every culture has its own
        interpretation of her. She may not be seen as a powerful deity by
        everyone, but she exists as a god in every culture. In large cities,
        temples are often built in her honor.
      </p>

      <p>
        Tales are often told about her bringing people together in romance.
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