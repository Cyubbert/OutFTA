import { ref } from 'vue'

export function useOpen5e() {
    const results = ref([])
    const loading = ref(false)
    const error   = ref(null)

    async function searchSpells(query) {
        if (!query.trim()) { results.value = []; return }
        loading.value = true
        error.value   = null
        try {
            const res  = await fetch(`https://api.open5e.com/v1/spells/?search=${encodeURIComponent(query)}&limit=10`)
            const data = await res.json()
            results.value = data.results
        } catch (e) {
            error.value = 'Could not reach the API.'
        } finally {
            loading.value = false
        }
    }

    return { results, loading, error, searchSpells }
}