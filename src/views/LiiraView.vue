<script setup>

</script>

<template>

  <nav class="home-nav">
    <router-link to="/" class="home-button">Home</router-link>
  </nav>


  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/Liira.png"
        alt="Liira Cover"
    />
  </header>


  <main class="container">
    <h1>Liira</h1>

    <section class="section">
      <p>
        Radoon's second child. Also known as Lady of Joy. It is told that
        Liira's creation occurred while Radoon was watching a sunset that shone
        on sheep clouds resting in the sky. He took one of the clouds and birthed
        Liira. They are the Goddess of Weather, Day and Night Cycle, Freedom and
        Joy. It is said that everyone has at least once met Liira when they had a
        joyous moment in their life. Any moment of joy that happened due to an
        interaction can most likely be traced back to Liira fooling around in
        the world of the living, disguising herself as one of them and living
        happily among them.
      </p>

      <p>
        A children's tale says that if you ever feel down, you can wish for good
        company and Liira will appear to lighten your mood and grant your wish.
        Whether this tale is actually true remains up for debate.
      </p>

      <p>
        In Ivia, Liira plays a central role in their beliefs, people pray to her
        for guidance through storms and to maintain their spirits.
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