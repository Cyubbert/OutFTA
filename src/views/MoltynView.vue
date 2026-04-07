<script setup>

</script>

<template>


  <header class="page-header">
    <img
        class="page-cover-image"
        src="/images/Moltyn.png"
        alt="Moltyn Cover"
    />
  </header>

  <main class="container">
    <h1>Moltyn</h1>

    <section class="section">
      <p>
        Moltyn is a 132 year old drow, once devoted to Liira.
        She stands around 160 cm tall, with light purple skin and eyes of the same hue.
        Her long, straight hair, white with a faint purple tint, falls freely with soft bangs framing her face.
      </p>

      <p>
        She has revealed that she was born into a noble family but ultimately fled from them.
        During a coma that lasted over 70 years, her family subjected her to cruel experimentation which caused Moltyn to be part construct.
        Moltyn has also spoken of her two sisters, one older and one younger, with the elder inheriting their house.
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