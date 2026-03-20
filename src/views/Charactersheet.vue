<script setup>
import {ref, watch} from 'vue'
import {useRoute, useRouter} from 'vue-router'

const route = useRoute()
const router = useRouter()
const charId = route.params.id
const STORAGE_KEY = 'dnd-char-' + charId

const defaultChar = () => ({
  id: charId,
  name: '', race: '', class: '', level: 1, background: '', alignment: '',
  hp: 10, maxHp: 10, tempHp: 0, ac: 10, speed: 30, initiative: 0,
  proficiencyBonus: 2, inspiration: false,
  abilities: {
    str: 10, dex: 10, con: 10, int: 10, wis: 10, cha: 10,
  },
  savingThrows: {
    str: false, dex: false, con: false, int: false, wis: false, cha: false,
  },
  skills: {
    acrobatics: false, animalHandling: false, arcana: false, athletics: false,
    deception: false, history: false, insight: false, intimidation: false,
    investigation: false, medicine: false, nature: false, perception: false,
    performance: false, persuasion: false, religion: false, sleightOfHand: false,
    stealth: false, survival: false,
  },
  notes: '',
  features: '',
  equipment: '',
})

const skillAbility = {
  acrobatics: 'dex', animalHandling: 'wis', arcana: 'int', athletics: 'str',
  deception: 'cha', history: 'int', insight: 'wis', intimidation: 'cha',
  investigation: 'int', medicine: 'wis', nature: 'int', perception: 'wis',
  performance: 'cha', persuasion: 'cha', religion: 'int', sleightOfHand: 'dex',
  stealth: 'dex', survival: 'wis',
}

const skillLabels = {
  acrobatics: 'Acrobatics', animalHandling: 'Animal Handling', arcana: 'Arcana',
  athletics: 'Athletics', deception: 'Deception', history: 'History',
  insight: 'Insight', intimidation: 'Intimidation', investigation: 'Investigation',
  medicine: 'Medicine', nature: 'Nature', perception: 'Perception',
  performance: 'Performance', persuasion: 'Persuasion', religion: 'Religion',
  sleightOfHand: 'Sleight Of Hand', stealth: 'Stealth', survival: 'Survival',
}

const abilityLabels = {str: 'STR', dex: 'DEX', con: 'CON', int: 'INT', wis: 'WIS', cha: 'CHA'}
const abilityFull = {
  str: 'Strength', dex: 'Dexterity', con: 'Constitution',
  int: 'Intelligence', wis: 'Wisdom', cha: 'Charisma'
}

const saved = localStorage.getItem(STORAGE_KEY)
const char = ref(saved ? JSON.parse(saved) : defaultChar())

watch(char, val => localStorage.setItem(STORAGE_KEY, JSON.stringify(val)), {deep: true})

const mod = (score) => Math.floor((score - 10) / 2)
const fmt = (n) => n >= 0 ? `+${n}` : `${n}`
const skillMod = (skill) => {
  const base = mod(char.value.abilities[skillAbility[skill]])
  return char.value.skills[skill] ? base + char.value.proficiencyBonus : base
}
const saveMod = (ab) => {
  const base = mod(char.value.abilities[ab])
  return char.value.savingThrows[ab] ? base + char.value.proficiencyBonus : base
}

const activeTab = ref('stats')
const tabs = [
  {id: 'stats', label: 'Stats'},
  {id: 'skills', label: 'Skills'},
  {id: 'notes', label: 'Notes'},
]

function adjustHp(delta) {
  char.value.hp = Math.max(0, Math.min(char.value.maxHp, char.value.hp + delta))
}

function resetChar() {
  if (!confirm('Reset Character?')) return
  localStorage.removeItem(STORAGE_KEY)
  router.push('/charaktere')
}
</script>

<template>
  <article class="page sans">
    <header>
      <div class="sheet-topbar">
        <router-link to="/charaktere" class="back-btn">← All Characters</router-link>
        <button class="reset-btn" @click="resetChar">Delete</button>
      </div>
      <h1 class="page-title">{{ char.name || 'New Character' }}</h1>
    </header>

    <div class="page-body">

      <!-- Identity -->
      <section class="sheet-section identity-grid">
        <div class="field-group span2">
          <label>Name</label>
          <input v-model="char.name" placeholder="Name"/>
        </div>
        <div class="field-group">
          <label>Species</label>
          <input v-model="char.race" placeholder="e.g. Elf"/>
        </div>
        <div class="field-group">
          <label>Class</label>
          <input v-model="char.class" placeholder="e.g. Druid"/>
        </div>
        <div class="field-group small">
          <label>Level</label>
          <input type="number" v-model.number="char.level" min="1" max="20"/>
        </div>
        <div class="field-group">
          <label>Background</label>
          <input v-model="char.background" placeholder="e.g. Soldier"/>
        </div>
        <div class="field-group">
          <label>Alignment</label>
          <input v-model="char.alignment" placeholder="e.g. Neutral Good"/>
        </div>
      </section>

      <!-- Combat Stats -->
      <section class="sheet-section combat-row">
        <div class="stat-box">
          <span class="stat-label">AC</span>
          <input class="stat-input" type="number" v-model.number="char.ac"/>
        </div>
        <div class="stat-box">
          <span class="stat-label">Initiative</span>
          <span class="stat-val">{{ fmt(mod(char.abilities.dex)) }}</span>
        </div>
        <div class="stat-box">
          <span class="stat-label">Movement</span>
          <input class="stat-input" type="number" v-model.number="char.speed"/>
        </div>
        <div class="stat-box">
          <span class="stat-label">Proficiency Bonus</span>
          <span class="stat-val">{{ fmt(char.proficiencyBonus) }}</span>
        </div>
        <div class="stat-box hp-box">
          <span class="stat-label">Hit Points</span>
          <div class="hp-controls">
            <button class="hp-btn" @click="adjustHp(-1)">−</button>
            <span class="hp-current" :class="{ critical: char.hp <= char.maxHp * 0.25 && char.hp > 0 }">
              {{ char.hp }}
            </span>
            <span class="hp-sep">/</span>
            <input class="hp-max" type="number" v-model.number="char.maxHp" min="1"/>
            <button class="hp-btn" @click="adjustHp(1)">+</button>
          </div>
        </div>
        <div class="stat-box">
          <span class="stat-label">Temp. HP</span>
          <input class="stat-input" type="number" v-model.number="char.tempHp" min="0"/>
        </div>
      </section>

      <!-- Tabs -->
      <div class="tabs">
        <button
            v-for="t in tabs"
            :key="t.id"
            @click="activeTab = t.id"
            :class="{ active: activeTab === t.id }"
        >{{ t.label }}
        </button>
      </div>

      <!-- Stats Tab -->
      <transition name="fade">
        <section v-if="activeTab === 'stats'" class="tab-content">
          <div class="abilities-grid">
            <div v-for="(label, ab) in abilityLabels" :key="ab" class="ability-card">
              <span class="ab-full">{{ abilityFull[ab] }}</span>
              <span class="ab-label">{{ label }}</span>
              <input class="ab-score" type="number" v-model.number="char.abilities[ab]" min="1" max="30"/>
              <span class="ab-mod">{{ fmt(mod(char.abilities[ab])) }}</span>
              <label class="save-row">
                <input type="checkbox" v-model="char.savingThrows[ab]"/>
                <span class="save-label">ST {{ fmt(saveMod(ab)) }}</span>
              </label>
            </div>
          </div>
        </section>
      </transition>

      <!-- Skills Tab -->
      <transition name="fade">
        <section v-if="activeTab === 'skills'" class="tab-content">
          <div class="skills-list">
            <label v-for="(label, skill) in skillLabels" :key="skill" class="skill-row">
              <input type="checkbox" v-model="char.skills[skill]"/>
              <span class="skill-mod" :class="{ proficient: char.skills[skill] }">
                {{ fmt(skillMod(skill)) }}
              </span>
              <span class="skill-name">{{ label }}</span>
              <span class="skill-ab">{{ abilityLabels[skillAbility[skill]] }}</span>
            </label>
          </div>
        </section>
      </transition>

      <!-- Notes Tab -->
      <transition name="fade">
        <section v-if="activeTab === 'notes'" class="tab-content notes-grid">
          <div class="note-block">
            <label>Abilities</label>
            <textarea v-model="char.features" placeholder="Class Features, Magic, Talents..."></textarea>
          </div>
          <div class="note-block">
            <label>Equipment</label>
            <textarea v-model="char.equipment" placeholder="Inventory, Weapons, Armor..."></textarea>
          </div>
          <div class="note-block span2">
            <label>Notes</label>
            <textarea v-model="char.notes" rows="6" placeholder="Notes..."></textarea>
          </div>
        </section>
      </transition>

      <div class="sheet-footer">
        <span class="save-indicator">Automatically saved</span>
      </div>

    </div>
  </article>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Iosevka+Charon:wght@400;500;700&family=Jost:wght@300;400;500;700&display=swap');

.page {
  margin: 2em auto;
  max-width: 900px;
  padding: 0 1rem;
  font-family: 'Jost', sans-serif;
  color: #e0e0e0;
}

.page-title {
  font-size: 2.5rem;
  font-weight: 700;
  margin: 0.5rem 0 2rem;
  color: #fff;
  text-align: center;
  font-family: 'Iosevka Charon', monospace;
  letter-spacing: 0.04em;
}

.page-body {
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
}

.sheet-topbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.back-btn {
  font-size: 0.85rem;
  color: #555;
  text-decoration: none;
  transition: color 0.2s;
}

.back-btn:hover {
  color: #90caf9;
}

.sheet-section {
  background: #1a1a1a;
  border-radius: 12px;
  padding: 1.1rem 1.2rem;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
}

.identity-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.span2 {
  grid-column: span 2;
}

.small {
  max-width: 100%;
}

.field-group {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.field-group label {
  font-size: 0.62rem;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: #555;
}

.field-group input {
  background: #121212;
  border: 1px solid #2a2a2a;
  border-radius: 6px;
  color: #e0e0e0;
  font-family: 'Jost', sans-serif;
  font-size: 0.9rem;
  padding: 0.45rem 0.7rem;
  outline: none;
  transition: border-color 0.2s;
}

.field-group input:focus {
  border-color: #90caf9;
}

.combat-row {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.stat-box {
  flex: 1;
  min-width: 80px;
  background: #121212;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  padding: 0.6rem 0.7rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.stat-label {
  font-size: 0.6rem;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: #555;
  text-align: center;
}

.stat-val {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1.3rem;
  color: #90caf9;
  font-weight: 500;
}

.stat-input {
  background: transparent;
  border: none;
  border-bottom: 1px solid #2a2a2a;
  color: #90caf9;
  font-family: 'Iosevka Charon', monospace;
  font-size: 1.3rem;
  font-weight: 500;
  text-align: center;
  width: 56px;
  outline: none;
  transition: border-color 0.2s;
}

.stat-input:focus {
  border-bottom-color: #90caf9;
}

.hp-box {
  flex: 2;
  min-width: 160px;
}

.hp-controls {
  display: flex;
  align-items: center;
  gap: 6px;
}

.hp-btn {
  background: #222;
  border: 1px solid #333;
  color: #888;
  border-radius: 4px;
  width: 24px;
  height: 24px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.15s;
  line-height: 1;
}

.hp-btn:hover {
  background: #90caf9;
  color: #121212;
  border-color: #90caf9;
}

.hp-current {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1.4rem;
  font-weight: 700;
  color: #e0e0e0;
  min-width: 28px;
  text-align: center;
}

.hp-current.critical {
  color: #ef9a9a;
}

.hp-sep {
  color: #333;
}

.hp-max {
  background: transparent;
  border: none;
  border-bottom: 1px solid #2a2a2a;
  color: #555;
  font-family: 'Iosevka Charon', monospace;
  font-size: 0.95rem;
  width: 36px;
  text-align: center;
  outline: none;
}

.tabs {
  display: flex;
  gap: 0.75rem;
  justify-content: center;
}

.tabs button {
  padding: 0.5rem 1.4rem;
  border: none;
  border-radius: 6px;
  background: #333;
  color: #fff;
  cursor: pointer;
  font-family: 'Jost', sans-serif;
  font-weight: 500;
  font-size: 0.85rem;
  letter-spacing: 0.05em;
  transition: background 0.2s;
}

.tabs button.active {
  background: #90caf9;
  color: #121212;
}

.tabs button:hover:not(.active) {
  background: #444;
}

.tab-content {
  background: #1a1a1a;
  border-radius: 12px;
  padding: 1.2rem;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
}

.abilities-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.ability-card {
  background: #121212;
  border: 1px solid #2a2a2a;
  border-radius: 10px;
  padding: 0.8rem 0.7rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  transition: border-color 0.2s;
}

.ability-card:hover {
  border-color: #333;
}

.ab-full {
  font-size: 0.6rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: #444;
}

.ab-label {
  font-family: 'Iosevka Charon', monospace;
  font-size: 0.75rem;
  font-weight: 700;
  color: #90caf9;
  letter-spacing: 0.1em;
}

.ab-score {
  background: transparent;
  border: none;
  border-bottom: 1px solid #2a2a2a;
  color: #e0e0e0;
  font-family: 'Iosevka Charon', monospace;
  font-size: 1.6rem;
  font-weight: 500;
  text-align: center;
  width: 52px;
  outline: none;
  transition: border-color 0.2s;
}

.ab-score:focus {
  border-bottom-color: #90caf9;
}

.ab-mod {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1rem;
  color: #888;
}

.save-row {
  display: flex;
  align-items: center;
  gap: 5px;
  cursor: pointer;
  margin-top: 2px;
}

.save-row input[type=checkbox] {
  accent-color: #90caf9;
  width: 12px;
  height: 12px;
}

.save-label {
  font-size: 0.7rem;
  color: #555;
}

.skills-list {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4px;
}

.skill-row {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 5px 8px;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.15s;
}

.skill-row:hover {
  background: #222;
}

.skill-row input[type=checkbox] {
  accent-color: #90caf9;
  flex-shrink: 0;
}

.skill-mod {
  font-family: 'Iosevka Charon', monospace;
  font-size: 0.8rem;
  color: #555;
  min-width: 28px;
  text-align: right;
}

.skill-mod.proficient {
  color: #90caf9;
}

.skill-name {
  flex: 1;
  font-size: 0.85rem;
  color: #ccc;
}

.skill-ab {
  font-size: 0.65rem;
  color: #444;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.notes-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.note-block {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.note-block label {
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: #555;
}

.note-block textarea {
  background: #121212;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  color: #e0e0e0;
  font-family: 'Jost', sans-serif;
  font-size: 0.875rem;
  line-height: 1.6;
  padding: 0.7rem 0.8rem;
  resize: vertical;
  min-height: 100px;
  outline: none;
  transition: border-color 0.2s;
}

.note-block textarea:focus {
  border-color: #90caf9;
}

.note-block.span2 {
  grid-column: span 2;
}

.sheet-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.25rem 0;
}

.save-indicator {
  font-size: 0.7rem;
  color: #333;
  letter-spacing: 0.08em;
}

.reset-btn {
  background: transparent;
  border: 1px solid #2a2a2a;
  color: #444;
  border-radius: 6px;
  padding: 0.4rem 1rem;
  font-family: 'Jost', sans-serif;
  font-size: 0.8rem;
  cursor: pointer;
  transition: color 0.2s, border-color 0.2s;
}

.reset-btn:hover {
  color: #ef9a9a;
  border-color: #ef9a9a;
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.2s;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

@media (max-width: 600px) {
  .identity-grid {
    grid-template-columns: 1fr 1fr;
  }

  .span2 {
    grid-column: span 2;
  }

  .abilities-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .skills-list {
    grid-template-columns: 1fr;
  }

  .notes-grid {
    grid-template-columns: 1fr;
  }

  .note-block.span2 {
    grid-column: span 1;
  }

  .combat-row {
    gap: 6px;
  }
}
</style>