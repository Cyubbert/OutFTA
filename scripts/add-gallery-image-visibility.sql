-- One-off setup: lets a user mark their own profile_gallery_images posts as
-- not visible to other people, while still seeing them (with a "hidden"
-- marker) on their own profile. See PublicProfileView.vue / ProfileView.vue.
--
-- Only the select policy needs to change. `profile_gallery_images` already
-- carries two permissive select policies (Postgres OR's them together):
--   "Users can view own gallery images" (authenticated, user_id = auth.uid())
--   "Anyone can view profile gallery images" (public, using (true))
-- Restricting the public one to is_visible = true is enough -- the owner
-- keeps full access (including their own hidden rows) through the other,
-- untouched policy.
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.profile_gallery_images
  add column if not exists is_visible boolean not null default true;

drop policy if exists "Anyone can view profile gallery images" on public.profile_gallery_images;
create policy "Anyone can view visible profile gallery images"
on public.profile_gallery_images
for select
to public
using (is_visible = true);
