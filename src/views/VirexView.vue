<script setup>

</script>

<template>

  <nav class="home-nav">
    <router-link to="/" class="home-button">Home</router-link>
  </nav>

  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/VirexBanner.png"
        alt="Sune Cover"
    />
  </header>

  <main class="container">
    <h1>Sir Virex Halden</h1>

    <section class="section">
      <p>
        Virex Halden, often called Commander Halden or Sir Halden, is known for being efficient, distrustful and polite in a way that still feels threatening.
        He stands about 185 cm tall and carries himself with strict discipline.
      </p>

      <p>
        He is an elf with long, straight black hair that falls neatly down his back.
        His face is slim and sharp, but the most noticeable feature is the scar running across his left eye.
        Because of this injury, one of his eyes has turned milky white, while the other remains a cold, piercing grey.
        Virex usually wears heavy armor marked with the Lacrimian Royal Family crest, showing his loyalty to the crown.
      </p>

      <p>
        He comes from the Halden family, a noble house in Lacrima.
        Long ago, the Galanodel family served as the personal guards of the royal family.
        When they stepped down from this duty, the Halden family took their place, becoming the main protectors of the Lacrima royal household.
      </p>

      <p>
        Rather than becoming another close aide to the Lacrimian royal family, he gave up his position as an heir.
        Instead, he chose to rise through the ranks through discipline and service, eventually earning the rank of Commander.
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