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
    tags: ["non-Damage"],
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
      traits: [{name: "Familiar Form", desc: "Flier or Crawler — determined on cast."}],
      actions: [{name: "Bite", desc: "Melee Weapon Attack: +3 to hit, reach 5 ft., one target. Hit: 1 poison damage."}]
    }
  },
  {
    id: 2, name: "Control Smoke", level: "Cantrip", school: "Transmutation",
    castingTime: "1 action", range: "60 feet", components: "S, M",
    materials: "a pinch of ash, dirt or sand", duration: "Instantaneous or 1 hour", concentration: false,
    description: `You choose nonmagical smoke that you can see within range and that fits within a 5 foot cube. You affect it in one of the following ways:

- You make the smoke disappear
- You make the smoke expand 5 feet in one direction that is not down
- You change the smoke's color
- You create shapes within the 5 foot cube, these shapes can be incredibly detailed and beautiful, but are always clearly made of smoke.`,
    higherLevels: "If you cast this spell multiple times, you can have up to three of its non instantaneous effects active at a time, and you can dismiss such an effect as an action.",
    tags: ["non-Damage"],
  },
  {
    id: 3, name: "Elemental Burst", level: "Cantrip", school: "Evocation",
    castingTime: "1 action", range: "90 feet", components: "V, S",
    materials: "", duration: "Instantaneous", concentration: false,
    description: `You hurl a burst of elemental energy at a creature or object within range. Make a ranged spell attack against the target. On a hit, the target takes 2d4 damage. Choose one of the d4s. The number rolled on that die determines the damage type as shown below.

1 — Cold
2 — Fire
3 — Lightning
4 — Thunder`,
    higherLevels: "This spell's damage increases by 2d4 when you reach 5th level (4d4), 9th level (6d4), and 11th level (8d4).",
    tags: ["damage"],
  },
  {
    id: 4, name: "Incendiary Charge", level: "Cantrip", school: "Evocation",
    castingTime: "1 action", range: "Touch", components: "S, M",
    materials: "a tiny nonmagical object that weighs less than 300g and is worth less than 1 gp",
    duration: "1 minute", concentration: false,
    description: `You infuse the object used to cast this spell with explosive energy which makes it pulsate faintly with light. When you do so, you may throw the infused object up to 60 feet as part of the same action. If you don't, until the spell ends, you or another creature can throw it the same distance as an action. The object explodes on impact and the spell ends.

When the object explodes, the explosion fills a 5 foot cube centered on it. Any creature within this cube must succeed on a Dexterity saving throw or take 1d8 fire damage. Any flammable objects within that cube that aren't being worn or carried catch fire. An object infused by this spell is destroyed completely after exploding, only ash remains.`,
    higherLevels: "The infused object's damage increases by 1d8 when it explodes when you reach 5th level (2d8), 11th level (3d8), and 17th level (4d8).",
    tags: ["damage"],
  },
  {
    id: 5, name: "Magic Leaf", level: "Cantrip", school: "Transmutation",
    castingTime: "1 bonus action", range: "Touch", components: "V, S",
    materials: "", duration: "1 minute", concentration: false,
    description: `You touch one to three leaves and imbue them with magic, causing them to become as sharp as knives. You or someone else can make a melee or ranged spell attack with one of the leaves by wielding it like a dagger or throwing it. If thrown, it has a range of 45 feet. If someone else attacks with the leaf, that attacker adds your spellcasting ability modifier, not the attacker's, to the attack roll. On a hit, the target takes piercing damage equal to 1d6 + your spellcasting ability modifier. Hit or miss, the spell then ends on the leaf.

If you cast this spell again, the spell ends early on any leaves still affected by it.`,
    higherLevels: "The number of leaves you can imbue with magic increases by 1 when you reach 5th level (4), 11th level (5) and 17th level (6).",
    tags: ["damage"],
  },
  {
    id: 6, name: "Minor Appearance Modification", level: "Cantrip", school: "Illusion",
    castingTime: "1 action", range: "Self", components: "V, S, M",
    materials: "makeup", duration: "1 hour", concentration: false,
    description: `You create a small illusory change in your appearance. You may:

- Change the size or colour of your eyes.
- Change the shape, width or length of your nose (no more than 10cm)
- Change the colour or length of your hair (no more than 10cm)
- Change the colour or length of your fingernails (no more than 10cm)
- Create a small tattoo or scar anywhere on your body (no larger than 10cm²)
- Remove a spot, scar or mark (no larger than 10cm²)

If you cast this spell multiple times, you can have up to two of its effects active at a time and you can dismiss such an effect as an action.`,
    higherLevels: "/",
    tags: ["non-Damage"],
  },
  {
    id: 7, name: "Punishing Blade", level: "Cantrip", school: "Evocation",
    castingTime: "1 action", range: "Self", components: "S, M",
    materials: "a melee weapon worth at least 1 sp", duration: "1 round", concentration: false,
    description: `You brandish the weapon used in the spell's casting and make a melee attack with it against one creature within range of that weapon. On a hit, the target suffers the weapon attack's normal effects and then becomes sheathed in radiant energy until the start of your next turn. If the target deals damage to a creature other than you before then, the target takes 1d6 radiant damage and the spell ends.`,
    higherLevels: "At 5th level the melee attack deals an extra 1d6 radiant damage to the target on a hit and the damage the target takes for dealing damage to another creature increases to 2d6. Both damage rolls increase by 1d6 at 11th level (2d6 and 3d6) and again at 17th level (3d6 and 4d6).",
    tags: ["damage"],
  },
  {
    id: 8, name: "Redraw and Rewrite", level: "Cantrip", school: "Transmutation",
    castingTime: "1 action", range: "Touch", components: "S, M",
    materials: "a drop of ink", duration: "1 hour", concentration: false,
    description: `You choose non magical ink, paint or another type of marking on a single surface that you can see within range and that fits within a 5 foot cube. You affect it in one of the following ways:

- You change its color.
- You change its shape, you can do this to a painting to change what's depicted or to a script to change what is written.
- You cause the drawing or script to animate, such as making the words dance across the page or making the figure in a painting move or turn.

If you cast this spell multiple times, you can have up to three of its effects active at a time and you can dismiss such an effect as an action. When the spell ends, the modified ink, paint or marking returns to its original shape and color.

If you use this spell to attempt to imitate something, such as a work of art or an official document, you must succeed on a check with your spellcasting ability modifier or it will be a very imprecise copy.`,
    higherLevels: "/",
    tags: ["non-Damage"],
  },
  {
    id: 9, name: "Sacred Symbol", level: "Cantrip", school: "Illusion",
    castingTime: "1 action", range: "30 feet", components: "V, S, M",
    materials: "a symbol of your god or their likeness", duration: "1 minute", concentration: true,
    description: `You create a glowing sacred symbol that hovers in the air within range. The glowing symbol occupies a space no larger than a 5 foot cube, and sheds dim light for 20 feet. This sacred symbol can be your holy symbol, a depiction of your god or of a person or object associated with your god, or your god's name spelt out in a language you can write.

As a bonus action on your turn, you can move the symbol up to 60 feet to a new spot within range. The sacred symbol winks out if it exceeds the spell's range.`,
    higherLevels: "/",
    tags: ["non-Damage"],
  },
  {
    id: 10, name: "Spacial Shunt", level: "Cantrip", school: "Conjuration",
    castingTime: "1 action", range: "90 feet", components: "V, S",
    materials: "", duration: "Instantaneous", concentration: false,
    description: `Choose a creature you can see within range and roll a d4. The creature is teleported 5 feet in a direction determined by the result:

1 — North
2 — South
3 — East
4 — West

If the space it would be teleported to is occupied or you cannot see it, the spell has no effect. An unwilling creature must succeed on a Charisma saving throw in order to not be teleported.`,
    higherLevels: "/",
    tags: ["non-Damage"],
  },
  {
    id: 11, name: "Taunting Blade", level: "Cantrip", school: "Enchantment",
    castingTime: "1 action", range: "Self", components: "S, M",
    materials: "a melee weapon worth at least 1 sp", duration: "1 round", concentration: false,
    description: `You brandish the weapon used in the spell's casting and make a melee attack with it against one creature within range of that weapon. On a hit, the target suffers the weapon attack's normal effects and then becomes surrounded by mocking whispers until the start of your next turn. If the target fails an ability check or misses an attack roll before then, the target takes 1d6 psychic damage, and the spell ends.`,
    higherLevels: "At 5th level, the melee attack deals an extra 1d6 psychic damage to the target on a hit, and the damage the target takes for failing an ability check or missing an attack roll increases to 2d6. Both damage rolls increase by 1d6 at 11th level (2d6 and 3d6) and again at 17th level (3d6 and 4d6).",
    tags: ["damage"],
  },
  {
    id: 12, name: "Trickster's Quirk", level: "Cantrip", school: "Enchantment",
    castingTime: "1 action", range: "60 feet", components: "S, M",
    materials: "a fox's whisker", duration: "Instantaneous", concentration: false,
    description: `You attempt to cause a creature within range that you can see to make an involuntary expression or sound. The creature must succeed on a Wisdom saving throw. On a failure, choose one of the following:

- The creature's facial muscles contract, causing it to wink, blink, grin, grimace or drop its jaw (your choice).
- The creature lets out an involuntary belch, cough, laugh, scream or sneeze, or says a random word.

If the creature was concentrating on a spell or ability when it failed the saving throw, it must succeed on a Constitution saving throw against your spell save DC to maintain concentration.`,
    higherLevels: "/",
    tags: ["non-damage"],
  },
  {
    id: 13, name: "Ventriloquism", level: "Cantrip", school: "Illusion",
    castingTime: "1 action", range: "30 feet", components: "S, M",
    materials: "a ball of string", duration: "1 minute", concentration: true,
    description: `When you cast this spell, select a creature or object that you can see within range. For the duration, whenever you would speak you may keep your mouth closed, if you do the sounds you would emit come from the target instead of you.

If the target has a mouth (or something resembling a mouth), this mouth appears to move in sync with the sounds you produce. This doesn't change your voice or the sounds you can make. Any creature trying to determine who is really talking must make a Wisdom (Perception) or Wisdom (Insight) check against your spell save DC.

If you move more than 60 feet away from the target, the spell ends.`,
    higherLevels: "/",
    tags: ["non-damage"],
  },
])

const search = ref('')
const activeSchool = ref('All')
const openSpells = ref(new Set())
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
        <input v-model="search" class="search-input" placeholder="Search homebrew spells..."/>
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

      <div>
        <h3 class="collection-title">Homebrew Spells</h3>
        <div v-if="!filtered.length" class="empty-state">No spells found.</div>

        <transition-group name="fade" tag="div" class="spell-list">
          <div v-for="spell in filtered" :key="spell.id" class="spell-card">

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

            <transition name="expand">
              <div class="spell-body" v-if="openSpells.has(spell.id)">
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

                <div class="spell-desc">
                  <p
                      v-for="(para, i) in spell.description.split('\n\n').filter(p => p.trim())"
                      :key="i"
                      class="desc-para"
                  >{{ para.trim() }}</p>
                </div>

                <div class="tag-row" v-if="spell.tags?.length">
                  <span v-for="tag in spell.tags" :key="tag" class="tag">{{ tag }}</span>
                </div>

                <div class="higher-levels" v-if="spell.higherLevels && spell.higherLevels !== '/'">
                  <span class="hl-label">At Higher Levels. </span>{{ spell.higherLevels }}
                </div>

                <button v-if="spell.statBlock" class="sb-toggle" @click="toggleStatBlock(spell.id)">
                  {{ openStatBlocks.has(spell.id) ? '▲ Hide' : '▼ Show' }} {{ spell.statBlock.name }} Stat Block
                </button>

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

.collection-title {
  margin-bottom: 0.75rem;
  color: #ffffff;
  font-family: 'Iosevka Charon', monospace;
  font-weight: 400;
  letter-spacing: 0.06em;
}

.spell-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 0.5rem;
}

.empty-state {
  text-align: center;
  color: #444;
  font-style: italic;
  padding: 2rem 0;
}

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
  white-space: pre-line;
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

@media (max-width: 600px) {
  .cast-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .spell-meta-row {
    display: none;
  }
}
</style>