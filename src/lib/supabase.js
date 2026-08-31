import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// flowType: 'pkce' puts the password-recovery/magic-link token in a `?code=`
// query param instead of a `#access_token=...` URL fragment. The app uses
// hash-based routing (`#/route`), so a fragment-based token would collide
// with the router's own `#/...` URL and break navigation on the reset link.
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: { flowType: 'pkce' }
})
