<script setup>

</script>

<template>

  <nav class="home-nav">
    <router-link to="/" class="home-button">Home</router-link>
  </nav>


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
        Aiden Hugh VII rules Dredel not from a single seat of power but by traveling constantly between its major settlements, administering the kingdom from wherever he happens to be.
        His symbol, a hammer crossed with a climbing pick, represents the unity between craftsmanship and survival, values central to Dredel’s identity.
        Rejecting the concept of a centralized capital, Aiden believes that “Dredel itself is our capital, the peaks our throne, the stone our walls” reflecting his conviction that no single city could adequately govern such a rugged and fragmented kingdom.
      </p>

      <h2>Landscape</h2>

      <p>
        Dredel is defined entirely by its mountains, whose extreme and varied terrain shapes the kingdom’s identity.
        Towering peaks, frozen northern expanses, deep ravines, volcanic crests and labyrinthine tunnels dominate the landscape.
        The Spine Peaks form the central ridge, rising as the tallest mountains in Norrun, while the Northern Frostlands are perpetually snow covered and nearly uninhabitable, home only to beasts adapted to the cold.
        Beneath the mountains lie the Crag Tunnels, an immense network of subterranean passageways dug by dwarves and gnomes, serving as vital roads when surface travel is impossible.
        Rift Valleys, created by ancient earthshaking activity, are deep chasms where settlements cling to ledges, occupy caves, or are connected by rope bridges.
        Travel across Dredel is hazardous, caravans depend on mules, giant goats, or specially trained insectoid mountain beasts capable of navigating cliffs.
      </p>

      <h2>Culture</h2>

      <p>
        Dredel’s culture is shaped by isolation and adaptation to its harsh environment.
        Communities are spread across cliffs, caves and tunnels, emphasizing self reliance, endurance and creativity.
        The kingdom places great value on craftsmanship and survival, which are intertwined symbolically and practically, as seen in the ruler’s emblem.
        Trade and travel require specialized knowledge and resilient beasts, reinforcing a culture where cooperation and ingenuity are essential for daily life.
        In such an unforgiving terrain, the people of Dredel have developed a deep respect for the land, its dangers and the skills necessary to thrive within it.
      </p>

      <h2>Languages</h2>

      <p>
        Dragonic, Dwarvish, Gnomish, Orkish, Goliath, Undercommon, Common
      </p>

      <h2>Belief</h2>

      <p>
        The people in Dredel continue to worship Radoon, likely making Dredel the only place where he is still revered as a god.
        Citizens look to Radoon as a symbol of strength, companionship and endurance.
        Qualities essential for surviving the dangerous mountains and remote settlements.
        His worship reflects the kingdom’s broader cultural values, emphasizing resilience, cooperation and the ability to thrive in even the most unforgiving terrain.
      </p>



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