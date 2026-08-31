-- One-off setup: rewrites the public `/gallery` page from an admin-curated,
-- read-only board (old `gallery_images`: id bigint, title, artist,
-- image_path, description, is_nsfw, sort_order -- no user_id, no RLS-based
-- ownership) into a Community Hub-style board where any permitted user can
-- upload/edit/delete their own posts, matching create-community-hub-tables.sql's
-- pattern. This DROPS the old table and its 94 existing rows -- explicitly
-- requested ("delete all pictures from the gallery so far"). The
-- underlying storage files (bucket root, e.g. `RayRef.webp`) are left in
-- place; only the DB rows/listing are cleared. Back up the old rows first
-- with `select * from public.gallery_images` if you want a copy before
-- running this.
--
-- The old boolean `is_nsfw` + separate NSFW-tab-with-password gate is
-- replaced by a plain `tags text[]` column -- NSFW becomes just one tag
-- among others (checked at upload time), no separate gate. Fixed tags used
-- by the UI: nsfw, waesstan, marvers, ray (the last three are character
-- tags -- clicking one on a picture navigates to that character's public
-- profile at /profile/:username, which now shows that user's
-- profile_gallery_images).
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded (except the `drop
-- table`, which is intentionally a hard reset -- do not re-run this script
-- a second time expecting it to preserve rows added between runs).
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

-- ── profiles: new gallery-posting permission flag (added before the
-- gallery_images policies below, which reference this column) ──

alter table public.profiles
  add column if not exists can_post_gallery boolean not null default true;

drop table if exists public.gallery_images cascade;

create table public.gallery_images (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  title text,
  body text,
  image_url text not null,
  tags text[] not null default '{}',
  created_at timestamptz not null default now(),
  edited_at timestamptz
);

create index gallery_images_created_at_idx on public.gallery_images (created_at desc);

alter table public.gallery_images enable row level security;

create policy "Anyone can view gallery images"
on public.gallery_images
for select
to public
using (true);

create policy "Permitted users can insert gallery images"
on public.gallery_images
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or profiles.can_post_gallery = true)
  )
);

create policy "Users can update own gallery images"
on public.gallery_images
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Users can delete own gallery images"
on public.gallery_images
for delete
to authenticated
using (user_id = auth.uid());

create policy "Admins can update gallery images"
on public.gallery_images
for update
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
)
with check (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

create policy "Admins can delete gallery images"
on public.gallery_images
for delete
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

-- ── storage: gallery-board post images live under
-- gallery-posts/{user_id}/* in the existing `images` bucket, same model as
-- create-community-hub-tables.sql's community/{user_id}/* policy. Distinct
-- from the `gallery/{user_id}/*` prefix already used by
-- create-profile-gallery-images-table.sql's private per-user gallery, so
-- the two features' uploads don't intermix in storage.

drop policy if exists "Users can upload own gallery post images" on storage.objects;
create policy "Users can upload own gallery post images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'gallery-posts'
  and (storage.foldername(name))[2] = auth.uid()::text
);

-- ── public per-user profile pages ──
-- /profile/:username (new route) needs to look up a profile by username
-- and show that user's personal gallery (profile_gallery_images), for
-- anyone -- including logged-out visitors, matching the rest of the
-- site's open-read philosophy. Both tables previously only allowed a user
-- to read their own row; these additive policies open read access to
-- everyone without touching (or needing to know the exact names of) the
-- existing owner-only policies, which remain in place for writes.

create policy "Anyone can view profiles"
on public.profiles
for select
to public
using (true);

create policy "Anyone can view profile gallery images"
on public.profile_gallery_images
for select
to public
using (true);
