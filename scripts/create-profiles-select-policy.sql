-- One-off setup: lets an authenticated user read their own profiles row.
-- Without this, `profiles` has RLS enabled but no SELECT policy, so the
-- "is this user an admin?" check in useAuth.js (and the admin-only INSERT
-- policies on sessions/diary_entries, which subquery profiles) always
-- silently sees zero rows for real users -- even actual admins.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create policy "Users can view own profile"
on public.profiles
for select
to authenticated
using (id = auth.uid());
