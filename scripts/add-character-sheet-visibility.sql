-- One-off setup: lets a user opt individual character_sheets into being
-- shown on their public profile (/profile/:username), while sheets stay
-- private by default -- matching add-gallery-image-visibility.sql's pattern
-- but inverted (character sheets were previously never visible to anyone
-- but the owner; now a sheet is public only once explicitly marked so).
-- See PublicProfileView.vue / ProfileView.vue.
--
-- Only an additional select policy is needed. `character_sheets` already
-- carries "Users can view own character sheets" (authenticated, user_id =
-- auth.uid()); Postgres OR's permissive select policies together, so the
-- owner keeps full access (including their own private sheets) through
-- that untouched policy, while this new one opens read access to everyone
-- else for sheets marked is_visible = true.
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.character_sheets
  add column if not exists is_visible boolean not null default false;

drop policy if exists "Anyone can view visible character sheets" on public.character_sheets;
create policy "Anyone can view visible character sheets"
on public.character_sheets
for select
to public
using (is_visible = true);
