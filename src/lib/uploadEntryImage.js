import { supabase } from '@/lib/supabase'

// Uploads a diary entry's image into the `images` bucket under
// diary-entries/{user_id}/ and returns its public URL. Storage RLS
// (create-diary-entry-image-storage-policy.sql) only lets admins and
// can_post_quinlan users write there.
export async function uploadEntryImage(file, userId) {
    if (!file.type.startsWith('image/')) throw new Error('That file isn’t an image.')
    if (file.size > 10 * 1024 * 1024) throw new Error('Image is too large (max 10 MB).')

    const ext = file.name.split('.').pop()?.toLowerCase() || 'png'
    const path = `diary-entries/${userId}/${Date.now()}.${ext}`

    const { error } = await supabase.storage.from('images').upload(path, file)
    if (error) throw error

    return supabase.storage.from('images').getPublicUrl(path).data.publicUrl
}
