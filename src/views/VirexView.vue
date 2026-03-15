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
        Efficient, distrustful, polite but threatening.
        Virex Halden, Commander Halden or Sir Halden is a 185cm tall Elf.
        He has long black straight hair that is neatly positioned on his back.
        He has a rather slim face and what stands out the most is a scar that goes across his left eye.
        One of his eyes is milky white and the other one a piercing grey.
        He wears heavy armor with the Lacrimian Royal Family Crest on it.
      </p>

      <p>
        He comes from a Noble Family in Lacrima.
        After the Galanodels retracted from their duty as the personal Guards of the Royal Family, the Halden Family took over, now mainly serving as Bodyguards for the Royal Family.
        Virex Halden is the 3rd Son of the Halden Family.
        He gave up his postion as the heir and worked hard to earn a position outside the Castle and to serve the Royal family well.
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