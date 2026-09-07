-- One-off setup: lets admins see every user's hidden/private posts when
-- browsing their public profile (/profile/:username) -- both
-- profile_gallery_images marked is_visible = false and character_sheets
-- marked is_visible = false (private by default). See
-- add-gallery-image-visibility.sql / add-character-sheet-visibility.sql,
-- which this builds on.
--
-- Adds one new permissive select policy per table, checking
-- profiles.role = 'admin' for the requesting user -- same admin-check
-- pattern used elsewhere (e.g. rebuild-gallery-as-community-board.sql's
-- "Permitted users can insert gallery images"). Postgres OR's permissive
-- policies together, so this is additive: the existing owner-only and
-- public-visible-only policies are untouched.
--
-- Uses `drop policy if exists` so it's safe to re-run in full even if an
-- earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

drop policy if exists "Admins can view all profile gallery images" on public.profile_gallery_images;
create policy "Admins can view all profile gallery images"
on public.profile_gallery_images
for select
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

drop policy if exists "Admins can view all character sheets" on public.character_sheets;
create policy "Admins can view all character sheets"
on public.character_sheets
for select
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);
