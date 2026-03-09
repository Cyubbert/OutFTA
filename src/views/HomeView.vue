<script setup>
import { onMounted } from "vue";
import { useWorldStore } from "../stores/worldStore";
import WorldCard from "../components/WorldCard.vue";

const store = useWorldStore();
onMounted(store.fetchWorld);
</script>

<template>


  <article class="page sans">

    <header>
      <img
          class="page-cover-image"
          src="/src/assets/images/AUGH.png"
          alt="Cover image"
      />

      <h1 class="page-title">Out for the Ancients</h1>
    </header>

    <div class="page-body">
      <div class="column-list">


        <div class="column column-small">
          <figure class="source">
            <iframe
                src="https://open.spotify.com/embed/playlist/3Frb2hSA7fBOCn4m5KpPoY"
                width="100%"
                height="380"
                frameborder="0"
                allowtransparency="true"
                allow="encrypted-media">
            </iframe>

            <button>
              <a
                  href="https://music.youtube.com/playlist?list=PLRb4N-m6OwfERLsSso2N09yZeNElRS8l4&si=1sP0Oqfo4yXKEoUg"
                  target="_blank"
                  rel="noopener noreferrer"
              >
                Youtube Playlist
              </a>
            </button>
          </figure>
        </div>


        <div class="column column-large">
          <section class="collection-content">
            <h3 class="collection-title">World &amp; Deities</h3>

            <div class="cards-container">

              <router-link to="/world/norrun" class="card">
                <img src="/src/assets/images/Map.png" alt="Norrun Icon">
                <div class="card-name">Norrun</div>
              </router-link>

              <router-link to="/world/talona" class="card">
                <img src="/src/assets/images/2.png" alt="Talona Icon">
                <div class="card-name">Talona</div>
              </router-link>

              <router-link to="/world/liira" class="card">
                <img src="/src/assets/images/Liira.png" alt="Liira Icon">
                <div class="card-name">Liira</div>
              </router-link>

              <router-link to="/world/sune" class="card">
                <img src="/src/assets/images/Illustration.png" alt="Sune Icon">
                <div class="card-name">Sune</div>
              </router-link>

            </div>
          </section>
        </div>

      </div>
    </div>

  </article>


</template>


<style>
* {
  box-sizing: border-box;
}

body {
  margin: 2em auto;
  max-width: 900px;
  font-family: ui-sans-serif, system-ui, sans-serif;
  line-height: 1.6;
  color: #e0e0e0;
  background-color: #121212;
}

.page-cover-image {
  width: 100%;
  max-height: 30vh;
  object-fit: cover;
  filter: brightness(0.75);
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 1rem 0 2rem 0;
  color: #ffffff;
  text-align: center;
}

/* ===== COLUMNS ===== */
.column-list {
  display: flex;
  gap: 2rem;
}

.column-small {
  width: 40%;
}

.column-large {
  width: 60%;
}

.source {
  border: 1px solid #333;
  border-radius: 6px;
  padding: 1.2rem;
  background-color: #1e1e1e;
  box-shadow: 0 2px 6px rgba(0,0,0,0.5);
  margin-bottom: 1rem;
}

.source iframe {
  border-radius: 6px;
}


button {
  background-color: #90caf9;
  border: none;
  border-radius: 6px;
  padding: 0.6rem 1.2rem;
  cursor: pointer;
  transition: background 0.2s, transform 0.2s;
}

button:hover {
  background-color: #64b5f6;
  transform: translateY(-2px);
}

button a {
  color: #121212;
  text-decoration: none;
  font-weight: 600;
  font-size: 1rem;
  display: inline-block;
}


.collection-title {
  margin-bottom: 0.5rem;
  color: #ffffff;
}

.cards-container {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;
  margin-top: 1rem;
}

.card {
  position: relative;
  height: 180px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 6px rgba(0,0,0,0.5);
  transition: transform 0.2s, box-shadow 0.2s;
}

.card img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.card-name {
  position: absolute;
  bottom: 0;
  width: 100%;
  text-align: center;
  padding: 0.4rem 0;
  background: rgba(0,0,0,0.55);
  color: #ffffff;
  font-weight: 600;
}

.card:hover {
  transform: translateY(-3px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.7);
}


a {
  color: #90caf9;
  text-decoration: underline;
}


@media (min-width: 1200px) {
  .cards-container {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 1024px) {
  .column-list {
    flex-direction: column;
  }

  .column-small,
  .column-large {
    width: 100%;
  }
}

@media (max-width: 768px) {
  .cards-container {
    grid-template-columns: 1fr;
  }

  .card {
    height: 260px;
  }

  .page-title {
    font-size: 2rem;
  }
}

@media (max-width: 480px) {
  .card {
    height: 260px;
  }

  .page-title {
    font-size: 1.8rem;
  }
}
</style>