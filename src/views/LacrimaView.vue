<script setup>

</script>

<template>

  <nav class="home-nav">
    <router-link to="/" class="home-button">Home</router-link>
  </nav>


  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/Map.png"
        alt="Norrun Cover"
    />
  </header>


  <main class="container">
    <h1>Lacrima</h1>

    <section class="section">
      <h2>Ruler</h2>

      <p>
        Lacrima is currently ruled by Queen Cyria Powsky, leader of the Powsky family that has controlled the kingdom for many centuries.
        The Powsky family is closely connected to stories of dragons, great warriors and powerful magic.
        Soon to be King Allen is supported by the Queen Mother, Cyria Powsky, who is known for being very clever in politics and often influences decisions behind the scenes.
        The Powsky family and many noble houses use dragon symbols in their crests.
        Some even keep dragon bones, claws, or scales as family heirlooms to show their history and power.
      </p>

      <h2>Landscape</h2>

      <p>
        Lacrima is the largest kingdom by land mass.
        It stretches across wide plains, large forests and mountain ranges.
        Because of this mix of land, the kingdom has many natural resources and strong farming areas.
        Trade routes also pass through the land, helping the kingdom stay wealthy.
        The capital city, Wiffprint, is a huge and busy city.
        It mixes tall elven style buildings with practical human designs.
        The city is known for its royal palaces, military schools, magic academies and large markets.
      </p>

      <h2>Culture</h2>

      <p>
        The culture of Lacrima is strongly connected to family history, the military and noble traditions.
        When people marry, they wear their rings on the left index finger.
        This shows loyalty not only to their partner but also to their family and the crown.
        Many nobles are trained as soldiers and proudly show dragon related symbols or heirlooms from their family’s past.
        Education is also very important, especially magic.
        The Unison University of Magic allows common people to study magic and possibly rise in social status.
        The crown helps pay for the university so that powerful mages remain loyal to the kingdom.
        Lacrima also has a special Elemental Banking System, where magical elementals deliver deposits to people wherever they are.
      </p>

      <h2>Commonly used Languages</h2>

      <p>
        Elvish, Abyssal, Dragonic, Common
      </p>

      <h2>Known History</h2>

      <p>
        One of the most important events in Lacrima’s history is the Battle of Scaled Nature.
        This battle ended a long war involving dragons.
        Lacrima’s army, together with a famous Dragon Slayer, finally defeated the threat.
        The noble families that helped win the battle are still honored today.
        The most known families, besides The Powsky Family, are: The Galanodel Family, The Halden Family, The Witword Family, The Fortis Family, The Montmorency Family, The Abire Family and many more.
      </p>

      <h2>Belief</h2>

      <p>
        Many people in Lacrima worship Sune, the goddess of love and devotion.
        Her worship is especially strong among noble families because they value loyalty, strong relationships and family bonds.
        Believing in Sune supports the ideas of devotion and unity that hold the noble houses together.
      </p>


    </section>

    <img
        src="/src/assets/images/LacrimaMap.png"
        class="map-again"
        alt="Map of Dredel"
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