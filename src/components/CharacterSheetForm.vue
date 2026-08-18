<template>
  <form class="entry-form" @submit.prevent="handleSubmit">
    <h3>{{ editSheet ? 'Edit character sheet' : 'New character sheet' }}</h3>

    <label>Name</label>
    <input v-model="form.name" required />

    <div class="row">
      <div>
        <label>Class</label>
        <input v-model="form.class" />
      </div>
      <div>
        <label>Race</label>
        <input v-model="form.race" />
      </div>
      <div>
        <label>Level</label>
        <input v-model.number="form.level" type="number" min="1" />
      </div>
    </div>

    <div class="row">
      <div>
        <label>Background</label>
        <input v-model="form.background" />
      </div>
      <div>
        <label>Alignment</label>
        <input v-model="form.alignment" />
      </div>
    </div>

    <label>Portrait image URL</label>
    <input v-model="form.image" placeholder="https://…" />

    <div class="row">
      <div>
        <label>HP current</label>
        <input v-model.number="form.hp_current" type="number" />
      </div>
      <div>
        <label>HP max</label>
        <input v-model.number="form.hp_max" type="number" />
      </div>
      <div>
        <label>AC</label>
        <input v-model.number="form.ac" type="number" />
      </div>
    </div>

    <div class="row">
      <div>
        <label>Speed</label>
        <input v-model="form.speed" placeholder="30 ft." />
      </div>
      <div>
        <label>Proficiency bonus</label>
        <input v-model.number="form.proficiency_bonus" type="number" />
      </div>
    </div>

    <label>Ability scores</label>
    <div class="ability-grid">
      <div v-for="key in abilityKeys" :key="key" class="ability-field">
        <span class="ability-label">{{ key.toUpperCase() }}</span>
        <input v-model.number="form[key]" type="number" min="1" max="30" />
      </div>
    </div>

    <label>Saving throw proficiencies</label>
    <div class="save-checks">
      <label v-for="key in abilityKeys" :key="key" class="save-check">
        <input type="checkbox" :value="key" v-model="savingThrows" />
        {{ key.toUpperCase() }}
      </label>
    </div>

    <label>Skill proficiencies (comma-separated)</label>
    <input v-model="skillsInput" placeholder="Perception, Stealth, Persuasion" />

    <label>Equipment (one per line)</label>
    <textarea v-model="equipmentInput" rows="4"></textarea>

    <label>Features & traits (one per line)</label>
    <textarea v-model="featuresInput" rows="4"></textarea>

    <label>Backstory</label>
    <textarea v-model="form.backstory" rows="6"></textarea>

    <div class="form-actions">
      <button type="submit" :disabled="submitting">
        {{ submitting ? 'Saving…' : (editSheet ? 'Update sheet' : 'Save sheet') }}
      </button>
      <button type="button" class="cancel-btn" @click="$emit('cancel')">Cancel</button>
    </div>

    <p v-if="errorMsg" class="error">{{ errorMsg }}</p>
  </form>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { supabase } from '@/lib/supabase'
import { useAuth } from '@/composables/useAuth'

const props = defineProps({
  editSheet: { type: Object, default: null }
})
const emit = defineEmits(['saved', 'cancel'])

const { user } = useAuth()

const abilityKeys = ['str', 'dex', 'con', 'int', 'wis', 'cha']

const form = reactive({
  name: props.editSheet?.name ?? '',
  class: props.editSheet?.class ?? '',
  race: props.editSheet?.race ?? '',
  level: props.editSheet?.level ?? null,
  background: props.editSheet?.background ?? '',
  alignment: props.editSheet?.alignment ?? '',
  image: props.editSheet?.image ?? '',
  hp_current: props.editSheet?.hp_current ?? null,
  hp_max: props.editSheet?.hp_max ?? null,
  ac: props.editSheet?.ac ?? null,
  speed: props.editSheet?.speed ?? '',
  proficiency_bonus: props.editSheet?.proficiency_bonus ?? null,
  str: props.editSheet?.str ?? null,
  dex: props.editSheet?.dex ?? null,
  con: props.editSheet?.con ?? null,
  int: props.editSheet?.int ?? null,
  wis: props.editSheet?.wis ?? null,
  cha: props.editSheet?.cha ?? null,
  backstory: props.editSheet?.backstory ?? ''
})

const savingThrows = ref([...(props.editSheet?.saving_throws ?? [])])
const skillsInput = ref((props.editSheet?.skills ?? []).join(', '))
const equipmentInput = ref((props.editSheet?.equipment ?? []).join('\n'))
const featuresInput = ref((props.editSheet?.features ?? []).join('\n'))
const submitting = ref(false)
const errorMsg = ref('')

function splitLines(value) {
  return value.split('\n').map(v => v.trim()).filter(Boolean)
}

function splitCommas(value) {
  return value.split(',').map(v => v.trim()).filter(Boolean)
}

async function handleSubmit() {
  submitting.value = true
  errorMsg.value = ''

  const payload = {
    ...form,
    saving_throws: savingThrows.value,
    skills: splitCommas(skillsInput.value),
    equipment: splitLines(equipmentInput.value),
    features: splitLines(featuresInput.value)
  }

  if (props.editSheet) {
    const { error } = await supabase
        .from('character_sheets')
        .update(payload)
        .eq('id', props.editSheet.id)

    submitting.value = false

    if (error) {
      errorMsg.value = error.message
      return
    }

    emit('saved', { id: props.editSheet.id, ...payload })
    return
  }

  const { data, error } = await supabase
      .from('character_sheets')
      .insert({ ...payload, user_id: user.value.id })
      .select()
      .single()

  submitting.value = false

  if (error) {
    errorMsg.value = error.message
    return
  }

  emit('saved', data)
}
</script>

<style scoped>
.entry-form {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-width: 560px;
}
label {
  font-size: 0.85rem;
  margin-top: 0.5rem;
}
.row {
  display: flex;
  gap: 0.75rem;
}
.row > div {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.ability-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 0.5rem;
}
.ability-field {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.ability-label {
  font-size: 0.65rem;
  text-align: center;
  color: #888;
  letter-spacing: 0.06em;
}
.ability-field input {
  text-align: center;
}
.save-checks {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}
.save-check {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.8rem;
  margin-top: 0;
}
.form-actions {
  display: flex;
  gap: 0.5rem;
}
.cancel-btn {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: #888;
}
.error {
  color: #e05252;
}
</style>
