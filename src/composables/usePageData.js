import { ref, watch, toValue } from 'vue'
import { supabase } from '@/lib/supabase.js'
import { BASE_ROUTE } from '@/composables/usePagesByCategory.js'

// slug can be a plain string or a ref/getter (e.g. the current route param),
// so one view can serve every /world/:slug, /kingdom/:slug and /npcs/:slug page.
//
// Besides the InfoPage props (`data`), returns `meta`: the raw row (for the edit
// form), its category, and `family` -- the main card plus every entry under it,
// in dropdown order, for the tabs at the top of the page.
export function usePageData(slug) {
  const data = ref(null)
  const meta = ref(null)
  const loading = ref(true)
  const error = ref(null)

  function toTab(row) {
    return { slug: row.slug, name: row.title, route: `${BASE_ROUTE[row.category]}/${row.slug}` }
  }

  async function load(current = toValue(slug), { quiet = false } = {}) {
    if (!quiet) loading.value = true
    error.value = null

    const { data: row, error: err } = await supabase
        .from('pages')
        .select('*')
        .eq('slug', current)
        .single()

    if (err) {
      error.value = err
      loading.value = false
      return
    }

    const rootSlug = row.parent_slug ?? row.slug
    const { data: relatives } = await supabase
        .from('pages')
        .select('slug, title, category, parent_slug, sort_order, created_at')
        .or(`slug.eq.${rootSlug},parent_slug.eq.${rootSlug}`)

    const root = (relatives ?? []).find(r => r.slug === rootSlug)
    const children = (relatives ?? [])
        .filter(r => r.parent_slug === rootSlug)
        .sort((a, b) => a.sort_order - b.sort_order || a.created_at.localeCompare(b.created_at))

    data.value = {
      title: row.title,
      coverImage: row.cover_image ?? '',
      coverAlt: row.cover_alt,
      sections: row.sections ?? [],
      mapImage: row.map_image ?? null,
      moodboards: row.moodboards ?? [],
    }
    meta.value = {
      row,
      category: row.category,
      family: root ? [root, ...children].map(toTab) : [],
    }
    loading.value = false
  }

  watch(() => toValue(slug), (current) => load(current), { immediate: true })

  // quiet: refresh after an edit without flashing the loading state.
  return { data, meta, loading, error, reload: () => load(toValue(slug), { quiet: true }) }
}
