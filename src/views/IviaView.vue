<script setup>

</script>

<template>

  <nav class="home-nav">
    <router-link to="/" class="home-button">Home</router-link>
  </nav>


  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/Ivia.png"
        alt="Ivia Cover"
    />
  </header>


  <main class="container">
    <h1>Ivia</h1>

    <section class="section">
      <h2>Ruler</h2>

      <p>
        The ruler of Ivia died three years ago under unclear circumstances, leaving the kingdom without a clear heir.
        Since then, two powerful claimants have risen, each reaching the throne.
        Both have gathered supporters among nobles, military leaders and city states.
        Because neither side has fully won, the kingdom remains divided and tense.
        <br><br>
        The capital city, Yoasthood, has become the center of this struggle.
        Alliances shift often and nobles, merchants and adventurers quietly choose sides.
        Rumors, secret deals and political games are common as each claimant tries to gain control.
      </p>

      <h2>Landscape</h2>

      <p>
        Ivia is the most isolated kingdom in Norrun, made up of wide deserts and golden savannahs.
        Life is centered around scattered oasis settlements, which provide water, farming land and places for trade caravans to rest.
        Some regions are fertile near the oases, while the deeper deserts are harsh and dangerous.
        Nomadic tribes travel across the sands and savannahs, living far from the cities.
        The climate is extremely hot, with burning sunlight during the day and cooler nights.
        Water is one of the most scarce resources in the kingdom.
        The capital, Yoasthood, is a large oasis city filled with tall sandstone buildings, canals that carry precious water through the streets and massive markets full of spices, cloth, and rare goods.
      </p>

      <h2>Culture</h2>

      <p>
        One of Ivia’s most famous traditions is called The Spine Tale.
        In Ivian culture, tattoos are not viewd as a decoration but a record of a person’s life.
        These tattoos are called Istoriya Nochnick, meaning “spine tales.”
        They are placed along the spine and read from the top down like a living story.
      </p>

      <h2>Languages</h2>

      <p>
        Abyssal, Celestial, Primordial, Infernal, Common
      </p>

      <h2>Inhabitants</h2>

      <p>
        Tieflings, Humans, Vedalken, Aasimar, Genasi
      </p>

      <h2>Belief</h2>

      <p>
        Many people in Ivia follow Liira, often worshipped through desert spirits, sun gods and ancestral guardians.
        These beliefs are tied closely to the land and the survival of the people.
        Temples are not only places of worship but also centers of learning, where magic, healing and spiritual guidance are taught.
      </p>



    </section>

    <img
        src="/src/assets/images/IviaMap.png"
        class="map-again"
        alt="Map of Ivia"
    />
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

h2 {
  margin-top: 2rem;
  color: #ffffff;
}

p {
  margin-bottom: 1.2rem;
  line-height: 1.6;
}

.map-again {
  width: 80%;
  display: block;
  margin: 2rem auto;
}
</style>