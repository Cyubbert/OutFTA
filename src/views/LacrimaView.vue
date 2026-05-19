<script setup>
import {ref} from 'vue'

const activeMoodboard = ref(null)

const openMoodboard = (type) => {
  activeMoodboard.value = type
}

const closeMoodboard = () => {
  activeMoodboard.value = null
}
</script>

<template>
  <header class="page-header">
    <img
        class="page-cover-image"
        src="/src/assets/images/LacrimaBanner.png"
        alt="Lacrima Cover"
    />
  </header>

  <section class="moodboard-container">
    <div class="moodboard-card" @click="openMoodboard('clothing')">
      <div class="card-overlay">
        <h3>Clothing Style</h3>
        <span class="click-text">Click to expand</span>
      </div>
    </div>

    <div class="moodboard-card instrument-card" @click="openMoodboard('instruments')">
      <div class="card-overlay">
        <h3>Common Instruments</h3>
        <span class="click-text">Click to expand</span>
      </div>
    </div>
  </section>


  <div v-if="activeMoodboard" class="moodboard-modal" @click="closeMoodboard">
    <button class="close-button" @click="closeMoodboard">&times;</button>

    <div class="modal-content" @click.stop>
      <h2 v-if="activeMoodboard === 'clothing'">Lacrimian's Clothing</h2>
      <h2 v-if="activeMoodboard === 'instruments'">Lacrima's common Instruments</h2>


      <img
          v-if="activeMoodboard === 'clothing'"
          src="/public/images/Lacrima_Fit.png"
          alt="Clothing Moodboard Detailed"
          class="moodboard-image"
      />
      <img
          v-if="activeMoodboard === 'instruments'"
          src="/public/images/Lacrima_instruments.png"
          alt="Instrument Moodboard Detailed"
          class="moodboard-image"
      />
    </div>
  </div>

  <main class="container">
    <h1>Lacrima</h1>

    <section class="section">
      <h2>Ruler</h2>
      <p>
        Lacrima is currently ruled by Queen Cyria Powsky, the Powsky family that has controlled the kingdom for many
        centuries.
        The Powsky family is deeply tied to ancient legends of dragons, heroic warriors and powerful magic that once
        flowed through the land.
        The soon to be king, Allen Powsky, receives strong guidance from the Queen Mother, Cyria Powsky.
        Known for her sharp political mind, she often influences decisions behind the scenes and plays a crucial role in
        maintaining the stability of the throne.
        Across Lacrima, the Powsky family and many noble houses display dragon symbols on their crests.
        These emblems represent power, legacy and their ancient connection to dragonkind.
        Some noble families even keep dragon bones, claws, or scales as treasured heirlooms, preserving them as symbols
        of their heritage and proof of their long standing ties to the war of scaled nature.
      </p>

      <h2>Landscape</h2>
      <p>
        Lacrima is the largest kingdom by land mass.
        It stretches across wide plains, large forests and mountain ranges.
        Because of this mix of land, the kingdom has many natural resources and strong farming areas.
        Trade routes also pass through the land, helping the kingdom stay wealthy.
        The capital city, Wiffprint, is a huge and busy city.
        It mixes tall elven style buildings with practical human designs.
        The city is known for her royal palaces, military schools, magic academies and large markets.
      </p>

      <h2>Culture</h2>
      <p>
        The culture of Lacrima is strongly connected to family history, the military and noble traditions.
        When people marry, they wear their rings on the left index finger.
        This shows loyalty not only to their partner but also to their family and the crown.
        Many nobles are trained as soldiers and proudly show dragon related symbols or heirlooms from their family’s
        past.
        Education is also very important, especially magic.
        The Unison University of Magic allows common people to study magic and possibly rise in social status.
        The crown helps pay for the university so that powerful mages remain loyal to the kingdom.
        Lacrima also has a special Elemental Banking System, where magical elementals deliver deposits to people
        wherever they are.
      </p>

      <h2>Languages</h2>
      <p>Elvish, Abyssal, Dragonic, Common</p>

      <h2>Inhabitants</h2>
      <p>Elves, Humans, Tiefling, Dragonborn</p>

      <h2>Known History</h2>
      <p>
        One of the most important events in Lacrima’s history is the Battle of Scaled Nature.
        This battle ended a long war involving dragons.
        Lacrima’s army, together with a famous knight, later known as The Dragon Slayer, finally defeated the threat.
        The noble families that helped win the battle are still honored today.
        The most known families, besides The Powsky Family, are: The Galanodel Family, The Halden Family, The Witword
        Family, The Fortis Family, The Montmorency Family, The Abire Family and many more.
      </p>

      <h2>Belief</h2>
      <p>
        Many people in Lacrima worship Sune, the goddess of love and devotion.
        Her worship is especially strong among noble families because they value loyalty, strong relationships and
        family bonds.
        Believing in Sune supports the ideas of devotion and unity that hold the noble houses together.
      </p>
    </section>

    <img
        src="/src/assets/images/LacrimaMap.png"
        class="map-again"
        alt="Map of Lacrima"
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
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.5);
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

.moodboard-container {
  max-width: 900px;
  margin: 1.5rem auto 0 auto;
  padding: 0 1rem;
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.moodboard-card {
  flex: 1;
  min-width: 280px;
  height: 150px;
  background-color: #2a2a2a;
  border-radius: 8px;
  cursor: pointer;
  overflow: hidden;
  position: relative;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  border: 1px solid #333;


  background-image: url('/images/Lacrima_Fit.png');
  background-size: cover;
  background-position: center;
}

.instrument-card {
  background-image: url('/images/Lacrima_instruments.png');
}

.moodboard-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(144, 202, 249, 0.2);
}

.card-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  transition: background 0.2s ease;
}

.moodboard-card:hover .card-overlay {
  background: rgba(0, 0, 0, 0.4);
}

.card-overlay h3 {
  color: #ffffff;
  margin: 0 0 0.5rem 0;
  font-size: 1.3rem;
}

.click-text {
  color: #90caf9;
  font-size: 0.85rem;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.moodboard-modal {
  position: fixed;
  inset: 0;
  background-color: rgba(0, 0, 0, 0.9);
  z-index: 2000;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 2rem;
}

.modal-content {
  max-width: 90%;
  max-height: 85vh;
  text-align: center;
}

.modal-content h2 {
  margin-top: 0;
  margin-bottom: 1rem;
}

.moodboard-image {
  max-width: 100%;
  max-height: 70vh;
  object-fit: contain;
  border-radius: 6px;
  box-shadow: 0 0 20px rgba(0, 0, 0, 0.8);
}

.close-button {
  position: absolute;
  top: 1.5rem;
  right: 2rem;
  background: none;
  border: none;
  color: #ffffff;
  font-size: 3rem;
  cursor: pointer;
  line-height: 1;
  transition: color 0.2s;
}

.close-button:hover {
  color: #90caf9;
}
</style>