import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabase'

const user = ref(null)
const isAdmin = ref(false)
const loading = ref(true)

async function checkAdminStatus(userId) {
    if (!userId) {
        isAdmin.value = false
        return
    }
    const { data, error } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single()

    isAdmin.value = !error && data?.role === 'admin'
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
            }
        })
    })

    return { user, isAdmin, loading, signIn, signUp, signOut }
}