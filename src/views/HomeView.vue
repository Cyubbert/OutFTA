<script setup>
import { onMounted } from "vue";
import { useWorldStore } from "../stores/worldStore";
const AughImg = "/images/AUGH.png";

const store = useWorldStore();
onMounted(store.fetchWorld);
</script>

<template>
  <article class="page sans">
    <header>
      <img class="page-cover-image" :src="AughImg" alt="Cover image" />
      <h1 class="page-title">Out for the Ancients</h1>
    </header>
    <p>Welcome to this website! It is a private website made by me, Fynn. I host it on Github with my own Domain :)</p>
    <p>This website is a place to keep all my Dungeons & Dragons Lore, NPCs, Session Recaps and Homebrew spells from my own Campaign. I assume that you have gotten this link either through me, my Players or you found my github and if not then what are you doing here? ∑d(°∀°d)</p>
    <p>Either way, it is a constant work in progress and I do update the session recaps as soon as I can to keep the website updated.</p>
  </article>
</template>



<style>

@import url('https://fonts.googleapis.com/css2?family=Iosevka+Charon:ital,wght@0,300;0,400;0,500;0,700;1,300;1,400;1,500;1,700&family=Jost:ital,wght@0,100..900;1,100..900&display=swap');

* {
  box-sizing: border-box;
}

body {
  margin: 2em auto;
  max-width: 900px;
  font-family: 'Jost', ui-sans-serif, system-ui, sans-serif; /* Jost als Basis */
  line-height: 1.6;
  color: #e0e0e0;
  background-color: #121212;
  padding: 0 1rem;
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
  font-family: 'Iosevka Charon', monospace;
  letter-spacing: 0.04em;
}

.tabs {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 1.5rem;
  overflow-x: auto;
  padding-bottom: 0.5rem;
  scrollbar-width: thin;
  scrollbar-color: #90caf9 transparent;
}

.tabs::-webkit-scrollbar {
  height: 6px;
}

.tabs::-webkit-scrollbar-track {
  background: transparent;
}

.tabs::-webkit-scrollbar-thumb {
  background-color: #90caf9;
  border-radius: 3px;
}

.tabs button {
  flex: 0 0 auto;
  padding: 0.6rem 1.2rem;
  border: none;
  border-radius: 6px;
  background: #333;
  color: #fff;
  cursor: pointer;
  transition: background 0.2s;
  white-space: nowrap;
  font-family: 'Jost', sans-serif;
  font-weight: 500;
  letter-spacing: 0.05em;
}

.tabs button.active {
  background: #90caf9;
  color: #121212;
}

.tabs button:hover {
  background: #64b5f6;
  color: #fff;
}

.column-list {
  display: flex;
  gap: 2rem;
}

.column-small {
  width: 40%;
}

.column-large {
  width: 100%;
}

.collection-title {
  margin-bottom: 0.5rem;
  color: #ffffff;
  font-family: 'Iosevka Charon', monospace;
  font-weight: 400;
  letter-spacing: 0.06em;
}


.cards-container {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.8rem;
  margin-top: 1.5rem;
}

.card {
  position: relative;
  height: 200px;
  width: 100%;
  border-radius: 12px;
  overflow: hidden;
  cursor: pointer;

  background: #1a1a1a;
  box-shadow: 0 4px 14px rgba(0,0,0,0.5);

  transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.card img {
  width: 100%;
  height: 100%;
  object-fit: cover;

  transform: scale(1);
  transition: transform 0.35s ease;
}


.card::after {
  content: "";
  position: absolute;
  inset: 0;

  background: linear-gradient(
      to top,
      rgba(0,0,0,0.85) 0%,
      rgba(0,0,0,0.35) 40%,
      rgba(0,0,0,0) 70%
  );
}


.card-name {
  position: absolute;
  bottom: 14px;
  left: 16px;
  right: 16px;
  z-index: 2;
  font-size: 1.1rem;
  font-weight: 500;
  color: white;
  letter-spacing: 0.04em;
  font-family: 'Jost', sans-serif;
}


.card:hover {
  transform: translateY(-6px);
  box-shadow: 0 10px 24px rgba(0,0,0,0.7);
}

.card:hover img {
  transform: scale(1.08);
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
    height: 240px;
  }

  .collection-title{
    margin-left:0.8rem;
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

  .collection-title{
    margin-left:0.8rem;
  }
}
</style>