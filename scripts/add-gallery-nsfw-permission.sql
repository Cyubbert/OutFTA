-- One-off setup: gates NSFW-tagged gallery_images rows behind a new
-- per-user permission (can_view_nsfw), so logged-out visitors and users
-- without the flag never receive those rows at all -- not even to render
-- blurred, since this site doubles as a portfolio. See GalleryView.vue's
-- blur/reveal toggle, which only ever has anything to reveal for users
-- who actually get the rows back from this policy.
--
-- Same admin-permission pattern as can_view_moryquinau in
-- add-user-permissions.sql. Replaces the single "Anyone can view gallery
-- images" policy from rebuild-gallery-as-community-board.sql with two:
-- non-nsfw rows stay fully public, nsfw rows require the permission.
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.profiles
  add column if not exists can_view_nsfw boolean not null default false;

drop policy if exists "Anyone can view gallery images" on public.gallery_images;

create policy "Anyone can view non-nsfw gallery images"
on public.gallery_images
for select
to public
using (not ('nsfw' = any(tags)));

create policy "Permitted users can view nsfw gallery images"
on public.gallery_images
for select
to authenticated
using (
  'nsfw' = any(tags)
  and exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or profiles.can_view_nsfw = true)
  )
);
