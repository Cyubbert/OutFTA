import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase.js'

const BASE_ROUTE = { kingdom: '/kingdom', npc: '/npcs', world: '/world' }

export function usePagesByCategory(category, slugOrder) {
  const cards = ref([])
  const loading = ref(true)
  const error = ref(null)

  onMounted(async () => {
    const { data, error: err } = await supabase
        .from('pages')
        .select('slug, title, cover_image')
        .eq('category', category)

    if (err) {
      error.value = err
    } else {
      const bySlug = Object.fromEntries(data.map((row) => [row.slug, row]))
      cards.value = slugOrder
          .filter((slug) => bySlug[slug])
          .map((slug) => ({
            name: bySlug[slug].title,
            img: bySlug[slug].cover_image,
            route: `${BASE_ROUTE[category]}/${slug}`,
          }))
    }
    loading.value = false
  })

  return { cards, loading, error }
}
