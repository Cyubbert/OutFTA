// Preset scarabs for Quinlan's entries: every src/assets/Scarab_NN.png
// (either capitalisation). Drop a new file in and it shows up in the form.
//
// An entry's `scarab` column holds either `preset:<file name>` for one of
// these, or a full URL for a scarab uploaded through the form. Presets are
// stored by name, not URL, because the built asset URLs change per deploy.
const files = import.meta.glob('/src/assets/[Ss]carab_*.png', { eager: true, import: 'default' })

export const presetScarabs = Object.entries(files)
    .map(([path, url]) => {
        const name = path.split('/').pop().replace(/\.png$/i, '')
        return { id: `preset:${name}`, name, url }
    })
    .sort((a, b) => a.name.localeCompare(b.name, undefined, { numeric: true, sensitivity: 'base' }))

export function scarabSrc(value) {
    if (!value) return null
    if (value.startsWith('preset:')) return presetScarabs.find(s => s.id === value)?.url ?? null
    return value
}
