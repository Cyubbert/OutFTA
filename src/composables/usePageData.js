import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase.js'

export function usePageData(slug) {
  const data = ref(null)
  const loading = ref(true)
  const error = ref(null)

  onMounted(async () => {
    const { data: row, error: err } = await supabase
        .from('pages')
        .select('*')
        .eq('slug', slug)
        .single()

    if (err) {
      error.value = err
    } else {
      data.value = {
        title: row.title,
        coverImage: row.cover_image,
        coverAlt: row.cover_alt,
        sections: row.sections ?? [],
        mapImage: row.map_image ?? null,
        moodboards: row.moodboards ?? [],
      }
    }
    loading.value = false
  })

  return { data, loading, error }
}
