import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase.js'

export const BASE_ROUTE = { kingdom: '/kingdom', npc: '/npcs', world: '/world' }

// Top-level rows become cards; rows with a parent_slug become that card's
// dropdown entries. Cards listed in slugOrder come first in that order, then
// any added from the site, oldest first.
export function usePagesByCategory(category, slugOrder) {
  const cards = ref([])
  const loading = ref(true)
  const error = ref(null)

  function toItem(row) {
    return {
      slug: row.slug,
      name: row.title,
      img: row.cover_image,
      route: `${BASE_ROUTE[category]}/${row.slug}`,
    }
  }

  function bySortThenAge(a, b) {
    return a.sort_order - b.sort_order || a.created_at.localeCompare(b.created_at)
  }

  async function load() {
    const { data, error: err } = await supabase
        .from('pages')
        .select('slug, title, cover_image, parent_slug, sort_order, created_at')
        .eq('category', category)

    if (err) {
      error.value = err
      loading.value = false
      return
    }

    const top = data.filter((row) => !row.parent_slug)
    const rank = (slug) => {
      const i = slugOrder.indexOf(slug)
      return i === -1 ? slugOrder.length : i
    }
    top.sort((a, b) => rank(a.slug) - rank(b.slug) || bySortThenAge(a, b))

    cards.value = top.map((row) => ({
      ...toItem(row),
      children: data
          .filter((child) => child.parent_slug === row.slug)
          .sort(bySortThenAge)
          .map(toItem),
    }))
    loading.value = false
  }

  onMounted(load)

  return { cards, loading, error, reload: load }
}
