<template>
  <div class="sheet-detail">
    <div class="sheet-header">
      <img v-if="sheet.image" :src="sheet.image" :alt="sheet.name" class="sheet-portrait" />
      <div>
        <h2 class="sheet-name">{{ sheet.name }}</h2>
        <p class="sheet-subline">
          Level {{ sheet.level ?? '?' }} {{ sheet.race }} {{ sheet.class }}
        </p>
        <p class="sheet-subline muted" v-if="sheet.background || sheet.alignment">
          {{ [sheet.background, sheet.alignment].filter(Boolean).join(' · ') }}
        </p>
      </div>
    </div>

    <div class="stat-row">
      <div class="stat-box">
        <span class="stat-label">HP</span>
        <span class="stat-val">{{ sheet.hp_current ?? '?' }} / {{ sheet.hp_max ?? '?' }}</span>
      </div>
      <div class="stat-box">
        <span class="stat-label">AC</span>
        <span class="stat-val">{{ sheet.ac ?? '?' }}</span>
      </div>
      <div class="stat-box">
        <span class="stat-label">Speed</span>
        <span class="stat-val">{{ sheet.speed || '?' }}</span>
      </div>
      <div class="stat-box">
        <span class="stat-label">Prof. Bonus</span>
        <span class="stat-val">{{ sheet.proficiency_bonus != null ? `+${sheet.proficiency_bonus}` : '?' }}</span>
      </div>
    </div>

    <div class="ability-row">
      <div v-for="key in abilityKeys" :key="key" class="ability">
        <span class="ability-label">{{ key.toUpperCase() }}</span>
        <span class="ability-score">{{ sheet[key] ?? '-' }}</span>
        <span class="ability-mod">{{ mod(sheet[key]) }}</span>
        <span v-if="sheet.saving_throws?.includes(key)" class="save-pip" title="Saving throw proficiency">●</span>
      </div>
    </div>

    <div class="sheet-section" v-if="sheet.skills?.length">
      <h3>Skill Proficiencies</h3>
      <div class="tag-row">
        <span v-for="skill in sheet.skills" :key="skill" class="tag">{{ skill }}</span>
      </div>
    </div>

    <div class="sheet-section" v-if="sheet.equipment?.length">
      <h3>Equipment</h3>
      <ul>
        <li v-for="(item, i) in sheet.equipment" :key="i">{{ item }}</li>
      </ul>
    </div>

    <div class="sheet-section" v-if="sheet.features?.length">
      <h3>Features & Traits</h3>
      <ul>
        <li v-for="(item, i) in sheet.features" :key="i">{{ item }}</li>
      </ul>
    </div>

    <div class="sheet-section" v-if="sheet.backstory">
      <h3>Backstory</h3>
      <p
          v-for="(para, i) in sheet.backstory.split('\n\n').filter(p => p.trim())"
          :key="i"
          class="backstory-para"
      >{{ para.trim() }}</p>
    </div>

    <button class="close-btn" @click="$emit('close')">Close</button>
  </div>
</template>

<script setup>
defineProps({
  sheet: { type: Object, required: true }
})
defineEmits(['close'])

const abilityKeys = ['str', 'dex', 'con', 'int', 'wis', 'cha']

function mod(score) {
  if (score == null) return ''
  const m = Math.floor((score - 10) / 2)
  return m >= 0 ? `+${m}` : `${m}`
}
</script>

<style scoped>
.sheet-detail {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
  max-width: 560px;
}

.sheet-header {
  display: flex;
  gap: 1rem;
  align-items: center;
}

.sheet-portrait {
  width: 84px;
  height: 84px;
  border-radius: 10px;
  object-fit: cover;
  flex-shrink: 0;
}

.sheet-name {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1.4rem;
  color: #fff;
  margin: 0 0 4px;
}

.sheet-subline {
  font-size: 0.85rem;
  color: #ccc;
  margin: 0;
}

.sheet-subline.muted {
  color: #888;
  margin-top: 2px;
}

.stat-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
}

.stat-box {
  background: #121212;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  padding: 0.55rem 0.7rem;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.stat-label {
  font-size: 0.6rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: #666;
}

.stat-val {
  font-size: 0.95rem;
  font-weight: 600;
  color: #e0e0e0;
}

.ability-row {
  display: flex;
  justify-content: space-between;
  gap: 6px;
}

.ability {
  position: relative;
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  background: #1a1a1a;
  border-radius: 8px;
  padding: 0.5rem 0;
}

.ability-label {
  font-size: 0.62rem;
  letter-spacing: 0.1em;
  color: #90caf9;
}

.ability-score {
  font-family: 'Iosevka Charon', monospace;
  font-size: 1.1rem;
  font-weight: 700;
  color: #fff;
}

.ability-mod {
  font-size: 0.72rem;
  color: #999;
}

.save-pip {
  position: absolute;
  top: 4px;
  right: 6px;
  font-size: 0.5rem;
  color: #90caf9;
}

.sheet-section h3 {
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  color: #90caf9;
  margin: 0 0 0.5rem;
}

.tag-row {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.tag {
  background: #1a1a1a;
  border: 1px solid #333;
  border-radius: 6px;
  padding: 2px 10px;
  font-size: 0.8rem;
  color: #e0e0e0;
}

.sheet-section ul {
  margin: 0;
  padding-left: 1.2rem;
  color: #ccc;
  line-height: 1.7;
}

.backstory-para {
  color: #ccc;
  line-height: 1.7;
  margin: 0 0 0.75rem;
}

.close-btn {
  align-self: flex-start;
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #e0e0e0;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  transition: border-color 0.2s, color 0.2s;
}

.close-btn:hover {
  border-color: #90caf9;
  color: #90caf9;
}
</style>
