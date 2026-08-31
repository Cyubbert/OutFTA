import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'

const user = ref(null)
const isAdmin = ref(false)
const loading = ref(true)
const profile = ref({ username: '', avatar_url: '', banner_url: '' })

async function checkAdminStatus(userId) {
    if (!userId) {
        isAdmin.value = false
        profile.value = { username: '', avatar_url: '', banner_url: '' }
        return
    }
    const { data, error } = await supabase
        .from('profiles')
        .select('role, username, avatar_url, banner_url')
        .eq('id', userId)
        .single()

    isAdmin.value = !error && data?.role === 'admin'
    profile.value = {
        username: data?.username || '',
        avatar_url: data?.avatar_url || '',
        banner_url: data?.banner_url || ''
    }
}

async function signIn(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    user.value = data.user
    await checkAdminStatus(data.user.id)
    return data
}

async function signUp(email, password) {
    const { data, error } = await supabase.auth.signUp({ email, password })
    if (error) throw error
    user.value = data.user ?? null
    if (user.value) await checkAdminStatus(user.value.id)
    return data
}

async function signOut() {
    await supabase.auth.signOut()
    user.value = null
    isAdmin.value = false
    profile.value = { username: '', avatar_url: '', banner_url: '' }
}

async function resetPasswordForEmail(email) {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}${window.location.pathname}#/reset-password`
    })
    if (error) throw error
}

async function updatePassword(newPassword) {
    const { error } = await supabase.auth.updateUser({ password: newPassword })
    if (error) throw error
}

export function useAuth() {
    onMounted(async () => {
        const { data: { session } } = await supabase.auth.getSession()
        user.value = session?.user ?? null
        if (user.value) await checkAdminStatus(user.value.id)
        loading.value = false

        supabase.auth.onAuthStateChange(async (_event, session) => {
            user.value = session?.user ?? null
            if (user.value) {
                await checkAdminStatus(user.value.id)
            } else {
                isAdmin.value = false
                profile.value = { username: '', avatar_url: '', banner_url: '' }
            }
        })
    })

    return { user, isAdmin, loading, profile, signIn, signUp, signOut, resetPasswordForEmail, updatePassword }
}