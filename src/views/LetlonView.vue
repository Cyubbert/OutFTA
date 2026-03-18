<script setup>

</script>

<template>


  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/Letlon.png"
        alt="Norrun Cover"
    />
  </header>


  <main class="container">
    <h1>Letlon</h1>

    <section class="section">

      <h2>Ruler</h2>

      <p>
        Letlon is ruled by Queen Joyce Farell VIII, a member of the Farell Dynasty, which has ruled the kingdom for more than 300 years.
        The Farell family is known for its strong connection to the spiritual forests that cover most of the land.
        According to tradition, the rulers maintain a special bond with the spirits and magical creatures living there.
        A unique rule of the dynasty is the Trials of the Wild.
        Future rulers are often chosen from those who survive this dangerous journey through the deep forests.
        During the trial, heirs must travel through the wild lands and earn the respect of the forest spirits.
        Because Queen Joyce VIII is growing older and does not have any children of her own, rumors say that the next ruler might not even be a Farell by blood, but someone chosen by the forest itself.
      </p>

      <h2>Landscape</h2>

      <p>
        Letlon is covered mostly by vast forests and tropical jungles.
        Much of the land is still unexplored and filled with hidden rivers, ancient ruins and strange wildlife.
        Because the forests are so dense and dangerous, most settlements are built near the outer edges of the wilderness.
        These towns act as trade centers and safe places for travelers.
        The capital city, Nay’Tal, is built high in the treetops of enormous ancient trees.
        Wooden platforms and rope bridges connect homes, temples and marketplaces above the forest floor.
        The city serves as the kingdom’s center for trade, diplomacy and magic.
      </p>

      <h2>Culture</h2>

      <p>
        Letlon’s culture is deeply connected to the forest and the spirits believed to live within it.
        Many buildings are built around or inside giant trees. Carvings of forest spirits and mythical creatures decorate the exterior of many structures.
        The people of Letlon also study the stars and the sky.
        Astronomy is very important and the kingdom keeps a detailed calendar to track celestial events and the movements of magical creatures or spirits.
        Seasonal festivals are common and celebrate both forest spirits and rare events in the sky.
      </p>

      <h2>Languages</h2>
npm
      <p>
        Common, Druidic, Sylvan, Deep Speech, Primordial
      </p>

      <h2>Inhabitants</h2>

      <p>
        Humans, Tabaxi, Aasimar, Goliath, Halfling, Orcs, Aaracokra
      </p>

      <h2>Belief</h2>

      <p>
        Beliefs in Letlon change depending on where people live.
        In the cities and settlements closer to the edges of the forest, many people worship Sune.
        In Letlon, Sune is often seen as a symbol of love for nature, harmony and the bond between people and the living world around them.
        Deeper inside the forests, beliefs shift.
        Many tribes and isolated communities worship Talona, there she is usually known as “Mother Nature.”
        Followers see her as the powerful force behind the wild forest itself both nurturing and dangerous.
        They believe she controls growth, decay and the balance of life within the deep forests.
        Because of this, religion in Letlon is closely tied to the land.
        The deeper someone lives in the forest, the more their beliefs focus on the raw power and mystery of nature.
      </p>


      <h2>Message to Leaf and Eddie</h2>

      <p>Do not overthink the information given on the website :)</p>



    </section>

    <img
        src="/src/assets/images/Letlon_Map.png"
        class="map-again"
        alt="Map of Letlon"
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