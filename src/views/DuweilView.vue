<script setup>

</script>

<template>

  <nav class="home-nav">
    <router-link to="/" class="home-button">Home</router-link>
  </nav>


  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/Duweil.png"
        alt="Duweil Cover"
    />
  </header>


  <main class="container">
    <h1>Duweil</h1>

    <section class="section">
      <h2>Ruler</h2>

      <p>
        Duweil is ruled by Queen Venus Snow VI, a clever and careful leader who keeps the powerful merchant guilds under control.
        While the Trade Guild Council holds a lot of influence over the kingdom’s economy and trade, the queen remains the highest authority.
        Queen Snow maintains stability through strong alliances, secret intelligence networks and carefully negotiated treaties with other nations.
        Her rule focuses on protecting Duweil’s trade routes and keeping the wealthy merchant powers balanced.
      </p>

      <h2>Landscape</h2>

      <p>
        Duweil is a kingdom made up of twelve large islands and many smaller ones spread across the Deep Dark Ocean.
        The sea around the islands is unusually deep and dark, filled with trenches and glowing coral reefs.
        Because of this darkness, the people of Duweil rely on bioluminescent plants, magically glowing stones, trained deep sea creatures and long lantern bridges hanging over the water to light their cities and harbors.
        The islands themselves are very different from each other.
        Some are covered in thick jungles, others are volcanic and some cities are carved directly into cliffs.
        Many buildings mix stone architecture with coral and sea materials, giving Duweil’s settlements a unique coastal style.
        The capital city, Fooch, is the largest trading port and the center of the kingdom’s power.
      </p>

      <h2>Culture</h2>

      <p>
        Life in Duweil is built around trade and the sea.
        Because the kingdom sits between several continents, it has become the center of global trade and many kingdoms depend on its merchant fleets for rare goods.
        Enormous ports and floating markets connect the islands and ships from many cultures arrive every day.
        Merchant guilds are extremely powerful in Duweil, often competing with each other for control of trade routes and valuable goods.
        These rivalries sometimes lead to sabotage or spying between guilds.
        Pirates are also a constant threat on the sea, with some crews rumored to have magical powers or ties to sea monsters.
      </p>

      <h2>Languages</h2>

      <p>
        Primordial, Sylvan, Common, Elvish, Loxodon, Abyssal, Auran, Aquan
      </p>

      <h2>Inhabitants</h2>

      <p>
        Sea Elves, Sirens, Triton, Vedalken, Human, Aaracokra, Water Genasi, Tortle, Loxodon
      </p>

      <h2>Belief</h2>

      <p>
        Most people in Duweil worship The Great Tide Mother. She is seen as the goddess of the sea’s cycles, travel and fortune in trade.
        Sailors, merchants and explorers pray to her for safe journeys and successful deals.
        Her followers believe that the tides represent the rise and fall of luck, reminding them that fortune can always change like the ocean.
      </p>



    </section>

    <img
        src="/src/assets/images/DuweilMap.png"
        class="map-again"
        alt="Map of Duweil"
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