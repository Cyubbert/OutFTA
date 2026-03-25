<script setup>
import {ref, computed} from 'vue'

const spells = ref([
  {
    id: 1,
    name: "Conjure Bug",
    level: "Cantrip",
    school: "Conjuration",
    castingTime: "1 action",
    range: "15 feet",
    components: "V, S, M",
    materials: "an insect's wing",
    duration: "1 minute",
    concentration: true,
    description: `You summon a fey spirit in the shape of a tiny arthropod, that appears in an unoccupied space you can see within range. This arthropod uses the Bug stat block shown below.

                  When you cast the spell, choose the creature's form: Flier or Crawler. The bug resembles an arthropod with the chosen form, which determines certain traits in its stat block. The creature disappears when it drops to 0 hit points or when the spell ends.

                  The summoned bug is friendly to you and your companions, shares your initiative count and takes its turn immediately after yours, but can obey only the simplest of your verbal commands (no action required). If you don't issue any commands to it, it defends itself from hostile creatures, but otherwise takes no actions.`,
    higherLevels: "The number of bugs you may summon when you cast this spell increases by 1 when you reach 5th level (2), and increases by 1 again when you reach 9th level (3) and when you reach 10th level (4).",
    tags: ["summoning", "fey", "concentration"],
    statBlock: {
      name: "Bug",
      size: "Tiny",
      type: "Fey Spirit",
      ac: 11,
      hp: "1 (1d4 - 1)",
      speed: "20 ft. (Crawler) / 5 ft., fly 30 ft. (Flier)",
      stats: {str: 4, dex: 12, con: 8, int: 2, wis: 10, cha: 4},
      skills: "Stealth +3",
      senses: "Darkvision 30 ft., Passive Perception 10",
      cr: "0",
      traits: [
        {name: "Familiar Form", desc: "Flier or Crawler — determined on cast."},
      ],
      actions: [
        {name: "Bite", desc: "Melee Weapon Attack: +3 to hit, reach 5 ft., one target. Hit: 1 poison damage."},
      ]
    }
  },
  {
    id: 2,
    name: "Control Smoke",
    level: "Cantrip",
    school: "Transmutation",
    castingTime: "1 action",
    range: "60 feet",
    components: "S, M",
    materials: "a pinch of ash, dirt or sand",
    duration: "Instantaneous or 1 hour",
    concentration: false,
    description: `You choose nonmagical smoke that you can see within range and that fits within a 5 foot cube. You affect it in one of the following ways:

- You make the smoke disappear
- You make the smoke expand 5 feet in one direction that is not down
- You change the smoke's color
- You create shapes within the 5 foot cube, these shapes can be incredibly detailed and beautiful, but are always clearly made of smoke.`,

    higherLevels: "If you cast this spell multiple times, you can have up to three of its non instantaneous effects active at a time, and you can dismiss such an effect as an action.",
    tags: ["summoning", "smoke"],
  },
  {
    id: 3,
    name: "Elemental Burst",
    level: "Cantrip",
    school: "Evocation",
    castingTime: "1 action",
    range: "90 feet",
    components: "V,S",
    materials: "none",
    duration: "Instantaneous",
    concentration: false,
    description: `You hurl a burst of elemental energy at a creature or object within range. Make a ranged spell attack against the target. On a hit, the target takes 2d4 damage. Choose one of the d4s. The number rolled on that die determines the damage type as shown below.

d4                                Damage Type

1                                           Cold

2                                           Fire

3                                           Lightning

4                                          Thunder`,

    higherLevels: "At Higher Levels: This spells's damage increases by 2d4 when you reach 5th Level (4d4), 9th level (6d4), and 11th level (8d4).",
    tags: ["damage", "elemental"],
  }
])

const search = ref('')
const activeSchool = ref('All')
const openSpells = ref(new Set([1]))
const openStatBlocks = ref(new Set())

const schools = computed(() => {
  const s = [...new Set(spells.value.map(sp => sp.school))]
  return ['All', ...s]
})

const filtered = computed(() =>
    spells.value.filter(sp => {
      const matchSearch = sp.name.toLowerCase().includes(search.value.toLowerCase())
      const matchSchool = activeSchool.value === 'All' || sp.school === activeSchool.value
      return matchSearch && matchSchool
    })
)

const schoolColors = {
  Conjuration: '#6ab04c',
  Evocation: '#ef9a9a',
  Illusion: '#9c7fd4',
  Abjuration: '#90caf9',
  Transmutation: '#f9cb42',
  Necromancy: '#aaaaaa',
  Divination: '#5dcaa5',
  Enchantment: '#f48fb1',
}

function schoolColor(school) {
  return schoolColors[school] || '#90caf9'
}

function toggleSpell(id) {
  const s = new Set(openSpells.value)
  s.has(id) ? s.delete(id) : s.add(id)
  openSpells.value = s
}

function toggleStatBlock(id) {
  const s = new Set(openStatBlocks.value)
  s.has(id) ? s.delete(id) : s.add(id)
  openStatBlocks.value = s
}

function mod(score) {
  const m = Math.floor((score - 10) / 2)
  return m >= 0 ? `+${m}` : `${m}`
}

const abilityLabels = ['STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA']
const abilityKeys = ['str', 'dex', 'con', 'int', 'wis', 'cha']
</script>

<template>
  <article class="page sans">
    <header>
      <h1 class="page-title">Spellbook</h1>
      <p class="page-subtitle">Homebrew Spells</p>

      <div class="filter-bar">
        <input v-model="search" class="search-input" placeholder="Search spells..."/>
        <div class="school-filters">
          <button
              v-for="school in schools"
              :key="school"
              class="school-btn"
              :class="{ active: activeSchool === school }"
              :style="activeSchool === school && school !== 'All'
              ? { background: schoolColor(school) + '22', borderColor: schoolColor(school), color: schoolColor(school) }
              : {}"
              @click="activeSchool = school"
          >{{ school }}
          </button>
        </div>
      </div>
    </header>

    <div class="page-body">
      <div v-if="!filtered.length" class="empty-state">No spells found.</div>

      <transition-group name="fade" tag="div" class="spell-list">
        <div v-for="spell in filtered" :key="spell.id" class="spell-card">

          <!-- ── Clickable header ── -->
          <button
              class="spell-header"
              :class="{ open: openSpells.has(spell.id) }"
              :style="{ borderLeftColor: schoolColor(spell.school) }"
              @click="toggleSpell(spell.id)"
          >
            <div class="spell-header-left">
              <span class="spell-name">{{ spell.name }}</span>
              <div class="spell-pills">
                <span class="pill school-pill"
                      :style="{ color: schoolColor(spell.school), background: schoolColor(spell.school) + '18' }">
                  {{ spell.school }}
                </span>
                <span class="pill level-pill">{{ spell.level }}</span>
                <span class="pill conc-pill" v-if="spell.concentration">Concentration</span>
              </div>
            </div>
            <div class="spell-header-right">
              <span class="spell-meta-row">
                <span class="meta-item">{{ spell.castingTime }}</span>
                <span class="meta-dot">·</span>
                <span class="meta-item">{{ spell.range }}</span>
                <span class="meta-dot">·</span>
                <span class="meta-item">{{ spell.duration }}</span>
              </span>
              <span class="chevron" :class="{ rotated: openSpells.has(spell.id) }">›</span>
            </div>
          </button>

          <!-- ── Expanded body ── -->
          <transition name="expand">
            <div class="spell-body" v-if="openSpells.has(spell.id)">

              <!-- Cast info grid -->
              <div class="cast-grid">
                <div class="cast-box">
                  <span class="cast-label">Casting Time</span>
                  <span class="cast-val">{{ spell.castingTime }}</span>
                </div>
                <div class="cast-box">
                  <span class="cast-label">Range</span>
                  <span class="cast-val">{{ spell.range }}</span>
                </div>
                <div class="cast-box">
                  <span class="cast-label">Components</span>
                  <span class="cast-val">{{ spell.components }}</span>
                  <span class="cast-material" v-if="spell.materials">({{ spell.materials }})</span>
                </div>
                <div class="cast-box">
                  <span class="cast-label">Duration</span>
                  <span class="cast-val">{{ spell.duration }}</span>
                </div>
              </div>

              <!-- Description -->
              <div class="spell-desc">
                <p v-for="(para, i) in spell.description.split('\n\n')" :key="i" class="desc-para">
                  {{ para }}
                </p>
              </div>

              <!-- Tags -->
              <div class="tag-row" v-if="spell.tags?.length">
                <span v-for="tag in spell.tags" :key="tag" class="tag">{{ tag }}</span>
              </div>

              <!-- Higher levels -->
              <div class="higher-levels" v-if="spell.higherLevels">
                <span class="hl-label">At Higher Levels. </span>{{ spell.higherLevels }}
              </div>

              <!-- Stat block toggle -->
              <button
                  v-if="spell.statBlock"
                  class="sb-toggle"
                  @click="toggleStatBlock(spell.id)"
              >
                {{ openStatBlocks.has(spell.id) ? '▲ Hide' : '▼ Show' }} {{ spell.statBlock.name }} Stat Block
              </button>

              <!-- Stat Block -->
              <transition name="fade">
                <div class="stat-block" v-if="openStatBlocks.has(spell.id) && spell.statBlock">
                  <div class="sb-header">
                    <h3 class="sb-name">{{ spell.statBlock.name }}</h3>
                    <p class="sb-type">{{ spell.statBlock.size }} {{ spell.statBlock.type }}</p>
                  </div>
                  <div class="sb-divider"/>
                  <div class="sb-row"><span>Armor Class</span><span>{{ spell.statBlock.ac }}</span></div>
                  <div class="sb-row"><span>Hit Points</span><span>{{ spell.statBlock.hp }}</span></div>
                  <div class="sb-row"><span>Speed</span><span>{{ spell.statBlock.speed }}</span></div>
                  <div class="sb-divider"/>
                  <div class="sb-ability-row">
                    <div v-for="(key, i) in abilityKeys" :key="key" class="sb-ability">
                      <span class="sb-ab-label">{{ abilityLabels[i] }}</span>
                      <span class="sb-ab-score">{{ spell.statBlock.stats[key] }}</span>
                      <span class="sb-ab-mod">{{ mod(spell.statBlock.stats[key]) }}</span>
                    </div>
                  </div>
                  <div class="sb-divider"/>
                  <div class="sb-row" v-if="spell.statBlock.skills"><span>Skills</span><span>{{
                      spell.statBlock.skills
                    }}</span></div>
                  <div class="sb-row"><span>Senses</span><span>{{ spell.statBlock.senses }}</span></div>
                  <div class="sb-row"><span>Challenge</span><span>{{ spell.statBlock.cr }}</span></div>
                  <template v-if="spell.statBlock.traits?.length">
                    <div class="sb-divider"/>
                    <div v-for="trait in spell.statBlock.traits" :key="trait.name" class="sb-trait">
                      <span class="sb-trait-name">{{ trait.name }}. </span>{{ trait.desc }}
                    </div>
                  </template>
                  <template v-if="spell.statBlock.actions?.length">
                    <p class="sb-section-title">Actions</p>
                    <div class="sb-divider"/>
                    <div v-for="action in spell.statBlock.actions" :key="action.name" class="sb-trait">
                      <span class="sb-trait-name">{{ action.name }}. </span>{{ action.desc }}
                    </div>
                  </template>
                </div>
              </transition>

            </div>
          </transition>
        </div>
      </transition-group>
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
  margin: 1rem 0 0.25rem;
  color: #fff;
  text-align: center;
  font-family: 'Iosevka Charon', monospace;
  letter-spacing: 0.04em;
}

.page-subtitle {
  text-align: center;
  color: #444;
  font-size: 0.8rem;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  margin: 0 0 1.2rem;
}

.filter-bar {
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
  margin-bottom: 1.5rem;
}

.search-input {
  width: 100%;
  background: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  color: #e0e0e0;
  font-family: 'Jost', sans-serif;
  font-size: 0.9rem;
  padding: 0.55rem 1rem;
  outline: none;
  transition: border-color 0.2s;
  box-sizing: border-box;
}

.search-input:focus {
  border-color: #90caf9;
}

.school-filters {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.school-btn {
  font-size: 0.7rem;
  padding: 3px 10px;
  border-radius: 5px;
  background: none;
  border: 1px solid #2a2a2a;
  color: #555;
  cursor: pointer;
  transition: all 0.15s;
  font-family: 'Jost', sans-serif;
  letter-spacing: 0.05em;
}

.school-btn:hover {
  border-color: #444;
  color: #aaa;
}

.school-btn.active {
  background: #222;
  color: #e0e0e0;
  border-color: #555;
}

.spell-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.empty-state {
  text-align: center;
  color: #444;
  font-style: italic;
  padding: 2rem 0;
}

/* ── Spell card ── */
.spell-card {
  background: #1a1a1a;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
}

.spell-header {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.9rem 1.1rem;
  background: none;
  border: none;
  border-left: 3px solid transparent;
  cursor: pointer;
  text-align: left;
  transition: background 0.15s;
  border-radius: 0;
}

.spell-header:hover {
  background: rgba(255, 255, 255, 0.03);
}

.spell-header.open {
  background: rgba(255, 255, 255, 0.02);
}

.spell-header-left {
  display: flex;
  flex-direction: column;
  gap: 5px;
  min-width: 0;
}

.spell-name {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1rem;
  font-weight: 600;
  color: #fff;
}

.spell-pills {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
}

.pill {
  font-size: 0.62rem;
  padding: 2px 7px;
  border-radius: 4px;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.school-pill {
  font-weight: 600;
}

.level-pill {
  background: #222;
  color: #666;
  border: 1px solid #2a2a2a;
}

.conc-pill {
  background: #0e2233;
  color: #90caf9;
  border: 1px solid #1a3a5a;
}

.spell-header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-shrink: 0;
}

.spell-meta-row {
  display: flex;
  align-items: center;
  gap: 5px;
}

.meta-item {
  font-size: 0.75rem;
  color: #555;
  white-space: nowrap;
}

.meta-dot {
  color: #333;
  font-size: 0.7rem;
}

.chevron {
  font-size: 1.2rem;
  color: #444;
  transition: transform 0.25s, color 0.2s;
  display: inline-block;
  line-height: 1;
}

.chevron.rotated {
  transform: rotate(90deg);
  color: #90caf9;
}

/* ── Body ── */
.spell-body {
  padding: 0 1.1rem 1.1rem;
  border-top: 1px solid #222;
}

.cast-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
  margin: 1rem 0;
}

.cast-box {
  background: #121212;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  padding: 0.55rem 0.7rem;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.cast-label {
  font-size: 0.58rem;
  text-transform: uppercase;
  letter-spacing: 0.14em;
  color: #444;
}

.cast-val {
  font-size: 0.85rem;
  color: #e0e0e0;
  font-weight: 500;
}

.cast-material {
  font-size: 0.72rem;
  color: #555;
  font-style: italic;
}

.spell-desc {
  margin-bottom: 0.75rem;
}

.desc-para {
  font-size: 0.9rem;
  line-height: 1.75;
  color: #ccc;
  margin: 0 0 0.65rem;
}

.tag-row {
  display: flex;
  gap: 5px;
  flex-wrap: wrap;
  margin-bottom: 0.75rem;
}

.tag {
  background: #1e1e1e;
  border: 1px solid #2a2a2a;
  border-radius: 4px;
  font-size: 0.62rem;
  color: #555;
  padding: 2px 8px;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.higher-levels {
  background: #141414;
  border-left: 3px solid #90caf9;
  border-radius: 0 6px 6px 0;
  padding: 0.65rem 1rem;
  font-size: 0.875rem;
  color: #aaa;
  line-height: 1.7;
  margin-bottom: 1rem;
}

.hl-label {
  font-weight: 700;
  color: #90caf9;
}

.sb-toggle {
  width: 100%;
  background: #121212;
  border: 1px solid #2a2a2a;
  border-radius: 7px;
  color: #555;
  font-family: 'Jost', sans-serif;
  font-size: 0.78rem;
  letter-spacing: 0.06em;
  padding: 0.5rem;
  cursor: pointer;
  transition: all 0.2s;
  margin-bottom: 0.75rem;
}

.sb-toggle:hover {
  border-color: #555;
  color: #aaa;
}

/* ── Stat block ── */
.stat-block {
  background: #111;
  border: 1px solid #2a2a2a;
  border-radius: 10px;
  padding: 1rem 1.1rem;
  font-size: 0.85rem;
}

.sb-header {
  margin-bottom: 6px;
}

.sb-name {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1.1rem;
  font-weight: 700;
  color: #c9a84c;
  margin: 0 0 2px;
}

.sb-type {
  font-size: 0.78rem;
  color: #666;
  font-style: italic;
  margin: 0;
}

.sb-divider {
  height: 1px;
  background: #2a2a2a;
  margin: 7px 0;
}

.sb-row {
  display: flex;
  justify-content: space-between;
  padding: 3px 0;
}

.sb-row span:first-child {
  color: #666;
  font-size: 0.8rem;
}

.sb-row span:last-child {
  font-weight: 500;
  color: #ccc;
  font-size: 0.85rem;
}

.sb-ability-row {
  display: flex;
  justify-content: space-between;
  padding: 4px 0;
}

.sb-ability {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1px;
}

.sb-ab-label {
  font-size: 0.62rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: #555;
}

.sb-ab-score {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1rem;
  font-weight: 700;
  color: #c9a84c;
}

.sb-ab-mod {
  font-size: 0.72rem;
  color: #666;
}

.sb-section-title {
  font-family: 'Iosevka Charon', monospace;
  font-size: 0.95rem;
  color: #c9a84c;
  margin: 8px 0 0;
}

.sb-trait {
  color: #aaa;
  line-height: 1.6;
  padding: 3px 0;
  font-size: 0.85rem;
}

.sb-trait-name {
  font-weight: 700;
  color: #e0e0e0;
  font-style: italic;
}

/* ── Transitions ── */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.2s;
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

.expand-enter-active, .expand-leave-active {
  transition: opacity 0.2s, transform 0.2s;
}

.expand-enter-from, .expand-leave-to {
  opacity: 0;
  transform: translateY(-6px);
}

/* ── Responsive ── */
@media (max-width: 600px) {
  .cast-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .spell-meta-row {
    display: none;
  }
}
</style>