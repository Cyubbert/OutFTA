-- One-off setup: adds `username` / `avatar_url` to `profiles` so users can
-- set a display name and profile picture, and lets a user update their own
-- profile row (only a SELECT policy existed before this, from
-- create-profiles-select-policy.sql).
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.profiles
  add column if not exists username text unique,
  add column if not exists avatar_url text;

create policy "Users can update own profile"
on public.profiles
for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());
