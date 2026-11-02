-- One-off setup: a shared art gallery for Mory's and Quinlan's diaries
-- (/diary-gallery, linked from DiaryNav). Same community-board model as
-- gallery_images (rebuild-gallery-as-community-board.sql) but its own
-- table and its own two admin-managed permission flags, so access can be
-- granted independently of the main /gallery:
--   can_post_diary_gallery  -- may upload (default off; admin grants it)
--   can_view_diary_nsfw     -- may see nsfw-tagged rows (default off)
--
-- Non-nsfw rows are fully public, including logged-out visitors. nsfw rows
-- are never returned to anyone without the permission -- same approach as
-- add-gallery-nsfw-permission.sql. Uploaders can always see their own rows,
-- so tagging your own upload nsfw doesn't make it vanish on save.
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.profiles
  add column if not exists can_post_diary_gallery boolean not null default false,
  add column if not exists can_view_diary_nsfw boolean not null default false;

create table if not exists public.diary_gallery_images (
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

create index if not exists diary_gallery_images_created_at_idx
  on public.diary_gallery_images (created_at desc);

alter table public.diary_gallery_images enable row level security;

-- ── read ──

drop policy if exists "Anyone can view non-nsfw diary gallery images" on public.diary_gallery_images;
create policy "Anyone can view non-nsfw diary gallery images"
on public.diary_gallery_images
for select
to public
using (not ('nsfw' = any(tags)));

drop policy if exists "Permitted users can view nsfw diary gallery images" on public.diary_gallery_images;
create policy "Permitted users can view nsfw diary gallery images"
on public.diary_gallery_images
for select
to authenticated
using (
  'nsfw' = any(tags)
  and exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or profiles.can_view_diary_nsfw = true)
  )
);

drop policy if exists "Users can view own diary gallery images" on public.diary_gallery_images;
create policy "Users can view own diary gallery images"
on public.diary_gallery_images
for select
to authenticated
using (user_id = auth.uid());

-- ── write ──

drop policy if exists "Permitted users can insert diary gallery images" on public.diary_gallery_images;
create policy "Permitted users can insert diary gallery images"
on public.diary_gallery_images
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or profiles.can_post_diary_gallery = true)
  )
);

drop policy if exists "Owners or admins can update diary gallery images" on public.diary_gallery_images;
create policy "Owners or admins can update diary gallery images"
on public.diary_gallery_images
for update
to authenticated
using (user_id = auth.uid() or public.is_admin())
with check (user_id = auth.uid() or public.is_admin());

drop policy if exists "Owners or admins can delete diary gallery images" on public.diary_gallery_images;
create policy "Owners or admins can delete diary gallery images"
on public.diary_gallery_images
for delete
to authenticated
using (user_id = auth.uid() or public.is_admin());

-- ── storage: uploads live under diary-gallery/{user_id}/* in the
-- existing `images` bucket, kept apart from the main gallery's
-- gallery-posts/{user_id}/* prefix.

drop policy if exists "Users can upload own diary gallery images" on storage.objects;
create policy "Users can upload own diary gallery images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'diary-gallery'
  and (storage.foldername(name))[2] = auth.uid()::text
);
