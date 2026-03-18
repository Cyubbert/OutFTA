<script setup>
import { ref, computed } from "vue";
import AughImg from "@/assets/images/AUGH.png";

const round = ref(1);
const currentIndex = ref(0);
const combatants = ref([]);
let nextId = 1;

const newName = ref("");
const newInit = ref(10);
const newHp = ref(20);
const newType = ref("player");

const conditions = [
  { key: "prone",         icon: "⬇", label: "Liegend" },
  { key: "stunned",       icon: "💫", label: "Betäubt" },
  { key: "poisoned",      icon: "☠",  label: "Vergiftet" },
  { key: "blinded",       icon: "👁",  label: "Blind" },
  { key: "frightened",    icon: "😱", label: "Verängstigt" },
  { key: "concentrating", icon: "🔮", label: "Konzentration" },
];

const sorted = computed(() =>
    [...combatants.value].sort((a, b) => b.initiative - a.initiative)
);

const activeCard = computed(() => sorted.value[currentIndex.value] ?? null);

function addCombatant() {
  combatants.value.push({
    id: nextId++,
    name: newName.value || (newType.value === "player" ? "Spieler" : "Gegner"),
    initiative: newInit.value,
    hp: newHp.value,
    maxHp: newHp.value,
    type: newType.value,
    conditions: [],
  });
  newName.value = "";
  newInit.value = 10;
  newHp.value = 20;
}

function remove(id) {
  combatants.value = combatants.value.filter((c) => c.id !== id);
  if (currentIndex.value >= sorted.value.length) currentIndex.value = 0;
}

function adjustHp(c, delta) {
  c.hp = Math.max(0, c.hp + delta);
}

function toggleCondition(c, key) {
  const idx = c.conditions.indexOf(key);
  if (idx === -1) c.conditions.push(key);
  else c.conditions.splice(idx, 1);
}

function nextTurn() {
  if (!sorted.value.length) return;
  currentIndex.value = (currentIndex.value + 1) % sorted.value.length;
  if (currentIndex.value === 0) round.value++;
}

function prevTurn() {
  if (!sorted.value.length) return;
  if (currentIndex.value === 0) {
    if (round.value > 1) { round.value--; currentIndex.value = sorted.value.length - 1; }
  } else {
    currentIndex.value--;
  }
}

function resetCombat() {
  if (!confirm("Kampf wirklich zurücksetzen?")) return;
  combatants.value = [];
  round.value = 1;
  currentIndex.value = 0;
}
</script>

<template>

  <nav class="home-nav">
    <router-link to="/" class="home-button">Home</router-link>
  </nav>

  <article class="page sans">

    <header>
      <img class="page-cover-image" :src="AughImg" alt="Cover image" />
      <h1 class="page-title">Kampf</h1>

      <!-- Round + controls bar -->
      <div class="fight-topbar">
        <div class="round-display">
          <span class="round-label">Runde</span>
          <span class="round-num">{{ round }}</span>
        </div>

        <div class="turn-controls">
          <button class="tab-btn" @click="prevTurn" :disabled="!sorted.length">◀ Zurück</button>
          <button class="tab-btn active" @click="nextTurn" :disabled="!sorted.length">Nächste ▶</button>
        </div>

        <button class="reset-btn" @click="resetCombat" title="Kampf zurücksetzen">↺ Reset</button>
      </div>

      <!-- Active banner -->
      <div class="active-banner" v-if="activeCard">
        Am Zug: <strong>{{ activeCard.name }}</strong>
      </div>
    </header>

    <div class="page-body">

      <!-- Combatant list -->
      <section class="collection-content">
        <h3 class="collection-title">Teilnehmer</h3>

        <div v-if="!sorted.length" class="empty-state">
          Noch keine Teilnehmer – füge unten Charaktere hinzu.
        </div>

        <transition-group name="fade" tag="div" class="combatants-list">
          <div
              v-for="(c, i) in sorted"
              :key="c.id"
              class="combatant-row"
              :class="{
              'row-active': i === currentIndex,
              'row-dead':   c.hp <= 0,
              'row-player': c.type === 'player',
              'row-enemy':  c.type === 'enemy',
            }"
          >
            <!-- Initiative badge -->
            <div class="init-badge">{{ c.initiative }}</div>

            <!-- Name + type -->
            <div class="row-info">
              <input class="name-input" v-model="c.name" placeholder="Name..." />
              <span class="type-tag" :class="c.type">{{ c.type === 'player' ? 'SC' : 'NSC' }}</span>
            </div>

            <!-- HP -->
            <div class="hp-block">
              <button class="hp-btn" @click="adjustHp(c, -1)">−</button>
              <span class="hp-val" :class="{ critical: c.hp > 0 && c.hp <= c.maxHp * 0.25 }">
                {{ c.hp }}
              </span>
              <span class="hp-sep">/</span>
              <input class="hp-max" type="number" v-model.number="c.maxHp" min="1" />
              <button class="hp-btn" @click="adjustHp(c, 1)">+</button>
            </div>

            <!-- Conditions -->
            <div class="conditions">
              <button
                  v-for="cond in conditions"
                  :key="cond.key"
                  class="cond-btn"
                  :class="{ active: c.conditions.includes(cond.key) }"
                  :title="cond.label"
                  @click="toggleCondition(c, cond.key)"
              >{{ cond.icon }}</button>
            </div>

            <button class="remove-btn" @click="remove(c.id)" title="Entfernen">✕</button>
          </div>
        </transition-group>
      </section>

      <!-- Add panel -->
      <section class="add-panel">
        <h3 class="collection-title">Hinzufügen</h3>
        <div class="add-row">
          <select v-model="newType" class="add-select">
            <option value="player">SC</option>
            <option value="enemy">NSC</option>
          </select>
          <input class="add-input" v-model="newName" placeholder="Name" @keyup.enter="addCombatant" />
          <div class="num-group">
            <label>Init</label>
            <input class="num-input" type="number" v-model.number="newInit" />
          </div>
          <div class="num-group">
            <label>HP</label>
            <input class="num-input" type="number" v-model.number="newHp" min="1" />
          </div>
          <button class="tab-btn active add-confirm-btn" @click="addCombatant">+ Hinzufügen</button>
        </div>
      </section>

    </div>
  </article>
</template>

<style scoped>
/* ── Base (inherits body styles from global CSS) ── */
.page {
  margin: 2em auto;
  max-width: 900px;
  padding: 0 1rem;
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 1rem 0 1.5rem;
  color: #ffffff;
  text-align: center;
}

/* ── Top bar ── */
.fight-topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin-bottom: 1rem;
}

.round-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 56px;
}
.round-label {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.15em;
  color: #888;
}
.round-num {
  font-size: 1.8rem;
  font-weight: 700;
  color: #90caf9;
  line-height: 1;
}

.turn-controls {
  display: flex;
  gap: 0.75rem;
}

/* Reuse tab button style from global */
.tab-btn {
  flex: 0 0 auto;
  padding: 0.6rem 1.2rem;
  border: none;
  border-radius: 6px;
  background: #333;
  color: #fff;
  cursor: pointer;
  transition: background 0.2s;
  white-space: nowrap;
  font-size: 0.9rem;
}
.tab-btn.active {
  background: #90caf9;
  color: #121212;
}
.tab-btn:hover:not(:disabled) {
  background: #64b5f6;
  color: #fff;
}
.tab-btn:disabled {
  opacity: 0.35;
  cursor: default;
}
.tab-btn.active:disabled {
  opacity: 0.35;
}

.reset-btn {
  padding: 0.5rem 1rem;
  border: 1px solid #444;
  border-radius: 6px;
  background: transparent;
  color: #888;
  cursor: pointer;
  font-size: 0.85rem;
  transition: color 0.2s, border-color 0.2s;
}
.reset-btn:hover { color: #ef9a9a; border-color: #ef9a9a; }

/* ── Active banner ── */
.active-banner {
  text-align: center;
  font-size: 0.95rem;
  color: #888;
  margin-bottom: 1.5rem;
  letter-spacing: 0.05em;
}
.active-banner strong { color: #90caf9; font-size: 1.05rem; }

/* ── Section titles (match .collection-title) ── */
.collection-title {
  margin-bottom: 0.75rem;
  color: #ffffff;
  font-size: 1rem;
  font-weight: 600;
}

/* ── Empty state ── */
.empty-state {
  color: #555;
  font-style: italic;
  font-size: 0.95rem;
  padding: 1.5rem 0;
  text-align: center;
}

/* ── Combatant rows ── */
.combatants-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 2rem;
}

.combatant-row {
  display: flex;
  align-items: center;
  gap: 10px;
  background: #1a1a1a;
  border-radius: 12px;
  padding: 0.65rem 1rem;
  border-left: 3px solid transparent;
  box-shadow: 0 4px 14px rgba(0,0,0,0.5);
  transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
}
.combatant-row:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0,0,0,0.6);
}
.row-player { border-left-color: #1a4a6b; }
.row-enemy  { border-left-color: #6b1a1a; }
.row-active {
  border-left-color: #90caf9 !important;
  background: #1c2130;
}
.row-dead { opacity: 0.4; }

/* Initiative badge */
.init-badge {
  font-size: 1.2rem;
  font-weight: 700;
  color: #90caf9;
  min-width: 32px;
  text-align: center;
}

/* Name + type */
.row-info {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}
.name-input {
  background: transparent;
  border: none;
  border-bottom: 1px solid #333;
  color: #e0e0e0;
  font-size: 0.95rem;
  font-family: inherit;
  padding: 2px 4px;
  width: 100%;
  outline: none;
  transition: border-color 0.2s;
}
.name-input:focus { border-bottom-color: #90caf9; }

.type-tag {
  font-size: 0.6rem;
  letter-spacing: 0.1em;
  padding: 2px 7px;
  border-radius: 4px;
  font-weight: 600;
  white-space: nowrap;
  text-transform: uppercase;
}
.type-tag.player { background: #0e2233; color: #90caf9; }
.type-tag.enemy  { background: #2a0e0e; color: #ef9a9a; }

/* HP block */
.hp-block {
  display: flex;
  align-items: center;
  gap: 4px;
}
.hp-btn {
  background: #333;
  border: none;
  color: #bbb;
  border-radius: 4px;
  width: 22px;
  height: 22px;
  font-size: 1rem;
  cursor: pointer;
  line-height: 1;
  transition: background 0.15s, color 0.15s;
}
.hp-btn:hover { background: #90caf9; color: #121212; }
.hp-val {
  font-size: 1rem;
  font-weight: 600;
  color: #e0e0e0;
  min-width: 24px;
  text-align: right;
}
.hp-val.critical { color: #ef9a9a; }
.hp-sep { color: #444; font-size: 0.85rem; }
.hp-max {
  background: transparent;
  border: none;
  color: #555;
  font-size: 0.85rem;
  font-family: inherit;
  width: 32px;
  outline: none;
}

/* Conditions */
.conditions {
  display: flex;
  gap: 3px;
}
.cond-btn {
  background: #222;
  border: 1px solid #333;
  border-radius: 4px;
  width: 24px;
  height: 24px;
  font-size: 0.7rem;
  cursor: pointer;
  opacity: 0.35;
  transition: opacity 0.15s, border-color 0.15s;
  padding: 0;
}
.cond-btn:hover { opacity: 0.7; }
.cond-btn.active { opacity: 1; border-color: #90caf9; }

/* Remove */
.remove-btn {
  background: none;
  border: none;
  color: #444;
  cursor: pointer;
  font-size: 0.8rem;
  padding: 4px;
  transition: color 0.15s;
}
.remove-btn:hover { color: #ef9a9a; }

/* ── Add panel ── */
.add-panel {
  background: #1a1a1a;
  border-radius: 12px;
  padding: 1rem 1.2rem;
  box-shadow: 0 4px 14px rgba(0,0,0,0.5);
}
.add-row {
  display: flex;
  gap: 8px;
  align-items: flex-end;
  flex-wrap: wrap;
}
.add-select, .add-input, .num-input {
  background: #121212;
  border: 1px solid #333;
  border-radius: 6px;
  color: #e0e0e0;
  font-family: inherit;
  font-size: 0.9rem;
  padding: 0.5rem 0.7rem;
  outline: none;
  transition: border-color 0.2s;
}
.add-select:focus, .add-input:focus, .num-input:focus { border-color: #90caf9; }
.add-select { width: 70px; }
.add-input  { flex: 1; min-width: 110px; }
.num-input  { width: 60px; text-align: center; }
.num-group {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
}
.num-group label {
  font-size: 0.6rem;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: #555;
}
.add-confirm-btn { align-self: flex-end; }

/* ── Transitions (match fade from HomeView) ── */
.fade-enter-active, .fade-leave-active { transition: opacity 0.25s ease; }
.fade-enter-from, .fade-leave-to       { opacity: 0; }
.fade-move { transition: transform 0.35s ease; }

/* ── Responsive ── */
@media (max-width: 768px) {
  .conditions { display: none; }
  .add-row { flex-direction: column; }
  .add-input, .add-select { width: 100%; }
  .fight-topbar { justify-content: center; }
}

@media (max-width: 480px) {
  .page-title { font-size: 1.8rem; }
  .combatant-row { flex-wrap: wrap; }
}
</style>