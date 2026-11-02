import { supabase } from '@/lib/supabase'

// Uploads an image into the `images` bucket under {folder}/{user_id}/ and
// returns its public URL. Diary entries use diary-entries/ (storage RLS in
// create-diary-entry-image-storage-policy.sql: admins and can_post_quinlan);
// World / Kingdom pages use pages/ (add-page-hierarchy.sql: admins only).
export async function uploadEntryImage(file, userId, folder = 'diary-entries') {
    if (!file.type.startsWith('image/')) throw new Error('That file isn’t an image.')
    if (file.size > 10 * 1024 * 1024) throw new Error('Image is too large (max 10 MB).')

    const ext = file.name.split('.').pop()?.toLowerCase() || 'png'
    const path = `${folder}/${userId}/${Date.now()}.${ext}`

    const { error } = await supabase.storage.from('images').upload(path, file)
    if (error) throw error

    return supabase.storage.from('images').getPublicUrl(path).data.publicUrl
}
